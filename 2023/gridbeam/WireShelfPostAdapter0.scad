// WireShelfPostAdapter0.1
// 
// See also: ../misc/BabyPusherClamp0, which is a very similar idea,
// but for a bar that doesn't have notches on it.

$fn = 48;

module __wireshelfpostadapter0__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGpolyhedronLib1.scad>

chunk = 38.1;

block_width_mm   = 50.8;
block_depth_mm   = chunk;
block_height_mm  = chunk;
notch_spacing_mm = 25.4;
pole_hole_d1_mm = 26.7;
pole_hole_d0_mm = 25.1;
gap_width_mm  = 3.175;

notch_height_mm = (pole_hole_d1_mm - pole_hole_d0_mm)/2;

bolt_hole = ["rotate", [90,0,0], tphl1_make_z_cylinder(zds=[
	[-block_depth_mm      , 8 + 8],
	[-block_depth_mm/2 - 2, 8 + 8],
	[-block_depth_mm/2 + 2, 8    ],
	[ block_depth_mm/2 - 2, 8    ],
	[ block_depth_mm/2 + 2, 8 + 8],
	[ block_depth_mm      , 8 + 8],
])];

post_hole = tphl1_make_z_cylinder(zds=[
	[- block_height_mm                      , pole_hole_d1_mm],
	[- block_height_mm/2 - 2                , pole_hole_d1_mm + 8],
	[- block_height_mm/2 + 2                , pole_hole_d1_mm],
	[-notch_spacing_mm/2 - notch_height_mm/2, pole_hole_d1_mm],
	[-notch_spacing_mm/2                    , pole_hole_d0_mm],
	[-notch_spacing_mm/2 + notch_height_mm/2, pole_hole_d1_mm],
	[ notch_spacing_mm/2 - notch_height_mm/2, pole_hole_d1_mm],
	[ notch_spacing_mm/2                    , pole_hole_d0_mm],
	[ notch_spacing_mm/2 + notch_height_mm/2, pole_hole_d1_mm],
	[  block_height_mm/2 - 2                , pole_hole_d1_mm],
	[  block_height_mm/2 + 2                , pole_hole_d1_mm + 8],
	[  block_height_mm                      , pole_hole_d1_mm + 8],
]);

togmod1_domodule(
	["difference",
		tphl1_make_rounded_cuboid(
			[block_width_mm, block_depth_mm, block_height_mm],
			r=[4.8, 4.8, 3.175], corner_shape="cone2"
		),
		
		post_hole,
		
		for( xm=[-1,1] )
		["translate", [xm*chunk/2,0,0], bolt_hole],
		
		togmod1_make_cuboid([block_width_mm*2, gap_width_mm, block_height_mm*2]),
	]
);
