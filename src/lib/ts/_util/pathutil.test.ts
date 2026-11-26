// Pure-lexical tests: no I/O, so `deno test` needs no permission flags.
// The filesystem-based oracle lives in pathutil.io.test.ts.
import { assertEquals } from 'https://deno.land/std@0.119.0/testing/asserts.ts';
import { normalizePath, basename, relativePath } from './pathutil.ts';

Deno.test("basename", () => {
	assertEquals(basename('a/b/c.stl'), 'c.stl');
	assertEquals(basename('c.stl'), 'c.stl');
	assertEquals(basename('a/'), '');           // documented trailing-slash wart
	assertEquals(basename('/x'), 'x');
	assertEquals(basename('a/b/../c.stl'), 'c.stl'); // lexical, never normalizes
});

// (tests are purely lexical: no cwd, no I/O -- the realpath oracle
// lives in pathutil.io.test.ts)

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
		relativePath('print-archive/p19xx/.temp/p1.scad', 'print-archive/p19xx/.temp/p1.stl'),
		'p1.stl'
	);
	assertEquals(relativePath('./sub/a.scad', './sub/b.stl'), 'b.stl');
	assertEquals(relativePath('a.scad', 'b.stl'), 'b.stl');
});

Deno.test("relativePath: ../-chains out of nested dirs", () => {
	assertEquals(
		relativePath('print-archive/p19xx/.temp/w.scad', 'sub/known.stl'),
		'../../../sub/known.stl'
	);
	assertEquals(
		relativePath('print-archive/p19xx/.temp/w.scad', 'print-archive/p19xx/.temp/deeper/x.stl'),
		'deeper/x.stl'
	);
	// '..' segments in the input are resolved before comparing:
	assertEquals(
		relativePath('print-archive/p19xx/.temp/w.scad', 'sub/../other/x.stl'),
		'../../../other/x.stl'
	);
});

Deno.test("relativePath: absolute targets, relative bases", () => {
	// relative-from / absolute-to: no shared base, so no relative path;
	// the normalized absolute target is the honest answer:
	assertEquals(
		relativePath('print-archive/p19xx/.temp/w.scad', '/tmp/elsewhere.stl'),
		'/tmp/elsewhere.stl'
	);
	// mixed anchors (absolute from, relative to), same story:
	assertEquals(
		relativePath('/proj/cwd/sub/w.scad', 'sub/x.stl'),
		'sub/x.stl'
	);
	// both absolute: fully computable:
	assertEquals(
		relativePath('/proj/cwd/print-archive/p19xx/.temp/w.scad', '/tmp/elsewhere.stl'),
		'../../../../../tmp/elsewhere.stl'
	);
});

Deno.test("relativePath: Windows drives", () => {
	assertEquals(
		relativePath('C:/work/.temp/w.scad', 'C:/work/sub/x.stl'),
		'../sub/x.stl'
	);
	assertEquals(
		relativePath('C:/work/.temp/w.scad', 'C:/other/x.stl'),
		'../../other/x.stl'
	);
	// Different drives: no relative path exists; fall back to absolute.
	assertEquals(
		relativePath('/x/w.scad', 'C:/other/x.stl'),
		'C:/other/x.stl'
	);
});

Deno.test("relativePath: degenerate same path", () => {
	assertEquals(relativePath('sub/a.stl', 'sub/a.stl'), 'a.stl');
});
