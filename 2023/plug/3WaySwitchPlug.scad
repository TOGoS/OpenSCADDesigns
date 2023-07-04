// 3WaySwitchPlug-v1.3.0
// 
// Adapter so that the 3-way (a-b c, a b-c, a b c) switches I bought from DigiKey years ago
// (TODO: link might be nice) can be put into a round hole.
// 
// Dimensions of the switch:
// Flange : 31.7mm x 16.4mm (long dimension is about 1+1/4")
// Shaft  : 30.7mm x 12.0mm (clips maximally squshed by my calipers)
// Shaft extends 18.3mm down, and contacts extend 28.3mm below the bottom of the flange
//
// Changes:
// v1.1:
// - Make hole length/width configurable
// v1.2:
// - Make all dimensions configurable in 0.1mm increments
// v1.3.0:
// - Shaft hole width = hole_width
// - Add 'snap-test' mode

diagonal = 33;

flange_thickness = 3.175;  // 0.1
flange_diameter  = 50.8;   // 0.1
shaft_length     = 12;     // 0.1
shaft_diameter   = 37;     // 0.1
shaft_inner_diameter = 35; // 0.1

hole_length = 31; // 0.1
hole_width  = 13; // 0.1

mode = "full"; // ["full","snap-test"]

$fn = 48;

module panel_hole() {
	square([hole_length, hole_width], center=true);
}
module shaft_hole() {
	intersection() {
		square([shaft_diameter, hole_width], center=true);
		circle(d=shaft_inner_diameter);
	}
	
}

module the_hole() {
	linear_extrude(total_height*3, center=true) panel_hole();
	translate([0,0,flange_thickness]) linear_extrude(total_height) shaft_hole();
}

total_height = flange_thickness+shaft_length;

difference() {
	if( mode == "full" ) union() {
		if(flange_thickness > 0) linear_extrude(flange_thickness) circle(d=flange_diameter);
		translate([0,0,flange_thickness]) linear_extrude(shaft_length) difference() {
			circle(d=shaft_diameter);
			// circle(d=shaft_inner_diameter);
		}
	} else if( mode == "snap-test" ) {
		linear_extrude(flange_thickness) {
			square([shaft_diameter,hole_width+2], center=true);
		}
	}

	the_hole();
}
