// TGx11
//
// Attenot at re-implementation of TGx9 shapes
// using TOGMod1 S-shapes and cleaner APIs with better defaults.

item = "block"; // ["block", "foot-column", "v6hc-xc", "concave-qath-demo","autozath-demo"]
block_size_chunks = [2,2];
block_height_u = 12;

atom_hole_style = "none"; // ["none","straight-5mm","THL-1001-bottom","deep-THL-1001-bottom"]
bottom_shape = "footed"; // ["footed","beveled"]

// 'shell-xs' makes a cross section of the 'shell' between the ideal shape and the offset one
mode = "normal"; // ["normal", "shell-xs"]
shell_xs_angle = 0;
shell_xs_offset = 10;

offset = -0.1; // 0.1

/* [Preview Options] */

include_test_plate = true;
include_unoffset_ghost = true;
preview_fn = 12;

/* [Render] */

render_fn = 24;

module __tgx11_end_params() { }

use <../lib/TOGPath1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>

//// 

function tgx11_ath_to_polygon(thing, offset=0) =
	togmod1_make_polygon(
		thing[0] == "togpath1-qath" ? togpath1_qath_points(thing, offset=offset) :
		thing[0] == "togpath1-zath" ? togpath1_zath_points(thing, offset=offset) :
		assert(false, str("Unrecognized object: ", thing))
	);

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

// TODO: Just use togpath1_points_to_zath!
function tgx11_beveled_rect_zath(size, bevel_size, bevels=[true,true,true,true]) =
assert(is_list(size))
assert(is_num(size[0]))
assert(is_num(size[1]))
assert(is_num(bevel_size))
let( data = tgx11__gnerate_beveled_rect_data(bevels) )
[
	"togpath1-zath",
	
	for( d=data ) [
		[
			d[0][0]*size[0]/2 + d[1][0] * bevel_size,
			d[0][1]*size[1]/2 + d[1][1] * bevel_size
		],
		d[2]
	]
];

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
		
		gender == "m" ? togridlib3_decode([1, "tgp-m-outer-corner-radius"]) + offset :
		gender == "f" ? togridlib3_decode([1, "tgp-f-outer-corner-radius"]) + offset :
		assert(false, str("Unknown gender for corner radius purposes: '", gender, "'"))
	);

function tgx11_chunk_xs_zath(size, bevels=[true,true,true,true]) =
	tgx11_beveled_rect_zath(size, bevel_size=togridlib3_decode([1,"tgp-standard-bevel"]), bevels=bevels);

function tgx11_chunk_xs_qath(size, offset=0, gender="m") = togpath1_zath_to_qath(
	tgx11_chunk_xs_zath(size),
	offset = offset,
	radius = tgx11__corner_radius(offset=offset, gender=gender)
);

function tgx11_chunk_xs_half_qath(size, offset=0, gender="m") = togpath1_zath_to_qath(
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
	togpath1_qath_points(tgx11_chunk_xs_qath(size, gender=gender, offset=offset));

// v6 atom foot cross-section
function tgx11_v6c_polygon(atom_size, gender="m", offset=0) = // tgx11_ath_to_polygon(tgx11_atom_foot_qath(atom_size, gender=gender, offset=offset));
	let( column_inset = togridlib3_decode([1,"tgp-column-inset"]) )
	togmod1_make_polygon(tgx11_chunk_xs_points(atom_size, gender=gender, offset=offset-column_inset));

// v6 atom foot, but right side is flat instead of beveled and rounded
function tgx11_v6c_flatright_polygon(atom_size, gender="m", offset=0) =
	let( column_inset = togridlib3_decode([1,"tgp-column-inset"]) )
	let( offset = offset-column_inset )
	togmod1_make_polygon([
		[atom_size[0]/2+offset,  atom_size[1]/2+offset],
		each togpath1_qath_points(tgx11_chunk_xs_half_qath(atom_size, gender=gender, offset=offset)),
		[atom_size[0]/2+offset, -atom_size[1]/2-offset],
	]);

//// Higher-level TOGridPile shapes; offset, gender passed implicitly
// Maybe I should differentiate by making these tgx12, tgx13 ha ha lmao

// Declare defaults:
$tgx11_offset = 0;
$tgx11_gender = "m";

/**
 * Generate a polyhedron with TOGridPile rounded beveled rectangle cross-sections
 * for each [z, offset] in layer_keys.
 */
function tgx11__chunk_footlike(layer_keys, size) =
	assert( is_list(size) && is_num(size[0]) && is_num(size[1]) )
	tphl1_make_polyhedron_from_layer_function(layer_keys, function(zo)
		[for (p=tgx11_chunk_xs_points(size, gender=$tgx11_gender, offset=zo[1])) [p[0], p[1], zo[0]]]
	);

function tgx11_chunk_foot(size) =
	let( u = togridlib3_decode([1,"u"]) )
	let( offset=$tgx11_offset )
	let( z41 = sqrt(2) - 1 )
	tgx11__chunk_footlike([
		[0*u - offset    , -2*u + offset*z41],
		[4*u - offset*z41,  2*u + offset],
		[size[2]         ,  2*u + offset]
	], size=size);

function tgx11_chunk_unifoot(size) =
	let( u = togridlib3_decode([1,"u"]) )
	let( offset=$tgx11_offset )
	let( z41 = sqrt(2) - 1 )
	tgx11__chunk_footlike([
		[0*u - offset    , -1*u + offset],
		[1*u - offset*z41, -1*u + offset],
		[4*u - offset*z41,  2*u + offset],
		[size[2]         ,  2*u + offset]
	], size=size);

//// Demo

use <../lib/TOGMod1.scad>
use <../lib/TOGridLib3.scad>
use <../lib/TOGHoleLib2.scad>

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

function tgx11_make_cylinder(d, zrange) =
	tphl1_make_polyhedron_from_layer_function([zrange[0],zrange[1]], function(z) togmod1_circle_points(r=d/2, pos=[0,0,z]));

/**
 * 'atomic' foot shape + enough solid stuff above to fully fill the rest of the block and goa bit beyond.
 * Intended to be intersected with a block hull that is no larger than block_size
 */
function tgx11__atomic_block_bottom(block_size_ca, bottom_shape="footed") =
let(block_size = togridlib3_decode_vector(block_size_ca))
let(block_size_atoms = togridlib3_decode_vector(block_size_ca, [1, "atom"]))
let(v6hc = ["rotate", [0,0,90], tgx11_v6c_flatright_polygon([12.7,12.7], offset=$tgx11_offset)])
let(atom_xms = [-block_size_atoms[0]/2+0.5:1:block_size_atoms[0]/2])
let(atom_yms = [-block_size_atoms[1]/2+0.5:1:block_size_atoms[1]/2])
let(u = togridlib3_decode([1,"u"]))
let(bevel_size = togridlib3_decode([1,"tgp-standard-bevel"]))
let(atom = togridlib3_decode([1,"atom"]))
let(atom_foot =
	bottom_shape == "footed" ? tgx11_chunk_unifoot([atom,atom,block_size[2]+3/32]) :
	bottom_shape == "beveled" ? tgx11_chunk_foot([atom,atom,block_size[2]+3/32]) :
	assert(false, str("Unrecognized bottom_shape '", bottom_shape, "' (expected 'footed' or 'beveled')"))
)
let(v6hc_y = togmod1_linear_extrude_y([-block_size[1]/2+6, block_size[1]/2-6], v6hc))
let(v6hc_x = togmod1_linear_extrude_x([-block_size[0]/2+6, block_size[0]/2-6], v6hc))
// tgx11_chunk_unifoot(block_size),
["union",
	// Atom feet
	for(xm=atom_xms) for(ym=atom_yms) ["translate", [xm*atom, ym*atom, 0], atom_foot],
	// Y-axis v6hcs
	for(xm=atom_xms) ["translate", [xm*atom,0,atom/2], v6hc_y],
	// X-axis v6hcs
	for(ym=atom_yms) ["translate", [0,ym*atom,atom/2], v6hc_x],
	// Chunk body
	["translate", [0,0,bevel_size+block_size[2]/2], togmod1_make_cuboid([
		block_size[0]-12, block_size[1]-12,
		block_size[2]+$tgx11_offset*2-bevel_size+1+1/32])]
];

function tgx11_block(block_size_ca, bottom_shape="footed", atom_bottom_subtractions=[]) =
let(block_size = togridlib3_decode_vector(block_size_ca))
let(block_size_atoms = togridlib3_decode_vector(block_size_ca, [1, "atom"]))
let(atom_xms = [-block_size_atoms[0]/2+0.5:1:block_size_atoms[0]/2])
let(atom_yms = [-block_size_atoms[1]/2+0.5:1:block_size_atoms[1]/2])
let(atom = togridlib3_decode([1,"atom"]))
// TODO: Taper top and bottom all cool?
["difference",
	["intersection",
		extrude_polypoints([-1,block_size[2]], tgx11_chunk_xs_points(
			size = block_size,
			offset = $tgx11_offset
		)),
		tgx11__atomic_block_bottom(block_size_ca, bottom_shape=bottom_shape),
	],
	
	if( len(atom_bottom_subtractions) > 0 )
	let( atom_bottom_subtraction = ["union", each atom_bottom_subtractions] )
	for(xm=atom_xms) for(ym=atom_yms) ["translate", [xm*atom, ym*atom, 0], atom_bottom_subtraction],
];

$togridlib3_unit_table = [
	// The defaults in TOGridLib3 were chosen for v8-style things;
	// for our v6-inspired designs with beveled corners,
	// and also 'tgp-' -prefix them while we're at it.
	["tgp-m-outer-corner-radius", [2, "u"]],
	["tgp-f-outer-corner-radius", [1, "u"]],
	["tgp-column-inset", [1, "u"]],
	["tgp-min-corner-radius", [1, "u"]],
	["tgp-standard-bevel", [2, "u"]],
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
	
	function foot_column_demo() = ["union",
		["linear-extrude-zs", [0,tgx11__bare_column_height()], tgx11_v6c_polygon(block_size, gender="m", offset=$tgx11_offset)],
	];
	
	demo_concave_qath = ["togpath1-qath",
		["togpath1-qathseg", [-5, 5],   90,  270,  5],
		["togpath1-qathseg", [ 5,-5],   90,    0,  5],
		["togpath1-qathseg", [15,-5], -180,    0,  5],
		["togpath1-qathseg", [10, 0],    0,   90, 10],
	];

	some_polypoints = [
		[-10,-10],
		[  5,-10],
		[ 10,- 5],
		[ 10, 10],
		[  5, 10],
		[  5,  5],
		[  0, 10],
		[-10, 10],
	];
	
	function polyhagl(plate_size, generator) =
	let(u = togridlib3_decode([1,"u"]))
	["hand+glove",
		["linear-extrude-zs", [0, u], generator($tgx11_offset)],
		["linear-extrude-zs", [0, u], ["difference",
			tgx11_v6c_polygon(plate_size),
			generator(-$tgx11_offset)
		]]
	];
	
	atom_bottom_subtractions = [
		if( atom_hole_style == "straight-5mm" ) tgx11_make_cylinder(d=5, zrange=[-20, block_size[2]+20]),
		if( atom_hole_style == "THL-1001-bottom" ) ["rotate", [180,0,0], tog_holelib2_hole("THL-1001", depth=block_size[2]+20)],
		if( atom_hole_style == "deep-THL-1001-bottom" ) ["rotate", [180,0,0], tog_holelib2_hole("THL-1001", depth=block_size[2]+20, inset=3)],
	];
	
	what =
		item == "block" ? ["hand+glove",
			tgx11_block(block_size_ca, atom_bottom_subtractions=atom_bottom_subtractions, bottom_shape=bottom_shape),
			test_plate(block_size),
			tgx11_block(block_size_ca, atom_bottom_subtractions=atom_bottom_subtractions, bottom_shape=bottom_shape, $tgx11_offset=0),
		] :
		item == "v6hc-xc" ? polyhagl([20,20], function(offset) tgx11_v6c_flatright_polygon([12.7,12.7], offset=offset)) :
		item == "foot-column" ? foot_column_demo() :
		item == "concave-qath-demo" ? polyhagl([60,30], function(offset) tgx11_ath_to_polygon(demo_concave_qath, offset=offset)) :
		item == "autozath-demo" ? polyhagl([30,30], function(offset) tgx11_ath_to_polygon(togpath1_points_to_zath(some_polypoints), offset=offset)) :
		assert(false, str("Unrecognized item: '", item, "'"));
	
	hand  = (what[0] == "hand+glove") ? what[1] : what;
	glove = (what[0] == "hand+glove") ? what[2] : ["union"];
	unoffset_hand = (what[0] == "hand+glove" && len(what) >= 4) ? what[3] : ["union"];
	assert(hand[0] != "hand+glove");

	shell = ["difference", unoffset_hand, hand];
	shell_xs = ["intersection",
	   shell,
		["rotate", [0,0,shell_xs_angle], ["translate", [block_size[0]/2+shell_xs_offset, 0, 0], togmod1_make_cuboid([block_size[0], block_size[1]*2, block_size[2]*2])]]
	];
	
	subject =
		mode == "normal" ? hand :
		mode == "shell-xs" ? shell_xs :
		assert(false, str("Unrecognized mode '", mode, "'"));
	
	togmod1_domodule(subject);
	
	if( $preview && include_test_plate ) togmod1_domodule(["x-debug", glove]);
	if( $preview && include_unoffset_ghost ) togmod1_domodule(["x-debug", unoffset_hand]);
}

tgmain(
	$tgx11_offset=offset,
	$fn = $preview ? preview_fn : render_fn
);
