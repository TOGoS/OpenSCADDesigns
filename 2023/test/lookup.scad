function mklookupfunc( interp_func ) =
	// TODO: Binary subdivision instead of linear scan?
	let( lookup_func = function( t, list, index=0 )
		assert(len(list) > 0, "Lookup requires at least one item, but empty list was given!")
		// At or beyond last position?   Give 'em the last value.
		index >= len(list)-1 ? list[len(list)-1][1] :
		// At or before current position?  Give 'em the current value.
		t <= list[index][0] ? list[index][1] :
		t < list[index+1][0] ?
			// Time to interpolate!
			assert( index >= 0 )
			assert( index+1 < len(list) )
			let( t0 = list[index+0][0], t1 = list[index+1][0] )
			let( v0 = list[index+0][1], v1 = list[index+1][1] )
			let( rat = (t-t0)/(t1-t0) )
			interp_func(v0, v1, rat) :
		// Try next span
		lookup_func(t, list, index+1)
	)
   lookup_func;

lerp_vec = function(left, right, rat)
	assert(len(left) == len(right), "left/right vectors must be same length to interpolate")
	[
		for( i=[0 : 1 : len(left)-1] )
		left[i] + (right[i] - left[i])*rat
	];

let( looked_up = mklookupfunc(lerp_vec)( 1, [
	[0, [0,0,0]],
	[2, [20,30,40]],
]))
assert( looked_up == [10, 15, 20] );

cube();
