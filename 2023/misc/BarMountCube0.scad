// BarMountCube0.1

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

*/

bar_hole_diameter = 19.2;

$fn = 32;
$tgx11_offset = -0.1;

module __flashlightbarmount0__end_params() { }

use <../lib/ChunkBeam2Lib.scad>
use <../lib/TOGridLib3.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TGx11.1Lib.scad>

$togridlib3_unit_table = tgx11_get_default_unit_table();

chunk_pitch = togridlib3_decode([1, "chunk"]);

function make_rathy_hole(length, shaft_d, corner_ops, bevel_size=10, inset=-0.1) =
let(zrs = togpath1_rath_to_polypoints(["togpath1-rath",
	["togpath1-rathnode", [-length/2 - 10   , shaft_d/2+bevel_size]],
	["togpath1-rathnode", [-length/2 + inset, shaft_d/2+bevel_size]],
	["togpath1-rathnode", [-length/2 + inset, shaft_d/2           ], each corner_ops],
	["togpath1-rathnode", [ length/2 - inset, shaft_d/2           ], each corner_ops],
	["togpath1-rathnode", [ length/2 - inset, shaft_d/2+bevel_size]],
	["togpath1-rathnode", [ length/2 + 10   , shaft_d/2+bevel_size]],
]))
tphl1_make_z_cylinder(zds=[for(zr=zrs) [zr[0], zr[1]*2]]);

function make_nice_hole(length, shaft_d, corner_ops=[["bevel", 3.175], ["round", 3.175]]) = make_rathy_hole(length, shaft_d, corner_ops);

togmod1_domodule(["difference",
	chunkbeam2_make_chunkbeam_hull(1),
	
	make_nice_hole(chunk_pitch, bar_hole_diameter),
	["rotate", [0,90,0], make_nice_hole(chunk_pitch, 5, [["round", 2]])],
	["rotate", [90,0,0], make_nice_hole(chunk_pitch, 5, [["round", 2]])],
]);
