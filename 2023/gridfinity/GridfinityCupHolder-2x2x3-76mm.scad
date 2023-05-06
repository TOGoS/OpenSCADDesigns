// Gridfinity-2x2x3-76mm-cup_holder-v1.0

$fn = 40;

module rounded_cylinder(h, d, corner_r=0) {
	if( corner_r <= 0 ) {
		cylinder(h, d=d, center=true);
	} else {
		hull() for( zm=[-1,1] ) {
			translate( [0,0,zm*(h/2-corner_r)] ) rotate_extrude() {
				translate([d/2-corner_r,0,0]) circle(r=corner_r);
			}
		}
	}
}

difference() {
	// TODO: Make GridfinityLib capable of making this shape
	// so I don't need to import an stl:
	import("gf2x2x3solid.stl");
	translate([0,0,21]) rounded_cylinder(h=28, d=76, corner_r=3);
}
