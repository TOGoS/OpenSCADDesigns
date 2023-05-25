
scale = 38.1;
hole_spacing = 12.7;
thickness = 12.7;

$fn = 24;

module 345_block(scale, hole_spacing, hole_size) {
	difference() {
		linear_extrude(thickness, center=true) polygon([
			[0,0],
			[4*scale,0],
			[0,3*scale]
		]);
		for( x=[hole_spacing/2 : hole_spacing : 4*scale-hole_spacing] ) {
			translate([x,0,0]) rotate([90,0,0]) cylinder(h=20, d=hole_size, center=true);
		}
		for( y=[hole_spacing/2 : hole_spacing : 3*scale-hole_spacing] ) {
			translate([0,y,0]) rotate([0,90,0]) cylinder(h=20, d=hole_size, center=true);
		}
		translate([0,3*scale,0]) rotate([0,0,-asin(3/5)]) {
			for( x=[hole_spacing*3/2 : hole_spacing : 5*scale-hole_spacing] ) {
				translate([x,0,0]) rotate([90,0,0]) cylinder(h=20, d=hole_size, center=true);
			}
		}
	}
}
345_block(scale, hole_spacing, 5);
