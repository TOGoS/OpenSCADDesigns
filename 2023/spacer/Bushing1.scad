// Bushing1.1
// 
// v1.1:
// - Gracefully handle funky cases:
//   - flange_height <= 0
//   - flange_diameter <= barrel_diameter
//   - flange_height >= total_height

inner_diameter  =  6.4;  // 0.01
barrel_diameter =  7.9;  // 0.01
flange_diameter = 19.05; // 0.01
flange_height   =  1.6;  // 0.01
total_height    = 12.7;  // 0.01

$fn = 72;

use <../lib/TOGMod1.scad>
use <../lib/TOGPolyhedronLib1.scad>

mode =
	flange_height <= 0 || flange_diameter <= barrel_diameter ? "barrel" :
	flange_height >= total_height ? "flange" :
	"flange+barrel";

togmod1_domodule(tphl1_make_z_cylinder(zds=[
	[            0,  inner_diameter],
	each (
		mode == "barrel" ? [
			[           0, barrel_diameter],
			[total_height, barrel_diameter],
		] :
		mode == "flange" ? [
			[           0, flange_diameter],
			[total_height, flange_diameter],
		] : [
			[            0, flange_diameter],
			[flange_height, flange_diameter],
			[flange_height, barrel_diameter],
			[ total_height, barrel_diameter],
		]
	),
	[ total_height,  inner_diameter],
	[            0,  inner_diameter],
], cap_bottom=false, cap_top=false));
