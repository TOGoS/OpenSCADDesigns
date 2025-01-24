// PowerCirclePanel0.2
// 
// Mounting panel for a uhm
// 
// Changes:
// v0.2:
// - Widen slot
// - Make center hole smaller, but add inset in back at the old diameter
// - Allow a few more mounting holes

thickness = 3.175;
slot_width = 12.7;
slot_depth = 1.6;
$fn = 32;

module __powercirclepanel0__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>

inch = 25.4;

togmod1_domodule(["difference",
	let( rops = [["round", 3.175]] )
	let( cops = [["bevel", 3.175], each rops] )
   let( panel_hull_2d = togmod1_make_polygon(togpath1_rath_to_polypoints(["togpath1-rath",
		["togpath1-rathnode", [ 3*inch, -3*inch], each cops],
		["togpath1-rathnode", [ 3*inch, -6.35 ], each rops],
		["togpath1-rathnode", [ 3*inch-6.35,  0     ]],
		["togpath1-rathnode", [ 3*inch,  6.35 ], each rops],
		["togpath1-rathnode", [ 3*inch,  3*inch], each cops],
		["togpath1-rathnode", [-3*inch,  3*inch], each cops],
		["togpath1-rathnode", [-3*inch,  6.35 ], each rops],
		["togpath1-rathnode", [-3*inch+6.35,  0     ]],
		["togpath1-rathnode", [-3*inch, -6.35 ], each rops],
		["togpath1-rathnode", [-3*inch, -3*inch], each cops],
	])))
	let( mounting_hole = togmod1_make_circle(d=4.5) )
	let( mounting_hole_positions = [
		for( ym=[-5.5 : 1 : 5.5] ) for( xm=[-5.5 : 1 : 5.5] )
		if( xm*xm + ym*ym > 22 && abs(ym) > 1 )
		[xm*12.7, ym*12.7]
	])
	togmod1_linear_extrude_z([0, thickness], ["difference",
		panel_hull_2d,
		togmod1_make_circle(d=3*inch, $fn=72),
		for( pos=mounting_hole_positions ) ["translate", pos, mounting_hole],
	]),
	togmod1_linear_extrude_z([-1, slot_depth], togmod1_make_circle(d=4*inch, $fn=72)),
	togmod1_linear_extrude_y([-slot_width/2, slot_width/2], togmod1_make_polygon(togpath1_rath_to_polypoints(["togpath1-rath",
		["togpath1-rathnode", [ 100       ,-100       ]],
		["togpath1-rathnode", [ 100       , 100       ]],
		["togpath1-rathnode", [ 5.5*inch/2, 100       ]],
		["togpath1-rathnode", [ 5.5*inch/2, slot_depth], ["round", 1.5]],
		["togpath1-rathnode", [-5.5*inch/2, slot_depth], ["round", 1.5]],
		["togpath1-rathnode", [-5.5*inch/2, 100       ]],
		["togpath1-rathnode", [-100       , 100       ]],
		["togpath1-rathnode", [-100       ,-100       ]],
	])))
]);
