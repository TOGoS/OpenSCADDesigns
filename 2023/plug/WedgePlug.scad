// WedgePlug-v1.1
// 
// A plug for inserting into e.g. gridbeam holes,
// into which a threaded insert can be heat-set
// (or not!), so that a smaller screw can be conveniently
// threaded into the hole from the other side.
// 
// An optional 'funnel' (if funnel_depth > 0) at the top
// and bottom can help guide the screw and/or the heat-set
// insert into place.
// 
// Default values are intended for adapting 5/16" holes
// to take #6-32 screws, providing a good amount of length
// without blocking crosswise holes.
// 
// Changes:
// v1.1:
// - Taper just the end instead of the entire length of the plug,
//   since plugs made from v1.0 were kinda weak
// - Length no longer includes the flange thickness
// - Funnel large diameter configurable separately from taper small diameter

/* [Exterior] */

// Length of barrel, not including flange
length           = 15.0; // 0.1
small_diameter   =  6.5; // 0.1
large_diameter   =  8.0; // 0.1
taper_length     =  4.0; // 0.1
flange_thickness =  1.6; // 0.1
flange_diameter  = 12.7; // 0.1

/* [Hole] */

funnel_depth          =  2.0; // 0.1
funnel_large_diameter = 6.0; // 0.1
hole_diameter         =  5.0; // 0.1

/* [Detail] */

$fn = 48;

total_height = flange_thickness+length;

difference() {
	union() {
		if( flange_thickness > 0 && flange_diameter > 0 ) {
			cylinder(d=flange_diameter, h=flange_thickness, center=false);
		}
		cylinder(d=large_diameter, h=total_height-taper_length);
		translate([0,0,total_height-taper_length]) cylinder(d1=large_diameter, d2=small_diameter, h=taper_length);
	}
	translate([0,0,length/2]) cylinder(h=length*2, d=hole_diameter, center=true);
	if(funnel_depth > 0) {
		translate([0,0,total_height]) cylinder(h=funnel_depth*2, d1=hole_diameter-0.1, d2=funnel_large_diameter+(funnel_large_diameter-hole_diameter), center=true);
		cylinder(h=funnel_depth*2, d2=hole_diameter-0.1, d1=small_diameter, center=true);
	}
}
