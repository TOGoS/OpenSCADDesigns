// TOGRez1
// 
// Functions for resampling arrays of things

// polypoints, r[adius] -> polypoints
// Take a conves shape and return a circle with the same number of points,
// where the first point is at the same angle as the first point of the
// input shape.  For symmetrical results, order the points so that the
// first is on a line of symmetry.
function togrez1_to_circle(polypoints, r) =
	assert(is_num(r))
	let( a0 = atan2(polypoints[0][1], polypoints[0][0]) )
	[
		for( i=[0 : 1 : len(polypoints)-1] ) let( a = a0 + i*360/len(polypoints) ) [r*cos(a), r*sin(a)]
	];

// Scale *something* (a) by scale (t)
// a can be a number, a list of numbers, a list of lists, etc.
// elements will be recursively scaled
function togrez1__scale( a, t ) =
	is_num(a) ? a*t :
	is_list(a) ? [ for(atem=a) togrez1__scale(atem, t) ] :
	assert(false, str("Don't know how to scale ", a));

// Lerp between two things, which may be numbers or lists
function togrez1__lerp( a, b, t ) = togrez1__scale(a, 1-t) + togrez1__scale(b, t);

// Pick the item at the given `index` from `things`.
// If `index` is not an integer, will interpolate
// between things using togrez1__lerp.
function togrez1_table_sample( things, index ) =
	floor(index) == index ? things[index] :
	let( i0 = floor(index), i1 = ceil(index) )
	let( s0 = things[i0 % len(things)], s1 = things[i1 % len(things)] )
	togrez1__lerp(s0, s1, index - i0 );

// Given len(things) things, create a new list of `n` things
// where the first is the same as `things[0]`, and the rest
// are interpolated cyclically (i.e. if n > len(things), then
// the n-1th resulting thing will be an interpolation between
// things[n-1] and things[0]
// 
// Use this when things is cyclical,
// i.e. the hypothetical things[n] == things[0],
// and things[n-1] is not special.
function togrez1_resample( things, n ) = [
	for( i=[0 : 1 : n-1] ) togrez1_table_sample(things, i * len(things)/n)
];

// Given len(things) things, create a new list of `n` things
// where the first and last are the first and last from the original
// list, and the rest are interpolated.
// 
// Use this when the first and last items represent 'fenceposts',
// i.e. when things[n-1] represents a boundary.
function togrez1_resample_posts( things, n ) = [
	for( i=[0 : 1 : n-1] ) togrez1_table_sample(things, i * (len(things)-1)/(n-1))
];
