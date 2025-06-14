// UnistrutMountingWasher1.0
// 
// Eh, let's see if it works!

// hole_style = "THL-1008";
hole_style = "straight-5mm";
$fn = 24;

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
// use <../lib/TOGModPolyhedronLib1.scad>
use <../lib/TOGHoleLib2.scad>

flange_thickness = 254/80;
flange_width = 1.25*254/10;
bump_width = 254/21; // Just under 1/2"
bump_thickness = 254/160;

togmod1_domodule(["difference",
	["union",
		togmod1_linear_extrude_z([0, flange_thickness], togmod1_make_rounded_rect([flange_width, flange_width], r=6)),
		togmod1_linear_extrude_z([flange_thickness/2, flange_thickness+bump_thickness], togmod1_make_circle(r=bump_width/2)),
	],
	["rotate", [180,0,0], tog_holelib2_hole(hole_style, depth=flange_thickness+bump_thickness+1)],
]);
