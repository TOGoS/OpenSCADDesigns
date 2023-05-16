// GridfinityPillBottleCover-v2.0
// Changes
// v2.0:
// - Change interior cutout to a cylinder instead of rounded square
//   that left only very thin, flimsy walls

include <../lib/TOGGridfinityLib-v1.scad>

$fn = 128;

module rounded_square(size, corner_radius, offset=0) {
	hull() for( ym=[-1,1] ) for( xm=[-1,1] ) {
		translate([
			xm*(size[0]/2-corner_radius),
			ym*(size[1]/2-corner_radius),
		]) circle(r=corner_radius+offset);
	}
}

module xy_rounded_cube(size, corner_radius, offset=0) {
	linear_extrude(size[2]+offset*2, center=true) rounded_square(size, corner_radius, offset=offset);
}

difference() {
	union() {
		translate([0,0,42]) scale([1,1,-1]) tog_gridfinity_block_bottom(21);
		tog_gridfinity_block_bottom(21);
	}
	translate([0,0,7+42/2]) {
		cylinder(d=40, h=42, center=true);
		// xy_rounded_cube([40,40,42], 3);
	}
}
