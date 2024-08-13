// ChunkBeam2.2
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

height_chunks = 2;

/* [Holes] */

hole_diameter = 8.0;
hole_style = "rounded-2mm"; // ["rounded-2mm","beveled-2mm", "beveled+rounded-2mm"]

/* [Detail] */

offset = -0.1; // 0.1
$fn = 32;

module __chunkbeam2__end_params() { }

use <../experimental/AutoOffsetPolyhedron0.scad>

use <../lib/TOGArrayLib1.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGVecLib0.scad>

u = 25.4/16;
chunk_pitch = 38.1;
bevel_size = 3.175;

function tgp_chunky_profile(chunk_count, chunk_height=38.1, bevel_size=3.175, ep=0.0001) = [
	for( c=[0:1:chunk_count-1] ) each let(cy0=chunk_height*c) [
		[-bevel_size,  cy0                             + ep],
		[          0,  cy0                + bevel_size     ],
		[          0,  cy0 + chunk_height - bevel_size     ],
		[-bevel_size,  cy0 + chunk_height              - ep],
	]
];

cc_cube = ["translate", [30,-30,0], togmod1_make_cuboid([60,60,60])];

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

tgp_profile = tgp_chunky_profile(height_chunks, chunk_pitch, bevel_size);
// Note: Subtracting offset from rounding radius
// (which actually increases the radius) is necessary to prevent
// <0 radius invalid corners.
// This maybe shows a limitation of the
// "just offset each layer" approach.
tgp_rath = let(x1=chunk_pitch/2, y1=chunk_pitch/2, cops = [["bevel", bevel_size], ["round", 3.175-offset]]) ["togpath1-rath",
	["togpath1-rathnode", [ x1, -y1], each cops],
	["togpath1-rathnode", [ x1,  y1], each cops],
	["togpath1-rathnode", [-x1,  y1], each cops],
	["togpath1-rathnode", [-x1, -y1], each cops],
];

function make_a_hole(length) =
	hole_style == "rounded-2mm" ? make_nice_hole(length, shaft_d=hole_diameter, corner_ops=[["round", 2]]) :
	hole_style == "beveled-2mm" ? make_nice_hole(length, shaft_d=hole_diameter, corner_ops=[["bevel", 2]]) :
	hole_style == "beveled+rounded-2mm" ? make_nice_hole(length, shaft_d=hole_diameter, corner_ops=[["bevel", 2], ["round", 2]]) :
	assert(false);

block_z_hole = make_a_hole(chunk_pitch * height_chunks);
chunk_z_hole = make_a_hole(chunk_pitch);

togmod1_domodule(["difference",
	aop0_make_polyhedron_from_profile_rath( tgp_profile, tgp_rath, offset=offset ),
	
	["translate", [0,0,height_chunks*chunk_pitch/2], block_z_hole],
	for( c=[0.5 : 1 : height_chunks-0.5] ) ["translate", [0,0,c*chunk_pitch], ["union",
		["rotate", [90,0,0], chunk_z_hole],
		["rotate", [0,90,0], chunk_z_hole],
	]],
]);
