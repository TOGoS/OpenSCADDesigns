// Purely lexical path helpers -- no filesystem access, so they work on
// targets that don't exist yet (unlike Deno.realPath).

export type FilePath = string;

/** '/'-delimited; a trailing slash leaves the basename empty. */
export function basename(path:FilePath) : FilePath {
	const lastSlashIndex = path.lastIndexOf('/');
	return lastSlashIndex < 0 ? path : path.substring(lastSlashIndex+1);
}

/** Normalizes lexically: '\'->'/'; drops '.'/empty segments; '..' clamps at anchors. */
export function normalizePath(path:FilePath) : FilePath {
	path = path.replaceAll('\\','/');
	const drive = /^[A-Za-z]:/.exec(path)?.[0] ?? '';
	const rooted = path.startsWith('/') || drive != '';
	const out : string[] = [];
	// (skip 'C:' segment: re-attached at the end, else we'd get 'C:/C:/')
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
 * Expresses `toPath` relative to the directory containing `fromPath`.
 * Inputs with no provable shared base -- mixed relative/absolute, or
 * different Windows drives -- just get the normalized `toPath`.
 */
export function relativePath(fromPath:FilePath, toPath:FilePath) : FilePath {
	// anchor ('/', 'C:', or '' for relative) + segments beneath:
	const split = (p:string) : [string,string[]] => {
		// (no trailing slash: normalizePath may yield bare 'C:')
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
