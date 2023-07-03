// 3WaySwitchPlug-v1.1
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

diagonal = 33;

// inset = 2;
flange_thickness = 3.175;
flange_diameter  = 50.8; // 2"
// flange_inner_diameter  = 36;
shaft_length     = 12;
shaft_diameter   = 37; // For a 1.5" hole
shaft_inner_diameter = 35;

hole_length = 31;
hole_width  = 13;

$fn = 48;

module panel_hole() {
	square([hole_length, hole_width], center=true);
}
module shaft_hole() {
	intersection() {
		square([shaft_diameter, 13], center=true);
		circle(d=shaft_inner_diameter);
	}
	
}

total_height = flange_thickness+shaft_length;

difference() {
	union() {
		if(flange_thickness > 0) linear_extrude(flange_thickness) circle(d=flange_diameter);
		translate([0,0,flange_thickness]) linear_extrude(shaft_length) difference() {
			circle(d=shaft_diameter);
			// circle(d=shaft_inner_diameter);
		}
	}
	
	linear_extrude(total_height*3, center=true) panel_hole();
	translate([0,0,flange_thickness]) linear_extrude(total_height) shaft_hole();
}
