// Stopper0.1

outer_diameter = 12.7;
total_height = 25.4;
screw_hole_style = "THL-1008";
screw_hole_top_z = 6.35;
$fn = 48;

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGHoleLib2.scad>

togmod1_domodule(["difference",
	togmod1_linear_extrude_z([0, total_height], togmod1_make_circle(d=outer_diameter)),
	
	["translate", [0,0,screw_hole_top_z], tog_holelib2_hole(screw_hole_style, depth=total_height*2, overhead_bore_height=total_height*2)],
]);
