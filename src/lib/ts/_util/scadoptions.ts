/**
 * Parser for build-metadata comments embedded in .scad files:
 *
 *   // FrenchCleat.scad 2021-06
 *   //
 *   // tog-scad-options: openscad=x:OpenSCAD20240727Com+Manifold; requires=csg-engine:manifold; prefers=speed:fast
 *   //
 *   // ...more comments...
 *
 * Convention: the options line sits just below the file's title
 * comment line, so whoever opens the file sees the constraints
 * before the code -- and deliberately NOT on line 1, where
 * emacs/vim would sniff it as their own syntax.
 *
 * Entries are ';'-separated 'key=value' pairs (values may contain
 * '=' and '-' -- splitting is on the first '=' only, so 'x:...'
 * pseudo-commands survive; a hypothetical 'x:FooCom-Manifold' would
 * otherwise collide with comment-marker hyphens in other dialects).
 * Keys:
 * - 'openscad': exact command pin; unknown values are errors.
 * - 'requires': feature tokens the chosen command must provide;
 *   unknown tokens are errors (typos shouldn't silently pass).
 * - 'prefers': soft tokens; unknown ones warn, unsatisfiable ones
 *   don't fail (it's a wish, not a contract).
 *
 * All values must be *thunks*: machine-shaped atoms -- kebab-case,
 * optionally colon-namespaced (the 'x:' command idiom's own shape) --
 * so prose never masquerades as metadata.  The token *vocabulary*
 * (which thunks exist, what provides them) is the build system's
 * business; this library only enforces the grammar.
 *
 * Returns null for files with no options line.  Lines past
 * maxScanLines land in warnings, not in the result -- the point of
 * scanning a prefix is that the options belong near the top, where
 * whoever opens the file will see them.
 */

export type ScadOptions = {
	pin?: string,
	requires: string[],
	prefers: string[],
};

const OPTIONS_MARKER = "tog-scad-options:",
	  KNOWN_KEYS = new Set(["openscad", "requires", "prefers"]),
	  THUNK_RE = /^[A-Za-z][A-Za-z0-9]*([-._+][A-Za-z0-9]+)*(?::[A-Za-z][A-Za-z0-9]*([-._+][A-Za-z0-9]+)*)?$/,
	  maxScanLines = 20;

function requireThunk(key:string, token:string) {
	if( !THUNK_RE.test(token) ) {
		throw new Error(`'${key}' token '${token}' is not a thunk (want machine-shaped: kebab/colon atoms, e.g. 'csg-engine:manifold' or 'x:OpenSCAD20240727Com+Manifold')`);
	}
}

export function parseScadOptions(text:string) : { options : ScadOptions|null, warnings:string[] } {
	const warnings : string[] = [];
	let raw : string|undefined, foundLine = 0;
	const lines = text.split(/\r?\n/);
	for( let i = 0; i < lines.length; ++i ) {
		const idx = lines[i].indexOf(OPTIONS_MARKER);
		if( idx < 0 ) continue;
		if( i >= maxScanLines ) {
			warnings.push(`options line at ${i+1} ignored (beyond header zone of ${maxScanLines} lines)`);
			continue;
		}
		if( raw != undefined ) {
			warnings.push(`multiple options lines; line ${foundLine} wins, line ${i+1} ignored`);
			continue;
		}
		raw = lines[i].substring(idx + OPTIONS_MARKER.length); foundLine = i+1;
	}
	if( raw == undefined ) return { options:null, warnings };

	// Conventional spot is line 3 (below '// title' and '//'); being
	// elsewhere is a smell, not a crime.
	if( foundLine != 3 ) warnings.push(`options line at ${foundLine}; convention is line 3 (below the title comment)`);

	const res : ScadOptions = { requires:[], prefers:[] };
	for( const entryRaw of raw.split(';') ) {
		const entry = entryRaw.trim();
		if( entry == '' ) continue;
		const eq = entry.indexOf('=');
		if( eq <= 0 ) {
			throw new Error(`Malformed options entry '${entry}' (expected 'key=value')`);
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
			throw new Error(`Unrecognized options key '${key}' (known: openscad, requires, prefers)`);
		}
	}
	return { options: res, warnings };
}
