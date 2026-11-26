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
	['a.scad','b.stl'],
	['a/b/w.scad','deep/c/x.stl'],
];
Deno.test("relativePath: filesystem roundtrip oracle", async () => {
	const root = await Deno.makeTempDir();
	const dirOf = (p:string) => p.substring(0, p.lastIndexOf('/')) || '/';
	for( const [from,to] of PAIRS ) {
		const fromAbs = `${root}/${from}`;
		const toAbs = `${root}/${to}`;
		await Deno.mkdir(dirOf(fromAbs), {recursive:true});
		await Deno.mkdir(dirOf(toAbs), {recursive:true});
		await Deno.writeTextFile(fromAbs, 'w');  // realpath resolves the full path, not just its dir
		await Deno.writeTextFile(toAbs, 'x');
		const rel = relativePath(fromAbs, toAbs);
		const resolved = await Deno.realPath(`${dirOf(await Deno.realPath(fromAbs))}/${rel}`);
		const want = await Deno.realPath(toAbs);
		assertEquals(resolved, want, `fs roundtrip failed for (${from} -> ${to}) via ${rel}`);
	}
	await Deno.remove(root, {recursive:true});
});
