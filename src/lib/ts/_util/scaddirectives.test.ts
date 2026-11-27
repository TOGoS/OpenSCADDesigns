import { assertEquals, assertThrows, assertStringIncludes } from 'https://deno.land/std@0.119.0/testing/asserts.ts';
import { parseScadDirectives } from './scaddirectives.ts';

const DOC = "// Foo.scad v2\n//\n// tog-scad-directives: ";

Deno.test("scaddirectives: no directives line yields null", () => {
	const r = parseScadDirectives("// just a comment\n\ncube(10);\n");
	assertEquals(r.directives, null);
	assertEquals(r.warnings.length, 0);
});

Deno.test("scaddirectives: full line parses (conventional spot)", () => {
	const r = parseScadDirectives(DOC + "openscad=x:OpenSCAD20240727Com+Manifold; requires=csg-engine:manifold, complex-list-parameters; prefers=speed:fast\n//\ncube();\n");
	assertEquals(r.directives?.pin, "x:OpenSCAD20240727Com+Manifold");
	assertEquals(r.directives?.requires, ["csg-engine:manifold", "complex-list-parameters"]);
	assertEquals(r.directives?.prefers, ["speed:fast"]);
	assertEquals(r.warnings.length, 0);
});

Deno.test("scaddirectives: hyphens and colons in values survive", () => {
	const r = parseScadDirectives(DOC + "openscad=x:OpenSCAD20240727Com-Manifold\n");
	assertEquals(r.directives?.pin, "x:OpenSCAD20240727Com-Manifold");
});

Deno.test("scaddirectives: prose values are rejected as non-thunks", () => {
	assertThrows(() => parseScadDirectives(DOC + "requires=Manifold Engine").directives, Error, 'not a thunk');
	assertThrows(() => parseScadDirectives(DOC + "requires=Fast!").directives, Error, 'not a thunk');
	assertThrows(() => parseScadDirectives(DOC + "openscad=2024.07.27").directives, Error, 'x:');
});

Deno.test("scaddirectives: unknown keys error; malformed entries error", () => {
	assertThrows(() => parseScadDirectives(DOC + "requires=a-b; needs=c-d").directives, Error, 'Unrecognized directives key');
	assertThrows(() => parseScadDirectives(DOC + "just-a-token").directives, Error, 'Malformed');
});

Deno.test("scaddirectives: off-convention placement warns but works", () => {
	// line 7 instead of 3:
	const r = parseScadDirectives("line1\nline2\nline3\nline4\nline5\nline6\n// tog-scad-directives: requires=complex-list-parameters\n");
	assertEquals(r.directives?.requires, ["complex-list-parameters"]);
	assertEquals(r.warnings.length, 1);
	assertStringIncludes(r.warnings[0], 'line 3');
});

Deno.test("scaddirectives: outside the header zone warns and does not apply", () => {
	const lines = Array.from({length:25}, (_,i) => `// line ${i}`);
	lines[24] = DOC + "requires=complex-list-parameters";
	const r = parseScadDirectives(lines.join('\n'));
	assertEquals(r.directives, null);
	assertEquals(r.warnings.length, 1);
	assertStringIncludes(r.warnings[0], 'header zone');
});

Deno.test("scaddirectives: duplicate pins error, duplicate tokens dedupe", () => {
	assertThrows(() => parseScadDirectives(DOC + "openscad=x:A; openscad=x:B").directives, Error, 'Duplicate');
	const r = parseScadDirectives(DOC + "requires=a-b, a-b, c-d");
	assertEquals(r.directives?.requires, ["a-b", "c-d"]);
});
