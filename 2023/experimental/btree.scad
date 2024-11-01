function make_btree_lookup(switch, low, mid, high) =
	function(x)
		let( s = switch(x) )
		s <  0 ?  low(x) :
		s == 0 ?  mid(x) :
		         high(x);

function list_to_btree_lookup(list, start_index=undef, end_index=undef) =
	let(start_idx = is_undef(start_index) ? 0 : start_index)
	let(end_idx = is_undef(end_index) ? len(list) : end_index)
	let(span = end_idx - start_idx)
	echo(start_idx=start_idx, end_idx=end_idx, span=span)
	assert(span > 0)
	span == 1 ? function(x) echo("The one at ",start_idx) list[start_idx][1] :
	let( i1 = start_idx + floor(span/2) )
	let( x1 = list[i1][0] )
	let( left = list_to_btree_lookup(list, start_idx, i1) )
	let( right = list_to_btree_lookup(list, i1, end_idx) )
	function(x) echo(str(x, " < ", x1, "?")) x < x1 ? left(x) : right(x);

// Functions that recursively create recursive functions
// seem to cause issues for OpenSCAD.
// Recursion detected in 'right', it says,
// which shouldn't be possible!
/*echo(
	let( myfunc = list_to_btree_lookup([[0,100],[1,200],[2,300]]) )
	let( rz = [for(x=[-1:0.5:4]) [x, myfunc(x)]] )
	rz
);*/



// TODO: Can we compare strings?
// Could be useful to make B-trees for symbol lookups.
