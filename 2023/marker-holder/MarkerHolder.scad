// MarkerHolder-v1.2
//
// Holder my paint sharpies, which are 7/16" wide according to my caliper
// 
// v1.1:
// - Customizable marker diameter and slot width and larger default values
// v1.2:
// - TOGridPile hybrid1 base

$fn = 16;

width = 38.1;
thickness = 12.7; // 19.05;
outer_margin = 0.25;
marker_diameter = 11.5;
slot_width = 11.25;
slot_depth = 3.175;

module __end_params() { }

include <../lib/TOGHoleLib-v1.scad>;
include <../lib/TOGridPileLib-v1.scad>;

inch = 25.4;

module marker_slot(depth) {
	translate([0,0,-depth]) rotate([0,90,0]) cylinder(d=marker_diameter, h=width+2, center=true);
	translate([0,0,0]) cube([width, slot_width, depth*2], center=true);
	translate([0,0,0]) rotate([45,0,0]) cube([width, slot_width/1.25, 6/16*inch], center=true);
}

module marker_holder_hull() {
	intersection() {
		translate([0,0,thickness])
			togridpile_hull_of_style("hybrid1", [1.5*inch, 1.5*inch, thickness*2], offset=-outer_margin);
		cube([1.5*inch, 1.5*inch, thickness*2], center=true);
	}
}

module marker_holder() {
	difference() {
		marker_holder_hull();
		translate([0,-3/8*inch,thickness]) marker_slot(slot_depth);
		translate([0,+3/8*inch,thickness]) marker_slot(slot_depth);
		translate([0,0,5/32*inch]) tog_holelib_hole("THL-1002", thickness, overhead_bore_height=thickness);
	}
}

marker_holder();
