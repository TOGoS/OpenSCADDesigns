// FilterCartridge0.1
// 
// v0.1:
// - Just the bottom panel; takes forever to render!

outer_margin = 0.2;
grating0_thickness = 1;

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

// GratingConfig = [beam_size : [num,num], pitch : num, angle : num]

function tgrat1_gratingbeam_size(grating_config) = grating_config[1];
function tgrat1_gratingpitch(    grating_config) = grating_config[2];
function tgrat1_gratingangle(    grating_config) = grating_config[3];

function tgrat1_make_grating(
	beam_size = [1,1],
	pitch = 10,
	angle = 30
) = ["tgrat1-simple-grating", beam_size, pitch, angle];

function tgrat1_make_multi_grating(
	grating_configs,
) = ["union", each grating_configs];

function tgrat1__simple_grating_to_togmod(area, grating_config) =
	let( maxlen = sqrt(area[0]*area[0] + area[1]*area[1]) )
	let( beam =
		let( xss = tgrat1_gratingbeam_size(grating_config) )
		togmod1_make_cuboid([xss[0], ceil(maxlen), xss[1]])
	)
	let( pitch = tgrat1_gratingpitch(grating_config) )
	let( count = ceil(maxlen / pitch) )
	// echo( maxlen=maxlen, beam=beam, pitch=pitch, count=count )
	["rotate", [0,0,tgrat1_gratingangle(grating_config)], ["union",
		for( i=[-count/2 : 1 : count/2] ) ["translate", [i*pitch, 0], beam]
	]];

function tgrat1__multi_grating_to_togmod(area, grating_config) = ["union",
	for( i=[1 : 1 : len(grating_config)-1] ) tgrat1_grating_to_togmod(area, grating_config[i])
];

function tgrat1_grating_to_togmod(area, grating_config) =
	grating_config[0] == "tgrat1-simple-grating" ? tgrat1__simple_grating_to_togmod(area, grating_config) :
	grating_config[0] == "union" ? tgrat1__multi_grating_to_togmod(area, grating_config) :
	assert(false, str("Bad grating specification: ", grating_config));

// function make_fractal_grating(grating_config, pitch, levels=1)


function make_grating0(size, cellsize) =
let( tri1 = togmod1_make_polygon([[-cellsize[0]*3/8, -cellsize[1]*7/16], [cellsize[0]*3/8, -cellsize[1]*7/16], [0,  cellsize[1]*7/16]]) )
let( tri2 = togmod1_make_polygon([[-cellsize[0]*3/8,  cellsize[1]*7/16], [cellsize[0]*3/8,  cellsize[1]*7/16], [0, -cellsize[1]*7/16]]) )
["union",
	for( ym=[-round(size[1]/cellsize[1])/2 + 0.5 : 2 : round(size[1]/cellsize[1])/2-0.4] ) each [
		for( xm=[-round(size[0]/cellsize[0])/2 + 0.5 : 1 : round(size[0]/cellsize[0])/2-0.4] )
			["translate", [xm*cellsize[0], ym*cellsize[1]], tri1],
		for( xm=[-round(size[0]/cellsize[0])/2 + 1 : 1 : round(size[0]/cellsize[0])/2-0.9] )
			["translate", [xm*cellsize[0], ym*cellsize[1]], tri2],
	],
	for( ym=[-round(size[1]/cellsize[1])/2 + 1.5 : 2 : round(size[1]/cellsize[1])/2-0.4] ) each [
		for( xm=[-round(size[0]/cellsize[0])/2 + 0.5 : 1 : round(size[0]/cellsize[0])/2-0.4] )
			["translate", [xm*cellsize[0], ym*cellsize[1]], tri2],
		for( xm=[-round(size[0]/cellsize[0])/2 + 1 : 1 : round(size[0]/cellsize[0])/2-0.9] )
			["translate", [xm*cellsize[0], ym*cellsize[1]], tri1],
	],
];

the_hull_2d = togmod1_make_polygon(togpath1_rath_to_polypoints(make_hull_rath(size, -outer_margin)));
the_cutout_hull_2d = togmod1_make_polygon(togpath1_rath_to_polypoints(make_cutout_rath(size, -inch/8)));

the_cutout = ["intersection",
	["union",
		togmod1_linear_extrude_z([-2, inch+1], make_grating0(size, [2/8*inch, 2/8*inch])),
		["translate", [0,0,inch], togmod1_make_cuboid([200,200,2*(inch-grating0_thickness)])],
	],
	togmod1_linear_extrude_z([-1, inch+1], the_cutout_hull_2d),
];

thing0 = ["difference",
	togmod1_linear_extrude_z([0, inch], the_hull_2d),
	the_cutout
];

grating1 = tgrat1_grating_to_togmod([4.5*inch, 4.5*inch], tgrat1_make_multi_grating([
	tgrat1_make_grating([0.6,1.2],  3,  30),
	tgrat1_make_grating([0.6,1.2],  3, 120),
	tgrat1_make_grating([1  ,3  ],  9,  60),
	tgrat1_make_grating([1  ,8  ], 12, 160),
]));

$togridlib3_unit_table = tgx11_get_default_unit_table();
$tgx11_offset = -outer_margin;

panel_size_ca = [[9, "atom"], [9, "atom"], [2, "u"]];

panel_size = togridlib3_decode_vector(panel_size_ca);

panel_hull =
	// togmod1_linear_extrude_z([0, 3.175], the_hull_2d);
	tgx11_block(panel_size_ca, bottom_segmentation = "block", lip_height=0);

mounting_hole = ["rotate", [180,0,0], tog_holelib2_hole("THL-1001", depth=panel_size[2]+1, inset=0.2)];

thing1 = ["intersection",
	["difference",
		panel_hull,
		for( xm=[-1,1] ) for( ym=[-1,1] )
			["translate", [xm*(panel_size[0]-12.7)/2, ym*(panel_size[1]-12.7)/2, 0],
				mounting_hole],
	],
	["union",
		grating1,
		togmod1_linear_extrude_z([-1, 10], ["difference",
			togmod1_make_rect([1000,1000]),
			the_cutout_hull_2d
		]),
	],
];

thing = thing1;

togmod1_domodule(thing);
