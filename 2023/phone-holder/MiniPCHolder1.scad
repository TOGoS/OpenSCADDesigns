// MiniPCHolder1.0
// 
// Based on outmax/Hanger0.scad, but with adjustable cavity size
// 
// v1.0:
// - Proof-of-concept.  Designed to hold a Beelink SER6.
//   Not everything takes cavity_size into account.

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

block_size = [for(d=cavity_size) (round(d/12.7)+1)*12.7];

togmod1_domodule(
let( inch = 25.4 )
let( front_slot_width = front_slot_width_u * 254/160 )
let( front_cut_zrange = [-3/4*inch-20, -3/4*inch+20] )
let( small_back_hole = ["rotate", [90,0,0], ["render", tog_holelib2_hole("THL-1001", depth=1*inch, overhead_bore_height=block_size[1])]] )
let( large_back_hole = ["rotate", [90,0,0], ["render", tog_holelib2_hole("THL-1002", depth=1*inch, overhead_bore_height=block_size[1])]] )
let( cavity_back_y = cavity_size[1]/2 + inner_margin )
let( vent_width = cavity_size[1]-6 )
let( bottom_hole_width = cavity_size[1]-3 )
["difference",
	togmod1_linear_extrude_z([-block_size[2]/2 + outer_margin, block_size[2]/2 - outer_margin], togmod1_make_rounded_rect([block_size[0] - outer_margin*2, block_size[1] - outer_margin*2], r=3.175)),
	
	// Main cavity
	["translate", [0,0,cavity_size[2]/2], togmod1_linear_extrude_y([-cavity_size[1]/2, cavity_size[1]/2], togmod1_make_rounded_rect([cavity_size[0] + inner_margin*2, cavity_size[2]*2 + inner_margin*2], r=cavity_corner_radius[0]+inner_margin))],
	
	// Bottom hole
	togmod1_linear_extrude_z([-5*inch, 0], togmod1_make_rounded_rect([cavity_size[0]-cavity_corner_radius[0]*2, bottom_hole_width], r=3.175)),
	
	// Side holes
	let( w = vent_width, h = 3*inch )
	let( r = min(w,h)*0.49 )
	// for( z=[-(1+3/16)*inch, (1+3/16)*inch] )
	for( z=[0] )
	["translate", [0,0,z], togmod1_linear_extrude_x([-5*inch, 5*inch], togmod1_make_rounded_rect([w, h], r=r))],

	// Small mounting holes
	for( xm=[-3.5 : 1 : 3.5] ) for( zm=[-3.5 : 1 : 4.5] )
	["translate", [xm*12.7, cavity_back_y, zm*12.7], small_back_hole],

	// Large mounting holes
	for( xm=[-1.5 : 3 : 1.5] ) for( zm=[3.5 : -3 : -4.5] )
	["translate", [xm*12.7, cavity_back_y, zm*12.7], large_back_hole],
	
	// Front cutout
	//togmod1_linear_extrude_y(front_cut_zrange, ["translate", [0,2.5*inch], togmod1_make_rounded_rect([3*inch, 6*inch], r=6.35)]),
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
]);
