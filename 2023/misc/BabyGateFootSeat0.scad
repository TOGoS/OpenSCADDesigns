// BabyGateFootSeat0.3
// 
// Block to be screwed to the wall to hold baby gate feet
// so that it doesn't slide down when Marilla stands on it,
// preventing the cats from being able to get through.
// 
// Changes:
// v0.2:
// - length is configurable
// v0.3:
// - length, width, and slot length are all configurable in one-atom increments

floor_height = 3.175;
total_height = 19.05;
cutout_diameter = 35;
width_atoms = 3; // [2 : 1 : 6]
length_atoms = 3; // [2 : 1 : 12]
cutout_length_atoms = 0;
$tgx11_offset = -0.1;

module __babygatefoorseat__end_params() { }

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGridLib3.scad>
use <../lib/TGx11.1Lib.scad>

$fn = 48;
$togridlib3_unit_table = tgx11_get_default_unit_table();

bottom_segmentation = width_atoms == 3 && length_atoms == 3 ? "chatom" : "block";
length = togridlib3_decode([length_atoms, "atom"]);

cutout_polyline_length = togridlib3_decode([cutout_length_atoms, "atom"]);
cutout_polyline_points =
	cutout_polyline_length == 0 ? [[0,0]] :
	[
		[-cutout_polyline_length/2, 0],
		[+cutout_polyline_length/2, 0],
	];

cutout_rath = togpath1_polyline_to_rath(cutout_polyline_points, cutout_diameter/2);
cutout_polygon = togmod1_make_polygon(togpath1_rath_to_polypoints(cutout_rath));

togmod1_domodule(["difference",
	//togmod1_linear_extrude_z([0, total_height], togmod1_make_rounded_beveled_rect([38.1,38.1], 3.175, 3.175)),
	tgx11_block([[length_atoms, "atom"], [width_atoms, "atom"], [total_height, "mm"]], bottom_segmentation=bottom_segmentation, top_segmentation="block"),
	
	togmod1_linear_extrude_z([floor_height, total_height+1], cutout_polygon),
	for( xm=[-cutout_length_atoms/2 : 1.5 : cutout_length_atoms/2] )
		["translate", [togridlib3_decode([xm,"atom"]),0,floor_height], tog_holelib2_hole("THL-1001")],
]);
