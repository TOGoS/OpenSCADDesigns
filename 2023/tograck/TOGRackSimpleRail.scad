// TOGRackSimpleRail

length_inches = 12;
width = 12.7;
height = 19.05;
hole_diameter = 5;
$fn = 48;

module __end_params() { }

inch = 25.4;
length = length_inches * inch;

difference() {
	translate([0,0,height/2]) cube([length, width, height], center=true);
	for( xi=[-length_inches/2+0.25 : 0.5 : length_inches/2-0.25] ) {
		translate([xi*inch, 0, height/2]) cylinder(d=hole_diameter, h=height*2, center=true);
	}
}
