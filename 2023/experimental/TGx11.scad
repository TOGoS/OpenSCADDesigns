// TGx11
//
// Attenot at re-implementation of TGx9 shapes
// using TOGMod1 S-shapes and cleaner APIs with better defaults.

// TGx11Path = ["tgx11-path", TGx11PathSegment, ...]
// TGx11PathSegment =
//   ["tgx11-line", [x0,y0], [x1,y1]] |
//   ["tgx11-curve-right"|"tgx11-curve-left", [x0,y0], [x1,y1], [xa,ya]]

// Simpler: a 'qath', which is just a list of the curved parts
// TGx11QathSegment = ["tgx11-qathseg", [x,y], a0, a1, r]
// TGx11Qath = ["tgx11-qath", TGx11QathSegment, ...]

// function tgx11_rounded_offset_path(pn, offset) =

// TGx11QathInfo = ["tgx11-qath-info"|"invalid", min_radius|undef, ["error message", "error message", ...]]

item = "block"; // ["block", "foot-column", "v6hc-xc", "concave-qath-demo"]
// radius = 4;
block_size_chunks = [2,2];
block_height_u = 12;

offset = -0.1; // 0.1

preview_fn = 12;

$fn = $preview ? preview_fn : 72;

use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>

//// Vector/angle functions

function tgx11__vec_length_squared(vec,i=0,acc=0) =
	i == len(vec) ? acc :
	tgx11__vec_length_squared(vec, i+1, acc + vec[i]*vec[i]);

function tgx11__vec_length(vec) =
	sqrt(tgx11__vec_length_squared(vec));

function tgx11__normalize_vec(vec) =
	let(vlen = tgx11__vec_length(vec))
	vlen == 0 ? vec : vec / vlen;

assert([0,0,0,0] == tgx11__normalize_vec([0,0,0,0]));
assert([0,0,0,1] == tgx11__normalize_vec([0,0,0,1]));
assert([0,1,0,0] == tgx11__normalize_vec([0,1,0,0]));
assert([0,0,0,1] == tgx11__normalize_vec([0,0,0,2]));
assert([0,1,0,0] == tgx11__normalize_vec([0,2,0,0]));

function tgx11__nvec_angle(nv) = atan2(nv[1], nv[0]);

tgx11__nvec_angle_test_cases = [
	[   0, tgx11__nvec_angle([ 0, 0])],
	[  90, tgx11__nvec_angle([ 0, 1])],
	[ 135, tgx11__nvec_angle([-1, 1])],
	[ 180, tgx11__nvec_angle([-1, 0])],
	[-135, tgx11__nvec_angle([-1,-1])],
	[ -90, tgx11__nvec_angle([ 0,-1])],
];
for( tc=tgx11__nvec_angle_test_cases ) {
	expected = tc[0];
	actual   = tc[1];
	assert(expected == actual, str("expected ", expected, " but got ", actual));
}


function tgx11__line_angle(v0, v1) =
	tgx11__nvec_angle(tgx11__normalize_vec(v1-v0));

assert( 90 == tgx11__line_angle([0,0], [0, 1]));
assert(  0 == tgx11__line_angle([0,0], [1, 0]));
assert(-90 == tgx11__line_angle([0,0], [0,-1]));
assert( 45 == tgx11__line_angle([0,0], [1, 1]));


function tgx11__pointlist_relative_edge_vectors(points) =
[
	for( i=[0:1:len(points)-1] )
	let( p0 = points[i] )
	let( p1 = points[(i+1)%len(points)] )
	p1 - p0
];

function tgx11__pointlist_normalized_relative_edge_vectors(points) =
[
	for( v = tgx11__pointlist_relative_edge_vectors(points) ) tgx11__normalize_vec(v)
];


//// Qath - Path defined by center and radius of each corner arc

function tgx11_merge_qath_info(i0, i1) =
	let(type = i0[0] == "tgx11-qath-info" && i1[0] == "tgx11-qath-info" ? "tgx11-qath-info" : "invalid")
	let(min_radius = is_undef(i0[1]) || is_undef(i1[1]) ? undef : min(i0[1],i1[1]))
	let(errs = concat(i0[2],i1[2]))
	[type, min_radius, errs];

assert(["tgx11-qath-info", 3, []] == tgx11_merge_qath_info(
	["tgx11-qath-info", 4, []],
	["tgx11-qath-info", 3, []]
));
assert(["invalid", undef, ["An error"]] == tgx11_merge_qath_info(
	["tgx11-qath-info", 4, []],
	["invalid", undef, ["An error"]]
));

function tgx11_qathseg_info(seg) =
	!is_list(seg) ? ["invalid", undef, [str("Segment is not a list: ", seg)]] :
	len(seg) != 5 ? ["invalid", undef, [str("Segment is not a list of length 5: ", seg)]] :
	seg[0] != "tgx11-qathseg" ? ["invalid", undef, [str("Segment[0] != \"tgx11-qathseg\": ", seg)]] :
	!is_list(seg[1]) || len(seg[1]) != 2 || !is_num(seg[1][0]) || !is_num(seg[1][1]) ?
		["invalid", undef, [str("Segment[1] is not [number,number]: ", seg)]] :
	!is_num(seg[2]) ? ["invalid", undef, [str("Segment[2] (angle 0) is not a number: ", seg)]] :
	!is_num(seg[3]) ? ["invalid", undef, [str("Segment[3] (angle 1) is not a number: ", seg)]] :
	!is_num(seg[4]) ? ["invalid", undef, [str("Segment[4] (radius) is not a number: ", seg)]] :
	["tgx11-qath-info", seg[4], []];

assert(["tgx11-qath-info", 3, []] == tgx11_qathseg_info(["tgx11-qathseg", [0,0], 0, 90, 3]));

function tgx11_qath_info(qath, off=0) =
	!is_list(qath) ? ["invalid", undef, ["Not a list"]] :
	len(qath) == 0 ? ["invalid", undef, ["Empty list"]] :
	len(qath) == off ? ["tgx11-qath-info", 1/0, []] :
	off == 0 && qath[off] == "tgx11-qath" ? tgx11_qath_info(qath, 1) :
	off == 0 ? ["invalid", undef, ["Not a tgx11-qath"]] :
	tgx11_merge_qath_info(tgx11_qathseg_info(qath[off]), tgx11_qath_info(qath, off+1));

assert(["tgx11-qath-info", 3, []] == tgx11_qath_info(["tgx11-qath",
	["tgx11-qathseg", [0,0], 0, 90, 3],
	["tgx11-qathseg", [0,0], 90, 180, 4],
	["tgx11-qathseg", [0,0], 180, 270, 5],
]));
assert("invalid" == tgx11_qath_info(["tgx11-qath",
	["tgx11-qathseg", [0,0], 0, 90, 3],
	["tgx11-qathseg-typo", [0,0], 90, 180, 4],
	["tgx11-qathseg", [0,0], 180, 270, 5],
])[0]);

function tgx11__fold(init, folder, list, off=0) =
	off == len(list) ? init :
	tgx11__fold(folder(init, list[off]), folder, list, off+1);

assert(6 == tgx11__fold(0, function(a,b) a+b, [1,2,3]));

function tgx11_offset_qath(qath, off) =
assert(tgx11_qath_info(qath)[0] == "tgx11-qath-info")
[
	"tgx11-qath",
	for( i=[1:1:len(qath)-1] )
	let( seg=qath[i] )
	// TODO: Maybe if a1 < a0, that means the curve is clockwise/concave, and we should subtract offset
	// (regardless of turn direction, negative offset means a kink which needs to be fixed)
	[seg[0], seg[1], seg[2], seg[3], seg[4] + off]
];

function tgx11_qathseg_points(seg, offset=0) =
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

function tgx11_qath_points(qath, offset=0) =
let(qathinfo = tgx11_qath_info(qath))
assert(qathinfo[0] != "invalid", qathinfo[2])
assert(qathinfo[0] == "tgx11-qath-info")
assert(qathinfo[1] >= 0, str("Can't turn qath into points because minimum radius is < 0: ", qathinfo[1]))
[
	for( si = [1:1:len(qath)-1] )
	each tgx11_qathseg_points(qath[si],offset=offset)
];

//// Zath - points with offset vector

function tgx11_offset_zathnode(zathnode, off) = [
	zathnode[0] + off*zathnode[1],
	zathnode[1]
];;

function tgx11_offset_zath(zath, off) =
assert(zath[0] == "tgx11-zath")
[
	for( i=[1:1:len(zath)-1] ) tgx11_offset_zathnode(zath[i], off)
];

function tgx11_zath_points_nocheck(zath, off=0) = 
assert(zath[0] == "tgx11-zath")
[
	for( i=[1:1:len(zath)-1] ) zath[i][0] + off*zath[i][1]
];

function tgx11__compare_edge_nvecs(points_a, points_b) =
assert(len(points_a) == len(points_b))
let(vecs_a = tgx11__pointlist_normalized_relative_edge_vectors(points_a))
let(vecs_b = tgx11__pointlist_normalized_relative_edge_vectors(points_b))
[
	for( i=[0:1:len(vecs_a)-1] )
	tgx11__vec_length(vecs_b[i] - vecs_a[i])
];

function tgx11__max_of(list, i=0, acc=0) =
	i == len(list) ? acc :
	tgx11__max_of(list, i+1, max(acc, list[i]));



function tgx11_zath_points(zath, off=0) =
let(points     = tgx11_zath_points_nocheck(zath,0  ))
let(new_points = tgx11_zath_points_nocheck(zath,off))
let(edgecomp   = tgx11__compare_edge_nvecs(points, new_points))
assert(tgx11__max_of(edgecomp) < 0.1, str("Max edge direction difference=", tgx11__max_of(edgecomp)))
new_points;

function tgx11_zath_to_qath(zath, radius=0, offset=0, closed=true) =
assert(zath[0] == "tgx11-zath")
let(points = tgx11_zath_points(zath, offset-radius))
[
	"tgx11-qath",
	
	for( i=closed ? [0:1:len(points)-1] : [1:1:len(points)-2])
	let( va = points[(i-1+len(points))%len(points)] )
	let( vb = points[(i              )            ] )
	let( vc = points[(i+1            )%len(points)] )
	let( aab = tgx11__line_angle(va, vb)-90 )
	let( abc = tgx11__line_angle(vb, vc)-90 )
	// TODO: Don't assume left turn
	let( abc_fixed = abc > aab ? abc : abc+360 )
	assert(abc_fixed > aab)
	["tgx11-qathseg", points[i], aab, abc_fixed, radius]
];

//// 

function tgx11__gnerate_beveled_rect_data(bevels=[true,true,true,true]) =
let(z41 = sqrt(2)-1) [
	each bevels[0] ? [
		[[ 1, 1], [ 0,-1], [   1,  z41]],
		[[ 1, 1], [-1, 0], [ z41,    1]],
	] : [
		[[ 1, 1], [ 0, 0], [   1,    1]],
	],
	each bevels[1] ? [
		[[-1, 1], [ 1, 0], [-z41,    1]],
		[[-1, 1], [ 0,-1], [-  1,  z41]],
	] : [
		[[-1, 1], [ 0, 0], [-  1,    1]],
	],
	each bevels[2] ? [
		[[-1,-1], [ 0, 1], [-  1, -z41]],
		[[-1,-1], [ 1, 0], [-z41, -  1]],
	] : [
		[[-1,-1], [ 0, 0], [-  1, -  1]],
	],
	each bevels[3] ? [
		[[ 1,-1], [-1, 0], [ z41, -  1]],
		[[ 1,-1], [ 0, 1], [   1, -z41]],
	] : [
		[[ 1,-1], [ 0, 0], [   1, -  1]],
	]
];


function tgx11_beveled_rect_zath(size, bevel_size, bevels=[true,true,true,true]) =
assert(is_list(size))
assert(is_num(size[0]))
assert(is_num(size[1]))
assert(is_num(bevel_size))
let( data = tgx11__gnerate_beveled_rect_data(bevels) )
[
	"tgx11-zath",
	
	for( d=data ) [
		[
			d[0][0]*size[0]/2 + d[1][0] * bevel_size,
			d[0][1]*size[1]/2 + d[1][1] * bevel_size
		],
		d[2]
	]
];

function tgx11_qath_to_polygon(qath,offset=0) = togmod1_make_polygon(tgx11_qath_points(qath,offset=offset));

//// TOGridPile-specific stuff

//// Low-level operations requiring explicit offset and gender
//// (but still reading from $togridlib3_unit_table)

// Height of the straight part at the bottom of blocks,
// or thickness of 'column-only' plates/lips:
function tgx11__bare_column_height() =
	togridlib3_decode([1, "tgp-standard-bevel"]) - 
	togridlib3_decode([1, "tgp-column-inset"]);

/**
 * Returns radius for corners for the given gender
 * at the given offset from the 'ideal' chunk hull
 */
function tgx11__corner_radius(offset, gender) =
	assert(is_num(offset))
	assert(is_string(gender))
	max(
		togridlib3_decode([1, "tgp-min-corner-radius"]),
		
		gender == "m" ? togridlib3_decode([1, "tgp-m-outer-corner-radius"]) :
		gender == "f" ? togridlib3_decode([1, "tgp-f-outer-corner-radius"]) :
		assert(false, str("Unknown gender for corner radius purposes: '", gender, "'"))
	);

function tgx11_chunk_xs_zath(size, bevels=[true,true,true,true]) =
	tgx11_beveled_rect_zath(size, bevel_size=togridlib3_decode([1,"tgp-standard-bevel"]), bevels=bevels);

function tgx11_chunk_xs_qath(size, offset=0, gender="m") = tgx11_zath_to_qath(
	tgx11_chunk_xs_zath(size),
	offset = offset,
	radius = tgx11__corner_radius(offset=offset, gender=gender)
);

function tgx11_chunk_xs_half_qath(size, offset=0, gender="m") = tgx11_zath_to_qath(
	tgx11_chunk_xs_zath(size, bevels=[false,true,true,false]),
	offset = offset,
	radius = tgx11__corner_radius(offset=offset, gender=gender),
	closed=false
);

/**
 * 'chunk cross-section points'
 *
 * Returns points for a rounded, beveled rectangle
 * of the standard bevel size and radius, given
 * the specified offset.
 */
function tgx11_chunk_xs_points(size, gender="m", offset=0) =
	assert( is_list(size) && is_num(size[0]) && is_num(size[1]) )
	tgx11_qath_points(tgx11_chunk_xs_qath(size, gender=gender, offset=offset));

// v6 atom foot cross-section
function tgx11_v6c_polygon(atom_size, gender="m", offset=0) = // tgx11_qath_to_polygon(tgx11_atom_foot_qath(atom_size, gender=gender, offset=offset));
	let( column_inset = togridlib3_decode([1,"tgp-column-inset"]) )
	togmod1_make_polygon(tgx11_chunk_xs_points(atom_size, gender=gender, offset=offset-column_inset));

// v6 atom foot, but right side is flat instead of beveled and rounded
function tgx11_v6c_flatright_polygon(atom_size, gender="m", offset=0) =
	let( column_inset = togridlib3_decode([1,"tgp-column-inset"]) )
	let( offset = offset-column_inset )
	togmod1_make_polygon([
		[atom_size[0]/2+offset,  atom_size[1]/2+offset],
		each tgx11_qath_points(tgx11_chunk_xs_half_qath(atom_size, gender=gender, offset=offset)),
		[atom_size[0]/2+offset, -atom_size[1]/2-offset],
	]);

//// Higher-level TOGridPile shapes; offset, gender passed implicitly
// Maybe I should differentiate by making these tgx12, tgx13 ha ha lmao

$tgx11_offset = 0;
$tgx11_gender = "m";

/**
 * Generate a polyhedron with TOGridPile rounded beveled rectangle cross-sections
 * for each [z, offset] in layer_keys.
 */
function tgx11__chunk_footlike(layer_keys, size) =
	assert( is_list(size) && is_num(size[0]) && is_num(size[1]) )
	let( u = togridlib3_decode([1,"u"]) )
	tphl1_make_polyhedron_from_layer_function(layer_keys, function(zo)
		let( z=u*zo[0] )
		[for (p=tgx11_chunk_xs_points(size, gender=$tgx11_gender, offset=$tgx11_offset+u*zo[1])) [p[0], p[1], z]]
	);

function tgx11_chunk_foot(size) =
	let( u = togridlib3_decode([1,"u"]) )
	let( z41 = sqrt(2) - 1 )
	tgx11__chunk_footlike([
		[0-offset    , -2],
		[4-offset-z41,  2],
		[   size[2]/u,  2]
	], size=size);

function tgx11_chunk_unifoot(size) =
	let( u = togridlib3_decode([1,"u"]) )
	let( z41 = sqrt(2) - 1 )
	tgx11__chunk_footlike([
		[0-offset    , -1],
		[1-offset*z41, -1],
		[4-offset*z41,  2],
		[   size[2]/u,  2]
	], size=size);

//// Demo

use <../lib/TOGMod1.scad>
use <../lib/TOGridLib3.scad>

function test_plate(size) =
	let(u = togridlib3_decode([1,"u"]))
	["linear-extrude-zs", [0, tgx11__bare_column_height()], ["difference",
		tgx11_v6c_polygon(size, gender="m", offset=5+offset),
		tgx11_v6c_polygon(size, gender="f", offset=0-offset),
	]];

function extrude_polypoints(zrange, points) =
	tphl1_make_polyhedron_from_layers([
		for( z=zrange ) [ for(p=points) [p[0],p[1],z] ]
	]);

function tgx11__atomic_block_bottom(block_size_ca) =
let(block_size = togridlib3_decode_vector(block_size_ca))
let(block_size_atoms = togridlib3_decode_vector(block_size_ca, [1, "atom"]))
let(v6hc = ["rotate", [0,0,90], tgx11_v6c_flatright_polygon([12.7,12.7], offset=$tgx11_offset)])
let(xms = [-block_size_atoms[0]/2+0.5:1:block_size_atoms[0]/2])
let(yms = [-block_size_atoms[1]/2+0.5:1:block_size_atoms[1]/2])
let(u = togridlib3_decode([1,"u"]))
let(bevel_size = togridlib3_decode([1,"tgp-standard-bevel"]))
let(atom = togridlib3_decode([1,"atom"]))
let(atom_unifoot = tgx11_chunk_unifoot([atom,atom,block_size[2]]))
["intersection",
	// tgx11_chunk_unifoot(block_size),
	["union",
		for(xm=xms) for(ym=yms) ["translate", [xm*12.7, ym*12.7, 0], atom_unifoot],
		for(xm=xms) ["translate", [xm*atom,0,atom/2], togmod1_linear_extrude_y([-block_size[1]/2+6, block_size[1]/2-6], v6hc)],
		for(ym=yms) ["translate", [0,ym*atom,atom/2], togmod1_linear_extrude_x([-block_size[0]/2+6, block_size[0]/2-6], v6hc)],
		//["translate", [0,0,2*$tgx11_u+0.1], tgx11_chunk_foot([block_size[0]-0.2, block_size[1]-0.2, block_size[2]-2*$tgx11_u-0.2])]
		["translate", [0,0,bevel_size+block_size[2]/2], togmod1_make_cuboid([block_size[0]-12, block_size[1]-12, block_size[2]])]
	]
];

function tgx11_block(block_size_ca) =
let(block_size = togridlib3_decode_vector(block_size_ca))
let(block_size_atoms = togridlib3_decode_vector(block_size_ca, [1, "atom"]))
// This is an 'atomic' chunk foot
["intersection",
	extrude_polypoints([-1,block_size[2]], tgx11_chunk_xs_points(
		size = block_size
	)),
	tgx11__atomic_block_bottom(block_size_ca)
];

$togridlib3_unit_table = [
	// The defaults in TOGridLib3 were chosen for v8-style things;
	// for our v6-inspired designs with beveled corners,
	// and also 'tgp-' -prefix them while we're at it.
	["tgp-m-outer-corner-radius", [2, "u"]],
	["tgp-f-outer-corner-radius", [1, "u"]],
	["tgp-column-inset", [1, "u"]],
	["tgp-min-corner-radius", [1, "u"]],
	each togridlib3_get_default_unit_table()
];

module tgmain() {
	block_size_ca = [
		[block_size_chunks[0], "chunk"],
		[block_size_chunks[1], "chunk"],
		[block_height_u, "u"],
	];
	block_size = togridlib3_decode_vector(block_size_ca);
	u = togridlib3_decode([1,"u"]);
	
	foot_column_demo = ["union",
		["linear-extrude-zs", [0,tgx11__bare_column_height()], tgx11_v6c_polygon(block_size, gender="m", offset=$tgx11_offset)],
	];
	
	demo_concave_qath = ["tgx11-qath",
		["tgx11-qathseg", [-5, 5],   90,  270,  5],
		["tgx11-qathseg", [ 5,-5],   90,    0,  5],
		["tgx11-qathseg", [15,-5], -180,    0,  5],
		["tgx11-qathseg", [10, 0],    0,   90, 10],
	];

	what = ["union",
		item == "block" ? tgx11_block(block_size_ca) :
		item == "v6hc-xc" ? tgx11_v6c_flatright_polygon([12.7,12.7]) :
		item == "foot-column" ? foot_column_demo :
		item == "concave-qath-demo" ? tgx11_qath_to_polygon(demo_concave_qath, offset=offset) :
		assert(false, str("Unrecognized item: '", item, "'"))
	];
	
	togmod1_domodule(what);
	
	if( $preview ) togmod1_domodule(["x-debug", test_plate(block_size)]);
}

tgmain($tgx11_offset=offset);