// CableBoltDown0.3
// 
// v0.2:
// - cap, currently thicker than necessary
// v0.3:
// - Cap, fixed.

mode = "block"; // [ "block", "cap" ]

$tgx11_offset = -0.1;

module __ctd0__end_params() { }

block_size_ca = [[1, "chunk"], [1, "chunk"], [8, "u"]];

// 2u would be fine for cap height, but TGx11.1Lib has trouble with it.
// TODO: Fix that.
cap_size_ca = [[1, "chunk"], [1, "chunk"], [2, "u"]];


use <../lib/TGx11.1Lib.scad>
use <../lib/TOGridLib3.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGPolyhedronLib1.scad>

$fn = $preview ? 16 : 48;

$togridlib3_unit_table = [
	["atom", [24, "u"]],
	["chunk", [1, "atom"]],
	each tgx11_get_default_unit_table(),
];

center_hole_diameter = 7.9375;
center_hole_wall_thickness = 1;
block_size = togridlib3_decode_vector(block_size_ca);

cable_groove_width = 12.7;
cable_groove_depth = block_size[2] - 6;
floor_z = block_size[2] - cable_groove_depth;

function make_block(block_size_ca) = tgx11_block(
	block_size_ca,
	$tgx11_gender = "m",
	lip_height = 1.5
);

cable_groove_r = min(cable_groove_width/2 - 1, 5);
// WOULDN'T IT BE NEAT TO make a bendy tube?
// That would require doing some math.
// Maybe for next edition.
cable_groove = tphl1_make_rounded_cuboid([block_size[0], cable_groove_width, cable_groove_depth*2], [0,cable_groove_r,cable_groove_r]);

thing =
	mode == "block" ? ["difference",
		make_block(block_size_ca),
		tphl1_make_z_cylinder(d=center_hole_diameter, zrange=[-1, block_size[2]+1]),
		["difference",
			["union", for( ym=[-1,1] ) ["scale", [1,ym,1], ["translate", [0,9,block_size[2]], cable_groove]]],
			
			let(cs=center_hole_wall_thickness*2+center_hole_diameter)
			let(bs=1) // Bevel size; less necessary if there's a wall down the middle
			tphl1_make_z_cylinder(zds=[
				[floor_z      , cs + bs],
				[floor_z + bs , cs    ],
				[block_size[2], cs]])
		]
	] :
	mode == "cap" ? ["difference",
		make_block(cap_size_ca),
		tphl1_make_z_cylinder(d=center_hole_diameter, zrange=[-1, block_size[2]+1]),
	] :
	assert(false, str("Unknown mode: '", mode, "'"));

togmod1_domodule(thing);
