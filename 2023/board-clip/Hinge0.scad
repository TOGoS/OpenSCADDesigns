// Hinge0.1
// 
// Use to make hinges off the ends of 1/2" boards.

height = 19.05;
$fn = 32;

module __hinge0_end_params() { }

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>

u = 25.4/16;

shape = ["difference",
	togmod1_make_polygon(togpath1_rath_to_polypoints(["togpath1-rath",
		["togpath1-rathnode", [- 6*u, -4*u]],
		["togpath1-rathnode", [-18*u, -4*u]],
		["togpath1-rathnode", [-18*u, -6*u]],
		["togpath1-rathnode", [  5*u, -6*u], ["round", 5.9*u]],
		["togpath1-rathnode", [  5*u,  6*u], ["round", 5.9*u]],
		["togpath1-rathnode", [-18*u,  6*u]],
		["togpath1-rathnode", [-18*u,  4*u]],
		["togpath1-rathnode", [- 6*u,  4*u]],
	])),
	
	togmod1_make_circle(d=6.5),
];

thing = ["difference",
	togmod1_linear_extrude_z([-height/2, height/2], shape),
	
	["translate", [-12*u, 6*u, 0], ["rotate", [-90,0,0], tog_holelib2_hole("THL-1001", depth=30*u)]]
];

togmod1_domodule(thing);
