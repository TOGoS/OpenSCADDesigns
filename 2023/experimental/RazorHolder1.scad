// RazorHolder1.1
// 
// For holding one of these 3/4" wide razor blades
// by clamping down on it.
// 
// Versions:
// v1.1:
// - Two pieces with matching pocket/protrusion

razor_width = 19.5;
razor_thickness = 0.5;

$fn = 32;

module __razorholder1__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>

thickness_unit = 3.175;
std_round = (sqrt(2)/2+1) * 3.175; // 1.707 * bevel size

baf = 19.05;

function razor_holder(body_thickness, protrusion_height, protrusion_width) =
	let(hole = tphl1_make_z_cylinder(d=5, zrange=[-50,50]))
	let(xp1 = protrusion_width/2)
	let(xz_intersection_2d = togmod1_make_polygon([
		[ 100, 0],
		[ 100, body_thickness],
		[ xp1, body_thickness],
		[ xp1, body_thickness + protrusion_height],
		[-xp1, body_thickness + protrusion_height],
		[-xp1, body_thickness],
		[-100, body_thickness],
		[-100, 0],
	]))
	let( xy_intersection = togmod1_linear_extrude_z([-100, 100],
	   togmod1_make_rounded_rect([3*baf, 2*baf], r=std_round)) )
	let( xz_intersection = togmod1_linear_extrude_y([-100, 100], xz_intersection_2d) )
	["difference",
		["intersection", xy_intersection, xz_intersection],
		
		for( xm=[-1,0,1] ) for( ym=[-0.5, 0.5] ) ["translate", [xm*baf, ym*baf], hole],
	];

togmod1_domodule(["union",
	["translate", [0,-1.5*baf,0], razor_holder(thickness_unit*2, -thickness_unit - razor_thickness/2, razor_width+0.2)],
	["translate", [0, 1.5*baf,0], razor_holder(thickness_unit*1,  thickness_unit - razor_thickness/2, razor_width-0.2)],
]);
