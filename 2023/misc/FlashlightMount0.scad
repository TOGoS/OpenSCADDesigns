// FlashlightMount0.2

/*

From WSTASK-201213's notes:

The bar diameter is about 16.65mm and 19.05mm on the narrow
and thick ends.

The diameter of the 48mm-long narrow part of the flashlight is 26.7mm.

I am thinking a simple design is just a ring that can fit around the
bar with a set screw to tighten it, with a flashlight-sized 'half pipe'
perpendicular to the bar hole on one side.
This could be a two-piece thing, with the same screw that holds the
pieces together also serving as the set screw against the bar.

---

Design v0.1:
So, to make things simple, let's make a 38.1mm cube
with a flashlight-sized groove in the top,
a bar-sized hole though the middle,
and additional holes for some string or something.

---

This design is for the flashlight holder part.

This is turning out very similar to ../experimental/CableTieDown,
and I think I actually want pretty much that, except with a rounder
hole for the flashlight, and a small screw hole instead of a larg one.

*/

// Changes:
// 
// v0.2:
// - Use the string grooves from CableTieDown0.6

groove_diameter = 27;

$fn = 32;
$tgx11_offset = -0.1;

module __flashlightbarmount0__end_params() { }

use <../lib/ChunkBeam2Lib.scad>
use <../lib/TOGridLib3.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TGx11.1Lib.scad>
use <../lib/TOGHoleLib2.scad>

// Copied from CableTieDown0.6
function make_string_cutout(outer_size, depth=[6,6,6]) =
let( dtop=depth[0] )
let( dside=depth[1] )
let( dbottom=depth[2] )
let( x0=-outer_size[0]/2 )
let( xA=-outer_size[0]/2 + 2 )
let( xB=+outer_size[0]/2 - 2 )
let( x1=+outer_size[0]/2 )
let( y0=-outer_size[1]/2 )
let( y1=+outer_size[1]/2 )
let( z0=-outer_size[2]/2 )
let( z1=+outer_size[2]/2 )
["difference",
	togmod1_make_cuboid([outer_size[0], outer_size[1]+8, outer_size[2]+8]),
	//togmod1_make_cuboid([50, 25.4, 19.05-6.35]),
	// TODO: Make the unner surface rounded
	tphl1_make_polyhedron_from_layer_function([
		//for( a=[-180:15:0] ) [3.5*cos(a), 4+3.5*sin(a)]
		[x0, 2],
		[xA, 0],
		[xB, 0],
		[x1, 2],
	], function(xo)
		let(off=xo[1])
		let(rrad=min(
			8,
			min(
				y1-y0 - dside*2,
				z1-z0 - dtop - dbottom
			) - 0.5
		)/2) [
		for(rpp = togpath1_rath_to_polypoints(["togpath1-rath",
			["togpath1-rathnode", [y0 + dside, z0 + dbottom], ["round", rrad], ["offset", off]],
			["togpath1-rathnode", [y1 - dside, z0 + dbottom], ["round", rrad], ["offset", off]],
			["togpath1-rathnode", [y1 - dside, z1 - dtop   ], ["round", rrad], ["offset", off]],
			["togpath1-rathnode", [y0 + dside, z1 - dtop   ], ["round", rrad], ["offset", off]],
		]))
		[xo[0], rpp[0], rpp[1]]
	])
	//tphl1_make_rounded_cuboid([50, 25.4, 19.05-6.35], [0,4,4]),
];

$togridlib3_unit_table = tgx11_get_default_unit_table();

chunk_pitch = togridlib3_decode([1, "chunk"]);

function make_rathy_hole(length, shaft_d, corner_ops, bevel_size=10, inset=-0.1) =
let(zrange = is_list(length) ? length : [-length/2, length/2])
let(zrs = togpath1_rath_to_polypoints(["togpath1-rath",
	["togpath1-rathnode", [zrange[0] - 10   , shaft_d/2+bevel_size]],
	["togpath1-rathnode", [zrange[0] + inset, shaft_d/2+bevel_size]],
	["togpath1-rathnode", [zrange[0] + inset, shaft_d/2           ], each corner_ops],
	["togpath1-rathnode", [zrange[1] - inset, shaft_d/2           ], each corner_ops],
	["togpath1-rathnode", [zrange[1] - inset, shaft_d/2+bevel_size]],
	["togpath1-rathnode", [zrange[1] + 10   , shaft_d/2+bevel_size]],
]))
tphl1_make_z_cylinder(zds=[for(zr=zrs) [zr[0], zr[1]*2]]);

block_height_chunks = 2/3;
block_size = togridlib3_decode_vector([[1, "chunk"], [1, "chunk"], [block_height_chunks, "chunk"]]);

string_groove_width        = 6.35;
string_groove_depth_bottom = 6.0; // 0.1
string_groove_depth_top    = 2.0; // 0.1
string_groove_depth_side   = 4.0; // 0.1
string_hole_diameter       = 3;

string_groove = make_string_cutout(
	[string_groove_width, block_size[1], block_size[2]],
	[string_groove_depth_top, string_groove_depth_side, string_groove_depth_bottom]
);

function make_nice_hole(length, shaft_d, corner_ops=[["bevel", 3.175], ["round", 3.175]]) = make_rathy_hole(length, shaft_d, corner_ops);

togmod1_domodule(["difference",
	chunkbeam2_make_chunkbeam_hull(block_height_chunks),
	
	["translate", [0,0,min(-block_size[2]/2 + 5, block_size[2]/2-groove_diameter/2)], tog_holelib2_hole("THL-1001", overhead_bore_height = block_size[2])],
	["translate", [0,0,block_size[2]/2], ["rotate", [0,90,0], make_nice_hole(chunk_pitch, groove_diameter, [["round", 2]])]],
	for( x=[-25.4/3,25.4/3] ) ["translate", [x,0,0], string_groove],
]);
