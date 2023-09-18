// DoorHungeRouterJig-v1.2

// Distance from lip to outer edge of jig (not including lip)
width2 = 35;
lip_height = 3.175;
lip_width  = 19.05;
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
// Inset from 'outer edge' to the screw holes
screw_hole_inset = 12.07; // 19.05;

preview_fn = 24;
render_fn = 64;

$fn = $preview ? preview_fn : render_fn;

include <../lib/TOGShapeLib-v1.scad>
include <../lib/TOGHoleLib-v1.scad>

panel_size = [width2 + lip_width, panel_height, panel_thickness];
edge_x = panel_size[0]/2 - lip_width;

mode = "jig"; // ["jig", "detached-lip"]

module __no_more_params() { }

inch = 25.4;

if( mode == "jig" ) difference() {
	translate([0,0,(panel_size[2]+lip_height)/2]) linear_extrude(panel_size[2]+lip_height, center=true) {
		difference() {
			tog_shapelib_rounded_square(panel_size, 6.35);

			translate([edge_x+hinge_width, 0]) {
				tog_shapelib_rounded_square([hinge_width*4, hinge_height], corner_radius);
			}
		}
	}
	
	translate([-lip_width,0,panel_size[2]+(panel_size[2]+lip_height)/2]) cube([panel_size[0], panel_size[1]+2, panel_size[2]+lip_height], center=true);
	
	for( ym=[-1,1] ) for( shd=screw_hole_distances ) translate([edge_x - screw_hole_inset, shd/2 * ym, panel_size[2]]) {
		tog_holelib_hole("THL-1001");
	}
	
	for( ym=[-1,1] ) for( shd=screw_hole_distances ) {
		y = ym * shd/2;
		hull() for( x=[edge_x, panel_size[0]/2 - 0.25*inch] ) {
			translate([x,y,panel_size[2]/2]) cylinder(h=panel_size[2]*3, d=3.5, center=true);
		}
		hull() for( x=[edge_x, panel_size[0]/2 - 0.25*inch] ) {
			translate([x,y,panel_size[2]]) cylinder(h=6.35, d=6.45, center=true);
		}
	}
} else if( mode == "detached-lip" ) difference() {
	thickness = 1/8*inch;
	
	linear_extrude(thickness) difference() {
		tog_shapelib_rounded_beveled_square([1/2*inch, panel_height]);

		/*for( y=[-panel_height/2 + 1/4*inch : 1/2*inch : panel_height/2] ) {
			translate([0, y]) circle(d=5);
			}*/
	}
	
	for( y=[-panel_height/2 + 1/4*inch : 1/2*inch : panel_height/2] ) {
		translate([0, y, thickness]) tog_holelib_hole("THL-1001");
	}
} else {
	assert(false, str("Bad mode: ", mode));
}
