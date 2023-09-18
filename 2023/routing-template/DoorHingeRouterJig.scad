// DoorHungeRouterJig-v1.0

// Distance from lip to outer edge of jig (not including lip)
width2 = 35;
lip_height = 3.175;
lip_width  = 3.175;
// 27 = just over 1+1/16"
hinge_width  = 27;
// 89mm = just over 3+1/2"
hinge_height = 89;
// (* (/ 5 8.0) 25.4)
corner_radius = 15.875;
// 9.525 = 3/16"

// 5+1/2" = 139.7mm
panel_height = 139.7;
panel_thickness = 9.525;

screw_hole_distances = [127, 101.6];

$fn = 32;

include <../lib/TOGShapeLib-v1.scad>
include <../lib/TOGHoleLib-v1.scad>

panel_size = [width2 + lip_width, panel_height, panel_thickness];

difference() {
	translate([0,0,(panel_size[2]+lip_height)/2]) linear_extrude(panel_size[2]+lip_height, center=true) {
		difference() {
			tog_shapelib_rounded_square(panel_size, 6.35);

			translate([panel_size[0]/2, 0]) {
				tog_shapelib_rounded_square([hinge_width*2, hinge_height], corner_radius);
			}
		}
	}
	
	translate([-lip_width,0,panel_size[2]+(panel_size[2]+lip_height)/2]) cube([panel_size[0], panel_size[1]+2, panel_size[2]+lip_height], center=true);
	
	for( ym=[-1,1] ) for( shd=screw_hole_distances ) translate([0, shd/2 * ym, 0]) rotate([0, 180, 0]) {
		tog_holelib_hole("THL-1001");
	}
}
