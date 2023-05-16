// TOGRackSteppedRail

length_inches = 12;
hole_diameter = 5;
$fn = 48;

module __end_params() { }

inch = 25.4;

difference() {
	union() {
		translate([0,0,1/4*inch]) cube([12*inch, 3/4*inch, 1/2*inch], center=true);
		translate([0,0,1/2*inch]) cube([12*inch, 1/2*inch, 1*inch], center=true);
	}
	for( z=[1/4*inch, 3/4*inch] ) {
		for( xi=[-length_inches/2+0.25 : 0.5 : length_inches/2-0.25] ) {
			translate([xi*inch, 0, z]) rotate([90,0,0]) cylinder(d=hole_diameter, h=1*inch, center=true);
		}
	}
}
