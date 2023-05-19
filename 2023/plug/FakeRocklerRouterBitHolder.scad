// v1.2:
// - Configurable sizes, yo
// v1.3:
// - Fix some calculations that I had b0rked up lmao
// v1.4:
// - Fix that small and large offsets were swapped oops

inch = 25.4;

rib_thickness = 1/8*inch;
rib_protrusion = 0.25;

small_id_offset = 0.25; // 0.01
large_id_offset = 0.25; // 0.01
od_offset       = 0.00; // 0.01

$fn = 48;

difference() {
	union() {
		shaft_d   = 5/8*inch + od_offset;
		tapered_d = 4/8*inch + od_offset;
		shaft_length = 3/4*inch;
		taper_length = 1/4*inch;
		flange_d = 7/8*inch;
		flange_thickness = 1/8*inch;
		rib_d2 = 5/8*inch+rib_protrusion*2 + od_offset;
		// Main shaft
		cylinder(d=shaft_d, h=flange_thickness+shaft_length-taper_length);
		// Taper
		translate([0,0,flange_thickness+shaft_length-taper_length]) cylinder(d1=shaft_d, d2=tapered_d, h=taper_length);
		cylinder(d=flange_d, h=flange_thickness);
		for( i=[0:1:floor((shaft_length-taper_length)/rib_thickness)] ) {
			translate([0,0,flange_thickness+rib_thickness*i])
				cylinder(d1=shaft_d, d2=rib_d2, h=rib_thickness/2);
			translate([0,0,flange_thickness+rib_thickness*(i+0.5)])
				cylinder(d2=shaft_d, d1=rib_d2, h=rib_thickness/2);
		}
	}
	//cylinder(d=1/2*inch, h=7/8*inch, center=true);
	intersection() {
		cylinder(d=1/2*inch + large_id_offset, h=100, center=true);
		// 'Overhang remedy'
		union() {
			cube([100,100,7/8*inch], center=true);
			cube([1/4*inch,100,7/8*inch+2], center=true);
		}
	}
	cylinder(d=1/4*inch + small_id_offset, h=100, center=true);
}
