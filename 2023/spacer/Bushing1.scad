// Bushing1.0

inner_diameter  =  6.4;  // 0.01
barrel_diameter =  7.9;  // 0.01
flange_diameter = 19.05; // 0.01
flange_height   =  1.6;  // 0.01
total_height    = 12.7;  // 0.01

$fn = 72;

use <../lib/TOGMod1.scad>
use <../lib/TOGPolyhedronLib1.scad>

togmod1_domodule(tphl1_make_z_cylinder(zds=[
	[            0,  inner_diameter],
	[            0, flange_diameter],
	[flange_height, flange_diameter],
	[flange_height, barrel_diameter],
	[ total_height, barrel_diameter],
	[ total_height,  inner_diameter],
	[            0,  inner_diameter],
], cap_bottom=false, cap_top=false));
