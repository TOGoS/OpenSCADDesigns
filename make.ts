#!/usr/bin/env deno -A

import Builder, { BuildContext, BuildRule } from 'https://deno.land/x/tdbuilder@0.5.19/Builder.ts';
import { HashAlgorithm, BITPRINT_ALGORITHM } from './src/lib/ts/_util/hash.ts';
import { toUint8Array } from './src/lib/ts/_util/bufutil.ts';

//// Utility functions

function* map<T,U>(input:Iterable<T>, fn:(x:T) => U) : Iterable<U> {
	for( const x of input ) yield fn(x);
}
function* flatMap<T,U>(input:Iterable<T>, fn:(x:T) => Iterable<U>) : Iterable<U> {
	for( const x of input ) for( const y of fn(x) ) yield y;
}

function flattenObj<T>(input:Iterable<{[k:string]: T}>) : {[k:string]: T} {
	const res : {[k:string]: T} = {};
	for( const obj of input ) {
		for( const k in obj ) {
			res[k] = obj[k];
		}
	}
	return res;
}



// TODO: Check for env vars, search for the .com if not specified
const OPENSCAD_COM = "C:/Program Files/OpenSCAD/openscad.com";
const MAGICK_EXE = "C:/Program Files/ImageMagick-7.1.0-Q16-HDRI/magick.exe";

type FilePath = string;

const defaultRenderSize = 3072;
// Version numbers to change when I break/fix stuff:
const stlBuilderVersion       = "b1318";
const renderPngBuilderVersion = "b1322";
const crushPngBuilderVersion  = "b1327";

type Vec2<T> = [T, T];
type Vec3<T> = [T, T, T];

const defaultCameraPosition : Vec3<number> = [-10, -10, 10];

const RESOLVED_PROMISE = Promise.resolve();

type Commande = {
	argv : string[]
}

function quotedArgv(argv:string[]) : string {
	return argv.map(arg => {
		if( /^[a-zA-Z0-9_\+\-\.]+$/.test(arg) ) {
			return arg;
		} else {
			return `"${
				arg
					.replaceAll('\\', '\\\\')
				   .replaceAll('"', '\\"')
			}"`;
		}
	}).join(' ');
}

class ProcessQueue {
	private queue: (() => void)[] = [];
	private activeCount = 0;
	private readonly maxConcurrency: number;
	
	constructor(maxConcurrency: number = 1) {
		this.maxConcurrency = maxConcurrency;
	}
	
	enqueue<T>(producer: () => Promise<T>): Promise<T> {
		return new Promise<T>((resolve, reject) => {
			const execute = async () => {
				this.activeCount++;
				try {
					const result = await producer();
					resolve(result);
				} catch (error) {
					reject(error);
				} finally {
					this.activeCount--;
					this.next();
				}
			};
			
			if (this.activeCount < this.maxConcurrency) {
				execute();
			} else {
				this.queue.push(execute);
			}
		});
	}
	
	private next() {
		if (this.queue.length > 0 && this.activeCount < this.maxConcurrency) {
			const nextTask = this.queue.shift();
			if (nextTask) {
				nextTask();
			}
		}
	}
}

const processQueues = new Map<string, ProcessQueue>();
function getProcessQueue(name:string, maxConcurrency:number) : ProcessQueue {
	let queue = processQueues.get(name);
	if( queue == undefined ) {
		queue = new ProcessQueue(maxConcurrency);
		processQueues.set(name, queue);
	}
	return queue;
}

const dirsMade = new Map<FilePath,Promise<void>>();
function mkdir(dir:FilePath) : Promise<void> {
	let prom = dirsMade.get(dir);
	if( prom == null ) {
		prom = Deno.mkdir(dir, {recursive:true});
		dirsMade.set(dir, prom);
	}
	return prom;
}

async function run(cmd:Commande) : Promise<void> {
	if( cmd.argv.length == 0 ) {
		throw new Error("Empty command");
	}
	
	if( cmd.argv[0] == "x:MkDirs" ) {
		return Promise.all(cmd.argv.slice(1).map(p => mkdir(p))).then(() => RESOLVED_PROMISE);
	} else if( cmd.argv[0] == "x:Hardlink" ) {
		const src = cmd.argv[1];
		const dst = cmd.argv[2];
		try {
			await Deno.remove(dst);
		} catch( _e ) {
			// Ignore; maybe it just didn't exist.
		}
		console.log(`Hardlinking: ${dst} = ${src}`);
		return Deno.link(src, dst);
	}
	
	let m : RegExpMatchArray | null;
	if( (m = /^x:MaxConcurrency:([^:]+):(\d+)/.exec(cmd.argv[0])) != null ) {
		const queueName = m[1];
		const maxConcurrency = +m[2];
		const queue = getProcessQueue(queueName, maxConcurrency);
		return queue.enqueue(() => run({argv: cmd.argv.slice(1)}));
	}
	
	const realExe =
		cmd.argv[0] == "x:OpenSCADCom" ? OPENSCAD_COM :
		cmd.argv[0] == "x:Magick" ? MAGICK_EXE :
		cmd.argv[0];
	
	console.log(`Spawning: ${quotedArgv([realExe, ...cmd.argv.slice(1)])}`);
	
	const dcmd = new Deno.Command(realExe, { args: cmd.argv.slice(1) });
	const proc = dcmd.spawn();
	const status = await proc.status;
	if (!status.success) {
		throw new Error(`${cmd.argv[0]} failed with code ${status.code}`);
	}
}
		
function openscadCommand(opts : {
	inScadPath : FilePath,
	inConfigPath? : FilePath,
	presetName? : string,
	renderSize?: Vec2<number>,
	cameraPosition?: Vec3<number>,
	outStlPath? : FilePath,
	outPngPath? : FilePath,
}) : Commande {
	const outPngArgs = opts.outPngPath ? ["-o", opts.outPngPath] : [];
	const outStlArgs = opts.outStlPath ? [
		"--export-format=binstl", // Otherwise it defaults to ASCIISTL
		"-o", opts.outStlPath
	] : [];
	
	if( opts.presetName != undefined && opts.inConfigPath == undefined ) {
		throw new Error("Preset name provided without config file");
	}
	
	const presetArgs = opts.presetName != undefined && opts.inConfigPath != undefined  ?
		["-p", opts.inConfigPath, "-P", opts.presetName] : [];
		
	const imgSizeArgs = opts.renderSize != undefined ?
		[`--imgsize=${opts.renderSize[0]},${opts.renderSize[1]}`] : [];
	
	const cameraArgs = opts.cameraPosition != undefined ?
		[
			`--camera=${opts.cameraPosition[0]},${opts.cameraPosition[1]},${opts.cameraPosition[2]},0,0,0`,
			'--autocenter',
			'--viewall',
		] : [];
	
	const colorSchemeArgs = opts.outPngPath != undefined ? [
		'--colorscheme=Tomorrow Night',
	] : [];
	
	return {argv: [
		"x:MaxConcurrency:OpenSCAD:2",
		"x:OpenSCADCom",
		"--hardwarnings",
		// "--backend=manifold",
		...presetArgs,
		"--render", opts.inScadPath,
		...outStlArgs,
		...colorSchemeArgs,
		...imgSizeArgs,
		...cameraArgs,
		...outPngArgs,
	]};
}

function magickCommand(inFile:FilePath, rotation:number, crushSize:number, outFile:FilePath, opts:{paletteSize?:number}={}) : Commande {
	const subSize = (crushSize * 240/256)|0;
	return {argv: [
		"x:Magick",
		'convert',
		inFile,
		'-trim',
		'+repage',
		// '-filter', 'Lanczos',
		'-background', '#1d1f21',
		'-rotate', `${rotation}`,
		'-resize', `${subSize}x${subSize}`,
		'-gravity', 'center',
		'-extent', `${crushSize}x${crushSize}`,
		'-dither', 'None',
		'-colors', ''+(opts.paletteSize ?? 36),
		outFile,
	]};
}

/** Build rule that is an alias for a set of targets */
function brAlias(targetNames:Iterable<string>|AsyncIterable<string>) : BuildRule {
	return {
		targetType: "phony",
		prereqs: targetNames
	};
}

async function hashFile(filePath:FilePath, algo:HashAlgorithm) : Promise<string> {
	const hasher = algo.createHasher();
	using file = await Deno.open(filePath, { read: true });
	for await( const chunk of file.readable ) {
		hasher.update(toUint8Array(chunk));
	}
	return algo.getUrn(toUint8Array(hasher.digest()));
}

async function unlink(path:FilePath) {
	try {
		await Deno.remove(path);
	} catch( e ) {
		if( (e as Error).name == 'NotFound' ) return;
		throw e;
	}
}

/**
 * Make sure the parent directory exists
 * and that the named file does *not* already exist.
 */
async function mkRoom(path:FilePath) {
	const lastSlashIndex = path.lastIndexOf('/');
	if( lastSlashIndex > 0 ) {
		await mkdir(path.substr(0,lastSlashIndex));
	}
	await unlink(path);
}

function osdBuildRules(partId:string, opts:{
	inScadFile:FilePath,
	cameraPosition?: Vec3<number>,
	renderSize?: Vec2<number>,
	imageRotation?: number,
	imageSize?: Vec2<number>,
	presetName?: string,
	paletteSize?: number,
}) : {[targetName:string]: BuildRule} {
	let m : RegExpMatchArray | null;
	let outDir : FilePath;
	if( (m = /^p(\d\d)(\d\d)$/.exec(partId)) != null ) {
		outDir = `2023/print-archive/p${m[1]}xx`;
	} else {
		outDir = `2023/print-archive/misc`;
	}
	const tempDir = `${outDir}/.temp`;
	
	const renderSize = opts.renderSize ?? [defaultRenderSize, defaultRenderSize];
	const cameraPos = opts.cameraPosition ?? defaultCameraPosition;
	const paletteSize = opts.paletteSize ?? 36;
	
	const outStlPath = `${tempDir}/${partId}-${stlBuilderVersion}.stl`;
	const simplifiedStlPath = `${outDir}/${partId}.stl`;
	const renderedPngPath = `${tempDir}/${partId}-${renderPngBuilderVersion}-cam${cameraPos.join('x')}.${renderSize.join('x')}.png`;
	const simplifiedPngPath = `${outDir}/${partId}.png`;
	const partTefPath = `${outDir}/${partId}.tef`;

	let inConfigFile : FilePath | undefined;
	if( opts.presetName != undefined ) {
		if( (m = /^(.*?)\.scad$/.exec(opts.inScadFile)) != null ) {
			inConfigFile = `${m[1]}.json`;
		}
	}

	const rotation = opts.imageRotation ?? 0;
	const rotPart = rotation != 0 ? `-rot${opts.imageRotation}` : '';
	const palSizePart = paletteSize == 36 ? '' : `-${paletteSize}color`;
	
	const crushSizes = [512, 384, 256, 128];
	const crushedPngBuildRules : {[targetName:string]: BuildRule}= {};
	for( const _size of crushSizes ) {
		const size = [_size, _size];
		const crushedPngPath = `${tempDir}/${partId}-${crushPngBuilderVersion}-cam${cameraPos.join('x')}${rotPart}${palSizePart}.${size.join('x')}.png`;
		crushedPngBuildRules[crushedPngPath] = {
			prereqs: [renderedPngPath],
			invoke: async (ctx:BuildContext) => {
				await mkdir(tempDir);
				await run(magickCommand(renderedPngPath, rotation, _size, ctx.targetName, {
					paletteSize: paletteSize
				}));
			}
		};
	}
	const imageSize = opts.imageSize ?? [256, 256];
	const preferredPngPath = `${tempDir}/${partId}-${crushPngBuilderVersion}-cam${cameraPos.join('x')}${rotPart}${palSizePart}.${imageSize.join('x')}.png`;

	const prereqs = [];
	prereqs.push(opts.inScadFile);
	if( inConfigFile != undefined ) prereqs.push(inConfigFile);
	
	return {
		[outStlPath]: {
			prereqs,
			invoke: async (ctx:BuildContext) => {
				await mkRoom(ctx.targetName);
				await run(openscadCommand({
					inScadPath: opts.inScadFile,
					inConfigPath: inConfigFile,
					presetName: opts.presetName,
					outStlPath: ctx.targetName,
				}));
			},
		},
		[renderedPngPath]: {
			prereqs,
			invoke: async (ctx:BuildContext) => {
				await mkRoom(ctx.targetName);
				await run(openscadCommand({
					inScadPath: opts.inScadFile,
					inConfigPath: inConfigFile,
					presetName: opts.presetName,
					outPngPath: ctx.targetName,
					cameraPosition: cameraPos,
					renderSize: renderSize
				}));
			},
		},
		...crushedPngBuildRules,
		[simplifiedStlPath]: {
			prereqs: [outStlPath],
			async invoke(ctx:BuildContext) {
				await mkRoom(ctx.targetName);
				await run({argv:["x:Hardlink", ctx.prereqNames[0], ctx.targetName]});
			}
		},
		[simplifiedPngPath]: {
			prereqs: [preferredPngPath, "make.ts"],
			async invoke(ctx:BuildContext) {
				await mkRoom(ctx.targetName);
				await run({argv:["x:Hardlink", ctx.prereqNames[0], ctx.targetName]});
			}
		},
		[partTefPath]: {
			prereqs: [simplifiedStlPath, simplifiedPngPath, "make.ts"],
			async invoke(ctx:BuildContext) {
				const [pngUrn, stlUrn] = await Promise.all([simplifiedPngPath, simplifiedStlPath].map(p => hashFile(p, BITPRINT_ALGORITHM)));
				await mkRoom(ctx.targetName);
				using writeStream = await Deno.open(ctx.targetName, {write:true, createNew:true});
				const textEncoder = new TextEncoder;
				writeStream.write(textEncoder.encode(
					`=part ${partId}\n`+
					`description: ...\n`+ // Hmm: I could read the part.json and extract descriptions!
					`stl-file: ${partId}.stl\t${stlUrn}\n`+
					`openscad-rendering-ref: http://picture-files.nuke24.net/uri-res/raw/${pngUrn}/${partId}.png\n`+
					"\n"
				));
			}
		},
		[partId]: brAlias([simplifiedStlPath, simplifiedPngPath, partTefPath]),
	};
}

/** Build rules for multiple presets (and otherwise same settings) for one .scad */
function multiOsdBuildRules(inScadFile:FilePath, partIds:string[], opts:{
	cameraPosition?: Vec3<number>,
	renderSize?: Vec2<number>,
	imageRotation?: number,
	imageSize?: Vec2<number>,
	paletteSize?: number,
}={}) : {[targetName:string]: BuildRule} {
	return flattenObj(partIds.map(partId => osdBuildRules(partId, {
		inScadFile,
		presetName: partId,
		...opts
	})));
}

function partIdRange(pfx:string, start:number, end:number) : string[] {
	const partIds : string[] = [];
	for( let i = start; i <= end; i++ ) partIds.push(pfx+i);
	return partIds;
}

const p186xPartIds = partIdRange("p",1861,1869);
const p186xBuildRules = flattenObj(map(
	p186xPartIds,
	partId => {
		return osdBuildRules(partId, {
			inScadFile: "2023/french-cleat/FrenchCleat.scad",
			presetName: partId,
			cameraPosition: [-10,-10,+10],
		})
	},
));

const p187xFcPartIds = partIdRange("p",1873,1879);
const p187xFcBuildRules = flattenObj(map(
	p187xFcPartIds,
	partId => {
		return osdBuildRules(partId, {
			inScadFile: "2023/french-cleat/HollowFrenchCleat1.scad",
			presetName: partId,
			cameraPosition: [-10,-10,+10],
			imageSize: [512,512],
		})
	},
));

const p190xPartIds = partIdRange("p",1901,1909);
const p190xBuildRules = flattenObj(map(
	p190xPartIds,
	partId => {
		return osdBuildRules(partId, {
			inScadFile: "2023/french-cleat/FrenchCleat.scad",
			presetName: partId,
			cameraPosition: [-10,-10,-10],
		})
	},
));

const p192xPartIds = partIdRange("p",1921,1939);
const p192xBuildRules = flattenObj(map(
	p192xPartIds,
	partId => {
		const num = +partId.substring(1);
		return osdBuildRules(partId, {
			inScadFile: "2023/gridbeam/ChunkBackBeam1.scad",
			presetName: partId,
			cameraPosition: [20,-20,-20],
			imageSize: num > 1932 ? [512,512] : num > 1927 ? [384,384] : [256,256],
		})
	},
));

// Something like this.
const builder = new Builder({
	rules: {
		...osdBuildRules("p1859", {
			inScadFile: "2023/experimental/ThreadTest2.scad",
			presetName: "p1859",
			imageSize: [512,512],
		}),
		...p186xBuildRules,
		"p186x": brAlias(p186xPartIds),
		...p187xFcBuildRules,
		"p187x": brAlias(p187xFcPartIds),
		...osdBuildRules("p1880", {
			inScadFile: "2023/french-cleat/FrenchCleat.scad",
			presetName: "p1880",
			cameraPosition: [20,50,+50],
			imageSize: [256,256],
		}),
		...osdBuildRules("p1896", {
			inScadFile: "2023/gridbeam/ChunkBackBeam1.scad",
			presetName: "p1896",
			cameraPosition: [-20,20,-30],
			imageSize: [512,512],
		}),
		...osdBuildRules("p1897", {
			inScadFile: "2023/gridbeam/ChunkBackBeam1.scad",
			presetName: "p1897",
			cameraPosition: [-20,-20,-30],
			imageSize: [512,512],
		}),
		...osdBuildRules("p1898", {
			inScadFile: "2023/experimental/p1898.scad",
			cameraPosition: [-15,-20,30],
			imageSize: [512,512],
		}),
		...osdBuildRules("p1913", {
			inScadFile: "2023/experimental/Pi4Holder1.scad",
			cameraPosition: [10,-20,20],
			imageSize: [512,512],
		}),
		"p188x": brAlias(["p1880"]),
		...p190xBuildRules,
		"p190x": brAlias(p190xPartIds),
		...p192xBuildRules,
		"p1920": brAlias(partIdRange('p',1921,1939)),
		...multiOsdBuildRules("2023/french-cleat/FrenchCleat.scad", ["p1916"], {
			cameraPosition: [-20,-20,-30],
			imageSize: [512,512],			
		}),
		...multiOsdBuildRules("2023/experimental/WSTYPE201630Nub1.scad", ["p1917"], {
			cameraPosition: [ 20, 20, 20],
			imageSize: [256, 256],
		}),
		...multiOsdBuildRules("2023/experimental/WSTYPE201630Nub1.scad", ["p1919"], {
			cameraPosition: [ 10, 20, 5],
			imageSize: [256, 256],
		}),
		...osdBuildRules("p1941", {
			inScadFile: "2023/panel/WSTYPE201630Plate1.scad",
			presetName: "p1940",
			cameraPosition: [-20, -20, 20],
			imageSize: [512, 512],
		}),
		...osdBuildRules("p1942", {
			inScadFile: "2023/phone-holder/MiniPCHolder1.scad",
			cameraPosition: [-10, -20, 20],
			imageSize: [512, 512],
		}),
		...multiOsdBuildRules("2023/french-cleat/FrenchCleat.scad", ["p1943"], {
			// Similar perspective to p165x: http://picture-files.nuke24.net/uri-res/raw/urn:bitprint:434G5TB3POPCU6EN4XDL5U4BMFSLZ5EY.TLGMRPMX6ARKDRBFUSJH37IODHTF5H25EA3DQQI/p165x.html
			cameraPosition: [20,20,20],
			imageSize: [512,512],			
		}),
		...multiOsdBuildRules("2023/phone-holder/Midblock2.scad", ["p1944","p1945","p1946","p1948","p1949"], {
			cameraPosition: [ 20, 20, 20],
			imageSize: [384, 384],
		}),
		...multiOsdBuildRules("2023/phone-holder/FrontPanel2.scad", ["p1947"], {
			cameraPosition: [ 15,-20, 20],
			imageSize: [384, 384],
		}),
		...multiOsdBuildRules("2023/french-cleat/FrenchCleat.scad", ["p1951","p1952","p1953","p1967","p1968"], {
			cameraPosition: [ 20, 20, 20],
			imageSize: [256,256],
		}),
		...multiOsdBuildRules("2023/french-cleat/FrenchCleatCrossSection.scad", ["p1427","p1489","p1954","p1955","p1956"], {
			cameraPosition: [ 20, 20, 20],
			imageSize: [256,256],
		}),
		...multiOsdBuildRules("2023/gridbeam/Gridrail2.scad", ["p1957","p1958"], {
			cameraPosition: [-20,-20, 20],
			imageSize: [256,256],
		}),
		...multiOsdBuildRules("2023/phone-holder/BrickHolder1.scad", ["p1963"], {
			cameraPosition: [-15,-20, 20],
			imageSize: [256,256],
		}),
		...multiOsdBuildRules("2023/phone-holder/BrickHolder2.scad", ["p1964", "p1965", "p1966"], {
			cameraPosition: [-15,-20, 20],
			imageSize: [256,256],
		}),
		...multiOsdBuildRules("2023/phone-holder/BrickHolder2.scad", ["p2067"], {
			cameraPosition: [-15,-20, 20],
			imageSize: [384,384],
			paletteSize: 72
		}),
		...multiOsdBuildRules("2023/phone-holder/BrickHolder2.scad", ["p2076","p2077"], {
			cameraPosition: [-15,-20, 40],
			imageSize: [384,384],
			paletteSize: 72
		}),
		...multiOsdBuildRules("2023/french-cleat/FrenchCleat.scad", ["p1971", "p1972", "p1973", "p1974", "p1975", "p1976", "p1977", "p1978", "p1979"], {
			cameraPosition: [ 20, 20, 20],
			imageSize: [384, 384],
		}),
		...multiOsdBuildRules("2023/hook/Hook2.scad", ["p1969"], {
			cameraPosition: [-20,-20, 30],
			imageSize: [384, 384],
		}),
		...multiOsdBuildRules("2023/spacer/UnistrutMountingWasher1.scad", ["p1992"], {
			cameraPosition: [-10,-20, 20],
			imageSize: [256, 256],
		}),
		...multiOsdBuildRules("2023/experimental/Clarp2506.scad", ["p1993"], {
			cameraPosition: [-10,-20, 20],
			imageSize: [512, 512],
		}),
		...multiOsdBuildRules("2023/conduit/Clarp2505.scad", ["p2001","p2002","p2028"], {
			cameraPosition: [ 10, 20, 20],
			imageSize: [512, 512],
		}),
		...multiOsdBuildRules("2023/conduit/Clurp2507.scad", ["p2003","p2004","p2005"], {
			cameraPosition: [-20,-20, 20],
			imageSize: [256, 256],
		}),
		...multiOsdBuildRules("2023/conduit/Clarp2508.scad", ["p2006","p2007","p2008","p2009","p2013","p2017","p2018"], {
			cameraPosition: [-20,-20, 40],
			imageSize: [384, 384],
		}),
		...multiOsdBuildRules("2023/conduit/Clarp2508.scad", ["p2034","p2036","p2038","p2044","p2046","p2048"], {
			cameraPosition: [-20,-20, 40],
			imageRotation: 225,
			imageSize: [384, 384],
		}),
		...multiOsdBuildRules("2023/tograck/GX12Breakout1.scad", ["p2010","p2012"], {
			cameraPosition: [-50,-50, 60],
			imageSize: [384, 384],
		}),
		...multiOsdBuildRules("2023/tograck/TagPanel1.scad", ["p2011","p2020","p2081","p2082"], {
			cameraPosition: [-50,-50, 60],
			imageSize: [384, 384],
		}),
		...multiOsdBuildRules("2023/tograck/TOGRack2Section0.scad", ["p2014","p2015","p2016","p2027"], {
			cameraPosition: [-40,-50, 80],
			imageSize: [384, 384],
		}),
		...multiOsdBuildRules("2023/tograck/CompHolePanel1.scad", ["p2019"], {
			cameraPosition: [-40,-50, 80],
			imageSize: [384, 384],
		}),
		...multiOsdBuildRules("2023/experimental/TinyScreenPanel0.scad", ["p2022","p2023","p2024"], {
			cameraPosition: [-40,-50, 80],
			imageSize: [256, 256],
		}),
		...multiOsdBuildRules("2023/tograck/CompHolePanel2.scad", ["p2025"], {
			cameraPosition: [-40,-50,-80],
			imageSize: [384, 384],
		}),
		...multiOsdBuildRules("2023/misc/PlantLabel1.scad", ["p2029","p2050"], {
			cameraPosition: [ 40,-50, 80],
			imageSize: [384, 384],
		}),
		...multiOsdBuildRules("2023/experimental/QuarterInchRail0.scad", ["p2051", "p2052"], {
			cameraPosition: [ 40, 40, 40],
			imageSize: [384, 384],
		}),
		...multiOsdBuildRules("2023/togridpile/TGx11.1.scad", ["p2053","p2058"], {
			cameraPosition: [-30,-40, 30],
			imageSize: [256, 256],
		}),
		...multiOsdBuildRules("2023/togridpile/P2054Like.scad", ["p2054","p2055","p2056","p2057","p2059","p2060","p2061","p2084"], {
			cameraPosition: [-30,-40, 30],
			imageSize: [256, 256],
		}),
		...multiOsdBuildRules("2023/panel/FHTVPSPlate1.scad", ["p2062"], {
			cameraPosition: [-30,-40, 50],
			imageSize: [384, 384],
		}),
		...multiOsdBuildRules("2023/experimental/DesiccantHolder0.scad", ["p2063","p2065"], {
			cameraPosition: [20,-40, 60],
			imageSize: [384, 384],
			paletteSize: 128,
		}),
		...multiOsdBuildRules("2023/experimental/DesiccantHolderCap0.scad", ["p2064","p2066"], {
			cameraPosition: [20,-40, 60],
			imageSize: [384, 384],
			paletteSize: 128,
		}),
		...multiOsdBuildRules("2023/togridpile/WeMosCase0.scad", ["p2070","p2071","p2072","p2089"], {
			cameraPosition: [-60,-40, 40],
			imageSize: [512, 512],
			paletteSize: 128,
		}),
		...multiOsdBuildRules("2023/togridpile/WeMosHeaderHolder0.scad", ["p2073","p2074"], {
			cameraPosition: [-60,-40, 40],
			imageSize: [384,384],
			paletteSize: 64,
		}),
		...multiOsdBuildRules("2023/experimental/DesiccantHolder1.scad", ["p2075"], {
			cameraPosition: [20,-40,-30],
			imageSize: [384, 384],
			paletteSize: 128,
		}),
		...multiOsdBuildRules("2023/togridpile/GX12PortModule0.scad", ["p2078"], {
			cameraPosition: [50, 40, 60],
			imageSize: [384, 384],
			paletteSize: 128,
		}),
		...multiOsdBuildRules("2023/togridpile/ChunkyPlate0.scad", ["p2079","p2080"], {
			cameraPosition: [-20, -40, 30],
			imageSize: [384, 384],
			paletteSize: 128,
		}),
		...multiOsdBuildRules("2023/togridpile/P1844Like.scad", ["p2083"], {
			cameraPosition: [-20, -40, 40],
			imageSize: [384, 384],
			paletteSize: 128,
		}),
		...multiOsdBuildRules("2023/experimental/HemisphereHolder1.scad", ["p2087"], {
			cameraPosition: [-30, +40, 40],
			imageSize: [384, 384],
			paletteSize: 96,
		}),
		...multiOsdBuildRules("2023/experimental/tripodishCameraMount0.scad", ["p2086"], {
			cameraPosition: [-40, -30, 30],
			imageSize: [256, 256],
			paletteSize: 64,
		}),
		...multiOsdBuildRules("2023/togridpile/TGPSCC0.scad", ["p2088"], {
			cameraPosition: [-40, -30, 50],
			imageSize: [384, 384],
			paletteSize: 64,
		}),
		...multiOsdBuildRules("2023/experimental/Bookmark0.scad", ["p2090"], {
			cameraPosition: [-30, -30, 60],
			imageSize: [384, 384],
			paletteSize: 64,
		}),
		"all": brAlias(["p1859", "p186x", "p187x", "p188x"]),
	},
});

if( import.meta.main ) {
	Deno.exit(await builder.processCommandLine(Deno.args));
}
