// v1.2:
// - Configurable sizes, yo

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
		cylinder(d=shaft_length-taper_length, h=shaft_d);
		translate([0,0,shaft_length-taper_length]) cylinder(d1=shaft_d, d2=tapered_d, h=taper_length);
		cylinder(d=flange_d, h=flange_thickness);
		for( i=[1:1:floor((shaft_length-taper_length)/rib_thickness)] ) {
			translate([0,0,rib_thickness*i])
				cylinder(d1=shaft_d, d2=rib_d2, h=rib_thickness/2);
			translate([0,0,rib_thickness*(i+0.5)])
			cylinder(d2=shaft_d, d1=rib_d2, h=rib_thickness/2);
		}
	}
	//cylinder(d=1/2*inch, h=7/8*inch, center=true);
	intersection() {
		cylinder(d=1/2*inch + small_id_offset, h=100, center=true);
		// 'Overhang remedy'
		union() {
			cube([100,100,7/8*inch], center=true);
			cube([1/4*inch,100,7/8*inch+2], center=true);
		}
	}
	cylinder(d=1/4*inch + large_id_offset, h=100, center=true);
}
