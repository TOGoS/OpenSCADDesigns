// Purely lexical path helpers: nothing here touches the filesystem,
// so they're usable for build targets that don't exist yet (unlike
// Deno.realPath).

export type FilePath = string;

/**
 * The final component of a '/'-delimited path.  NB: paths are
 * slash-delimited throughout this codebase ('\\' folded early); a
 * trailing slash leaves the basename empty, matching make.ts's
 * original, deliberately-simple behavior.
 */
export function basename(path:FilePath) : FilePath {
	const lastSlashIndex = path.lastIndexOf('/');
	return lastSlashIndex < 0 ? path : path.substring(lastSlashIndex+1);
}

/**
 * Makes a path absolute-free of fs access: folds '\\' to '/', drops
 * '.' and empty segments, resolves '..' lexically, and preserves
 * root- or drive-anchored paths (including their leading '/').
 */
export function normalizePath(path:FilePath) : FilePath {
	path = path.replaceAll('\\','/');
	const drive = /^[A-Za-z]:/.exec(path)?.[0] ?? '';
	const rooted = path.startsWith('/') || drive != '';
	const out : string[] = [];
	// (index 0 of a drive path is the 'C:/' segment; skip it, the drive
	// is re-attached at the end)
	for( const seg of path.split('/').slice(drive != '' ? 1 : 0) ) {
		if( seg == '' || seg == '.' ) continue;
		if( seg == '..' ) {
			if( out.length > 0 && out[out.length-1] != '..' ) out.pop();
			else if( !rooted ) out.push('..');
			continue;
		}
		out.push(seg);
	}
	const joined = out.join('/');
	if( drive != '' ) return drive + '/' + joined;
	if( rooted ) return '/' + joined;
	return joined == '' ? '.' : joined;
}

/**
 * Expresses `toPath` relative to the *directory containing* `fromPath`,
 * purely lexically (both are normalized first; mixing relative and
 * absolute inputs treats them as sharing one base, which suits
 * build-graph paths that are all repo-root-relative).
 * Works for targets that don't exist yet -- never stats.
 * Paths on different Windows drives have no relative path; that (rare)
 * case falls back to the normalized `toPath`.
 */
export function relativePath(fromPath:FilePath, toPath:FilePath) : FilePath {
	// Splits a path into its anchor ('/', 'C:', or '' for relative) and
	// the segments beneath it:
	const split = (p:string) : [string,string[]] => {
		// (no slash in the test: normalizePath may yield bare 'C:')
		const drive = /^[A-Za-z]:/.exec(p)?.[0];
		if( drive != undefined ) {
			return [drive, p.substring(drive.length).split('/').filter(s => s != '')];
		}
		const rooted = p.startsWith('/');
		return [rooted ? '/' : '', p.split('/').filter(s => s != '')];
	};
	const fromDir = normalizePath(fromPath).split('/').slice(0,-1).join('/');
	const to = normalizePath(toPath);
	const [fromAnchor, fromSegs] = split(fromDir);
	const [toAnchor, toSegs] = split(to);
	if( fromAnchor.toLowerCase() != toAnchor.toLowerCase() ) return to; // mixed or cross-drive: no relative path
	let common = 0;
	while( common < fromSegs.length && common < toSegs.length && fromSegs[common] == toSegs[common] ) ++common;
	const ups = fromSegs.length - common;
	const downs = toSegs.slice(common);
	const rel : string[] = [];
	for( let i = 0; i < ups; ++i ) rel.push('..');
	rel.push(...downs);
	return rel.length == 0 ? '.' : rel.join('/');
}
