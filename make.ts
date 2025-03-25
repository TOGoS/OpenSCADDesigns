#!/usr/bin/env deno -A

import Builder, { BuildContext, BuildRule } from 'https://deno.land/x/tdbuilder@0.5.0/Builder.ts';

// TODO: Check for env vars, search for the .com if not specified
const OPENSCAD_COM = "C:/Program Files/OpenSCAD/openscad.com";
const MAGICK_EXE = "C:/Program Files/ImageMagick-7.1.0-Q16-HDRI/magick.exe";

type FilePath = string;

const defaultRenderSize = 3072;
// Version numbers to change when I break/fix stuff:
const stlBuilderVersion       = "b1318";
const renderPngBuilderVersion = "b1317";
const crushPngBuilderVersion  = "b1320"; // 21 used 'Cubic' instead of 'Lanczos', but result seems the same

type Vec2<T> = [T, T];
type Vec3<T> = [T, T, T];

const defaultCameraPosition : Vec3<number> = [-10, -10, 10];

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

async function run(cmd:Commande) : Promise<void> {
	if( cmd.argv.length == 0 ) {
		throw new Error("Empty command");
	}
	
	if( cmd.argv[0] == "x:Hardlink" ) {
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

function magickCommand(inFile:FilePath, crushSize:number, outFile:FilePath) : Commande {
	const subSize = (crushSize * 240/256)|0;
	return {argv: [
		"x:Magick",
		'convert',
		inFile,
		'-trim',
		'+repage',
		'-filter', 'Lanczos',
		'-resize', `${subSize}x${subSize}`,
		'-background', '#1c2022',
		'-gravity', 'center',
		'-extent', `${crushSize}x${crushSize}`,
		'-colors', '36',
		outFile,
	]};
}

function osdBuildRules(partId:string, opts:{
	inScadFile:FilePath,
	cameraPosition?: Vec3<number>,
	renderSize?: Vec2<number>,
	imageSize?: Vec2<number>,
	presetName?: string
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
	
	const outStlPath = `${tempDir}/${partId}-${stlBuilderVersion}.stl`;
	const simplifiedStlPath = `${outDir}/${partId}.stl`;
	const renderedPngPath = `${tempDir}/${partId}-${renderPngBuilderVersion}-cam${cameraPos.join('x')}.${renderSize.join('x')}.png`;
	const simplifiedPngPath = `${outDir}/${partId}.png`;
	let inConfigFile : FilePath | undefined;
	if( opts.presetName != undefined ) {
		if( (m = /^(.*?)\.scad$/.exec(opts.inScadFile)) != null ) {
			inConfigFile = `${m[1]}.json`;
		}
	}
	
	const crushSizes = [512, 384, 256, 128];
	const crushedPngBuildRules : {[targetName:string]: BuildRule}= {};
	for( const _size of crushSizes ) {
		const size = [_size, _size];
		const crushedPngPath = `${tempDir}/${partId}-${crushPngBuilderVersion}-cam${cameraPos.join('x')}.${size.join('x')}.png`;
		crushedPngBuildRules[crushedPngPath] = {
			prereqs: [renderedPngPath],
			invoke: async (ctx:BuildContext) => {
				await run(magickCommand(renderedPngPath, _size, ctx.targetName));
			}
		};
	}
	const imageSize = opts.imageSize ?? [256, 256];
	const preferredPngPath = `${tempDir}/${partId}-${crushPngBuilderVersion}-cam${cameraPos.join('x')}.${imageSize.join('x')}.png`;
	
	return {
		[outStlPath]: {
			invoke: async (ctx:BuildContext) => {
				await run(openscadCommand({
					inScadPath: opts.inScadFile,
					inConfigPath: inConfigFile,
					presetName: opts.presetName,
					outStlPath: ctx.targetName,
				}));
			},
		},
		[renderedPngPath]: {
			invoke: async (ctx:BuildContext) => {
				await run(openscadCommand({
					inScadPath: opts.inScadFile,
					inConfigPath: inConfigFile,
					presetName: opts.presetName,
					outPngPath: ctx.targetName,
					cameraPosition: cameraPos,
				}));
			},
		},
		...crushedPngBuildRules,
		[simplifiedStlPath]: {
			prereqs: [outStlPath],
			invoke(ctx:BuildContext) {
				return run({argv:["x:Hardlink", ctx.prereqNames[0], ctx.targetName]});
			}
		},
		[simplifiedPngPath]: {
			prereqs: [preferredPngPath, "make.ts"],
			invoke(ctx:BuildContext) {
				return run({argv:["x:Hardlink", ctx.prereqNames[0], ctx.targetName]});
			}
		}
	};
}

function* rangInc(start:number, end:number) : Iterable<number> {
	for( let i = start; i <= end; i++ ) {
		yield i;
	}
}
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

const p186xBuildRules = flattenObj(map(
	rangInc(1861,1869),
	i => {
		const partId = `p${i}`;
		return osdBuildRules(partId, {
			inScadFile: "2023/french-cleat/FrenchCleat.scad",
			presetName: partId,
			cameraPosition: [-10,-10,+10],
		})
	},
));

// Something like this.
const builder = new Builder({
	rules: {
		...osdBuildRules("p1859", {
			inScadFile: "2023/experimental/ThreadTest2.scad",
			presetName: "p1859",
		}),
		...osdBuildRules("p1873", {
			inScadFile: "2023/french-cleat/HollowFrenchCleat1.scad",
			presetName: "p1873",
			imageSize: [512, 512],
		}),
		...osdBuildRules("p1874", {
			inScadFile: "2023/french-cleat/HollowFrenchCleat1.scad",
			presetName: "p1874",
			imageSize: [512, 512],
		}),
		...osdBuildRules("p1875", {
			inScadFile: "2023/french-cleat/HollowFrenchCleat1.scad",
			presetName: "p1875",
			imageSize: [512, 512],
		}),
		...p186xBuildRules,
		"p186x": {
			targetType: "phony",
			prereqs: [
				...flatMap(rangInc(1861,1869), i => [
					`2023/print-archive/p18xx/p${i}.stl`,
					`2023/print-archive/p18xx/p${i}.png`,
				]),
			]
		}
	},
});

if( import.meta.main ) {
	Deno.exit(await builder.processCommandLine(Deno.args));
}
