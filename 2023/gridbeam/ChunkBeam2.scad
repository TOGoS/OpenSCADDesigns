// ChunkBeam2.2.1
// 
// Based on AutoOffsetPolyhedron0.
// Uses it, even.  Something should be librarified, obviously.
// Probably that stuff should be made into a library.
// 
// Versions:
// v2.1:
// - Fix that Z hole didn't go all the way through
// v2.2:
// - Options for hole style
// v2.2.1:
// - Librarify the hull-making functions into ChunkBeam2Lib

height_chunks = 2;

/* [Holes] */

hole_diameter = 8.0;
hole_style = "rounded-2mm"; // ["rounded-2mm","beveled-2mm", "beveled+rounded-2mm"]

/* [Detail] */

offset = -0.1; // 0.1
$fn = 32;

module __chunkbeam2__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/ChunkBeam2Lib.scad>
use <../lib/TGx11.1Lib.scad>
use <../lib/TOGridLib3.scad>

$tgx11_offset = offset;
$togridlib3_unit_table = tgx11_get_default_unit_table();

u           = togridlib3_decode([1, "u"                 ]);
chunk_pitch = togridlib3_decode([1, "chunk"             ]);
bevel_size  = togridlib3_decode([1, "tgp-standard-bevel"]);

function make_rathy_hole(length, shaft_d, corner_ops, inset=-0.1) =
let(zrs = togpath1_rath_to_polypoints(["togpath1-rath",
	["togpath1-rathnode", [-length/2 - 10   , shaft_d/2+bevel_size]],
	["togpath1-rathnode", [-length/2 + inset, shaft_d/2+bevel_size]],
	["togpath1-rathnode", [-length/2 + inset, shaft_d/2           ], each corner_ops],
	["togpath1-rathnode", [ length/2 - inset, shaft_d/2           ], each corner_ops],
	["togpath1-rathnode", [ length/2 - inset, shaft_d/2+bevel_size]],
	["togpath1-rathnode", [ length/2 + 10   , shaft_d/2+bevel_size]],
]))
tphl1_make_z_cylinder(zds=[for(zr=zrs) [zr[0], zr[1]*2]]);

function make_nice_hole(length, shaft_d, corner_ops) = make_rathy_hole(length, shaft_d, corner_ops);

function make_a_hole(length) =
	hole_style == "rounded-2mm" ? make_nice_hole(length, shaft_d=hole_diameter, corner_ops=[["round", 2]]) :
	hole_style == "beveled-2mm" ? make_nice_hole(length, shaft_d=hole_diameter, corner_ops=[["bevel", 2]]) :
	hole_style == "beveled+rounded-2mm" ? make_nice_hole(length, shaft_d=hole_diameter, corner_ops=[["bevel", 2], ["round", 2]]) :
	assert(false);

block_z_hole = make_a_hole(chunk_pitch * height_chunks);
chunk_z_hole = make_a_hole(chunk_pitch);

togmod1_domodule(["difference",
	chunkbeam2_make_chunkbeam_hull(height_chunks),
	
	["translate", [0,0,height_chunks*chunk_pitch/2], block_z_hole],
	for( c=[0.5 : 1 : height_chunks-0.5] ) ["translate", [0,0,c*chunk_pitch], ["union",
		["rotate", [90,0,0], chunk_z_hole],
		["rotate", [0,90,0], chunk_z_hole],
	]],
]);
