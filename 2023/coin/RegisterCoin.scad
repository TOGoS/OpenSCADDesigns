// Replacement coins for the Fisher Price toy cash register

diam = 38.4;
wall_thickness = 3.5;
thickness = 11.2;
center_text = "25";

$fn = $preview ? 8 : 144;

use <../lib/TOGMod1.scad>
use <../lib/TOGPolyhedronLib1.scad>

module m_linear_extrude(zrange) {
	translate([0,0,zrange[0]]) linear_extrude(zrange[1]-zrange[0]) children();
}

union() {
	togmod1_domodule(["difference",
		tphl1_make_z_cylinder(d=diam, zrange=[0, thickness]),
		tphl1_make_z_cylinder(d=diam - wall_thickness*2, zrange=[wall_thickness, thickness+1]),
	]);
	
	m_linear_extrude([wall_thickness-1, (thickness+wall_thickness)/2])
		offset(0.5)
		text(center_text, halign="center", valign="center", size=diam/3, $fn=$fn/4);
}
