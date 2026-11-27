import { assertEquals, assertThrows, assertStringIncludes } from 'https://deno.land/std@0.119.0/testing/asserts.ts';
import { parseOpenScadOptions } from './scadoptions.ts';

const DOC = "// Foo.scad v2\n//\n// tog-scad-directives: ";

Deno.test("scadoptions: no options line yields null", () => {
	const r = parseOpenScadOptions("// just a comment\n\ncube(10);\n");
	assertEquals(r.options, null);
	assertEquals(r.warnings.length, 0);
});

Deno.test("scadoptions: full line parses (conventional spot)", () => {
	const r = parseOpenScadOptions(DOC + "openscad=x:OpenSCAD20240727Com+Manifold; requires=csg-engine:manifold, complex-list-parameters; prefers=speed:fast\n//\ncube();\n");
	assertEquals(r.options?.pin, "x:OpenSCAD20240727Com+Manifold");
	assertEquals(r.options?.requires, ["csg-engine:manifold", "complex-list-parameters"]);
	assertEquals(r.options?.prefers, ["speed:fast"]);
	assertEquals(r.warnings.length, 0);
});

Deno.test("scadoptions: hyphens and colons in values survive", () => {
	const r = parseOpenScadOptions(DOC + "openscad=x:OpenSCAD20240727Com-Manifold\n");
	assertEquals(r.options?.pin, "x:OpenSCAD20240727Com-Manifold");
});

Deno.test("scadoptions: prose values are rejected as non-thunks", () => {
	assertThrows(() => parseOpenScadOptions(DOC + "requires=Manifold Engine").options, Error, 'not a thunk');
	assertThrows(() => parseOpenScadOptions(DOC + "requires=Fast!").options, Error, 'not a thunk');
	assertThrows(() => parseOpenScadOptions(DOC + "openscad=2024.07.27").options, Error, 'x:');
});

Deno.test("scadoptions: unknown keys error; malformed entries error", () => {
	assertThrows(() => parseOpenScadOptions(DOC + "requires=a-b; needs=c-d").options, Error, 'Unrecognized options key');
	assertThrows(() => parseOpenScadOptions(DOC + "just-a-token").options, Error, 'Malformed');
});

Deno.test("scadoptions: off-convention placement warns but works", () => {
	// line 7 instead of 3:
	const r = parseOpenScadOptions("line1\nline2\nline3\nline4\nline5\nline6\n// tog-scad-directives: requires=complex-list-parameters\n");
	assertEquals(r.options?.requires, ["complex-list-parameters"]);
	assertEquals(r.warnings.length, 1);
	assertStringIncludes(r.warnings[0], 'line 3');
});

Deno.test("scadoptions: outside the header zone warns and does not apply", () => {
	const lines = Array.from({length:25}, (_,i) => `// line ${i}`);
	lines[24] = DOC + "requires=complex-list-parameters";
	const r = parseOpenScadOptions(lines.join('\n'));
	assertEquals(r.options, null);
	assertEquals(r.warnings.length, 1);
	assertStringIncludes(r.warnings[0], 'header zone');
});

Deno.test("scadoptions: duplicate pins error, duplicate tokens dedupe", () => {
	assertThrows(() => parseOpenScadOptions(DOC + "openscad=x:A; openscad=x:B").options, Error, 'Duplicate');
	const r = parseOpenScadOptions(DOC + "requires=a-b, a-b, c-d");
	assertEquals(r.options?.requires, ["a-b", "c-d"]);
});
