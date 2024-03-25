// MiniRail0.5
// 
// v0.2
// - Attempt to fix clip path to be not too tight in parts
// - mode = "rail"|"clip" instead of always both at once
// v0.3:
// - Rename to 'MiniRail', since smaller ones are easy to imagine
// - none/THL-1001/THL-1002 options for primary and secondary holes
// v0.4:
// - Add 'jammer' - don't forget to increase offset to >0!
// v0.5
// - Add notches for stoppers or whatever you want to not move

length_chunks = 3;
mode = "rail"; // ["rail", "clip", "jammer"]
hole_type = "THL-1002"; // ["none", "THL-1001", "THL-1002"]
alt_hole_type = "THL-1001"; // ["none", "THL-1001", "THL-1002"]
notches_enabled = true;
offset = -0.1;

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>

module ___edasdkn123und_end_params() { }

u = 25.4/16;
chunk_pitch = 38.1;
mhole_pitch = chunk_pitch;
$fn = $preview ? 12 : 48;
$tgx11_offset = offset;

function make_minirail_profile_rath(tap=0, notch=0, off=0) =
["togpath1-rath",
	["togpath1-rathnode", [-8*u, -2*u + tap], ["offset", off+tap], ["round", 0.6, $fn*3/8]],
	["togpath1-rathnode", [+8*u, -2*u + tap], ["offset", off+tap], ["round", 0.6, $fn*3/8]],
	["togpath1-rathnode", [+4*u + notch*2*u, +2*u + tap - notch*2*u], ["offset", off+tap]],
	["togpath1-rathnode", [-4*u - notch*2*u, +2*u + tap - notch*2*u], ["offset", off+tap]],
];

function make_minirail_hull(
	length,
	taper_length = 4,
	offset = $tgx11_offset,
	notch_width = 6.35,
	notch_spacing = 19.05
) =
let( length_notches = round(length/notch_spacing) )
tphl1_make_polyhedron_from_layer_function([
	[-length/2               , -1, 0],
	[-length/2 + taper_length,  0, 0],

	if( notch_width > 0 ) for( xm=[-length_notches/2+0.5 : 1 : +length_notches/2-0.5] ) each [
		[xm*notch_spacing - notch_width/2 - 1,  0, 0],
		[xm*notch_spacing - notch_width/2    ,  0, 1],
		[xm*notch_spacing + notch_width/2    ,  0, 1],
		[xm*notch_spacing + notch_width/2 + 1,  0, 0],
	],

	[+length/2 - taper_length,  0, 0],
	[+length/2               , -1, 0],
], function(lon)
	let(yzpoints=togpath1_rath_to_polypoints(make_minirail_profile_rath(lon[1], off=offset, notch=lon[2])))
	[ for(yz=yzpoints) [lon[0], yz[0], yz[1]] ]
);

mhole = ["rotate", [180,0,0], tog_holelib2_hole(hole_type, inset=1)];
alt_mhole = ["rotate", [180,0,0], tog_holelib2_hole(alt_hole_type, inset=1)];

function make_minirail(length) =
let( length_mholes = round(length/mhole_pitch) )
["difference",
	["translate", [0, 0, 2*u], make_minirail_hull(
		length,
		notch_width = notches_enabled ? 6.35 : 0,
		notch_spacing = mhole_pitch / 2
	)],
	for( xm=[-length_mholes/2+0.5 : 1 : length_mholes/2-0.4] ) ["translate", [xm*mhole_pitch, 0, 0], mhole],
	for( xm=[-length_mholes/2+1   : 1 : length_mholes/2-0.9] ) ["translate", [xm*mhole_pitch, 0, 0], alt_mhole],
];

function jammer_rath(iops=[], lops=[], eops=[], cops=[], oops=[]) = ["togpath1-rath",
	["togpath1-rathnode", [ 12*u,   7*u], each cops],
	["togpath1-rathnode", [  7*u,  12*u], each cops],

	["togpath1-rathnode", [  4*u,  12*u], each oops, each cops],
	["togpath1-rathnode", [  8*u,   8*u], each oops           ],
	["togpath1-rathnode", [- 8*u,   8*u], each oops           ],
	["togpath1-rathnode", [- 4*u,  12*u], each oops, each cops],

	["togpath1-rathnode", [- 7*u,  12*u], each cops],
	["togpath1-rathnode", [-12*u,   7*u], each cops],
];

function clip_rath(iops=[], lops=[], eops=[], cops=[], oops=[]) = ["togpath1-rath",
	["togpath1-rathnode", [- 7*u,  12*u], each cops],
	["togpath1-rathnode", [-12*u,   7*u], each eops],
	["togpath1-rathnode", [-12*u, - 6*u], each eops],
	["togpath1-rathnode", [- 6*u, -12*u], each eops],
	["togpath1-rathnode", [  6*u, -12*u], each eops],
	["togpath1-rathnode", [ 12*u, - 6*u], each cops],
	
	["togpath1-rathnode", [ 10*u, - 5*u], each cops],
	["togpath1-rathnode", [  5*u, -10*u], each iops],
	["togpath1-rathnode", [- 5*u, -10*u], each lops],
	["togpath1-rathnode", [-10*u, - 5*u], each lops],
	["togpath1-rathnode", [-10*u,   5*u], each lops],
	["togpath1-rathnode", [- 9*u,   6*u], each lops],
	["togpath1-rathnode", [  9*u,   6*u], each iops],
	["togpath1-rathnode", [ 10*u,   5*u], each cops],
	
	["togpath1-rathnode", [ 12*u,   7*u], each cops],
	["togpath1-rathnode", [  7*u,  12*u], each cops],
	
	["togpath1-rathnode", [  4*u,  12*u], each oops, each cops],
	["togpath1-rathnode", [  8*u,   8*u], each oops           ],
	["togpath1-rathnode", [- 8*u,   8*u], each oops           ],
	["togpath1-rathnode", [- 4*u,  12*u], each oops, each cops],
];

outer_rad=4*u;

the_clip = tphl1_extrude_polypoints([0, 19.05], togpath1_rath_to_polypoints(clip_rath(
	iops=[["round", outer_rad-2*u]],
	lops=[["round", 2]],
	eops=[["round", outer_rad]],
	cops=[["round", 1]],
	oops=[["offset", $tgx11_offset]]
)));
the_jammer = tphl1_extrude_polypoints([0, 6.35], togpath1_rath_to_polypoints(jammer_rath(
	iops=[["round", outer_rad-2*u]],
	lops=[["round", 2]],
	eops=[["round", outer_rad]],
	cops=[["round", 1]],
	oops=[["offset", $tgx11_offset]]
)));

rail_length = length_chunks*chunk_pitch;

the_rail = make_minirail(rail_length);

togmod1_domodule(
	mode == "rail" ? the_rail :
	mode == "clip" ? the_clip :
	mode == "jammer" ? the_jammer :
	assert(false, str("Unrecognized mode: '", mode, "'"))
);
