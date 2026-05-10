// ThneedBlock1.1
// 
// A block with lots of holes for whatever.
// 
// You probably want to print this upside-down.
// 
// v1.1:
// - Add `hull_shape` parameter and `triangular-prism` option

hull_shape = "cuboid"; // ["cuboid","triangular-prism"]

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
use <../lib/TOGPath1.scad>

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
	let( bev = inch_mm/8 )
	["difference",
		// TODO: Make it TOGridPile lol?
		hull_shape == "cuboid" ? tphl1_make_rounded_cuboid(size_mm, r=[5,5,bev], corner_shape="cone2") :
		hull_shape == "triangular-prism" ? let( r = bev*1.5 ) ["rotate", [0,90,0], tphl1_make_polyhedron_from_layer_function(
			[
				[-size_mm[0]/2      , -bev],
				[-size_mm[0]/2 + bev,  0  ],
				[ size_mm[0]/2 - bev,  0  ],
				[ size_mm[0]/2      , -bev],
			],
			function(zo) togpath1_rath_to_polypoints(["togpath1-rath",
				["togpath1-rathnode", [-size_mm[1]/2, -size_mm[2]/2], ["round", r], ["offset", zo[1]]],
				["togpath1-rathnode", [ size_mm[1]/2,  size_mm[2]/2], ["round", r], ["offset", zo[1]]],
				["togpath1-rathnode", [-size_mm[1]/2,  size_mm[2]/2], ["round", r], ["offset", zo[1]]],
			]),
			layer_points_transform = "key0-to-z"
		)] :
		assert(false, str("Unrecongized hull shape: '", hull_shape, "'")),
		
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
