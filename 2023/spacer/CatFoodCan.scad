// CatFoodCan-v1.2
//
// v1.1:
// - Slightly thinner lip to try to accomodate 9lives can
// - Oops; this also widens the bottom!
// v1.2:
// - Alternate top shapes: lip, beveled, square
// - Decouple bottom_diameter from lip_inner_diameter
// - Slightly decrease lip_inner_diameter down to 83.5
// - Add optional beam cutout

top_shape = "lip"; // ["lip","beveled","square"]

// measured 85.5..86.0
lip_outer_diameter     = 86.0;
// measured 82.5..83.1
lip_inner_diameter     = 83.5;
sublip_inner_diameter  = 78.1;
bottom_diameter        = 82.0;
main_body_diameter     = 84.0;
// lip_height is the height of the lip that will
// overlap with the bottom of the next can.
// Deeper for Frieskies cans, shallower for 9lives cans,
// and the 9lives cans have a raised 'sublip' so
// that the can bottoms don't need to be inset
// to avoid the tab, wheras Friskies cans have an inset bottom.
// 3.0 for Friskies cans, 2.0 for 9lives
lip_height             =  2.0;

// Height of can minus lip; Friskies and 9lives differ, so let's pick a convenient in-between value:
main_body_height       = 38.1; // 0.01

// Thickness of bottom of 'can'; set to >= main_body_height to make solid
floor_thickness = 2;

/* [Beam cutout] */
beam_cutout_enabled    = false;
beam_cutout_width      = 39;
beam_cutout_round      = 1.5;
beam_cutout_floor_thickness = 6.35;

beam_attachment_holes_enabled = true;

module __casdb123489__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGHoleLib2.scad>

$fn = $preview ? 24 : 72;

floor_z = min(floor_thickness, main_body_height);

top_bevel = 1;

// [diam, z]
can_profile = [
	[bottom_diameter         ,          0],
	[bottom_diameter         , lip_height],
	[main_body_diameter      , lip_height + (main_body_diameter-bottom_diameter)],
	each top_shape == "lip" ? [
		[main_body_diameter      , main_body_height - 2 - (lip_outer_diameter - main_body_diameter)],
		[lip_outer_diameter      , main_body_height - 2],
		[lip_outer_diameter      , main_body_height + lip_height],
		[lip_inner_diameter      , main_body_height + lip_height],
		[lip_inner_diameter      , main_body_height],
	] : top_shape == "beveled" ? [
		[main_body_diameter                 , main_body_height - top_bevel],
		[main_body_diameter    - top_bevel*2, main_body_height            ],
		[sublip_inner_diameter + top_bevel*2, main_body_height            ],
		[sublip_inner_diameter              , max(floor_z, main_body_height - top_bevel)],
	] : top_shape == "square" ? [
		[main_body_diameter      , main_body_height],
		[sublip_inner_diameter   , main_body_height],
	] : assert(false, str("Bad top_shape: '", top_shape, "'")),
	[sublip_inner_diameter   , main_body_height],
	[sublip_inner_diameter   , floor_z],
];

can_hull = tphl1_make_polyhedron_from_layer_function(can_profile, function(params) togmod1_circle_points(d=params[0], pos=[0,0,params[1]]));

mounting_hole = tog_holelib2_hole("THL-1002", main_body_height + 2, inset=1);

subtractions = [
	if( beam_cutout_enabled ) ["translate",
		[0,0,beam_cutout_floor_thickness+main_body_height],
		tphl1_make_rounded_cuboid([main_body_diameter*2, beam_cutout_width, main_body_height*2], beam_cutout_round)],
	if(beam_cutout_enabled && beam_attachment_holes_enabled ) each [
		for( xm=[-1 : 1 : 1] ) ["translate", [xm*19.05,0,0], ["rotate", [180,0,0], mounting_hole]]
	]
];

can = ["difference", can_hull, each subtractions];

togmod1_domodule(can);
