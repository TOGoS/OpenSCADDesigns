// Run with: deno test --allow-read --allow-write (the filesystem oracle needs a temp dir)
import { assertEquals } from 'https://deno.land/std@0.119.0/testing/asserts.ts';
import { normalizePath, basename, relativePath } from './pathutil.ts';

Deno.test("basename", () => {
	assertEquals(basename('a/b/c.stl'), 'c.stl');
	assertEquals(basename('c.stl'), 'c.stl');
	assertEquals(basename('a/'), '');           // documented trailing-slash wart
	assertEquals(basename('/x'), 'x');
	assertEquals(basename('a/b/../c.stl'), 'c.stl'); // lexical, never normalizes
});

// Fixed cwd so relative-path assertions don't depend on where the
// test happened to be invoked from.
const CWD = '/proj/cwd';

Deno.test("normalizePath: dot and empty segments", () => {
	assertEquals(normalizePath('a/./b/../c.stl'), 'a/c.stl');
	assertEquals(normalizePath('a//b/'), 'a/b');
	assertEquals(normalizePath('./a'), 'a');
	assertEquals(normalizePath('.'), '.');
	assertEquals(normalizePath('..'), '..');
});

Deno.test("normalizePath: anchored paths keep their anchor", () => {
	assertEquals(normalizePath('/abs/q'), '/abs/q');
	assertEquals(normalizePath('/a/../..'), '/');
	assertEquals(normalizePath('/a/../../b'), '/b'); // can't escape root
});

Deno.test("normalizePath: Windows drives", () => {
	assertEquals(normalizePath('C:\\a\\..\\b'), 'C:/b');   // no 'C:/C:/b' doubling
	assertEquals(normalizePath('C:/x/../..'), 'C:/');
	assertEquals(normalizePath('c:\\x\\y.stl'), 'c:/x/y.stl');
	assertEquals(normalizePath('C:'), 'C:/');
});

Deno.test("normalizePath: UNC shares the rooted branch", () => {
	// '//server/share/x/..' collapses within the share but can't escape it
	assertEquals(normalizePath('//server/share/x/..'), '/server/share');
});

Deno.test("relativePath: sibling in same directory -> bare filename", () => {
	assertEquals(
		relativePath('print-archive/p19xx/.temp/p1.scad', 'print-archive/p19xx/.temp/p1.stl', CWD),
		'p1.stl'
	);
	assertEquals(relativePath('./sub/a.scad', './sub/b.stl', CWD), 'b.stl');
	assertEquals(relativePath('a.scad', 'b.stl', CWD), 'b.stl');
});

Deno.test("relativePath: ../-chains out of nested dirs", () => {
	assertEquals(
		relativePath('print-archive/p19xx/.temp/w.scad', 'sub/known.stl', CWD),
		'../../../sub/known.stl'
	);
	assertEquals(
		relativePath('print-archive/p19xx/.temp/w.scad', 'print-archive/p19xx/.temp/deeper/x.stl', CWD),
		'deeper/x.stl'
	);
	// '..' segments in the input are resolved before comparing:
	assertEquals(
		relativePath('print-archive/p19xx/.temp/w.scad', 'sub/../other/x.stl', CWD),
		'../../../other/x.stl'
	);
});

Deno.test("relativePath: absolute targets, relative bases", () => {
	// fromDir = /proj/cwd/print-archive/p19xx/.temp : 5 segments deep
	assertEquals(
		relativePath('print-archive/p19xx/.temp/w.scad', '/tmp/elsewhere.stl', CWD),
		'../../../../../tmp/elsewhere.stl'
	);
	// absolute base, relative target resolves against cwd:
	assertEquals(
		relativePath(`${CWD}/sub/w.scad`, 'sub/x.stl', CWD),
		'x.stl'
	);
	assertEquals(
		relativePath('/proj/cwd/print-archive/p19xx/.temp/w.scad', '/tmp/elsewhere.stl', CWD),
		'../../../../../tmp/elsewhere.stl'
	);
});

Deno.test("relativePath: Windows drives", () => {
	assertEquals(
		relativePath('C:/work/.temp/w.scad', 'C:/work/sub/x.stl', CWD),
		'../sub/x.stl'
	);
	assertEquals(
		relativePath('C:/work/.temp/w.scad', 'C:/other/x.stl', CWD),
		'../../other/x.stl'
	);
	// Different drives: no relative path exists; fall back to absolute.
	assertEquals(
		relativePath('/x/w.scad', 'C:/other/x.stl', CWD),
		'C:/other/x.stl'
	);
});

Deno.test("relativePath: degenerate same path", () => {
	assertEquals(relativePath('sub/a.stl', 'sub/a.stl', CWD), 'a.stl');
});

// Oracle: for every (from,to) pair, materialize both under a real
// temp tree, then let the OS itself resolve the relative path:
// realpath(dirname(from) + '/' + rel) must equal realpath(to).
// (Filesystem-based, deliberately independent of the lexical code
// under test.  Drive-letter pairs are skipped: this box has no
// C: drive, and their handling is covered by explicit asserts.)
const PAIRS : [string,string][] = [
	['print-archive/p19xx/.temp/w.scad','print-archive/p19xx/.temp/x.stl'],
	['print-archive/p19xx/.temp/w.scad','sub/known.stl'],
	['print-archive/p19xx/.temp/w.scad','sub/../other/x.stl'],
	['a.scad','b.stl'],
	['a/b/w.scad','deep/c/x.stl'],
];
Deno.test("relativePath: filesystem roundtrip oracle", async () => {
	const root = await Deno.makeTempDir();
	for( const [from,to] of PAIRS ) {
		const fromAbs = from.startsWith('/') ? from : `${root}/${from}`;
		const toAbs = to.startsWith('/') ? to : `${root}/${to}`;
		const dirOf = (p:string) => p.substring(0, p.lastIndexOf('/')) || '/';
		await Deno.mkdir(dirOf(fromAbs), {recursive:true});
		await Deno.mkdir(dirOf(toAbs), {recursive:true});
		await Deno.writeTextFile(fromAbs, 'w');  // realpath resolves the full path, not just its dir
		await Deno.writeTextFile(toAbs, 'x');
		const rel = relativePath(fromAbs, toAbs, CWD);
		const resolved = await Deno.realPath(`${dirOf(await Deno.realPath(fromAbs))}/${rel}`);
		const want = await Deno.realPath(toAbs);
		assertEquals(resolved, want, `fs roundtrip failed for (${from} -> ${to}) via ${rel}`);
	}
	await Deno.remove(root, {recursive:true});
});
