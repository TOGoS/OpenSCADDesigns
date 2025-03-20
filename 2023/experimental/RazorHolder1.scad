// RazorHolder1.0
// 
// For holding one of these 3/4" wide razor blades
// by clamping down on it.

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>

main_thickness = 3.175;
pocket_depth = 0.4;
pocket_width = 19.5;
std_round = (sqrt(2)/2+1) * 3.175; // 1.707 * bevel size

$fn = 32;

togmod1_domodule(
	let(baf = 19.05)
	let(hole = tphl1_make_z_cylinder(d=5, zrange=[-50,50]))
	["difference",
		togmod1_linear_extrude_z([0, main_thickness],
		   togmod1_make_rounded_rect([3*baf, 2*baf], r=std_round)),
		togmod1_linear_extrude_z([main_thickness - pocket_depth, main_thickness + pocket_depth],
			togmod1_make_rect([pocket_width, 3*baf])),
		for( xm=[-1,0,1] ) for( ym=[-0.5, 0.5] ) ["translate", [xm*baf, ym*baf], hole],
	]
);
