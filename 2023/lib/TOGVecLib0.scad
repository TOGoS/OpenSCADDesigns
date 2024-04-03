// Note: TOGMod1Constructors's togmod1__make_nd_vector_adder is used for similar purpose.

function togvec0_extend(vec, length, filler=0) = [
	for( i=[0 : 1 : length-1] ) len(vec) <= i ? filler : vec[i]
];

function togvec0_add_vec(a, b) =
	let( newlen = max(len(a), len(b)) )
	togvec0_extend(a, newlen) + togvec0_extend(b, newlen);

function togvec0_offset_points(points, offset, numtovec=function(n) [0,0,n] ) =
	let( offset_vec =
		is_list(offset) ? offset :
		is_num(offset) ? numtovec(offset) :
		assert(false, str("togvec0_offset_points: `offset` must be a List<Number> or Number; got: ", offset)) )
	[for(p=points) togvec0_add_vec(p, offset_vec)];
