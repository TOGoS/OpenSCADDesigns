// PanelCornerBracket1.1
// 
// Build 'gridbeam' structures with only panels;
// no actual gridbeam required!
// Use these inside corners.
// May require bolts or nuts with small heads.
// 
// v1.1:
// - Round coners using tphl1_make_rounded_cuboid.
//   This is one way to get that done, but maybe not the best way.

thickness = "3/8inch";
$fn = 32;

module __panelcornerbracket1__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGUnits1.scad>

thickness_mm = togunits1_to_mm(thickness);

togmod1_domodule(
	let( size_chunks = [3,3,3] )
	let( ex1 = size_chunks[0]-0.5, ey1 = size_chunks[1]-0.5, ez1 = size_chunks[2]-0.5 )
	let( chunk = 38.1 )
	// TODO: Chop off more of corners
	// TODO: Round corners nicely?
	let( unit_cube = tphl1_make_rounded_cuboid([chunk, chunk, chunk], r=min(3.175, thickness_mm/2), corner_shape="cone2") )
	let( z_hole = tphl1_make_z_cylinder(zrange=[-thickness_mm/2-1, thickness_mm/2+1], d=9) )
	let( x_hole = ["rotate", [0,90,0], z_hole] )
	let( y_hole = ["rotate", [90,0,0], z_hole] )
	["difference",
		["hull",
			["translate", [chunk*0.5, chunk*0.5, chunk*0.5], unit_cube],
			["translate", [chunk*ex1, chunk*0.5, chunk*0.5], unit_cube],
			["translate", [chunk*0.5, chunk*ey1, chunk*0.5], unit_cube],
			["translate", [chunk*0.5, chunk*0.5, chunk*ez1], unit_cube],
		],
		
		["translate", [thickness_mm + 100, thickness_mm + 100, thickness_mm + 100], togmod1_make_cuboid([200,200,200])],
		for( xm=[0.5 : 0.5 : size_chunks[0]-0.5] ) ["translate", [xm*chunk, thickness_mm/2, 0.5*chunk], y_hole],
		for( xm=[0.5 : 0.5 : size_chunks[0]-0.5] ) ["translate", [xm*chunk, 0.5*chunk, thickness_mm/2], z_hole],
		for( ym=[0.5 : 0.5 : size_chunks[1]-0.5] ) ["translate", [thickness_mm/2, ym*chunk, 0.5*chunk], x_hole],
		for( ym=[0.5 : 0.5 : size_chunks[1]-0.5] ) ["translate", [0.5*chunk, ym*chunk, thickness_mm/2], z_hole],
		for( zm=[0.5 : 0.5 : size_chunks[2]-0.5] ) ["translate", [thickness_mm/2, 0.5*chunk, zm*chunk], x_hole],
		for( zm=[0.5 : 0.5 : size_chunks[2]-0.5] ) ["translate", [0.5*chunk, thickness_mm/2, zm*chunk], y_hole],
	]
);
