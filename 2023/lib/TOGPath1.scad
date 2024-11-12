use <./TOGComplexLib1.scad>

//// Assertion helpers

/**
 * Are a and b identical in structure with corresponding numeric
 * components being 'approximately equal'?
 */
function togpath1__approximate_equal(a, b, offset=0) =
	is_list(a) && is_list(b) && len(a) == len(b) ? (
		len(a) == offset ? true :
		togpath1__approximate_equal(a[offset], b[offset]) && togpath1__approximate_equal(a, b, offset+1)
	) :
	is_num(a) && is_num(b) ? abs(a-b) < 0.0001 :
	a == b;

function togpath1__assert_equals(expected, actual, eqfunc=function(a,b) togpath1__approximate_equal(a,b)) =
	assert(eqfunc(expected, actual), str("\nExpected=", expected, ";\nActual  =", actual))
	true;
module togpath1__assert_equals(expected, actual) {
	_ignored = togpath1__assert_equals(expected, actual);
}


//// Vector/angle functions

function togpath1__vec_length_squared(vec,i=0,acc=0) =
	i == len(vec) ? acc :
	togpath1__vec_length_squared(vec, i+1, acc + vec[i]*vec[i]);

function togpath1__vec_length(vec) =
	sqrt(togpath1__vec_length_squared(vec));

function togpath1__normalize_vec(vec) =
	let(vlen = togpath1__vec_length(vec))
	vlen == 0 ? vec : vec / vlen;

assert([0,0,0,0] == togpath1__normalize_vec([0,0,0,0]));
assert([0,0,0,1] == togpath1__normalize_vec([0,0,0,1]));
assert([0,1,0,0] == togpath1__normalize_vec([0,1,0,0]));
assert([0,0,0,1] == togpath1__normalize_vec([0,0,0,2]));
assert([0,1,0,0] == togpath1__normalize_vec([0,2,0,0]));

function togpath1__nvec_angle(nv) = atan2(nv[1], nv[0]);

togpath1__nvec_angle_test_cases = [
	[   0, togpath1__nvec_angle([ 0, 0])],
	[  90, togpath1__nvec_angle([ 0, 1])],
	[ 135, togpath1__nvec_angle([-1, 1])],
	[ 180, togpath1__nvec_angle([-1, 0])],
	[-135, togpath1__nvec_angle([-1,-1])],
	[ -90, togpath1__nvec_angle([ 0,-1])],
];
for( tc=togpath1__nvec_angle_test_cases ) {
	expected = tc[0];
	actual   = tc[1];
	assert(expected == actual, str("expected ", expected, " but got ", actual));
}


function togpath1__line_angle(v0, v1) =
	togpath1__nvec_angle(togpath1__normalize_vec(v1-v0));

assert( 90 == togpath1__line_angle([0,0], [0, 1]));
assert(  0 == togpath1__line_angle([0,0], [1, 0]));
assert(-90 == togpath1__line_angle([0,0], [0,-1]));
assert( 45 == togpath1__line_angle([0,0], [1, 1]));


function togpath1__pointlist_relative_edge_vectors(points) =
[
	for( i=[0:1:len(points)-1] )
	let( p0 = points[i] )
	let( p1 = points[(i+1)%len(points)] )
	p1 - p0
];

function togpath1__pointlist_normalized_relative_edge_vectors(points) =
[
	for( v = togpath1__pointlist_relative_edge_vectors(points) ) togpath1__normalize_vec(v)
];


//// Qath - Path defined by center and radius of each corner arc

// Qath = ["togpath1-qath", ...QuathSeg...]
// QathSeg = ["togpath1-qathseg", point, angle0, angle1, radius, pointcount=$fn*angle/360]
// 
// Positive angle difference means a counter-clockwise turn around
// the point, negative means a clockwise turn around the point.
// i.e. if tracing a shape counter-clockwise, point should be
// inside the shape when angle1 > angle0, and outside  when angle1 < angle0.
// I think (writing this months after having coded it).

function togpath1_merge_qath_info(i0, i1) =
	let(type = i0[0] == "togpath1-qath-info" && i1[0] == "togpath1-qath-info" ? "togpath1-qath-info" : "invalid")
	let(min_radius = is_undef(i0[1]) || is_undef(i1[1]) ? undef : min(i0[1],i1[1]))
	let(errs = concat(i0[2],i1[2]))
	[type, min_radius, errs];

assert(["togpath1-qath-info", 3, []] == togpath1_merge_qath_info(
	["togpath1-qath-info", 4, []],
	["togpath1-qath-info", 3, []]
));
assert(["invalid", undef, ["An error"]] == togpath1_merge_qath_info(
	["togpath1-qath-info", 4, []],
	["invalid", undef, ["An error"]]
));

function togpath1_qathseg_info(seg) =
	!is_list(seg) ? ["invalid", undef, [str("Segment is not a list: ", seg)]] :
	(len(seg) < 5 || len(seg) > 6) ? ["invalid", undef, [str("Segment is not a list of length 5 or 6: ", seg)]] :
	seg[0] != "togpath1-qathseg" ? ["invalid", undef, [str("Segment[0] != \"togpath1-qathseg\": ", seg)]] :
	!is_list(seg[1]) || len(seg[1]) != 2 || !is_num(seg[1][0]) || !is_num(seg[1][1]) ?
		["invalid", undef, [str("Segment[1] is not [number,number]: ", seg)]] :
	!is_num(seg[2]) ? ["invalid", undef, [str("Segment[2] (angle 0) is not a number: ", seg)]] :
	!is_num(seg[3]) ? ["invalid", undef, [str("Segment[3] (angle 1) is not a number: ", seg)]] :
	!is_num(seg[4]) ? ["invalid", undef, [str("Segment[4] (radius) is not a number: ", seg)]] :
	(!is_undef(seg[5]) && !is_num(seg[5])) ? ["invalid", undef, [str("Segment[5] (vertex count) is neither undef nor a number: ", seg)]] :
	["togpath1-qath-info", seg[4], []];

assert(["togpath1-qath-info", 3, []] == togpath1_qathseg_info(["togpath1-qathseg", [0,0], 0, 90, 3]));

function togpath1_qath_info(qath, off=0) =
	!is_list(qath) ? ["invalid", undef, ["Not a list"]] :
	len(qath) == 0 ? ["invalid", undef, ["Empty list"]] :
	len(qath) == off ? ["togpath1-qath-info", 1/0, []] :
	off == 0 && qath[off] == "togpath1-qath" ? togpath1_qath_info(qath, 1) :
	off == 0 ? ["invalid", undef, ["Not a togpath1-qath"]] :
	togpath1_merge_qath_info(togpath1_qathseg_info(qath[off]), togpath1_qath_info(qath, off+1));

assert(["togpath1-qath-info", 3, []] == togpath1_qath_info(["togpath1-qath",
	["togpath1-qathseg", [0,0], 0, 90, 3],
	["togpath1-qathseg", [0,0], 90, 180, 4],
	["togpath1-qathseg", [0,0], 180, 270, 5],
]));
assert("invalid" == togpath1_qath_info(["togpath1-qath",
	["togpath1-qathseg", [0,0], 0, 90, 3],
	["togpath1-qathseg-typo", [0,0], 90, 180, 4],
	["togpath1-qathseg", [0,0], 180, 270, 5],
])[0]);

function togpath1__fold(init, folder, list, off=0) =
	off == len(list) ? init :
	togpath1__fold(folder(init, list[off]), folder, list, off+1);

assert(6 == togpath1__fold(0, function(a,b) a+b, [1,2,3]));

function togpath1_offset_qath(qath, offset) =
assert(togpath1_qath_info(qath)[0] == "togpath1-qath-info")
[
	"togpath1-qath",
	for( i=[1:1:len(qath)-1] )
	let( seg=qath[i] )
	// TODO: Maybe if a1 < a0, that means the curve is clockwise/concave, and we should subtract offset
	// (regardless of turn direction, negative offset means a kink which needs to be fixed)
	[seg[0], seg[1], seg[2], seg[3], seg[4] + offset]
];

function togpath1__qathseg_to_polypoints(seg, offset=0) =
	let( a0 = seg[2] )
	let( a1 = seg[3] )
	let( rad = seg[4] )
	let( rad1 = rad + (a1>a0?1:-1)*offset )
	let( vcount = !is_undef(seg[5]) ? seg[5] : max(2, round(abs(a1 - a0) * max($fn,1) / 360)) )
	assert( rad >= 0 )
	assert( abs(a1 - a0) > 0 )
	let( fcount = vcount-1 )
	assert( fcount >= 1 )
	[
		for( vi = [0:1:fcount] )
		// Calculate angles in such a way that first and last are exact
		let( a = a0 * (fcount-vi)/fcount + a1 * vi/fcount )
		[seg[1][0] + cos(a) * rad1, seg[1][1] + sin(a) * rad1]
	];

function togpath1_qath_to_polypoints(qath, offset=0) =
let(qathinfo = togpath1_qath_info(qath))
assert(qathinfo[0] != "invalid", qathinfo[2])
assert(qathinfo[0] == "togpath1-qath-info")
assert(qathinfo[1] >= 0, str("Can't turn qath into points because minimum radius is < 0: ", qathinfo[1]))
[
	for( si = [1:1:len(qath)-1] )
	each togpath1__qathseg_to_polypoints(qath[si],offset=offset)
];

// Deprecated; use togpath1_qath_to_polypoints.
// Same thing, different name.
// 
// 'to polypoints' implies a specific conversion, whereas just 'points'
// might seem to mean extracting the original point data or something.
function togpath1_qath_points(qath, offset=0) = togpath1_qath_to_polypoints(qath,offset=offset);


/**
 * For now this only allows two points, because I didn't want to bother
 * with the math for concave turns (even though it's already been
 * figured out for rendering zaths).
 * 
 * Generates a qath that traces around the line,
 * optionally at some radius.
 * 
 * Primary use case is for making ovals in a way that's
 * slightly more efficient (and has fewer corner cases)
 * than making a rectangle and then rounding the corners;
 * this only makes one 180-degree turn at each end instead
 * of two 90-degree ones
 */
function togpath1_polyline_to_qath(points, r=0) =
assert(len(points) == 2, "togpath1_polyline_to_qath: Only simple lines supported for now")
let(diff = points[1]-points[0])
let(ang = atan2(diff[1], diff[0]))
["togpath1-qath",
	["togpath1-qathseg", points[0], ang+90, ang+270, r],
	["togpath1-qathseg", points[1], ang-90, ang+ 90, r],
];

togpath1__assert_equals(
	["togpath1-qath",
		["togpath1-qathseg", [-2,0],  90, 270, 1],
		["togpath1-qathseg", [ 2,0], -90,  90, 1],
	],
	togpath1_polyline_to_qath([[-2,0],[2,0]], r=1)
);
togpath1__assert_equals(
	[[-2,1],[-3,0],[-2,-1],[2,-1],[3,0],[2,1]],
	togpath1_qath_to_polypoints(togpath1_polyline_to_qath([[-2,0],[2,0]], r=1), $fn=4)
);


//// Zath - points with offset vector

// Zath = ["togpath1-zath", ZathPoint...]
// ZathPoint = [[x, y], [ox, oy]] ; where ox,oy is the outward-pointing offset vector

function togpath1_offset_zathnode(zathnode, offset) = [
	zathnode[0] + offset*zathnode[1],
	zathnode[1]
];;

function togpath1_offset_zath(zath, offset) =
assert(zath[0] == "togpath1-zath")
[
	for( i=[1:1:len(zath)-1] ) togpath1_offset_zathnode(zath[i], offset)
];

function togpath1_zath_points_nocheck(zath, offset=0) = 
assert(zath[0] == "togpath1-zath")
[
	for( i=[1:1:len(zath)-1] ) zath[i][0] + offset*zath[i][1]
];

function togpath1__compare_edge_nvecs(points_a, points_b) =
assert(len(points_a) == len(points_b))
let(vecs_a = togpath1__pointlist_normalized_relative_edge_vectors(points_a))
let(vecs_b = togpath1__pointlist_normalized_relative_edge_vectors(points_b))
[
	for( i=[0:1:len(vecs_a)-1] )
	togpath1__vec_length(vecs_b[i] - vecs_a[i])
];

function togpath1__max_of(list, i=0, acc=0) =
	i == len(list) ? acc :
	togpath1__max_of(list, i+1, max(acc, list[i]));



function togpath1_zath_to_polypoints(zath, offset=0) =
let(points     = togpath1_zath_points_nocheck(zath,0    ))
let(new_points = togpath1_zath_points_nocheck(zath,offset))
let(edgecomp   = togpath1__compare_edge_nvecs(points, new_points))
assert(togpath1__max_of(edgecomp) < 0.1, str("Max edge direction difference=", togpath1__max_of(edgecomp)))
new_points;

// Deprecated alias to togpath1_zath_to_polypoints
function togpath1_zath_points(zath, offset=0) = togpath1_zath_to_polypoints(zath, offset=offset);



function togpath1_zath_to_qath(zath, radius=0, offset=0, closed=true) =
assert(zath[0] == "togpath1-zath")
let(points = togpath1_zath_points(zath, offset-radius))
[
	"togpath1-qath",
	
	for( i=closed ? [0:1:len(points)-1] : [1:1:len(points)-2])
	let( va = points[(i-1+len(points))%len(points)] )
	let( vb = points[(i              )            ] )
	let( vc = points[(i+1            )%len(points)] )
	// Note that Qaths can handle turns > 180 degrees,
	// which is why they need to use a1-a0 <> 0 to determine turn direction.
	// Angles > 180 or <-180 makes no sense for a Zath,
	// so we can assume that 'turn' has the correct sign
	// and abc = aab+turn will give it the proper relationship to abc:
	let( aab = togpath1__line_angle(va, vb)-90 )
	let( turn = tcplx1_relative_angle_abc(va, vb, vc) )
	let( abc = aab+turn )
	["togpath1-qathseg", points[i], aab, abc, radius]
];

function togpath1_polypoint_offset_vectors(points) = [
	for( i = [0:1:len(points)-1] )
	let( pa = points[ (i-1+len(points))%len(points) ] )
	let( pb = points[ (i              )           ] )
	let( pc = points[ (i+1            )%len(points) ] )
	let( turn = tcplx1_relative_angle_abc(pa, pb, pc) )
	let( ab_normalized = tcplx1_normalize(pb-pa) )
	let( ov_forward = tan(turn/2) ) // 2023-12-04 Eureka
	tcplx1_multiply(ab_normalized, [0,-1]) + tcplx1_multiply(ab_normalized, [ov_forward,0])
];


// Simplest case: a square
togpath1__assert_equals([[1,1], [-1,1], [-1,-1], [1,-1]], togpath1_polypoint_offset_vectors([[2,2], [-2,2], [-2,-2], [2,-2]]));
// A rectangle
togpath1__assert_equals([[1,1], [-1,1], [-1,-1], [1,-1]], togpath1_polypoint_offset_vectors([[3,2], [-4,2], [-4,-1], [3,-1]]));
// A diamond
let(s2 = sqrt(2))
togpath1__assert_equals([[s2,0], [0,s2], [-s2,0], [0,-s2]], togpath1_polypoint_offset_vectors([[3,0], [0,3], [-3,0], [0,-3]]));
// Something with a 45-degree turn
let(z41 = sqrt(2)-1)
togpath1__assert_equals([
	[-1,-1], [1,-1], [1,z41], [z41, 1], [-1,1]
], togpath1_polypoint_offset_vectors([[0,0], [5,0], [5,3], [3,5], [0,5]]));


function togpath1_points_to_zath(points) =
let(ovecs = togpath1_polypoint_offset_vectors(points))
["togpath1-zath",
	for( i = [0:1:len(points)-1] ) [ points[i], ovecs[i] ]
];


// Rath = ["togpath1-rath", RathNode...]
// RathNode = ["togpath1-rathnode",[x,y], RathOp...]
// RathOp = ["bevel", size] | ["round", radius] | ["offset", distance]

function togpath1_is_rath(rath) =
	is_list(rath) && len(rath) >= 1 &&
	rath[0] == "togpath1-rath";

function togpath1__bevel(pa, pb, pc, bevel_size) =
	let( ba_normalized = tcplx1_normalize(pa-pb) )
	let( bc_normalized = tcplx1_normalize(pc-pb) )
	[pb + ba_normalized * bevel_size, pb + bc_normalized * bevel_size];

// Given 3 points: pa,pb,pc, determine an offset vector
// that when added to pb, will be `dist` from both pa-pb and pb-pc.
function togpath1__offset_vector(pa, pb, pc, dist) =
	let( ab_normalized = tcplx1_normalize(pb-pa) )
	let( turn = tcplx1_relative_angle_abc(pa, pb, pc) )
	let( ov_forward = tan(turn/2) )
	let( ovec = tcplx1_multiply(ab_normalized, [0,-1]) + tcplx1_multiply(ab_normalized, [ov_forward,0]) )
	ovec*dist;

function togpath1__offset(pa, pb, pc, dist) =
	[pb + togpath1__offset_vector(pa, pb, pc, dist)];

// Rounds a corner using `force_fn` (or `ceil($fn * angle/360)`) points.
// If point count is 1, will return `[pb]`.
// Note that this is designed to be used to round corners between two straight line segments.
function togpath1__round(pa, pb, pc, radius, force_fn=undef) =
	let( ab_normalized = tcplx1_normalize(pb-pa) )
	let( turn = tcplx1_relative_angle_abc(pa, pb, pc) )
	let( turndir = turn > 0 ? 1 : -1 ) // +1=left, -1=right
	let( ov_forward = tan(turn/2) )
	let( ovec = tcplx1_multiply(ab_normalized, [0,-1]) + tcplx1_multiply(ab_normalized, [ov_forward,0]) )
	let( fulc = pb - turndir * ovec*radius )
	let( a0 = togpath1__line_angle(pa, pb) - turndir * 90 )
	let( a1 = a0+turn )
	let( vcount = !is_undef(force_fn) ? force_fn : ceil(abs(turn) * max($fn,1) / 360) )
	let( vmax = vcount-1 )
	assert( vmax >= 0 )
	vmax == 0 ? [pb] : // Special case when only one point
	[
		for( vi = [0:1:vmax] )
		// Calculate angles in such a way that first and last are exact
		let( a = a0 * (vmax-vi)/vmax + a1 * vi/vmax )
		[fulc[0] + cos(a) * radius, fulc[1] + sin(a) * radius]
	];

// Note!  ["offset", x], ["round", r] will currently give
// not the results you expect, because the offsetting and
// rounding is done independently for each point.
// The whole rathnode_to_polypoints should probably
// apply all offsets first before applying other ops.
// 
// As long as you only apply offset *last*, all should be well.

function togpath1__rathnode_apply_op(pa, pb, pc, op) =
	op[0] == "bevel" ? togpath1__bevel(pa, pb, pc, op[1]) :
	op[0] == "round" ? togpath1__round(pa, pb, pc, op[1], force_fn=op[2]) :
	op[0] == "offset" ? togpath1__offset(pa, pb, pc, op[1]) :
	assert(false, str("Unrecognized rath node op, '", op, "'"));

function togpath1__rathnode_to_polypoints(pa, pb, pc, rathnode, opindex) =
	assert(is_list(pa))
	assert(is_list(pb))
	assert(is_list(pc))
	assert(is_list(rathnode))
	assert(is_num(opindex))
	opindex == len(rathnode) ? [pb] :
	let( newpoints = [pa, each togpath1__rathnode_apply_op(pa, pb, pc, rathnode[opindex]), pc] )
	[ for( i=[1:1:len(newpoints)-2] ) each togpath1__rathnode_to_polypoints(newpoints[i-1], newpoints[i], newpoints[i+1], rathnode, opindex+1) ];

function togpath1_rath_to_polypoints(rath) =
	assert(rath[0] == "togpath1-rath")
	let(points = [ for(i=[1:1:len(rath)-1]) rath[i][1] ])
[
	for(i=[0:1:len(points)-1])
	let( pa = points[ (i-1+len(points))%len(points) ] )
	let( pb = points[ (i              )           ] )
	let( pc = points[ (i+1            )%len(points) ] )
	each togpath1__rathnode_to_polypoints(pa, pb, pc, rath[i+1], 2)
];

// Deprecated name for togpath1_rath_to_polypoints
function togpath1_rath_to_points(rath) = togpath1_rath_to_polypoints(rath);

function togpath1_map_rath_nodes(rath, func) = [
	rath[0],
	for( i=[1:1:len(rath)-1] ) func(rath[i])
];

function togpath1_offset_rath(rath,offset) =
	assert(togpath1_is_rath(rath))
	assert(is_num(offset))
	offset == 0 ? rath :
	togpath1_map_rath_nodes(rath, function(rn) [each rn, ["offset", offset]]);

function togpath1_make_rectangle_rath(size, corner_ops=[], position=[0,0]) = ["togpath1-rath",
	["togpath1-rathnode", [position[0]-size[0]/2, position[1]-size[1]/2], each corner_ops],
	["togpath1-rathnode", [position[0]+size[0]/2, position[1]-size[1]/2], each corner_ops],
	["togpath1-rathnode", [position[0]+size[0]/2, position[1]+size[1]/2], each corner_ops],
	["togpath1-rathnode", [position[0]-size[0]/2, position[1]+size[1]/2], each corner_ops],
];

function togpath1_polypoints_to_rath(points, corner_ops=[]) = ["togpath1-rath",
	for(p=points) ["togpath1-rathnode", p, each corner_ops]
];

function togpath1_make_polygon_rath(r, corner_ops=[], position=[0,0], rotation=0) = ["togpath1-rath",
	for( i=[0:1:$fn-1] ) ["togpath1-rathnode", [position[0]+r*cos(rotation+i*360/$fn), position[1]+r*sin(rotation+i*360/$fn)], each corner_ops]
];

function togpath1_make_circle_rath(r, position=[0,0]) = togpath1_make_rectangle_rath(
	[r*2, r*2], corner_ops=[["round", r]], position=position
);

// Calculate an offset vector from pa
// given the next point, pb, and the angle
// from pa-pb
function togpath1__la_offset_vector(pa, pb, angle, length=1) =
	let( ab = tcplx1_normalize(pb - pa) )
	tcplx1_multiply( ab, [cos(angle)*length, sin(angle)*length] );

// Make a zath by offsetting the given polyline to the right and left by r.
// Convex corners are not beveled, so will be 'pointy'.
function togpath1_polyline_to_zath(polyline, end_shape="square") =
// end_shape would affect end offset vectors, which are currently
// hardcoded to the 'square' shape.
assert( end_shape == "square" )
let( sqrt2 = sqrt(2) )
["togpath1-zath",
	for( i=[0 : 1 : len(polyline)-1] ) [
		polyline[i],
		i == 0               ? togpath1__la_offset_vector(polyline[0  ], polyline[1], -135, sqrt2) :
		i == len(polyline)-1 ? togpath1__la_offset_vector(polyline[i-1], polyline[i], - 45, sqrt2) :
		togpath1__offset_vector(polyline[i-1], polyline[i], polyline[i+1], 1)
	],
	for( i=[len(polyline)-1 : -1 : 0] ) [
		polyline[i],
		i == len(polyline)-1 ? togpath1__la_offset_vector(polyline[i], polyline[i-1], -135, sqrt2) :
		i == 0               ? togpath1__la_offset_vector(polyline[1], polyline[0]  , - 45, sqrt2) :
		togpath1__offset_vector(polyline[i+1], polyline[i], polyline[i-1], 1)
	]
];

// Make a rath by offsetting the given polyline to the right and left by r.
// Optionally rounds ends.
// 
// Convex corners are not beveled, so will be 'pointy'.
// If you want wider turns, round the polyline before passing it in,
// or maybe do some post-processing of the rath idk.
// 
// end_shape = "round"|"square", matching behavior of SVG's `stroke-linecap`
// (may add 'butt' later)
function togpath1_polyline_to_rath(polyline, r, end_shape="round") =
assert( end_shape == "square" || end_shape == "round" )
len(polyline) == 1 ? (
	end_shape == "round" ? togpath1_make_circle_rath(r=r, position=polyline[0]) :
	end_shape == "square" ? togpath1_make_rectangle_rath([r*2,r*2], position=polyline[0]) :
	assert(false, str("Unsupported end_shape for single-point polyline: '", end_shape, "'"))
) :
assert( len(polyline) >= 2 )
let( end_ops = end_shape == "round" ? [["round", r-0.1, round($fn/4)]] : [] )
let( polylen = len(polyline) )
let( zath = togpath1_polyline_to_zath(polyline, end_shape="square") )
["togpath1-rath",
	for( i=[1:1:len(zath)-1] ) let( p = zath[i] )
		let( is_end_node = i == 1 || i == 1 + polylen-1 || i == 1 + polylen || i == len(zath)-1 )
		["togpath1-rathnode", p[0] + p[1]*r, if(is_end_node) each end_ops]
];
