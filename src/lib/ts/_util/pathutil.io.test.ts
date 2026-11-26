// Run with: deno test --allow-read --allow-write src/lib/ts/_util/pathutil.io.test.ts
import { assertEquals } from 'https://deno.land/std@0.119.0/testing/asserts.ts';
import { relativePath } from './pathutil.ts';

// Oracle: materialize both endpoints in a temp tree and let realpath --
// not the lexical code under test -- adjudicate.  Drive-letter pairs
// live in pathutil.test.ts instead; this box has no C:.
const PAIRS : [string,string][] = [
	['print-archive/p19xx/.temp/w.scad','print-archive/p19xx/.temp/x.stl'],
	['print-archive/p19xx/.temp/w.scad','sub/known.stl'],
	['print-archive/p19xx/.temp/w.scad','sub/../other/x.stl'],
	['a/b/w.scad','deep/c/x.stl'],
];
Deno.test("relativePath: filesystem roundtrip oracle", async () => {
	const root = await Deno.makeTempDir();
	for( const [from,to] of PAIRS ) {
		const fromAbs = `${root}/${from}`;
		const toAbs = `${root}/${to}`;
		// Slice from the *constructed* path: root always has a directory
		// component (every pair nests at least one level), so this can't
		// collapse to '' and form a '//server'-style UNC when joined --
		// realpath output was not safe to slice that way on Windows,
		// where makeTempDir may return UNC-ish ('\\?\...') paths.
		const fromDir = fromAbs.substring(0, fromAbs.lastIndexOf('/'));
		const toDir = toAbs.substring(0, toAbs.lastIndexOf('/'));
		await Deno.mkdir(fromDir, {recursive:true});
		await Deno.mkdir(toDir, {recursive:true});
		await Deno.writeTextFile(fromAbs, 'w');  // realpath resolves the full path, not just its dir
		await Deno.writeTextFile(toAbs, 'x');
		const rel = relativePath(fromAbs, toAbs);
		const resolved = await Deno.realPath(`${fromDir}/${rel}`);
		const want = await Deno.realPath(toAbs);
		assertEquals(resolved, want, `fs roundtrip failed for (${from} -> ${to}) via ${rel}`);
	}
	await Deno.remove(root, {recursive:true});
});
