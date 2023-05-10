// MarkerHolder-v1.0
//
// Holder my paint sharpies, which are 7/16" wide according to my caliper

$fn = 16;

width = 38.1;
thickness = 12.7; // 19.05;
outer_margin = 0.25;
marker_diameter = 11.1125;
slot_depth = 3.175;

module __end_params() { }

include <../lib/TOGHoleLib-v1.scad>;

inch = 25.4;

module rounded_square(size, corner_radius, offset=0) {
	hull() for( ym=[-1,1] ) for( xm=[-1,1] ) {
		translate([
			xm*(size[0]/2-corner_radius),
			ym*(size[1]/2-corner_radius),
		]) circle(r=corner_radius+offset);
	}	
}

module marker_slot(depth) {
	translate([0,0,-depth]) rotate([0,90,0]) cylinder(d=7/16*inch+0.5, h=width+2, center=true);
	translate([0,0,0]) cube([width, marker_diameter, depth*2], center=true);
	translate([0,0,0]) rotate([45,0,0]) cube([width, marker_diameter/1.25, 6/16*inch], center=true);
}

module marker_holder_hull() {
	linear_extrude(thickness) {
		rounded_square([1.5*inch-outer_margin*2, 1.5*inch-outer_margin*2], 3/16*inch, -0.1);
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
