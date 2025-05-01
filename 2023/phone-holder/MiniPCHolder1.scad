// MiniPCHolder1.1
// 
// Based on outmax/Hanger0.scad, but with adjustable cavity size
// 
// v1.0:
// - Proof-of-concept.  Designed to hold a Beelink SER6.
//   Not everything takes cavity_size into account.
// v1.1:
// - Remove some references to 'inch', base on block_size, instead
// v1.2:
// - Add 'insert' mode, of questionable utility

mode = "uniholder"; // ["uniholder","insert"]

cavity_size = [111.125, 50.8, 111.125];
cavity_corner_radius = [12.7,12.7,0];
outer_margin = 0.1;
inner_margin = 0.1;
front_slot_width_u = 32;
$fn = 48;

module oumaxholder0__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGHoleLib2.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>

atom = 12.7;

main_cavity = ["translate", [0,0,cavity_size[2]/2], togmod1_linear_extrude_y([-cavity_size[1]/2, cavity_size[1]/2], togmod1_make_rounded_rect([cavity_size[0] + inner_margin*2, cavity_size[2]*2 + inner_margin*2], r=cavity_corner_radius[0]+inner_margin))];

function make_side_vent_holes(cavity_size) =
	let( w = cavity_size[1]-6, h = cavity_size[2]-25.4 )
	let( r = min(w,h)*0.49 )
	let( z = 0 )
	["translate", [0,0,z], togmod1_linear_extrude_x([-cavity_size[0], cavity_size[0]], togmod1_make_rounded_rect([w, h], r=r))];

function make_bottom_hole(cavity_size) =
	let( bottom_hole_width = cavity_size[1]-3 )
	togmod1_linear_extrude_z([-cavity_size[2], 0], togmod1_make_rounded_rect([cavity_size[0]-cavity_corner_radius[0]*2, bottom_hole_width], r=3.175));

function make_uniholder() =
let( block_size = [for(d=cavity_size) (round(d/atom)+1)*atom] )
let( inch = 25.4 )
let( front_slot_width = front_slot_width_u * 254/160 )
let( front_cut_zrange = [-block_size[1], 0] )
let( small_back_hole = ["rotate", [90,0,0], ["render", tog_holelib2_hole("THL-1001", depth=50, overhead_bore_height=block_size[1])]] )
let( large_back_hole = ["rotate", [90,0,0], ["render", tog_holelib2_hole("THL-1002", depth=50, overhead_bore_height=block_size[1])]] )
let( cavity_back_y = cavity_size[1]/2 + inner_margin )
["difference",
	togmod1_linear_extrude_z([-block_size[2]/2 + outer_margin, block_size[2]/2 - outer_margin], togmod1_make_rounded_rect([block_size[0] - outer_margin*2, block_size[1] - outer_margin*2], r=3.175)),
	
	main_cavity,
	make_bottom_hole(cavity_size),
	make_side_vent_holes(block_size),

	// Small mounting holes
	for( xm=[-3.5 : 1 : 3.5] ) for( zm=[-3.5 : 1 : 4.5] )
	["translate", [xm*atom, cavity_back_y, zm*atom], small_back_hole],

	// Large mounting holes
	for( xm=[-1.5 : 3 : 1.5] ) for( zm=[3.5 : -3 : -4.5] )
	["translate", [xm*atom, cavity_back_y, zm*atom], large_back_hole],
	
	// Front cutout
	togmod1_linear_extrude_y(front_cut_zrange, togmod1_make_polygon(togpath1_rath_to_polypoints(["togpath1-rath",
		["togpath1-rathnode", [ 2*inch, -1.5*inch], ["round", 12.7 ]],
		["togpath1-rathnode", [ 2*inch,  2.5*inch], ["round",  6.35]],
		["togpath1-rathnode", [ 3*inch,  2.5*inch]],
		["togpath1-rathnode", [ 3*inch,  5  *inch]],
		["togpath1-rathnode", [-3*inch,  5  *inch]],
		["togpath1-rathnode", [-3*inch,  2.5*inch]],
		["togpath1-rathnode", [-2*inch,  2.5*inch], ["round",  6.35]],
		["togpath1-rathnode", [-2*inch, -1.5*inch], ["round", 12.7 ]],
		each front_slot_width == 0 ? [] : [
			["togpath1-rathnode", [-front_slot_width/2, -1.5*inch], ["round", 6.35 ]],
			["togpath1-rathnode", [-front_slot_width/2, -5  *inch]],
			["togpath1-rathnode", [ front_slot_width/2, -5  *inch]],
			["togpath1-rathnode", [ front_slot_width/2, -1.5*inch], ["round", 6.35 ]],
		]
	]))),
];

function make_insert() =
let( block_size = [for(d=cavity_size) (ceil(d/atom))*atom] )
["difference",
	["intersection",
		["translate", [0,0,-block_size[2]/2], tphl1_make_rounded_cuboid([block_size[0]-outer_margin*2, block_size[1]-outer_margin*2, block_size[2]*2-outer_margin*2], r=[0,6,6])],
		//["translate", [0,0, block_size[2]/2], togmod1_make_cuboid([block_size[0]*2, block_size[1]*2, block_size[2]*2-outer_margin*2])],
		["translate", [0,0, block_size[2]/2], tphl1_make_rounded_cuboid([block_size[0]-outer_margin*2, block_size[1]*2-outer_margin*2, block_size[2]*2-outer_margin*2], r=[5,0,5])],
	],
	// togmod1_linear_extrude_z([-block_size[2]/2 + outer_margin, block_size[2]/2 - outer_margin], togmod1_make_rounded_rect([block_size[0] - outer_margin*2, block_size[1] - outer_margin*2], r=3.175)),
	main_cavity,
	make_side_vent_holes(cavity_size),
	make_bottom_hole(cavity_size)
];

function make_thing() =
	mode == "uniholder" ? make_uniholder() :
	mode == "insert" ? make_insert() :
	assert(false, str("Unrecognized mode: '", mode, "'"));

togmod1_domodule(make_thing());
