// AlamengdaTriangle1.1
// 
// replacement triangle for https://www.amazon.com/dp/B0C59W6JKD
//
// Changes:
// v1.1:
// - Minor adjustments to tip holes and triangle size
// - Make slots instead of circles for a little wiggle room

module __alamencase_triangle__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>

inch = 25.4;

side_length = (3+7/32)*inch;
hole1_x = inch*11/16;
hole2_x = inch*(2+23/32);
hole_diameter = 4.5;

$fn = $preview ? 12 : 32;

panel_rath = let(leg=side_length) let(rr = 5) ["togpath1-rath",
	["togpath1-rathnode", [  0,  0], ["round", rr]],
	["togpath1-rathnode", [leg,  0], ["round", rr]],
	["togpath1-rathnode", [0  ,leg], ["round", rr]],
];

panel_2d = togmod1_make_polygon(togpath1_rath_to_polypoints(panel_rath));
hole_2d = togmod1_make_circle(d=hole_diameter);
slot_2d = togmod1_make_rounded_rect([hole_diameter+1/16*inch, hole_diameter], r=hole_diameter/2);
holes_2d = let(y1=inch/4, x1=hole1_x, x2=hole2_x)
	["union",
		for(pos=[[x1,y1,0], [x2,y1,0], [y1,x1,90], [y1,x2,90]])
			["translate", pos,
				is_undef(pos[2]) ? hole_2d :
				["rotate", pos[2], slot_2d]]
	];

togmod1_domodule(togmod1_linear_extrude_z([0, inch/32], ["difference", panel_2d, holes_2d]));
