// DoorHungeRouterJig-v1.5
//
// v1.3:
// - Thicker detached lip, hexagonal counterbores for hex nuts
// v1.4:
// - Abolish non-detachable lip
// v1.5:
// - Change defaults to better suit Renee's door frame

mode = "jig"; // ["jig", "detached-lip"]

/* [Jig] */

// Distance from lip to outer edge of jig (not including lip)
width2 = 31;
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
panel_thickness = 12.7;

screw_hole_distances = [127, 101.6];
// Inset from 'outer edge' to the screw holes
screw_hole_inset = 12.07; // 19.05;

/* [Detachable Lip] */

detachable_lip_thickness = 1.5875;

/* [Detail] */

preview_fn = 24;
render_fn = 64;

$fn = $preview ? preview_fn : render_fn;

include <../lib/TOGShapeLib-v1.scad>
include <../lib/TOGHoleLib-v1.scad>

panel_size = [width2 + lip_width, panel_height, panel_thickness];
edge_x = panel_size[0]/2 - lip_width;

module __no_more_params() { }

inch = 25.4;

module hexagon(side_to_side) {
	intersection_for( r=[0, 60, 120] ) rotate([0,0,r]) square([side_to_side*2, side_to_side], center=true);
}

if( mode == "jig" ) difference() {
	translate([0,0,panel_size[2]/2]) linear_extrude(panel_size[2], center=true) {
		difference() {
			tog_shapelib_rounded_square(panel_size, 6.35);

			translate([edge_x+hinge_width, 0]) {
				tog_shapelib_rounded_square([hinge_width*4, hinge_height], corner_radius);
			}
		}
	}
		
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
	linear_extrude(detachable_lip_thickness) {
		tog_shapelib_rounded_beveled_square([1/2*inch, panel_height]);
	}

	for( y=[-panel_height/2 + 1/4*inch : 1/2*inch : panel_height/2] ) {
		translate([0, y, detachable_lip_thickness]) { // tog_holelib_hole("THL-1001");
			cylinder(h=detachable_lip_thickness*3, d=4, center=true);
			if( detachable_lip_thickness >= 6.35 ) linear_extrude(6.35, center=true) hexagon(5/16*inch);
		}
	}
} else {
	assert(false, str("Bad mode: ", mode));
}
