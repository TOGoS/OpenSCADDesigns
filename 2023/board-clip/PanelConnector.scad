// PanelConnector-v1.2
//
// Changes:
// v1.1:
// - Adjust height of teeth such that they are lower near the center and higher at the edges
// v1.2:
// - Make sizes adjustable

// Bolt hole diameter, in mm; 11 ~= 7/16", 8mm ~= 5/16"
bolt_hole_diameter  = 11;
connector_length    = 76.2;
connector_width     = 25.4;
// Thickness of piece, not including the teeth; 4.7625mm = 3/16"
connector_thickness =  4.7625; // 0.0001

module __oiserfv98h34_end_params() { }

inch = 25.4;

zig_height       = 1/8*inch;
zig_slope        = 1/32;

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
