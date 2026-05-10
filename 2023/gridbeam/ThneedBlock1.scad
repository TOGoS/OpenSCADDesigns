// ThneedBlock1.0
// 
// A block with lots of holes for whatever.
// 
// You probably want to print this upside-down.

width = "2chunk";
depth = "2chunk";
height = "2chunk";

// Want the back of the block to wrap around a gridbeam or unistrut or something?
back_slot_width = "1+21/32inch";
back_slot_depth = "1/8inch";
$fn = 32;

// TODO: Make holes more customizable, probably!

module __block1__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGUnits1.scad>

size = [width, depth, height];

chunk_mm = 38.1;
inch_mm = 25.4;

size_mm = togunits1_decode_vec(size, unit="mm");
size_chunks = togunits1_decode_vec(size, unit="chunk", xf="round");
back_slot_width_mm = togunits1_to_mm(back_slot_width);
back_slot_depth_mm = togunits1_to_mm(back_slot_depth);

regular_z_hole_cb_diameter_mm = inch_mm * 7/8;
regular_z_hole_diameter_mm = inch_mm * 5/16;

togmod1_domodule(
	let( xyzmax = max(size_mm[0], size_mm[1], size_mm[2]) )
	let( countersunk_z_hole = tphl1_make_z_cylinder(zds=[
		[-xyzmax, 13],
		[   -5/4, 13],
		[    5/4,  8],
		[ xyzmax,  8],
	]))
	let( y_hole = ["translate", [0,size_mm[1]/2 - 8,0], ["rotate", [-90,0,0], countersunk_z_hole]] )
	let( regular_z_hole = tphl1_make_z_cylinder(zds=[
		[-size_mm[2]      , regular_z_hole_cb_diameter_mm],
		[ size_mm[2]/2 - 8, regular_z_hole_cb_diameter_mm],
		[ size_mm[2]/2 - 8, regular_z_hole_diameter_mm   ],
		[ size_mm[2]      , regular_z_hole_diameter_mm   ],
	]))
	["difference",
		// TODO: Make it TOGridPile lol?
		tphl1_make_rounded_cuboid(size_mm, r=[5,5,3.175], corner_shape="cone2"),
		
		if( back_slot_depth_mm > 0 && back_slot_width_mm > 0 )
		["translate", [0,size_mm[1]/2,0], togmod1_make_cuboid([back_slot_width_mm, back_slot_depth_mm*2, size_mm[2]*2])],
		
		for( xm=[-size_chunks[0]/2+0.5 : 0.5 : size_chunks[0]/2-0.5] )
		for( zm=[-size_chunks[2]/2+0.5 : 0.5 : size_chunks[2]/2-0.5] )
		["translate", [xm*chunk_mm, 0, zm*chunk_mm], y_hole],
		
		tphl1_make_z_cylinder(zds=[
			[-xyzmax                   , inch_mm*7/8],
			[ size_mm[2]/2-chunk_mm*3/4, inch_mm*7/8],
			[ size_mm[2]/2-chunk_mm*3/4, inch_mm*1/2],
			[ xyzmax                   , inch_mm*1/2],
		]),
		
		for( xm=[-size_chunks[0]/2+0.5 : 1 : size_chunks[0]/2-0.5] )
		for( ym=[-size_chunks[1]/2+0.5 : 1 : size_chunks[1]/2-0.5] )
		["translate", [xm*chunk_mm, ym*chunk_mm, 0], regular_z_hole],
	]
);
