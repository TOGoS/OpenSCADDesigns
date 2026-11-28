/**
 * Parser for build-metadata comments embedded in .scad files:
 *
 *   // FrenchCleat.scad 2021-06
 *   //
 *   // tog-scad-directives: openscad=x:OpenSCAD20240727Com+Manifold; requires=csg-engine:manifold; prefers=speed:fast
 *   //
 *   // ...more comments...
 *
 * Convention: the directives line sits below the file's title comment,
 * so usually around line 3.  But it just needs to be in the first
 * kilobyte or so so that the entire file doesn't need to be scanned for it.
 *
 * Entries are ';'-separated 'key=value' pairs, split on the first
 * '=' only, so values may contain '=' and ':'.  Keys:
 * - 'openscad': exact command pin; unknown pins are errors.
 * - 'requires': features the chosen command must provide; unknown
 *   tokens are errors (typos shouldn't silently pass).
 * - 'prefers': soft tokens; unknown ones warn, unsatisfiable ones
 *   don't fail (it's a wish, not a contract).
 *
 * Values must be *thunks*: machine-shaped atoms (see THUNK_RE), so
 * prose never masquerades as metadata.  Which thunks exist, and what
 * provides them, is the build system's business; this library only
 * enforces the grammar.
 *
 * Returns null for files with no directives line; lines past
 * MAX_SCAN_LINES warn rather than apply -- the metadata belongs near
 * the top, where whoever opens the file will see it.
 */

export type ScadDirectives = {
	pin?: string,
	requires: string[],
	prefers: string[],
};

const DIRECTIVES_MARKER = "tog-scad-directives:",
	  KNOWN_KEYS = new Set(["openscad", "requires", "prefers"]),
	  THUNK_RE = /^[A-Za-z][A-Za-z0-9]*([-._+][A-Za-z0-9]+)*(?::[A-Za-z][A-Za-z0-9]*([-._+][A-Za-z0-9]+)*)?$/,
	  MAX_SCAN_LINES = 20;

function requireThunk(key:string, token:string) {
	if( !THUNK_RE.test(token) ) {
		throw new Error(`'${key}' token '${token}' is not a thunk (want machine-shaped kebab/colon atoms; see scaddirectives.ts header)`);
	}
}

export function parseScadDirectives(text:string) : { directives : ScadDirectives|null, warnings:string[] } {
	const warnings : string[] = [];
	let raw : string|undefined, foundLine = 0;
	const lines = text.split(/\r?\n/);
	for( let i = 0; i < lines.length; ++i ) {
		const idx = lines[i].indexOf(DIRECTIVES_MARKER);
		if( idx < 0 ) continue;
		if( i >= MAX_SCAN_LINES ) {
			warnings.push(`directives line at ${i+1} ignored (beyond header zone of ${MAX_SCAN_LINES} lines)`);
			continue;
		}
		if( raw != undefined ) {
			warnings.push(`multiple directives lines; line ${foundLine} wins, line ${i+1} ignored`);
			continue;
		}
		raw = lines[i].substring(idx + DIRECTIVES_MARKER.length); foundLine = i+1;
	}
	if( raw == undefined ) return { directives:null, warnings };
	
	const res : ScadDirectives = { requires:[], prefers:[] };
	for( const entryRaw of raw.split(';') ) {
		const entry = entryRaw.trim();
		if( entry == '' ) continue;
		const eq = entry.indexOf('=');
		if( eq <= 0 ) {
			throw new Error(`Malformed directives entry '${entry}' (expected 'key=value')`);
		}
		const key = entry.substring(0,eq).trim(), val = entry.substring(eq+1).trim();
		if( key == "openscad" ) {
			if( res.pin != undefined ) throw new Error(`Duplicate 'openscad=' pin on line ${foundLine}`);
			if( !val.startsWith("x:") ) throw new Error(`'openscad=' pin should be an x: pseudo-command, got '${val}'`);
			requireThunk("openscad", val);
			res.pin = val;
		} else if( key == "requires" || key == "prefers" ) {
			const list = res[key];
			for( const tok of val.split(',').map(s=>s.trim()).filter(s=>s!='') ) {
				requireThunk(key, tok);
				if( !list.includes(tok) ) list.push(tok);
			}
		} else {
			// Unknown *keys* are errors, per parser doctrine; typos in
			// requires:/prefers: *values* are handled by the build-system
			// side, which owns the feature vocabulary.
			throw new Error(`Unrecognized directives key '${key}' (known: openscad, requires, prefers)`);
		}
	}
	return { directives: res, warnings };
}
