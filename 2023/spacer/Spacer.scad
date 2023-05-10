// 1/8" = 3.175, 3/16" = 4.7625
thickness = 3.175;
togridpile_compat = false;
gridfinity_compat = false;
corner_radius = 4.7625;
hole_diameter = 5;
center_hole_diameter = 6;
$fn = 16;

include <../lib/TOGHoleLib-v1.scad>;
include <../lib/TOGridPileLib-v1.scad>;
include <../lib/TOGGridfinityLib-v1.scad>;

module spacer_hull(size) {
	tall_size = [size[0], size[1], 100];
	intersection() {
		if(togridpile_compat) translate([0,0,tall_size[2]/2])
			togridpile_hull_of_style("hybrid1", tall_size, offset=-0.1);
		if(gridfinity_compat) tog_gridfinity_block_bottom(tall_size[2]);
		translate([0,0,size[2]/2]) togridpile__xy_rounded_cube(size, corner_radius=corner_radius);
	}
}

difference() {
	spacer_hull([38.1, 38.1, thickness]);
	for( ym=[-1,0,1] ) for( xm=[-1,0,1] ) {
		translate([ym*12.7, xm*12.7, thickness/2]) cylinder(d=hole_diameter, h=thickness*2, center=true); // tog_holelib_hole("THL-1001");
	}
	for( ym=[0] ) for( xm=[0] ) {
		translate([ym*12.7, xm*12.7, thickness/2]) cylinder(d=center_hole_diameter, h=thickness*2, center=true);
	}
}
