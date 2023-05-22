// SDCardHolder-v1.0

$fn = 12;

inch = 25.4;

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


module sd_card_cav() {
	cube([26, 2.25, 48], center=true);
}

difference() {
	translate([0,0,3/8*inch]) xy_rounded_cube([2*inch, 1/2*inch, 3/4*inch], 3/32*inch);
	translate([0,0,3/4*inch + 8]) sd_card_cav();
	for( xi=[-0.75, 0.75] ) {
		translate([xi*inch, 0, 3/8*inch]) rotate([90,0,0]) cylinder(d=6, h=50, center=true);
	}
}
