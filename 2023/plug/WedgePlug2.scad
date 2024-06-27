// WedgePlug-v2.0
// 
// A different approach to the wedge plug,
// using a THL-1005 hole for a hex nut at the butt end of the thing,
// since this is easier and stronger than horsing with heat-set inserts.
// Though if you wanted, you could still heat-set inserts in there.

/* [Exterior] */

// Length of barrel, not including flange
barrel_length    =  6.4; // 0.1
small_diameter   =  7.0; // 0.1
large_diameter   =  8.0; // 0.1
taper_length     =  2.0; // 0.1
flange_thickness =  6.4; // 0.1
flange_diameter  = 15.9; // 0.1

/* [Hole] */

funnel_depth          = 1.0; // 0.1
funnel_large_diameter = 6.0; // 0.1

/* [Detail] */

$fn = 48;

total_height = flange_thickness+barrel_length;

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>

module wedgeplug2__end_params() { }

hole_diameter         =  3.0;

difference() {
	union() {
		if( flange_thickness > 0 && flange_diameter > 0 ) {
			cylinder(d=flange_diameter, h=flange_thickness, center=false, $fn=6);
		}
		cylinder(d=large_diameter, h=total_height-taper_length);
		translate([0,0,total_height-taper_length]) cylinder(d1=large_diameter, d2=small_diameter, h=taper_length);
	}
	//translate([0,0,barrel_length/2]) cylinder(h=barrel_length*2, d=hole_diameter, center=true);
	if(funnel_depth > 0) {
		translate([0,0,total_height]) cylinder(h=funnel_depth*2, d1=hole_diameter-0.1, d2=funnel_large_diameter+(funnel_large_diameter-hole_diameter), center=true);
		cylinder(h=funnel_depth*2, d2=hole_diameter-0.1, d1=small_diameter, center=true);
	}
	togmod1_domodule(["rotate", [180,0,0], tog_holelib2_hole("THL-1005", depth=barrel_length+flange_thickness+2, inset=flange_thickness-2.5)]);

	//translate([5,0,0]) cube([10,20,40], center=true);
}
