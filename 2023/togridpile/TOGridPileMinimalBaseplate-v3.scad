// TOGridPileMinimalBaseplate-v3.0

plate_size_chunks = [4,4];

/* [Size System] */

u = 1.5875; // 0.0001
atom_pitch_u = 8;
chunk_pitch_atoms = 3;

/* [Detail] */

outer_offset = -0.10; // 0.01
inner_offset = -0.10; // 0.01
preview_fn = 12;
render_fn = 24;

module tgpmbpv3__end_params() { }

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>

$fn = $preview ? preview_fn : render_fn;

chunk_pitch = chunk_pitch_atoms * atom_pitch_u * u;
chunk_size = [chunk_pitch, chunk_pitch];
plate_size = plate_size_chunks * chunk_pitch;

function _rect_rath(size, corner_ops=[]) = ["togpath1-rath",
	["togpath1-rathnode", [-size[0]/2, -size[1]/2], each corner_ops],
	["togpath1-rathnode", [+size[0]/2, -size[1]/2], each corner_ops],
	["togpath1-rathnode", [+size[0]/2, +size[1]/2], each corner_ops],
	["togpath1-rathnode", [-size[0]/2, +size[1]/2], each corner_ops],
];
function _rect_poly(size, corner_ops=[]) =
	togmod1_make_polygon(togpath1_rath_to_points(_rect_rath(size, corner_ops)));

function tgpmbpv3_make_the_baseplate_poly() =
let( inner = _rect_poly(chunk_size, [["bevel", 2*u], ["round", 1*u], ["offset", -u-inner_offset]]) )
["difference",
	_rect_poly(plate_size, [["bevel", 2*u], ["round", 1*u], ["offset", outer_offset]]),
	
	for( ym=[-plate_size_chunks[1]/2 + 0.5 : 1 : plate_size_chunks[1]/2] )
	for( xm=[-plate_size_chunks[0]/2 + 0.5 : 1 : plate_size_chunks[0]/2] )
	["translate", [xm*chunk_pitch, ym*chunk_pitch], inner]
];

function tgpmbpv3_make_the_baseplate() =
let( thl_1001 = tog_holelib2_hole("THL-1001", depth=2*u, inset=0.01) )
["difference",
	togmod1_linear_extrude_z([0,u], tgpmbpv3_make_the_baseplate_poly()),
	
	for( ym=[-plate_size_chunks[1]/2 + 1 : 2 : plate_size_chunks[1]/2-1] )
	for( xm=[-plate_size_chunks[0]/2 + 1 : 2 : plate_size_chunks[0]/2-1] )
	["translate", [xm*chunk_pitch, ym*chunk_pitch, u], thl_1001]
];

togmod1_domodule(tgpmbpv3_make_the_baseplate());
