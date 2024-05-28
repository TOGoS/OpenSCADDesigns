// TGx11
//
// Attenot at re-implementation of TGx9 shapes
// using TOGMod1 S-shapes and cleaner APIs with better defaults.
// 
// TODO: v6gc should be:
// - For the male case: narrower; find out what the equivalent outer bevel
//   of 'v6.0' style is and use that
// - For the female case: have infinitely sharp corners
//   (may need to abolish tgp-min-corner-radius)
// 
// TODO: 'chunk' bottom style
// 
// TODO: 'atomic' bottom style

item = "block"; // ["block", "foot-column", "v6hc-xc", "concave-qath-demo","autozath-demo"]
block_size_chunks = [2,2];
block_height_u = 12;

bottom_segmentation = "atom"; // ["atom","chatom","none"]
top_segmentation = "atom"; // ["atom","chatom","none"]
atom_hole_style = "none"; // ["none","straight-5mm","THL-1001-bottom","deep-THL-1001-bottom"]
bottom_shape = "footed"; // ["footed","beveled"]

lip_height = 2.54;

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

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGridLib3.scad>
use <../lib/TGx11.1Lib.scad>
use <../lib/TOGHoleLib2.scad>

function test_plate(size) =
	let(u = togridlib3_decode([1,"u"]))
	["linear-extrude-zs", [0, tgx11__bare_column_height()], ["difference",
		tgx11_v6c_polygon(size, gender="m", offset=5+offset),
		tgx11_v6c_polygon(size, gender="f", offset=0-offset),
	]];

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
		if( atom_hole_style == "straight-5mm" ) tphl1_make_z_cylinder(d=5, zrange=[-20, block_size[2]+20]),
		if( atom_hole_style == "THL-1001-bottom" ) ["rotate", [180,0,0], tog_holelib2_hole("THL-1001", depth=block_size[2]+20)],
		if( atom_hole_style == "deep-THL-1001-bottom" ) ["rotate", [180,0,0], tog_holelib2_hole("THL-1001", depth=block_size[2]+20, inset=3)],
	];

	function blok() = tgx11_block(
		block_size_ca,
		bottom_segmentation = bottom_segmentation,
		top_segmentation = top_segmentation,
		atom_bottom_subtractions = atom_bottom_subtractions,
		bottom_shape = bottom_shape,
		lip_height = lip_height,
		$tgx11_gender = "m"
	);
	
	what =
		item == "block" ? ["hand+glove",
			blok(),
			test_plate(block_size),
			blok($tgx11_offset=0),
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
	$togridlib3_unit_table = tgx11_get_default_unit_table(),
	$tgx11_offset = offset,
	$fn = $preview ? preview_fn : render_fn
);
