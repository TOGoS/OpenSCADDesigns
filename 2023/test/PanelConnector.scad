// PanelConnector-v1.1
//
// Changes:
// v1.1:
// - Adjust height of teeth such that they are lower near the center and higher at the edges

inch = 25.4;

connector_length = 3*inch;
connector_width  = 1*inch;
connector_thickness = 3/16*inch;
zig_height       = 1/8*inch;
zig_slope        = 1/32;
bolt_hole_diameter = 7/16*inch; // should accommodate a 3/8" bolt

preview_fn = 12;
render_fn  = 36;

include <../lib/TOGShapeLib-v1.scad>

$fn = $preview ? preview_fn : render_fn;

intersection() {
	union() {
		for( xm=[-1, 1] )
		for( x=[-connector_length/2+zig_height/2 : zig_height : connector_length/2] ) {
			translate([x*xm,0,connector_thickness - (connector_length/2 - abs(x))*zig_slope]) rotate([0,45,0]) cube([zig_height/sqrt(2), connector_width*2, zig_height/sqrt(2)], center=true);
		}

		translate([0,0,connector_thickness/2]) cube([connector_length*2, connector_width*2, connector_thickness], center=true);
	}

	linear_extrude(connector_thickness*2) difference() {
		tog_shapelib_rounded_square([connector_length, connector_width], 1/4*inch);
		
		circle(d=bolt_hole_diameter);
	}
}
