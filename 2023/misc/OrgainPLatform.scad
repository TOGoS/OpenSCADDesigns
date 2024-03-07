// OrgainPlatform-v1.3
// 
// Platform to hold a teeter-totter for Renee's Orgain
// v1.1:
// - What if kinda TOGridPile baseplate?
// v1.2:
// - Fix the center holes to be countersunk on the right side
// v1.3:
// - Fix that tgx11_offset was applied backwards oops
// - Fix overhead_bore_height formula to work when lip_height = 0

lip_height = 0; // 0.0001
// 'atom' doesn't work so well with the holes we've got; 'chatom' would be better but TGx11.1Lib doesn't do that, yet.
bottom_segmentation = "none"; // ["none","atom"]
$tgx11_offset = -0.2;

use <../lib/TOGMod1.scad>
use <../lib/TOGPolyhedronlib1.scad>
use <../lib/TOGHoleLib2.scad>
use <../lib/TOGridLib3.scad>
use <../lib/TGx11.1Lib.scad>

module __asda_end_params() { }

$togridlib3_unit_table = tgx11_get_default_unit_table();
$tgx11_gender = "m";

magnet_hole_diameter = 6.2; // 0.1
magnet_hole_depth    = 2.4; // 0.1

fan_hole_spacing = 105;
fan_hole_diameter = 5; // *shrug*
// 5m will be fine for a #6 (0.138 = 3.51mm) and
// probably #8 (0.164" = 4.17mm) 3.96875

inch = 25.4;
u = inch/16;
atom_pitch  = 12.7;
chunk_pitch = 38.1;

block_size_ca = [
	[5, "inch"], [5, "inch"], [1/4, "inch"],
];
block_size = togridlib3_decode_vector(block_size_ca);
hull_size = [
	block_size[0]+$tgx11_offset*2, block_size[1]+$tgx11_offset*2, block_size[2] + lip_height
];
hull_size_ca = [ for(d=hull_size) [d,"mm"]];
$fn = $preview ? 24 : 72;

cshole = tog_holelib2_hole("THL-1005", depth=hull_size[2]*2, overhead_bore_height=lip_height+1);
magnet_hole = tphl1_make_z_cylinder(d=magnet_hole_diameter, zrange=[-magnet_hole_depth, magnet_hole_depth]);

function make_tgp_cutout(chunk_pitch, center_hole, include_magnet_holes=false) = ["union",
	["translate", [0,0,chunk_pitch/2],
		tphl1_make_rounded_cuboid(
			[chunk_pitch - 2*u - $tgx11_offset*2, chunk_pitch - 2*u - $tgx11_offset*2, chunk_pitch],
			[u, u, 0]
		)
	],
	if( !is_undef(center_hole) ) center_hole,
	if( include_magnet_holes ) ["union", for(xm=[-1,1]) for(ym=[-1,1]) ["translate", [xm*atom_pitch, ym*atom_pitch, 0], magnet_hole]]
];

inverted_cshole = ["rotate", [180,0,0], cshole];

central_tgp_cutout = make_tgp_cutout(38.1, include_magnet_holes=true);
edge_tgp_cutout    = make_tgp_cutout(38.1, include_magnet_holes=true);
corner_tgp_cutout  = make_tgp_cutout(38.1);

togmod1_domodule(["difference",
	["intersection",
		["translate", [0,0,hull_size[2]/2], tphl1_make_rounded_cuboid(hull_size, [9.525, 9.525, u], corner_shape="ovoid1")],
		if( bottom_segmentation == "atom" ) tgx11_atomic_block_bottom(hull_size_ca),
	],
	for( xm=[-1,1] ) for( ym=[-1,1] ) ["translate", [xm*fan_hole_spacing/2, ym*fan_hole_spacing/2, block_size[2]], cshole],
	for( xm=[-0.5:1:0.5] ) for( ym=[-0.5:1:0.5] ) ["translate", [xm*chunk_pitch, ym*chunk_pitch, 0], inverted_cshole],
	if( lip_height > 0 ) ["translate", [0,0,block_size[2]], ["union",
		for( xm=[-1.5:1:1.5] ) for( ym=[-1.5:1:1.5] ) ["translate", [xm*38.1, ym*38.1, 0],
			abs(xm)+abs(ym) > 2 ? corner_tgp_cutout :
			abs(xm)+abs(ym) > 1 ? edge_tgp_cutout :
			central_tgp_cutout
		]
	]]
]);
