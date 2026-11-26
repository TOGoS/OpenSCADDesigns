// Built-marker machinery tests; lives beside make.ts because it
// imports make.ts's internals.  Run: deno test --allow-read --allow-write --allow-env
// imports make.ts's internals (requires --allow-read --allow-write).
import { assertEquals, assertStringIncludes } from 'https://deno.land/std@0.119.0/testing/asserts.ts';
import { mtimeWithBuiltMarkers, builtMarkerPath, run } from './make.ts';

const must = (x:number|undefined) : number => { if( x == undefined ) throw new Error('undefined mtime'); return x; };

Deno.test("mtimeWithBuiltMarkers: max of file and marker", async () => {
	const now = Date.now();
	const dir = await Deno.makeTempDir();
	const f = `${dir}/x.stl`;
	const marker = builtMarkerPath(f);
	try {
		await Deno.writeTextFile(f,'bits');
		await Deno.writeTextFile(marker,'t');
		await Deno.utime(f, (now-900e3)/1000, (now-900e3)/1000);        // old file
		await Deno.utime(marker, (now-100e3)/1000, (now-100e3)/1000);   // fresher marker
		const got = await mtimeWithBuiltMarkers(f);
		assertEquals(Math.abs(must(got) - (now-100e3)) < 2000, true, `expected marker time, got ${got}`);
		// Hand-restamp the file past the marker: max() must follow the file:
		await Deno.utime(f, new Date(), new Date());
		const got2 = await mtimeWithBuiltMarkers(f);
		assertEquals(Math.abs(must(got2) - Date.now()) < 5000, true, `expected file time, got ${got2}`);
		// Both gone -> undefined (builder falls back to its own stat):
		await Deno.remove(f); await Deno.remove(marker);
		assertEquals(await mtimeWithBuiltMarkers(f), undefined);
		// Marker survives, file deleted -> still undefined, but with a warning:
		await Deno.writeTextFile(f,'x');
		await Deno.writeTextFile(marker,'t');
		await Deno.remove(f);
		const warnings : string[] = [];
		const origWarn = console.warn;
		console.warn = (s:unknown) => warnings.push(String(s));
		try {
			assertEquals(await mtimeWithBuiltMarkers(f), undefined);
			assertEquals(await mtimeWithBuiltMarkers(f), undefined); // second call: deduped
		} finally { console.warn = origWarn; }
		assertEquals(warnings.length, 1, `expected exactly one warning, got ${warnings.length}`);
		assertStringIncludes(warnings[0], 'WO:');
	} finally {
		await Deno.remove(dir, {recursive:true});
	}
});

Deno.test("x:Hardlink: link mtime stays old, effective mtime is fresh", async () => {
	const dir = await Deno.makeTempDir();
	const src = `${dir}/src.stl`, dst = `${dir}/dst.stl`;
	try {
		await Deno.writeTextFile(src,'bits'); await Deno.utime(src, 0, 0);
		await run({argv:["x:Hardlink", src, dst]});
		assertEquals((await Deno.stat(dst)).mtime!.getFullYear() <= 1971, true);
		const eff = await mtimeWithBuiltMarkers(dst);
		assertEquals(Math.abs(must(eff) - Date.now()) < 60e3, true, `marker mtime not fresh: ${eff}`);
	} finally {
		await Deno.remove(dir, {recursive:true});
	}
});
