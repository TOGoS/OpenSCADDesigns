// CompactLidHolder0.1

mode = "base+posts"; // ["base+posts", "base"]

module __clh0___12e3uin1_end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGVecLib0.scad>

inch = 25.4;
u = inch/16;

lidslot_width  = 3.4*inch;
lidslot_neck_width = 2.8*inch;
lidslot_height = 1/4*inch;
wall_thickness  = 1/8*inch;
bloff = -0.1;
cone_rad = 3.5; // So a 1/4"-topped flathead might fit?
post_hole_diam = 5;

$fn = $preview ? 16 : 64;

polyfn = $preview ? 32 : 64;

base_rath = ["togpath1-rath",
	["togpath1-rathnode", [-28*u, 28*u], ["bevel", 2*u], ["round", 2*u]],
	["togpath1-rathnode", [-28*u,  4*u], ["bevel", 2*u], ["round", 2*u]],
	["togpath1-rathnode", [-22*u,  4*u], ["round", 2*u]],
	["togpath1-rathnode", [-22*u, 22*u], ["round", 16*u]],
	["togpath1-rathnode", [ 22*u, 22*u], ["round", 16*u]],
	["togpath1-rathnode", [ 22*u,  4*u], ["round", 2*u]],
	["togpath1-rathnode", [ 28*u,  4*u], ["bevel", 2*u], ["round", 2*u]],
	["togpath1-rathnode", [ 28*u, 28*u], ["bevel", 2*u], ["round", 2*u]],
];

base = tphl1_make_polyhedron_from_layer_function([
	[0             , 0],
	[wall_thickness, 0], // TODO: Bevel top/bottom
], function( zo ) togvec0_offset_points(togpath1_rath_to_polypoints(base_rath, $fn=polyfn), zo[0]));

topz = wall_thickness + lidslot_height;

post_hole_subtraction = tphl1_make_z_cylinder(zds=[
	[-1                  , cone_rad*2+2 - bloff*2],
	[cone_rad-post_hole_diam/2 - bloff*2, post_hole_diam],
	[topz * 2            , post_hole_diam]
]);

post = tphl1_make_z_cylinder(zds=[
	[   1                     , 12.7],
	[topz                     , 12.7],
	[topz                     , cone_rad*2 + bloff*2],
	[topz + cone_rad + bloff*2, 0],
]);

base_post_positions = [[-22*u, 22*u], [22*u, 22*u]];

base_and_posts = ["difference",
	["union",
		base,
		for( pos=base_post_positions ) ["translate", pos, post]
	],
	for( pos=base_post_positions ) ["translate", pos, post_hole_subtraction]
];

bare_base = ["difference",
	base,
	for( pos=base_post_positions ) ["translate", pos, ["union", post_hole_subtraction, ["translate", [0,0,wall_thickness], ["rotate", [180,0,0], post_hole_subtraction]]]],
];

thing =
	mode == "base" ? bare_base :
	mode == "base+posts" ? base_and_posts :
	assert(false, str("Unrecognized mode: '", mode, "'"));

togmod1_domodule(thing);
