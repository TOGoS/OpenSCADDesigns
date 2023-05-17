// WedgePlug-v1.0
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

hole_diameter    =  5.0; // 0.1
length           = 15.0; // 0.1
small_diameter   =  6.5; // 0.1
large_diameter   =  8.0; // 0.1
flange_thickness =  1.6; // 0.1
flange_diameter  = 12.7; // 0.1
funnel_depth     =  2.0; // 0.1

$fn = 48;

difference() {
	union() {
		if( flange_thickness > 0 && flange_diameter > 0 ) {
			cylinder(d=flange_diameter, h=flange_thickness, center=false);
		}
		cylinder(d1=large_diameter, d2=small_diameter, h=length);
	}
	translate([0,0,length/2]) cylinder(h=length*2, d=hole_diameter, center=true);
	if(funnel_depth > 0) {
		translate([0,0,length]) cylinder(h=funnel_depth*2, d1=hole_diameter-0.1, d2=small_diameter, center=true);
		cylinder(h=funnel_depth*2, d2=hole_diameter-0.1, d1=small_diameter, center=true);
	}
}
