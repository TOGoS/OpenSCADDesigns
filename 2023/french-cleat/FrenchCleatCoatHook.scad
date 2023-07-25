// FrenchCleatCoatHook-v1.1
// 
// Versions:
// v1.0: 2022-02-19
// - Original two-hooks design
// v1.1:
// - "mold-box" mode!

inch = 25.4;

mode = "hooks"; // ["hooks", "mold-box"]

preview_fn = 16;
render_fn = 48;

$fn = $preview ? preview_fn : render_fn;

3inch_coat_hook_hole_positions = [
	// In 8ths of an inch
	[ 0,-12],
	[-6, -7.5],
	[ 0, -6],
	[ 0,  0],
	[ 0, +6],
	[+6, +7.5],
	[ 0,+12],
];

module 3inch_coat_hook() {
	scale(inch / 8) {
		difference() {
			linear_extrude(6) {
				polygon([
					[+3,-14],[+3,+6],[+8,+1],[+8.5,+1],[+9,+1.5],[+9,+9],[+3,+15],[-2,+15],
					[-3,+14],[-3,-6],[-8,-1],[-8.5,-1],[-9,-1.5],[-9,-9],[-3,-15],[+2,-15]
				]);
			}
			for( hp = 3inch_coat_hook_hole_positions ) {
				translate(hp) cylinder(d=1.5, h=18, $fn=24, center=true);
				translate(hp) translate([0,0,4]) cylinder(d=3, h=18, $fn=24);
			}
		}
	}
}

module two_hooks() {
	translate([-1.38 * inch,0,0]) scale([ 1,1,1]) 3inch_coat_hook();
	
	translate([ 1.38 * inch,0,0]) scale([-1,1,1]) 3inch_coat_hook();
}

use <../lib/TOGShapeLib-v1.scad>

module molding_box() {
	floor_thickness = 1/8*inch;
	wall_thickness = 1.2;
	box_size = [6*inch, 4.5*inch, 1.25*inch];

	difference() {
		linear_extrude(box_size[2]) tog_shapelib_rounded_beveled_square(box_size, 1/8*inch, 1/16*inch);
		
		translate([0, 0, box_size[2]/2 + floor_thickness]) cube([box_size[0]-wall_thickness*2, box_size[1]-wall_thickness*2, box_size[2]], center=true);
	}

	translate([0,0,floor_thickness]) two_hooks();

	translate([0,-1*inch,floor_thickness]) linear_extrude(3/4*inch) difference() {
		tog_shapelib_rounded_beveled_square([1.5*inch, 1.5*inch], 1/8*inch, 1/16*inch);
		circle(d=5/16*inch);
	}
	for( xm=[-1,+1] ) translate([xm*2.4375*inch,1*inch,floor_thickness]) {
		linear_extrude(3/4*inch) difference() {
			tog_shapelib_rounded_beveled_square([3/4*inch, 1.5*inch], 1/8*inch, 1/16*inch);
		
			for( ym=[-1,1] ) translate([0, ym*3/8*inch, 0]) circle(d=1.5/8*inch);
		}
	}
}

if( mode == "hooks" ) {
	two_hooks();
} else {
	molding_box();
}
