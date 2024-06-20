// CounterboreFiller1.1
//
// Changes:
// - v1.1: Make parametrically instead of using a DXF

thickness = 3.175;
bevel_size = 0.5;
hole_style = "THL-1001"; // ["none","THL-1001","THL-1002"]
square_length   = 19.05;
circle_diameter = 21;

// Some approaches to making the rounded square/circle intersection:
// - Use the DXF (v1.0)
// X Minkowski a square/circle intersection
// - Smash the points of a circle-based polygon into a rectangle,
//   smoothed by ~some algorithm~

$fn = $preview ? 24 : 48;

module roundify_2d(rounding_radius) {
	if( rounding_radius <= 0 ) children();
	else minkowski() {
		children();
		circle(r=rounding_radius, $fn=$fn*2);
	}
}

module hull_shape_2d(off=0, rounding_radius=6.35) {
	roundify_2d(rounding_radius) {
		intersection() {
			square([square_length + off*2 - rounding_radius*2, square_length + off*2 - rounding_radius*2], center=true);
			circle(d = circle_diameter + off*2 - rounding_radius*2, $fn=$fn*2);
		}
	}
	//scale(25.4) import("CounterboreFillerOutline1.dxf", $fn = $fn*2);
}

module the_hull() {
	hull() {
		linear_extrude(thickness) hull_shape_2d(off=-bevel_size);
		translate([0,0,bevel_size]) linear_extrude(thickness - bevel_size*2) hull_shape_2d(off=0);
	}
}

use <../lib/TOGMod1.scad>
use <../lib/TOGHoleLib2.scad>

difference() {
	the_hull();
	togmod1_domodule(["translate", [0,0,thickness], tog_holelib2_hole(hole_style, depth=thickness+1, inset=0.5)]);
}
