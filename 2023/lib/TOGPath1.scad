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
	len(seg) != 5 ? ["invalid", undef, [str("Segment is not a list of length 5: ", seg)]] :
	seg[0] != "togpath1-qathseg" ? ["invalid", undef, [str("Segment[0] != \"togpath1-qathseg\": ", seg)]] :
	!is_list(seg[1]) || len(seg[1]) != 2 || !is_num(seg[1][0]) || !is_num(seg[1][1]) ?
		["invalid", undef, [str("Segment[1] is not [number,number]: ", seg)]] :
	!is_num(seg[2]) ? ["invalid", undef, [str("Segment[2] (angle 0) is not a number: ", seg)]] :
	!is_num(seg[3]) ? ["invalid", undef, [str("Segment[3] (angle 1) is not a number: ", seg)]] :
	!is_num(seg[4]) ? ["invalid", undef, [str("Segment[4] (radius) is not a number: ", seg)]] :
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

function togpath1_qathseg_points(seg, offset=0) =
	let( a0 = seg[2] )
	let( a1 = seg[3] )
	let( rad = seg[4] )
	let( rad1 = rad + (a1>a0?1:-1)*offset )
	assert( rad >= 0 )
	let( vcount = ceil(abs(a1 - a0) * max($fn,1) / 360) )
	assert( vcount >= 1 )
[
	for( vi = [0:1:vcount] )
	// Calculate angles in such a way that first and last are exact
	let( a = a0 * (vcount-vi)/vcount + a1 * vi/vcount )
	[seg[1][0] + cos(a) * rad1, seg[1][1] + sin(a) * rad1]
];

function togpath1_qath_points(qath, offset=0) =
let(qathinfo = togpath1_qath_info(qath))
assert(qathinfo[0] != "invalid", qathinfo[2])
assert(qathinfo[0] == "togpath1-qath-info")
assert(qathinfo[1] >= 0, str("Can't turn qath into points because minimum radius is < 0: ", qathinfo[1]))
[
	for( si = [1:1:len(qath)-1] )
	each togpath1_qathseg_points(qath[si],offset=offset)
];

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



function togpath1_zath_points(zath, offset=0) =
let(points     = togpath1_zath_points_nocheck(zath,0    ))
let(new_points = togpath1_zath_points_nocheck(zath,offset))
let(edgecomp   = togpath1__compare_edge_nvecs(points, new_points))
assert(togpath1__max_of(edgecomp) < 0.1, str("Max edge direction difference=", togpath1__max_of(edgecomp)))
new_points;


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
