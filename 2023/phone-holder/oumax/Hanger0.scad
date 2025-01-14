// [Oumax]Hanger0.4
// 
// v0.1:
// - Based on testing with BottomSizeTester0.1 and SideSizeTester0.1,
//   4.75" x 1.5" with 0.5mm margins is just barely big enough.
//   So let's use 1.0mm margins for the 'full holder' prototype.
// v0.2:
// - Scoop out the front
// - Make side holes less wide
// - Add 'large' backside mounting holes
// v0.3:
// - Subdivide side holes
// v0.4:
// - One smaller hole per side
// - Shrink bottom hole Y-wise

outer_margin = 0.1;
inner_margin = 1.0;
front_slot_width_u = 32;
$fn = 48;

module oumaxholder0__end_params() { }

use <../../lib/TOGMod1.scad>
use <../../lib/TOGMod1Constructors.scad>
use <../../lib/TOGHoleLib2.scad>
use <../../lib/TOGPath1.scad>

togmod1_domodule(
let( inch = 25.4 )
let( front_slot_width = front_slot_width_u * 254/160 )
let( front_cut_zrange = [-3/4*inch-20, -3/4*inch+20] )
let( small_back_hole = ["rotate", [90,0,0], ["render", tog_holelib2_hole("THL-1001", depth=1*inch, overhead_bore_height=2*inch)]] )
let( large_back_hole = ["rotate", [90,0,0], ["render", tog_holelib2_hole("THL-1002", depth=1*inch, overhead_bore_height=2*inch)]] )
["difference",
	togmod1_linear_extrude_z([-2.5*inch + outer_margin, 2.5*inch - outer_margin], togmod1_make_rounded_rect([5*inch - outer_margin*2, 1.75*inch - outer_margin*2], r=3.175)),
	
	// Main cavity
	["translate", [0,0,2.5*inch], togmod1_linear_extrude_y([-3/4*inch - inner_margin, 3/4*inch + inner_margin], togmod1_make_rounded_rect([4.75*inch + inner_margin*2, 9.75*inch - inner_margin*2], r=12.7))],
	
	// Bottom hole
	togmod1_linear_extrude_z([-5*inch, 0], togmod1_make_rounded_rect([3.75*inch, (1+1/4)*inch], r=3.175)),
	
	// Side holes
	let( w = (1+1/4)*inch, h = 3*inch )
	let( r = min(w,h)*0.49 )
	// for( z=[-(1+3/16)*inch, (1+3/16)*inch] )
	for( z=[0] )
	["translate", [0,0,z], togmod1_linear_extrude_x([-5*inch, 5*inch], togmod1_make_rounded_rect([w, h], r=r))],

	// Small mounting holes
	for( xm=[-3.5 : 1 : 3.5] ) for( zm=[-3.5 : 1 : 4.5] )
	["translate", [xm*12.7, 3/4*inch + inner_margin, zm*12.7], small_back_hole],

	// Large mounting holes
	for( xm=[-1.5 : 3 : 1.5] ) for( zm=[3.5 : -3 : -4.5] )
	["translate", [xm*12.7, 3/4*inch + inner_margin, zm*12.7], large_back_hole],
	
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
