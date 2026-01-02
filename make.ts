#!/usr/bin/env deno -A

import Builder, { BuildContext, BuildRule } from 'https://deno.land/x/tdbuilder@0.5.19/Builder.ts';
import { HashAlgorithm, BITPRINT_ALGORITHM } from './src/lib/ts/_util/hash.ts';
import { toUint8Array } from './src/lib/ts/_util/bufutil.ts';

//// Utility functions

let skipScadReruns = false;

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

const OPENSCAD202101_CMD = "x:OpenSCAD202101Com" as const;
const OPENSCAD20240727_CMD = "x:OpenSCAD20240727Com" as const;
const OPENSCAD2024_MANIFOLD_CMD = "x:OpenSCAD20240727Com+Manifold" as const;
const DEFAULT_OPENSCAD_CMD = OPENSCAD202101_CMD;

type BaseOpenSCADCmd =
	typeof OPENSCAD202101_CMD |
	typeof OPENSCAD20240727_CMD;

type OpenSCADCmd =
	BaseOpenSCADCmd |
	typeof OPENSCAD2024_MANIFOLD_CMD;

type OpenSCADFeatureName = "manifold"; // etc. see `openscad.com --help` for more

// See also: `SynthGen2100/P0019/packages/sgutils@0.1/tdarx/openscad.ts`
// which is where this naming convention (minus the version) is copied from.
const OPENSCAD202101_COM   = Deno.env.get("OPENSCAD_202101_CLI_EXE"  ) ?? "x:UnconfiguredCommand:OPENSCAD_202101_CLI_EXE"  ;
const OPENSCAD20240727_COM = Deno.env.get("OPENSCAD_20240727_CLI_EXE") ?? "x:UnconfiguredCommand:OPENSCAD_20240727_CLI_EXE";
const MAGICK_EXE = "C:/Program Files/ImageMagick-7.1.0-Q16-HDRI/magick.exe";
const ATTRIB_EXE = "attrib"; // For `chmod -w`ing on Windows, `attrib +r`

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
	} else if( cmd.argv[0] == "x:Readonlify" ) {
		// Windows version:
		cmd = {
			argv: [ATTRIB_EXE, "+r", ...cmd.argv.slice(1)]
		};
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
		cmd.argv[0] == OPENSCAD202101_CMD ? OPENSCAD202101_COM :
		cmd.argv[0] == OPENSCAD20240727_CMD ? OPENSCAD20240727_COM :
		cmd.argv[0] == "x:Magick" ? MAGICK_EXE :
		cmd.argv[0];
		
	if( (m = /^x:UnconfiguredCommand:(.*)$/.exec(realExe)) != null ) {
		const missingEnvVar = m[1];
		throw new Error(`Please set environment variable: ${missingEnvVar}`);
	}
	
	console.log(`Spawning: ${quotedArgv([realExe, ...cmd.argv.slice(1)])}`);
	
	const dcmd = new Deno.Command(realExe, { args: cmd.argv.slice(1) });
	const proc = dcmd.spawn();
	const status = await proc.status;
	if (!status.success) {
		throw new Error(`${cmd.argv[0]} failed with code ${status.code}`);
	}
}
		
function openscadCommand(opts : {
	openScadCmd : OpenSCADCmd,
	inScadPath : FilePath,
	inConfigPath? : FilePath,
	featuresEnabled : string[],
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
	
	const featureOpts = opts.featuresEnabled.flatMap(f => ["--enable",f]);
	
	return {argv: [
		"x:MaxConcurrency:OpenSCAD:2",
		opts.openScadCmd,
		"--hardwarnings",
		...featureOpts,
		...presetArgs,
		// OpenSCAD 2021 seemed to treat the option following '--render'
		// as the input .scad filename.
		// If you try to do that with OpenSCAD 2024.07.27, it prints the usage text and exits,
		// annoyingly not giving specifics about what's wrong with the command.
		// Both versions seem to accept this format, with a useless argument to `--render`,
		// and the input .scad path passed as the last argument.
		"--render=useless-render-argument",
		...outStlArgs,
		...colorSchemeArgs,
		...imgSizeArgs,
		...cameraArgs,
		...outPngArgs,
		opts.inScadPath,
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

const readTextFile = Deno.readTextFile;

async function fileExists(path:FilePath) {
	return Deno.stat(path).then( stat => true, (err:Error) => {
		if( err.name == "NotFound" ) {
			return false;
		} else {
			return Promise.reject(err);
		}
	});
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

function toBaseScadCmdAndImplicitFeatures(cmd: OpenSCADCmd) : { openScadCmd: BaseOpenSCADCmd, implicitFeatures: OpenSCADFeatureName[] } {
	// Support a combined "OpenSCAD + Manifold" alias by returning the base
	// OpenSCAD command plus an implicit "manifold" feature, otherwise return
	// the command unchanged with no implicit features.
	if( cmd === OPENSCAD2024_MANIFOLD_CMD ) {
		return { openScadCmd: OPENSCAD20240727_CMD, implicitFeatures: ["manifold"] };
	}
	return { openScadCmd: cmd, implicitFeatures: [] };
}

function normalizeFeatureList(input: Iterable<string>) : string[] {
	// Remove duplicates and sort using default string sort.
	return Array.from(new Set(input)).sort();
}

function osdBuildRules(partId:string, opts:{
	openScadCmd?: OpenSCADCmd,
	featuresEnabled?: OpenSCADFeatureName[],
	inScadFile: FilePath,
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

	const { openScadCmd, implicitFeatures } =
		toBaseScadCmdAndImplicitFeatures(opts.openScadCmd ?? DEFAULT_OPENSCAD_CMD);
	
	let scadVariantSuffix = "";
	
	switch( openScadCmd ) {
	case OPENSCAD202101_CMD:
		break;
	case OPENSCAD20240727_CMD:
		scadVariantSuffix += "+scad20240727"; // Typo lol
		break;
	default:
		throw new Error(`Unrecognized openScadCmd: '${openScadCmd}'`);
	}
	
	const featuresEnabled = normalizeFeatureList([
		...implicitFeatures,
		...(opts.featuresEnabled ?? []),
	]);
	
	for( const feat of featuresEnabled ) scadVariantSuffix += '+' + feat;
	
	const outStlPath = `${tempDir}/${partId}-${stlBuilderVersion}${scadVariantSuffix}.stl`;
	const simplifiedStlPath = `${outDir}/${partId}.stl`;
	const renderedPngPath = `${tempDir}/${partId}-${renderPngBuilderVersion}${scadVariantSuffix}-cam${cameraPos.join('x')}.${renderSize.join('x')}.png`;
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
		const crushedPngPath = `${tempDir}/${partId}-${crushPngBuilderVersion}${scadVariantSuffix}-cam${cameraPos.join('x')}${rotPart}${palSizePart}.${size.join('x')}.png`;
		crushedPngBuildRules[crushedPngPath] = {
			prereqs: [renderedPngPath],
			invoke: async (ctx:BuildContext) => {
				// await mkdir(tempDir);
				await mkRoom(ctx.targetName);
				await run(magickCommand(renderedPngPath, rotation, _size, ctx.targetName, {
					paletteSize: paletteSize
				}));
				await run({argv: ["x:Readonlify", ctx.targetName]});
			}
		};
	}
	const imageSize = opts.imageSize ?? [256, 256];
	const preferredPngPath = `${tempDir}/${partId}-${crushPngBuilderVersion}${scadVariantSuffix}-cam${cameraPos.join('x')}${rotPart}${palSizePart}.${imageSize.join('x')}.png`;

	const prereqs = [];
	prereqs.push(opts.inScadFile);
	if( inConfigFile != undefined ) prereqs.push(inConfigFile);
	
	return {
		[outStlPath]: {
			prereqs,
			invoke: async (ctx:BuildContext) => {
				const exists = await fileExists(ctx.targetName);
				if( exists && skipScadReruns ) return;
				
				await mkRoom(ctx.targetName);
				await run(openscadCommand({
					openScadCmd,
					featuresEnabled,
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
				const exists = await fileExists(ctx.targetName);
				if( exists && skipScadReruns ) return;
				
				await mkRoom(ctx.targetName);
				await run(openscadCommand({
					openScadCmd,
					featuresEnabled,
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
			// And inConfigFile, but I don't want it to fail if that doesn't exist. :-/
			prereqs: [simplifiedStlPath, simplifiedPngPath, "make.ts"],
			async invoke(ctx:BuildContext) {
				const [pngUrn, stlUrn] = await Promise.all([simplifiedPngPath, simplifiedStlPath].map(p => hashFile(p, BITPRINT_ALGORITHM)));
				let descriptionFromConfig:string|undefined = undefined;
				let commentsFromConfig:string[] = [];
				if( inConfigFile != undefined ) {
					// console.log(`# Attempting to read ${inConfigFile} for description...`);
					const configText = await readTextFile(inConfigFile);
					// if(configText == undefined ) console.log("# No config text");
					const config:any = JSON.parse(configText);
					// if( config == undefined ) console.log("# No config");
					// console.log("# Config: ", config );
					const partConfig = config?.parameterSets?.[partId];
					if( partConfig ) {
						// console.log(`# Part config: ${JSON.stringify(partConfig)}`);
						descriptionFromConfig = partConfig.description;
						if( Array.isArray(partConfig.comments) ) commentsFromConfig = partConfig.comments;
					}
				}
				const description = descriptionFromConfig?.replaceAll('"','-inch') ?? "...";
				const bodyText = commentsFromConfig.map(c => `${c}\n`).join('');
				
				await mkRoom(ctx.targetName);
				using writeStream = await Deno.open(ctx.targetName, {write:true, createNew:true});
				const textEncoder = new TextEncoder;
				writeStream.write(textEncoder.encode(
					`=part ${partId}\n`+
					`short-description: ${description}\n`+ // Hmm: I could read the part.json and extract descriptions!
					`stl-file: ${partId}.stl\t${stlUrn}\n`+
					`openscad-rendering-ref: http://picture-files.nuke24.net/uri-res/raw/${pngUrn}/${partId}.png\n`+
					"\n" +
					bodyText
				));
			}
		},
		[partId]: brAlias([simplifiedStlPath, simplifiedPngPath, partTefPath]),
	};
}

/** Build rules for multiple presets (and otherwise same settings) for one .scad */
function multiOsdBuildRules(inScadFile:FilePath, partIds:string[], opts:{
	openScadCmd?: OpenSCADCmd,
	featuresEnabled?: OpenSCADFeatureName[],
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

/**
 * Generate a list of IDs of the form prefix + decimal-encoded integer
 * for the given prefix and numbers between (inclusive) start and end
 * e.g. partIdRange("p", 10, 13) = ["p10","p11","p12","p13"]
 */
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
		...multiOsdBuildRules("2023/french-cleat/FrenchCleat.scad", [
			...partIdRange("p",1711,1719),
			...partIdRange("p",2260,2269),
			...partIdRange("p",2271,2279),
		], {
			openScadCmd: OPENSCAD202101_CMD, // 2024 doesn't work due to parameters
			// The p17xxs were made without the help of this makefile,
			// so I have to guess where the camera was.
			// Well, actually, I like the shading better if it's flipped:
			cameraPosition: [ 100, 100, 150],
			imageSize: [512,512],
			paletteSize: 64
		}),
		"p226x": brAlias(partIdRange("p",2260,2269)),
		"p227x": brAlias(partIdRange("p",2271,2279)),
		...multiOsdBuildRules("2023/experimental/Threads2.scad", [
			"p1889","p2142","p2143","p2145","p2146","p2148","p2159",
			"p2190","p2191","p2192","p2199",
			"p2201","p2202","p2203","p2204","p2205","p2206","p2207","p2208","p2209",
			"p2316","p2317",
		], {
			cameraPosition: [-60,-120, 140],
			imageSize: [256,256],
			paletteSize: 64,
		}),
		...multiOsdBuildRules("2023/experimental/Threads2.scad", [
			"p2193","p2194","p2195","p2196",
		], {
			cameraPosition: [ 60, 120, 140],
			imageSize: [512,512],
			paletteSize: 64,
		}),
		...multiOsdBuildRules("2023/bowtie/RoundBowtie0.scad", ["p1857","p2109","p2112","p2182"], {
			cameraPosition: [-20,-20, 30],
			imageSize: [256,256],
			paletteSize: 64,
		}),
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
		...multiOsdBuildRules("2023/french-cleat/FrenchCleat.scad", [
			"p1951","p1952","p1953","p1967","p1968",
			"p2288","p2289",
		], {
			// FC (and gridrail) testers
			cameraPosition: [ 20, 20, 20],
			imageSize: [256,256],
		}),
		...multiOsdBuildRules("2023/french-cleat/FrenchCleatCrossSection.scad", ["p1427","p1489","p1954","p1955","p1956"], {
			cameraPosition: [ 20, 20, 20],
			imageSize: [256,256],
		}),
		...multiOsdBuildRules("2023/gridbeam/Gridrail2.scad", ["p1957","p1958","p2244","p2245","p2247"], {
			cameraPosition: [-20,-20, 20],
			imageSize: [512,512],
			paletteSize: 128
		}),
		...multiOsdBuildRules("2023/phone-holder/BrickHolder1.scad", ["p1963"], {
			cameraPosition: [-15,-20, 20],
			imageSize: [256,256],
		}),
		...multiOsdBuildRules("2023/phone-holder/BrickHolder2.scad", ["p1964", "p1965", "p1966"], {
			cameraPosition: [-15,-20, 20],
			imageSize: [256,256],
		}),
		...multiOsdBuildRules("2023/phone-holder/BrickHolder2.scad", ["p2067","p2076","p2077","p2323"], {
			cameraPosition: [-15,-20, 20],
			imageSize: [384,384],
			paletteSize: 72
		}),
		...multiOsdBuildRules("2023/french-cleat/FrenchCleat.scad", [
			"p1971", "p1972", "p1973", "p1974", "p1975", "p1976", "p1977", "p1978", "p1979",
			"p2210",
		], {
			// Must be done with OpenSCAD2021 due to '_ca' parameters that OpenSCAD 2024 ignores.
			openScadCmd: "x:OpenSCAD202101Com",
			cameraPosition: [ 20, 20, 20],
			imageSize: [384, 384],
		}),
		...multiOsdBuildRules("2023/hook/Hook2.scad", ["p1969"], {
			cameraPosition: [-20,-20, 30],
			imageSize: [384, 384],
		}),
		
		...multiOsdBuildRules("2023/hook/Hook3.scad", ["p2068","p2069"], {
			openScadCmd: OPENSCAD2024_MANIFOLD_CMD,
			cameraPosition: [20,-20, 30],
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
		...multiOsdBuildRules("2023/togridpile/TGx11.1.scad", [
			"p2053","p2058","p2104","p2105","p2106",
			...partIdRange("p",2252,2254)
		], {
			cameraPosition: [-30,-40, 30],
			imageSize: [256, 256],
		}),
		...multiOsdBuildRules("2023/togridpile/P2054Like.scad", [
			"p2054","p2055","p2056","p2057","p2059","p2060","p2061","p2084",
			"p2233",
		], {
			cameraPosition: [-30,-40, 30],
			imageSize: [256, 256],
		}),
		...multiOsdBuildRules("2023/panel/FHTVPSPlate1.scad", ["p2062"], {
			cameraPosition: [-30,-40, 50],
			imageSize: [384, 384],
		}),
		...multiOsdBuildRules("2023/experimental/DesiccantHolder0.scad", ["p2063","p2065","p2219"], {
			openScadCmd: OPENSCAD2024_MANIFOLD_CMD,
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
		...multiOsdBuildRules("2023/togridpile/ChunkyPlate0.scad", ["p2079","p2080","p2094"], {
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
		...multiOsdBuildRules("2023/experimental/Bookmark0.scad", ["p2090","p2091"], {
			cameraPosition: [-30, -30, 60],
			imageSize: [384, 384],
			paletteSize: 64,
		}),
		...multiOsdBuildRules("2023/nut/HexKnob0.scad", ["p2092"], {
			cameraPosition: [-30, -30, 60],
			imageSize: [256, 256],
			paletteSize: 64,
		}),
		...multiOsdBuildRules("2023/routing-template/MonitorMountRouterJig-v1.scad", ["p2093","p2295"], {
			cameraPosition: [-30, -30, 60],
			imageSize: [384, 384],
			paletteSize: 64,
		}),
		...multiOsdBuildRules("2023/misc/BoreSizer0.scad", ["p2095","p2096"], {
			cameraPosition: [-30, -30, 60],
			imageSize: [256, 256],
			paletteSize: 64,
		}),
		...multiOsdBuildRules("2023/nut/MatchfitSlotShover0.scad", ["p2099","p2100","p2101","p2102"], {
			cameraPosition: [ 30, -40, 30],
			imageSize: [256, 256],
			paletteSize: 64,
		}),
		...multiOsdBuildRules("2023/french-cleat/FCUnipanel0.scad", ["p2103"], {
			cameraPosition: [-40, -30, 40],
			imageSize: [256, 256],
			paletteSize: 32,
		}),
		...multiOsdBuildRules("2023/togridpile/TOGridPileMinimalBaseplate4.scad", ["p2107","p2108","p2110","p2111","p2113","p2117"], {
			cameraPosition: [-40, -30, 60],
			imageSize: [512, 512],
			paletteSize: 32,
		}),
		...multiOsdBuildRules("2023/togridpile/EdgeSpacer0.scad", ["p2114","p2115","p2116"], {
			cameraPosition: [-40, -30, 60],
			imageSize: [256, 256],
			paletteSize: 32,
		}),
		...multiOsdBuildRules("2023/togridpile/MarkerHolder2.scad", ["p2118","p2119","p2120","p2122"], {
			cameraPosition: [-40, -30, 60],
			imageSize: [512, 512],
			paletteSize: 128,
		}),
		...multiOsdBuildRules("2023/gridbeam/ChunkBeam-v1.scad", ["p2121","p2126","p2129"], {
			cameraPosition: [-40, -30, 40],
			imageSize: [256, 256],
			paletteSize: 64,
		}),
		...multiOsdBuildRules("2023/panel/GX12SolderingHolder0.scad", ["p2123"], {
			cameraPosition: [-30, -40, 40],
			imageSize: [256, 256],
			paletteSize: 64,
		}),
		...multiOsdBuildRules("2023/experimental/UDPickleJarHolder0.scad", ["p2125"], {
			cameraPosition: [-40, -30, 30],
			imageSize: [512, 512],
			paletteSize: 128,
		}),
		...multiOsdBuildRules("2023/conduit/Stopper0.scad", ["p2127"], {
			cameraPosition: [-15, -15, 100],
			imageSize: [256, 256],
			paletteSize: 128,
		}),
		...multiOsdBuildRules("2023/misc/SieveBlock0.scad", ["p2130","p2131","p2132","p2133","p2134","p2135"], {
			cameraPosition: [-40, -20, 60],
			imageSize: [512, 512],
			paletteSize: 128,
		}),
		...multiOsdBuildRules("2023/experimental/TwoPartPortLid0.scad", ["p2128","p2141","p2144"], {
			cameraPosition: [-40, -20, 30],
			imageSize: [512, 512],
			paletteSize: 128,
		}),
		...multiOsdBuildRules("2023/misc/BarCap0.scad", ["p2147","p2249","p2250"], {
			cameraPosition: [10,-20,20],
			imageSize: [256,256],
		}),
		...osdBuildRules("p2150", {
			inScadFile: "2023/experimental/TubePort0.scad",
			cameraPosition: [20,-20,40],
			imageSize: [512,512],
		}),
		...multiOsdBuildRules("2023/experimental/MasonJarLid0.scad", ["p2156"], {
			cameraPosition: [20,-20,40],
			imageSize: [384, 384],
			paletteSize: 128,
		}),
		...multiOsdBuildRules("2023/terrarium/TubePort1.scad", ["p2157","p2158"], {
			cameraPosition: [20,-20,40],
			imageSize: [512, 512],
			paletteSize: 128,
		}),
		...multiOsdBuildRules("2023/terrarium/TubePort1.scad", ["p2160","p2163","p2168","p2169","p2171","p2176","p2177"], {
			cameraPosition: [-20,-30,40],
			imageSize: [512, 512],
			paletteSize: 128,
		}),
		...multiOsdBuildRules("2023/experimental/GasketizingWasher0.scad", ["p2161","p2162"], {
			cameraPosition: [-20,-30,-30],
			imageSize: [512, 512],
			paletteSize: 128,
		}),
		...multiOsdBuildRules("2023/terrarium/WSTYPE4007Rimmogram0.scad", ["p2164","p2165","p2166","p2170"], {
			cameraPosition: [0,0,60],
			imageSize: [512, 512],
			paletteSize: 32,
		}),
		...multiOsdBuildRules("2023/plug/QuarterInchIrrigationPlug0.scad", ["p2172","p2173","p2178"], {
			cameraPosition: [-20,-40,40],
			imageSize: [256,256],
			paletteSize: 32,
		}),
		...multiOsdBuildRules("2023/tograck/CompHolePanel2.scad", ["p2179"], {
			cameraPosition: [-40,-50, 80],
			imageSize: [384, 384],
		}),
		...multiOsdBuildRules("2023/experimental/MiniRailPSMount0.scad", ["p2180"], {
			cameraPosition: [-40,-50, 50],
			imageSize: [384, 384],
		}),
		...multiOsdBuildRules("2023/track/MiniRail2.scad", ["p2184","p2185","p2186","p2187","p2188","p2243"], {
			openScadCmd: OPENSCAD2024_MANIFOLD_CMD, // Cuz faster
			cameraPosition: [-40,-50, 50],
			imageSize: [384, 384],
		}),
		...multiOsdBuildRules("2023/board-clip/EdgeDrillJig2.scad", ["p2189","p2216","p2217","p2218"], {
			openScadCmd: OPENSCAD2024_MANIFOLD_CMD,
			cameraPosition: [-40,-50, 50],
			imageSize: [384, 384],
		}),
		...multiOsdBuildRules("2023/experimental/ThreadConnector2.scad", ["p2198"], {
			cameraPosition: [-40,-50, 60],
			imageSize: [384, 384],
		}),
		...multiOsdBuildRules("2023/experimental/ThreadConnector2.scad", [
			"p2211","p2213",
		], {
			openScadCmd: OPENSCAD2024_MANIFOLD_CMD,
			cameraPosition: [ 60, 120, 140],
			imageSize: [512,512],
			paletteSize: 128,
		}),
		...multiOsdBuildRules("2023/experimental/ThreadConnector2.scad", [
			"p2223",
		], {
			openScadCmd: OPENSCAD2024_MANIFOLD_CMD,
			cameraPosition: [ 60, 120, 100],
			imageSize: [256,256],
			paletteSize: 64,
		}),
		...multiOsdBuildRules("2023/experimental/Threads2.scad", [
			"p2212", "p2220", "p2234", "p2311", "p2312", "p2314", "p2315", "p2318","p2319",
			"p2320",
		], {
			openScadCmd: OPENSCAD2024_MANIFOLD_CMD,
			cameraPosition: [ 60, 120, 140],
			imageSize: [512,512],
			paletteSize: 192,
		}),
		...multiOsdBuildRules("2023/experimental/Threads2.scad", [
			"p2281", "p2282",
		], {
			openScadCmd: OPENSCAD2024_MANIFOLD_CMD,
			// Need to get a bit higher on p2282 to show it's a cap
			cameraPosition: [ 60, 120, 200],
			imageSize: [512,512],
			paletteSize: 192,
		}),
		...multiOsdBuildRules("2023/experimental/Threads2.scad", [
			// Maybe good camera settings for hex heads
			"p2214","p2215","p2285","p2303","p2304","p2305",
		], {
			openScadCmd: OPENSCAD2024_MANIFOLD_CMD,
			cameraPosition: [-60, -60, 140],
			imageSize: [512,512],
			paletteSize: 192,
		}),
		...multiOsdBuildRules("2023/experimental/DesiccantHolderLid1.scad", [
			"p2221","p2222",
		], {
			openScadCmd: OPENSCAD2024_MANIFOLD_CMD,
			cameraPosition: [-60, -60, 140],
			imageSize: [256,256],
			paletteSize: 64,
		}),
		...multiOsdBuildRules("2023/experimental/NutDriver0.scad", [
			"p2224",
		], {
			cameraPosition: [-60, -60, 160],
			imageSize: [256,256],
			paletteSize: 64,
		}),
		...multiOsdBuildRules("2023/hook/SprayBottleHolder0.scad", [
			"p2225","p2226","p2228",
		], {
			openScadCmd: OPENSCAD2024_MANIFOLD_CMD, // Just because it's faster
			cameraPosition: [-30, -60, 60],
			imageSize: [256,256],
			paletteSize: 64,
		}),
		...multiOsdBuildRules("2023/gridbeam/SmallPlatformBracket0.scad", [
			"p2227"
		], {
			cameraPosition: [-30, -60, 60],
			imageSize: [256,256],
			paletteSize: 64,
		}),
		...multiOsdBuildRules("2023/gridbeam/SmallPlatformBracket1.scad", [
			"p2230"
		], {
			openScadCmd: OPENSCAD2024_MANIFOLD_CMD, // Just because it's faster
			cameraPosition: [-30, -60, 0],
			imageSize: [512,512],
			paletteSize: 128,
		}),
		...multiOsdBuildRules("2023/misc/CrudBump0.scad", [
			"p2231","p2232",
		], {
			openScadCmd: OPENSCAD2024_MANIFOLD_CMD, // Just because it's faster
			cameraPosition: [-30, -60, 60],
			imageSize: [256,256],
			paletteSize: 128,
		}),
		...multiOsdBuildRules("2023/experimental/DrillyMcSandCone0.scad", [
			"p2236","p2238",
		], {
			cameraPosition: [-30, -30, 15],
			imageSize: [256,256],
			paletteSize: 128,
		}),
		...multiOsdBuildRules("2023/experimental/TubePort0Washer0.scad", [
			"p2237","p2239","p2242",
		], {
			cameraPosition: [-30, -30, 60],
			imageSize: [256,256],
			paletteSize: 128,
		}),
		...multiOsdBuildRules("2023/experimental/TubePort0.scad", [
			"p2240","p2241",
		], {
			openScadCmd: OPENSCAD2024_MANIFOLD_CMD, // Just because it's faster
			cameraPosition: [-30, -30, 60],
			imageSize: [256,256],
			paletteSize: 128,
		}),
		...multiOsdBuildRules("2023/experimental/BarHolder1.scad", [
			"p2248",
		], {
			openScadCmd: OPENSCAD2024_MANIFOLD_CMD,
			cameraPosition: [-20, -30, 60],
			imageSize: [512,512],
			paletteSize: 128,
		}),
		...multiOsdBuildRules("2023/experimental/CylHolder3.scad", [
			"p2280", "p2283", "p2284", "p2286",
		], {
			openScadCmd: OPENSCAD2024_MANIFOLD_CMD,
			cameraPosition: [-30, -30, 30],
			imageSize: [512,512],
			paletteSize: 128,
		}),
		...multiOsdBuildRules("2023/tograck/WeMosPanel2.scad", ["p2287"], {
			openScadCmd: OPENSCAD2024_MANIFOLD_CMD,
			cameraPosition: [-40,-50,-80],
			imageSize: [384, 384],
		}),
		...multiOsdBuildRules("2023/panel/DovetailSlotExtensionPanel1.scad", ["p2292"], {
			openScadCmd: OPENSCAD2024_MANIFOLD_CMD,
			cameraPosition: [-120,-120, 160],
			imageSize: [384, 384],
			paletteSize: 128,
		}),
		...multiOsdBuildRules("2023/misc/BroomHandleMender1.scad", ["p2293"], {
			openScadCmd: OPENSCAD2024_MANIFOLD_CMD,
			cameraPosition: [-120,-120, 220],
			imageSize: [384, 384],
			paletteSize: 128,
		}),
		...multiOsdBuildRules("2023/tograck/HollowRail0.scad", ["p2294"], {
			openScadCmd: OPENSCAD2024_MANIFOLD_CMD,
			cameraPosition: [-100, 100, 80],
			imageSize: [384, 384],
			paletteSize: 128,
		}),
		...multiOsdBuildRules("2023/panel/DovetailSlotExtensionPanel2.scad", ["p2296"], {
			openScadCmd: OPENSCAD2024_MANIFOLD_CMD,
			cameraPosition: [-120,-120, 160],
			imageSize: [384, 384],
			paletteSize: 128,
		}),
		...multiOsdBuildRules("2023/experimental/CylBooster3.scad", ["p2297","p2298","p2299","p2301","p2302"], {
			openScadCmd: OPENSCAD2024_MANIFOLD_CMD,
			cameraPosition: [-30, -30, 30],
			imageSize: [384, 384],
			paletteSize: 128,
		}),
		...multiOsdBuildRules("2023/experimental/TubePort3.scad", ["p2306"], {
			openScadCmd: OPENSCAD2024_MANIFOLD_CMD,
			cameraPosition: [-30, -30, 30],
			imageSize: [512, 512],
			paletteSize: 128,
		}),
		...multiOsdBuildRules("2023/experimental/TubePortNut3.scad", ["p2307"], {
			openScadCmd: OPENSCAD2024_MANIFOLD_CMD,
			cameraPosition: [-30, -23, 60],
			imageSize: [512, 512],
			paletteSize: 128,
		}),
		...multiOsdBuildRules("2023/experimental/TwoPartPortLid1.scad", ["p2309"], {
			cameraPosition: [0, 0, 60],
			imageSize: [128, 128],
			paletteSize: 16,
		}),
		...multiOsdBuildRules("2023/experimental/ClarpNut0.scad", ["p2313"], {
			cameraPosition: [60, 60, 60],
			imageSize: [384, 384],
			paletteSize: 128,
		}),
		...multiOsdBuildRules("2023/experimental/P2321Like.scad", ["p2321"], {
			cameraPosition: [-60, -40, 60],
			imageSize: [256,256],
			paletteSize: 128,
		}),
		...multiOsdBuildRules("2023/experimental/Threads2.scad", [
			// Match the perspective of p2321, which p2322 'goes with'
			"p2322",
		], {
			cameraPosition: [-60, -40, 60],
			imageSize: [256,256],
			paletteSize: 128,
		}),
	},
});

if( import.meta.main ) {
	let args = Deno.args;
	// Use this when you know the shape is unchanged,
	// even if perhaps the .scad or .json has been updated:
	if( args[0] == "--skip-scad-reruns" ) {
		skipScadReruns = true;
		args = args.slice(1);
	}
	Deno.exit(await builder.processCommandLine(args));
}
