// p1844 v1.0
// 
// v1.0:
// - Copy TGx11.1.19
// - Add magnet holes

block_size_chunks = [2,2];
block_height_u = 12;

module __p1844_end_params() { }

bottom_segmentation = "chatom"; // ["atom","chatom","chunk","block","none"]
top_segmentation = "block"; // ["atom","chatom","chunk","block","none"]
atom_hole_style = "none"; // ["none","straight-5mm","THL-1001-bottom","deep-THL-1001-bottom"]
bottom_shape = "footed"; // ["footed","beveled"]
bottom_foot_bevel = 0.0; // 0.1
bottom_v6hc_style = "v6.1"; // ["v6.1", "none"]

lip_height = 2.54;

// 'shell-xs' makes a cross section of the 'shell' between the ideal shape and the offset one
mode = "normal"; // ["normal", "shell-xs"]
shell_xs_angle = 0;
shell_xs_offset = 10;

offset = -0.1; // 0.1

/* [Bottom] */

bottom_magnet_hole_diameter = 6.3;
bottom_magnet_hole_depth    = 2.4;

/* [Cavity] */

cavity_type = "basic"; // ["none", "basic"]

/* [Preview Options] */

include_test_plate = false;
include_unoffset_ghost = false;
preview_fn = 12;

/* [Render] */

render_fn = 24;

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGridLib3.scad>
use <../lib/TGx11.1Lib.scad>
use <../lib/TOGHoleLib2.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGVecLib0.scad>

function test_plate(size) =
	let(u = togridlib3_decode([1,"u"]))
	["linear-extrude-zs", [0, tgx11__bare_column_height()], ["difference",
		tgx11_v6c_polygon(size, gender="m", offset=5+offset),
		tgx11_v6c_polygon(size, gender="f", offset=0-offset),
	]];

function bottom_hole_positions(size_chunks) =
let( chunk = togridlib3_decode([1,"chunk"]) )
let(  atom = togridlib3_decode([1,"atom" ]) )
[
	for(yc=[-size_chunks[1]/2+0.5 : 1 : size_chunks[1]/2])
	for(xc=[-size_chunks[0]/2+0.5 : 1 : size_chunks[0]/2])
	for(apos=[[1,-1],[1,0],[1,1],[0,1],[-1,1],[-1,0],[-1,-1],[0,-1]])
	[xc*chunk + apos[0]*atom, yc*chunk + apos[1]*atom]
];

function bottom_holes(size_chunks) =
	let( bottom_hole = tphl1_make_z_cylinder(d=bottom_magnet_hole_diameter, zrange=[-1, bottom_magnet_hole_depth]) )
	["union",
		for( pos = bottom_hole_positions(size_chunks) )
			["translate", pos, bottom_hole]
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
		if( atom_hole_style == "straight-5mm" ) tphl1_make_z_cylinder(d=5, zrange=[-20, block_size[2]+20]),
		if( atom_hole_style == "THL-1001-bottom" ) ["rotate", [180,0,0], tog_holelib2_hole("THL-1001", depth=block_size[2]+20)],
		if( atom_hole_style == "deep-THL-1001-bottom" ) ["rotate", [180,0,0], tog_holelib2_hole("THL-1001", depth=block_size[2]+20, inset=3)],
	];

	function blok1() = tgx11_block(
		block_size_ca,
		bottom_segmentation = bottom_segmentation,
		bottom_shape        = bottom_shape,
		bottom_foot_bevel   = bottom_foot_bevel,
		bottom_v6hc_style   = bottom_v6hc_style,
		top_segmentation = top_segmentation,
		atom_bottom_subtractions = atom_bottom_subtractions,
		lip_height = lip_height,
		$tgx11_gender = "m"
	);
	
	function basic_cavity() =
		let(block_size = togridlib3_decode_vector(block_size_ca))
		let(wall_thickness = u)
		let(bev = togridlib3_decode([1, "tgp-standard-bevel"]))
		tphl1_make_polyhedron_from_layer_function(
			[
				[                4*u, -1*u],
				[                5*u, -0*u],
				// TODO: Adjust based on block height, maybe use cos or something
				[block_size[2] - 7*u, -0*u],
				[block_size[2] - 3*u, -1*u],
				[block_size[2] - 1*u, -2*u],
				[block_size[2] + 2*u, -2*u],
			],
			function(zo) togvec0_offset_points(
				togpath1_rath_to_polypoints(togpath1_make_rectangle_rath(
				   [block_size[0], block_size[1]],
					corner_ops=[["offset", -wall_thickness], ["bevel", bev], ["round", bev], ["offset", zo[1]]]
			   )),
				zo[0]
			)
		);

	function cavity() =
		cavity_type == "none" ? ["union"] :
		cavity_type == "basic" ? basic_cavity() :
		assert(false, str("Unrecognized cavity type: '", cavity_type, "'"));
	
	function blok() = ["difference",
		blok1(),
		cavity(),
		bottom_holes(block_size_chunks)
	];

	what = ["hand+glove",
		blok(),
		test_plate(block_size),
		blok($tgx11_offset=0),
	];
	
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
