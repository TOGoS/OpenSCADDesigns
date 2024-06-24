// KeyHolderDowner-v0.1

module __khd18923123fn__end_params() { }

panel_thickness = 3.175;
lip_height = 1.6;

$fn = $preview ? 12 : 48;
$tgx11_offset = -0.1;
inch = 25.4;

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGVecLib0.scad>

// Quarter inches
panel_point_dat = [
	[ 3, -11],
	[ 3, - 3],
/*
	[ 1, - 1],
	[ 1,   1],
	[-1,   1],
	[-1, - 1],
*/

	[ 1,   1],
	[-1,   1],

	[-3, - 3],
	[-3, -11],
];

panel_points = togpath1_rath_to_points(["togpath1-rath",
	for( pd = panel_point_dat ) ["togpath1-rathnode", [pd[0]*6.35, pd[1]*6.35], ["round", (3/16)*inch]],
]);

panel = tphl1_make_polyhedron_from_layer_function([
	0, panel_thickness + lip_height
], function(z) togvec0_offset_points(panel_points, z));

poker = ["intersection", ["translate", [0,0,10.5], togmod1_make_cuboid([10,10,20])], tphl1_make_rounded_cuboid([6.35, 6.35, 38.1], r=3)];

tgp_base_cutout = ["translate", [0,0,lip_height], tphl1_make_rounded_cuboid([(1+3/8)*inch - $tgx11_offset*2, (1+3/8)*inch - $tgx11_offset*2, lip_height*2], r=[3.175, 3.175, 0])];

//thing = ["union", panel, poker];

thole = tog_holelib2_hole("THL-1001", overhead_bore_height = lip_height*2, inset=0.5);
bhole = ["rotate", [180,0,0], tog_holelib2_hole("THL-1001", inset=0.5)];

thing = ["difference",
	panel,
	["translate", [0,0,panel_thickness], thole],
	for( ym=[-2, -8] ) ["translate", [0,ym*6.35,panel_thickness], tgp_base_cutout],
	for( ym=[-2 : -2 : -10] ) ["translate", [0,ym*6.35,0], bhole],

];

togmod1_domodule(thing);
