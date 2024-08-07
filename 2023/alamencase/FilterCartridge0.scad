// FilterCartridge0.6
// 
// v0.1:
// - Just the bottom panel; takes forever to render!
// v0.2:
// - Add what="walls"
// v0.3:
// - Add what="grating-layer"
// - Add grating_style="grating1"|"grating2"
// v0.4:
// - Add 'grating3'
// v0.5:
// - Remove dead code
// - Organize options
// - Add `wall_height` option
// v0.6:
// - Center hole
// - Add 'empty' grating style
// - $tgx11_offset = -0.1; outer_margin is applied separately.

what = "bottom"; // ["bottom", "grating-layer", "walls"]

/* [Wall settings] */

wall_height = 19.05;

/* [Grating/panel settings] */

grating_style = "grating1"; // ["empty","grating1", "grating2","grating3"]

center_hole_diameter = 0;

/* [Margins, Detail] */

outer_margin = 0.2;

module __fc0__end_params() { }

inch = 25.4;
size = [4.5*inch, 4.5*inch];
$fn = 24;

use <../lib/TGx11.1Lib.scad>
use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGridLib3.scad>
use <../lib/TOGVecLib0.scad>

function make_hull_rath(size, offset=0) =
let( corner_ops = [["bevel", inch/8], ["round", inch/8], ["offset", offset]] )
["togpath1-rath",
	["togpath1-rathnode", [-size[0]/2, -size[1]/2], each corner_ops],
	["togpath1-rathnode", [ size[0]/2, -size[1]/2], each corner_ops],
	["togpath1-rathnode", [ size[0]/2,  size[1]/2], each corner_ops],
	["togpath1-rathnode", [-size[0]/2,  size[1]/2], each corner_ops],
];

function make_cutout_rath(size, offset=0) =
let( corner_ops = [["bevel", inch*3/4], ["round", inch/4], ["offset", offset]] )
["togpath1-rath",
	["togpath1-rathnode", [-size[0]/2, -size[1]/2], each corner_ops],
	["togpath1-rathnode", [ size[0]/2, -size[1]/2], each corner_ops],
	["togpath1-rathnode", [ size[0]/2,  size[1]/2], each corner_ops],
	["togpath1-rathnode", [-size[0]/2,  size[1]/2], each corner_ops],
];


//// Begin grating proto-lib

// GratingConfig = [beam_size : [num,num], pitch : num, angle : num]

function tgrat1_grating_beam_size(grating_config) = grating_config[1];
function tgrat1_grating_pitch(    grating_config) = grating_config[2];
function tgrat1_grating_angle(    grating_config) = grating_config[3];
function tgrat1_grating_z(        grating_config) = grating_config[4];


function tgrat1_grating_zrange(grating_config, idx=1, cur=[9999,-9999]) =
	grating_config[0] == "tgrat1-simple-grating" ? [
		tgrat1_grating_z(grating_config) - tgrat1_grating_beam_size(grating_config)[1]/2,
		tgrat1_grating_z(grating_config) + tgrat1_grating_beam_size(grating_config)[1]/2,
	] :
	grating_config[0] == "union" ?
		idx >= len(grating_config) ? cur :
		let( atidx = tgrat1_grating_zrange(grating_config[idx]) )
		tgrat1_grating_zrange(grating_config, idx+1, [min(cur[0],atidx[0]), max(cur[1],atidx[1])]) :
	assert(false, str("Don't know how to calculate zrange for grating config: ", grating_config));

function tgrat1_make_grating(
	beam_size = [1,1],
	pitch = 10,
	angle = 30,
	z     =  0
) = ["tgrat1-simple-grating", beam_size, pitch, angle, z];

function tgrat1_make_multi_grating(
	grating_configs,
) = ["union", each grating_configs];

function tgrat1__simple_grating_to_togmod(area, grating_config) =
	let( maxlen = sqrt(area[0]*area[0] + area[1]*area[1]) )
	let( beam =
		let( xss = tgrat1_grating_beam_size(grating_config) )
		togmod1_make_cuboid([xss[0], ceil(maxlen), xss[1]])
	)
	let( z = tgrat1_grating_z(grating_config) )
	let( pitch = tgrat1_grating_pitch(grating_config) )
	let( count = ceil(maxlen / pitch) )
	// echo( maxlen=maxlen, beam=beam, pitch=pitch, count=count )
	["rotate", [0,0,tgrat1_grating_angle(grating_config)], ["union",
		for( i=[-count/2 : 1 : count/2] ) ["translate", [i*pitch, 0, z], beam]
	]];

function tgrat1__multi_grating_to_togmod(area, grating_config) = ["union",
	for( i=[1 : 1 : len(grating_config)-1] ) tgrat1_grating_to_togmod(area, grating_config[i])
];

function tgrat1_grating_to_togmod(area, grating_config) =
	grating_config[0] == "tgrat1-simple-grating" ? tgrat1__simple_grating_to_togmod(area, grating_config) :
	grating_config[0] == "union" ? tgrat1__multi_grating_to_togmod(area, grating_config) :
	assert(false, str("Bad grating specification: ", grating_config));

// function make_fractal_grating(grating_config, pitch, levels=1)

//// End grating proto-lib


effective_center_hole_diameter = what == "walls" ? 0 : center_hole_diameter;

the_center_hole_2d =
	effective_center_hole_diameter == 0 ? ["union"] :
	togmod1_make_circle(d=center_hole_diameter, $fn=48);

the_center_hole_border =
	effective_center_hole_diameter == 0 ? ["union"] :
	togmod1_make_circle(d=center_hole_diameter + inch/4, $fn=48);	

the_cutout_rath = make_cutout_rath(size, -inch/8);

the_hull_2d = togmod1_make_polygon(togpath1_rath_to_polypoints(make_hull_rath(size, -outer_margin)));

the_cutout_hull_2d = ["difference",
	togmod1_make_polygon(togpath1_rath_to_polypoints(the_cutout_rath)),
	
	the_center_hole_border,
];

grating1_config = tgrat1_make_multi_grating([
	tgrat1_make_grating([0.6,1.2],  3,  30),
	tgrat1_make_grating([0.6,1.2],  3, 120),
	tgrat1_make_grating([1  ,3  ],  9,  60),
	tgrat1_make_grating([1  ,8  ], 12, 160),
]);

layer_height = 0.3;

grating2_config = tgrat1_make_multi_grating([
	tgrat1_make_grating([0.6,2*layer_height],  3,  30, 1*layer_height),
	tgrat1_make_grating([0.6,2*layer_height],  3, 120, 3*layer_height),
]);

grating3_config = tgrat1_make_multi_grating([
	tgrat1_make_grating([0.6,2*layer_height],  3,  30, 1*layer_height),
	tgrat1_make_grating([0.6,2*layer_height],  3, 120, 3*layer_height),
	tgrat1_make_grating([1.2,4*layer_height], 12,  75, 6*layer_height),
	tgrat1_make_grating([1.2,8*layer_height], 12,   0, 8*layer_height),
]);

$togridlib3_unit_table = tgx11_get_default_unit_table();
$tgx11_offset = -0.1;

panel_size_ca = [[9, "atom"], [9, "atom"], [2, "u"]];

panel_size = togridlib3_decode_vector(panel_size_ca);

bottom_panel_hull =
	// togmod1_linear_extrude_z([0, 3.175], the_hull_2d);
	tgx11_block(panel_size_ca, bottom_segmentation = "block", lip_height=0);

mounting_hole = ["rotate", [180,0,0], tog_holelib2_hole("THL-1001", depth=100, inset=0.2)];

hole_positions = [
	for( xm=[-1,1] ) for( ym=[-1,1] ) [xm*(panel_size[0]-12.7)/2, ym*(panel_size[1]-12.7)/2]
];

function extend_zrange(zrange, amt) = [zrange[0]-amt, zrange[1]+amt];

function make_bottom_panel( grating_config ) =
let( zrange = [0, panel_size[2]] )
let( zrange1 = extend_zrange(zrange, 1) )
let( zrange2 = extend_zrange(zrange, 2) )
["intersection",
	togmod1_linear_extrude_z(zrange1, ["difference",
		the_hull_2d,
		the_center_hole_2d
	]),
	["difference",
		bottom_panel_hull,
		for( pos=hole_positions )
			["translate", [pos[0], pos[1], 0], mounting_hole],
	],
	["union",
		tgrat1_grating_to_togmod([4.5*inch, 4.5*inch], grating_config),
		togmod1_linear_extrude_z(zrange2, ["difference",
			togmod1_make_rect([1000,1000]),
			the_cutout_hull_2d
		]),
	],
];

function make_grating_layer( grating_config ) =
let( zrange=tgrat1_grating_zrange(grating_config) )
echo( grating_zrange=zrange )
["intersection",
	["difference",
		togmod1_linear_extrude_z(zrange, ["difference",
			the_hull_2d,
			the_center_hole_2d
		]),
		for( pos=hole_positions )
			["translate", [pos[0], pos[1], min(zrange[0], zrange[1]-3)], mounting_hole],
	],
	["union",
		tgrat1_grating_to_togmod([4.5*inch, 4.5*inch], grating_config),
		togmod1_linear_extrude_z([zrange[0]-1, zrange[1]+1], ["difference",
			togmod1_make_rect([1000,1000]),
			the_cutout_hull_2d
		]),
	],
];

walls_outer_polypoints =
	let( corner_ops = [["bevel", inch/8], ["round", inch/8], ["offset", $tgx11_offset]] )
	togpath1_rath_to_polypoints(["togpath1-rath",
		["togpath1-rathnode", [-size[0]/2, -size[1]/2], each corner_ops],
		["togpath1-rathnode", [ size[0]/2, -size[1]/2], each corner_ops],
		["togpath1-rathnode", [ size[0]/2,  size[1]/2], each corner_ops],
		["togpath1-rathnode", [-size[0]/2,  size[1]/2], each corner_ops],
	]);

walls_inner_polypoints =
	let( corner_ops = [["bevel", inch*3/8], ["round", inch/8], ["offset", $tgx11_offset]] )
	togpath1_rath_to_polypoints(the_cutout_rath);


walls = ["linear-extrude-zs",
	[0, wall_height],
	["difference",
		the_hull_2d,
		the_cutout_hull_2d,
		for( pos=hole_positions ) ["translate", pos, togmod1_make_circle(d=5)],
	]
];

grating_config =
	grating_style == "empty" ? ["union"] :
	grating_style == "grating1" ? grating1_config :
	grating_style == "grating2" ? grating2_config :
	grating_style == "grating3" ? grating3_config :
	assert(false, str("Unknown grating style: '", grating_style, "'"));

thing =
	what == "bottom" ? make_bottom_panel(grating_config) :
	what == "grating-layer" ? make_grating_layer(grating_config) :
	what == "walls" ? walls :
	assert(false, str("What is the ", what));

togmod1_domodule(thing);
