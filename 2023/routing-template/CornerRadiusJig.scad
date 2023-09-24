// CornerRadiusJig-v0.1

lip_height = 6.35; // 0.01
lip_width = 6.35;

preview_fn = 16;
render_fn = 64;

module __end_params_xy120931() {}

inch = 25.4;

body_thickness = 1/8*inch;

arm_length = 6*inch;
arm_width = 1.5*inch;
// 9.525mm = 3/8", 6.35mm = 1/4"
radius = 7.9375;
lip_clearance = radius * 3;

$fn = $preview ? preview_fn : render_fn;

use <../lib/TOGShapeLib-v1.scad>
use <../lib/TOGHoleLib-v1.scad>

difference() {
	linear_extrude(body_thickness) {
		translate([arm_length/2, arm_width/2]) tog_shapelib_rounded_square([arm_length, arm_width], radius);
		translate([arm_width/2, arm_length/2]) tog_shapelib_rounded_square([arm_width, arm_length], radius);
	}
	
	linear_extrude(body_thickness + lip_height) {
		lip_length = arm_length - lip_clearance*2;
		translate([lip_clearance + lip_length/2, -lip_width/2]) square([lip_length, lip_width], center=true);
		translate([-lip_width/2, lip_clearance + lip_length/2]) square([lip_width, arm_length - lip_clearance - radius], center=true);
	}
	
	screw_hole_positions = [for(x = [6.35 : 12.7 : arm_length-3]) for(y = [6.35 : 12.7 : arm_length-3]) [x,y]];
	
	difference() {
		for( pos = screw_hole_positions ) {
			translate(pos) rotate([180,0,0]) tog_holelib_hole("THL-1001");
		}
	}
}
