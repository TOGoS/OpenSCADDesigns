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
 * Expresses `toPath` relative to the *directory containing* `fromPath`
 * (both may be relative or absolute; relative ones are resolved
 * against `cwd`, which defaults to the process cwd).  Purely lexical
 * -- never stats -- so it works for build targets that don't exist yet.
 * Paths on different Windows drives have no relative path; that (rare)
 * case falls back to the resolved absolute form.
 */
export function relativePath(fromPath:FilePath, toPath:FilePath, cwd:FilePath = Deno.cwd()) : FilePath {
	const abs = (p:string) => {
		const r = normalizePath(p);
		if( r.startsWith('/') || /^[A-Za-z]:/.test(r) ) return r;
		return normalizePath(`${cwd}/${r}`);
	};
	// Splits an absolute path into its anchor ('/' or 'C:/') and the
	// directory/file segments beneath it:
	const split = (p:string) : [string,string[]] => {
		// (no slash in the test: normalizePath may yield bare 'C:')
		const drive = /^[A-Za-z]:/.exec(p)?.[0];
		return drive != undefined
			? [drive, p.substring(drive.length).replace(/^\//,'').split('/').filter(s => s != '')]
			: ['/', p.split('/').filter(s => s != '')];
	};
	const fromDir = abs(fromPath).split('/').slice(0,-1).join('/') || '/';
	const to = abs(toPath);
	const [fromAnchor, fromSegs] = split(fromDir);
	const [toAnchor, toSegs] = split(to);
	if( fromAnchor.toLowerCase() != toAnchor.toLowerCase() ) return to; // cross-drive: no relative path
	let common = 0;
	while( common < fromSegs.length && common < toSegs.length && fromSegs[common] == toSegs[common] ) ++common;
	const ups = fromSegs.length - common;
	const downs = toSegs.slice(common);
	const rel : string[] = [];
	for( let i = 0; i < ups; ++i ) rel.push('..');
	rel.push(...downs);
	return rel.length == 0 ? '.' : rel.join('/');
}
