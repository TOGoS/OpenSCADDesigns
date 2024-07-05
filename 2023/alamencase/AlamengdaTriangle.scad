// AlamengdaTriangle1.2
// 
// replacement triangle for https://www.amazon.com/dp/B0C59W6JKD
//
// Changes:
// v1.1:
// - Minor adjustments to tip holes and triangle size
// - Make slots instead of circles for a little wiggle room
// v1.2:
// - 'sloppy' mode, which pretends this is a half-inch grid system
// - Customizable thickness, by default 1/16"

// exact=as close as I could get to the real triangle; 'sloppy'=pretend it's a 1/2" grid
hole_placement = "sloppy"; // ["exact","slotty","sloppy"]
thickness = 1.6;           // 0.1

module __alamencase_triangle__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>

inch = 25.4;

side_length = hole_placement == "exact" ? (3+7/32)*inch : (3+1/2)*inch;
hole1_x = hole_placement == "sloppy" ? inch*(  3/4) : inch*(  11/16);
hole2_x = hole_placement == "sloppy" ? inch*(2+3/4) : inch*(2+23/32);
slot_slop = hole_placement == "exact" ? 0 : 1/8*inch;
hole_diameter = 4.5;

$fn = $preview ? 12 : 32;

panel_rath = let(leg=side_length) let(rr = 5) ["togpath1-rath",
	["togpath1-rathnode", [  0,  0], ["round", rr]],
	["togpath1-rathnode", [leg,  0], ["round", rr]],
	["togpath1-rathnode", [0  ,leg], ["round", rr]],
];

panel_2d = togmod1_make_polygon(togpath1_rath_to_polypoints(panel_rath));
hole_2d = togmod1_make_circle(d=hole_diameter);
slot_2d = slot_slop == 0 ? hole_2d : togmod1_make_rounded_rect([hole_diameter+slot_slop, hole_diameter], r=hole_diameter/2);
holes_2d = let(y1=inch/4, x1=hole1_x, x2=hole2_x)
	["union",
		for(pos=[[x1,y1,0], [x2,y1,0], [y1,x1,90], [y1,x2,90]])
			["translate", pos,
				is_undef(pos[2]) ? hole_2d :
				["rotate", pos[2], slot_2d]]
	];

togmod1_domodule(togmod1_linear_extrude_z([0, thickness], ["difference", panel_2d, holes_2d]));
