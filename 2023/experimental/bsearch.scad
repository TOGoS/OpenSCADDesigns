function bsearch__binary_search_alist(x, alist, i0, i1) =
	let( span = i1 - i0 )
	span <= 1 ? alist[i0][1] :
	x <  alist[i0  ][0] ? i0-1 :
	x >= alist[i1-1][0] ? i1-1 :
	let( imid = i0 + floor(span/2) )
	let( xmid = alist[imid][0] )
	x < xmid ? bsearch__binary_search_alist(x, alist, i0, imid) : bsearch__binary_search_alist(x, alist, imid, i1);

function bsearch_binary_search_alist(x, alist) =
	bsearch__binary_search_alist(x, alist, 0, len(alist));

assert(123 == bsearch_binary_search_alist(7, [[-12, 100], [-6, 38], [4, 205], [6, 123], [7.5, 44], [93, 901]]));
assert( 38 == bsearch_binary_search_alist(3, [[-12, 100], [-6, 38], [4, 205], [6, 123], [7.5, 44], [93, 901]]));
