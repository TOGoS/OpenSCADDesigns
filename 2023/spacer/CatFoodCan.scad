// CatFoodCan-v1.1
//
// v1.1:
// - Slightly thinner lip to try to accomodate 9lives can

// measured 85.5..86.0
lip_outer_diameter     = 86.0;
// measured 82.5..83.1
lip_inner_diameter     = 84.0;
sublip_inner_diameter  = 78.1;
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
main_body_height       = 38.1;

floor_thickness = 2;

module __casdb123489__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>

$fn = $preview ? 24 : 72;

bottom_diameter = lip_inner_diameter - 0.5;
floor_z = min(floor_thickness, main_body_height);

// [diam, z]
can_profile = [
	[bottom_diameter         ,          0],
	[bottom_diameter         , lip_height],
	[main_body_diameter      , lip_height + (main_body_diameter-bottom_diameter)],
	[main_body_diameter      , main_body_height - 2 - (lip_outer_diameter - main_body_diameter)],
	[lip_outer_diameter      , main_body_height - 2],
	[lip_outer_diameter      , main_body_height + lip_height],
	[lip_inner_diameter      , main_body_height + lip_height],
	[lip_inner_diameter      , main_body_height],
	[sublip_inner_diameter   , main_body_height],
	[sublip_inner_diameter   , floor_z],
];

can_hull = tphl1_make_polyhedron_from_layer_function(can_profile, function(params) togmod1_circle_points(d=params[0], pos=[0,0,params[1]]));
togmod1_domodule(can_hull);
