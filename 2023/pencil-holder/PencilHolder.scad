inch = 25.4;
$fn = 24;

height = 3.75*inch;

module rounded_square(size, corner_radius, offset=0) {
	hull() for( ym=[-1,1] ) for( xm=[-1,1] ) {
		translate([
			xm*(size[0]/2-corner_radius),
			ym*(size[1]/2-corner_radius),
		]) circle(r=corner_radius+offset);
	}
}
module xy_rounded_cube(size, corner_radius) {
	linear_extrude(size[2], center=true) rounded_square(size, corner_radius);
}

difference() {
	translate([0,0,height/2]) xy_rounded_cube([3*inch, 1.5*inch, height], corner_radius=5);
	translate([0,0,height]) xy_rounded_cube([3*inch-4, 1.5*inch-4, height*2-8], corner_radius=3);
	for( zi=[0.75, 3.0] ) {
		translate([0,  0.75*inch, zi*inch]) rotate([90,0,0]) cylinder(d=5, h=5, center=true);
		translate([0, -0.75*inch, zi*inch]) rotate([90,0,0]) cylinder(d=3/8*inch, h=5, center=true);
	}
}

if( $preview ) {
	translate([-0.75*inch, 0, 4]) color("yellow") cylinder(d=5/16*inch, h=7.5*inch);
	translate([    0*inch, 0, 4]) color("yellow") cylinder(d=5/16*inch, h=6*inch);
	translate([ 0*inch, 0, 4]) color("yellow") rotate([0,20,0]) cylinder(d=5/16*inch, h=(5+1/4)*inch);
}