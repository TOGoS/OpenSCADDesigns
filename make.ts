#!/usr/bin/env deno -A

import Builder, { BuildContext } from 'https://deno.land/x/tdbuilder@0.5.0/Builder.ts';
import { mkParentDirs } from 'https://deno.land/x/tdbuilder@0.5.0/FSUtil.ts';

// TODO: Check for env vars, search for the .com if not specified
const OPENSCAD_COM = "C:/Program Files/OpenSCAD/openscad.com";

type FilePath = string;

async function openscad(opts : {
	inScadFile : FilePath,
	inConfigFile? : FilePath,
	presetName? : string,
	outStlPath? : FilePath,
	outPngPathPrefix? : FilePath
}) : Promise<void> {
	const outPngArgs = opts.outPngPathPrefix ? ["-o", `${opts.outPngPathPrefix}.1.png`] : [];
	const outStlArgs = opts.outStlPath ? ["-o", opts.outStlPath] : [];
	
	if( opts.presetName != undefined && opts.inConfigFile == undefined ) {
		throw new Error("Preset name provided without config file");
	}
	
	const presetArgs = opts.presetName && opts.inConfigFile ?
		["-p", opts.inConfigFile, "-P", opts.presetName] : [];
	
	const cmd = new Deno.Command(OPENSCAD_COM, { args: [
		"--hardwarnings",
		...presetArgs,
		"--render", opts.inScadFile,
		"--colorscheme", "Tomorrow Night",
		...outPngArgs,
		...outStlArgs,
		"--imgsize", "3072,3072",
	]});
	const proc = cmd.spawn();
	const status = await proc.status;
	if (!status.success) {
		throw new Error(`OpenSCAD failed: ${status.code}`);
	}
}

// Something like this.
const builder = new Builder({
	rules: {
		// TDBuilder doesn't really support build rules
		// with more than one output, so we can't generate
		// both the STL and PNG at the same time while
		// also generating either only when it doesn't exist.
		// So let's just make a subdirectory for each output.
		"2023/print-archive/p18xx/p1859": {
			invoke(ctx:BuildContext) : Promise<void> {
				return Deno.mkdir(ctx.targetName).then(() => openscad({
					inScadFile: "2023/experimental/ThreadTest2.scad",
					outStlPath: `${ctx.targetName}/p1859.stl`,
					outPngPathPrefix: `${ctx.targetName}/p1859`,
				}));
			}
		}
	},
	defaultTargetNames: ["2023/print-archive/p18xx/p1859"]
});

if( import.meta.main ) {
	Deno.exit(await builder.processCommandLine(Deno.args));
}
