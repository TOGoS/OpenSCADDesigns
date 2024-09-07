// PanelConnector-v1.5
//
// Changes:
// v1.1:
// - Adjust height of teeth such that they are lower near the center and higher at the edges
// v1.2:
// - Make sizes adjustable
// v1.3:
// - Option for FUN TEXT on the bottom
// v1.4:
// - barrel_offset
// v1.5:
// - bolt_hole_spacing

// Bolt hole diameter, in mm; 11 ~= 7/16", 8mm ~= 5/16"
bolt_hole_diameter  = 11;

// If non-zero, bolt holes will be repeated along the length
bolt_hole_spacing   = 0; // 0.01

connector_length    = 76.2;
connector_width     = 25.4;
// Thickness of piece, not including the teeth; 4.7625mm = 3/16"
connector_thickness =  4.7625; // 0.0001

barrel_offset    =  0;
barrel_height       =  0; //3.175;
barrel_diameter     = 19.05;

bottom_text         = "Not for      babies";

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

		if( barrel_height > 0 ) translate([barrel_offset, 0, 0]) cylinder(d=barrel_diameter, h=connector_thickness+barrel_height, center=false);
	}

	difference() {
		linear_extrude((connector_thickness+barrel_height)*2) difference() {
			tog_shapelib_rounded_square([connector_length, connector_width], 1/4*inch);

			// This might be less than ideal.
			// Holes will be 'wrong' if there's an offset!
			// Maybe better to always put a hole at barrel_offset,
			// and just move outward towards the edges
			holecount = bolt_hole_spacing == 0 ? 1 : round((connector_length-bolt_hole_diameter*2)/bolt_hole_spacing);
			for( xm=[-holecount/2 + 0.5 : 1 : holecount/2-0.5] )
				translate([barrel_offset + xm*bolt_hole_spacing, 0, 0]) circle(d=bolt_hole_diameter);
		}

		if( len(bottom_text) > 0 ) linear_extrude(1, center=true) scale([-1,1]) text(bottom_text, halign="center", valign="center", font="Arial", size=7);
	}
}
