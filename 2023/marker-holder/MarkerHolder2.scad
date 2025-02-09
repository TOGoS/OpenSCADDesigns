// MarkerHolder2.1
// 
// Changelog:
// v2.1:
// - Fix: Take height_u into account for outer hull
// - Add options for inner_size_u, outer_size_u, and inner_surface_offset

height_u = 48;
floor_thickness_u = 4;
inner_size_u = [12,12];
outer_size_u = [16,16];
inner_surface_offset = 0.0; // 0.1

module __markerholder2__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGHoleLib2.scad>
use <../lib/TGx11.1Lib.scad>

u = 25.4/16;

$fn = $preview ? 24 : 72;

mounting_hole = ["x-debug", ["rotate", [90,0,0],
	// tog_holelib2_countersunk_hole(15*u, 5*u, 0,
	tog_holelib2_hole1002(
		depth=8*u, overhead_bore_d=9*u, overhead_bore_height=outer_size_u[1]*u, inset=0.5
	)
]];

togmod1_domodule(["difference",
	// TODO: intersect with TGX11 chatom bottom?
	["translate", [0,0,height_u/2*u], tphl1_make_rounded_cuboid([outer_size_u[0]*u, outer_size_u[1]*u, height_u*u], [2*u, 2*u, 2*u])],
	["translate", [0,0,height_u*u], tphl1_make_rounded_cuboid([
		inner_size_u[0]*u - inner_surface_offset*2,
		inner_size_u[1]*u - inner_surface_offset*2,
		(height_u-floor_thickness_u)*2*u
	], [1*u, 1*u, 0])],
	for( zm=[12:24:height_u] ) ["translate", [0,inner_size_u[1]/2*u,zm*u], mounting_hole]
]);
