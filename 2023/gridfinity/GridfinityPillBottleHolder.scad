$fn = 20;
block_height = 42;
hole_diameter = 33;
floor_height = 7;

include <../lib/TOGGridfinityLib-v1.scad>

difference() {
	tog_gridfinity_block_with_lip(block_height, block_height, 42, 4);
	translate([0, 0, block_height]) cylinder(d=hole_diameter, h=(block_height-floor_height)*2, center=true);
}
