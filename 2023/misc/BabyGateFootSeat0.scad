// BabyGateFootSeat0.1
// 
// Block to be screwed to the wall to hold baby gate feet
// so that it doesn't slide down when Marilla stands on it,
// preventing the cats from being able to get through.

floor_height = 3.175;
total_height = 19.05;
cutout_diameter = 35;
$tgx11_offset = -0.1;

module __babygatefoorseat__end_params() { }

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TGx11.1Lib.scad>

$fn = 48;
$togridlib3_unit_table = tgx11_get_default_unit_table();

togmod1_domodule(["difference",
	//togmod1_linear_extrude_z([0, total_height], togmod1_make_rounded_beveled_rect([38.1,38.1], 3.175, 3.175)),
	tgx11_block([[1, "chunk"], [1, "chunk"], [total_height, "mm"]], bottom_segmentation="chatom", top_segmentation="block"), 
	
	togmod1_linear_extrude_z([floor_height, total_height+1], togmod1_make_circle(d=cutout_diameter)),
	["translate", [0,0,floor_height], tog_holelib2_hole("THL-1001")],
]);
