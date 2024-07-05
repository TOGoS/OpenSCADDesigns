// AlamengdaTriangle1.0
// 
// replacement triangle for https://www.amazon.com/dp/B0C59W6JKD

module __alamencase_triangle__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>

inch = 25.4;

$fn = $preview ? 12 : 32;

panel_rath = let(leg=3.25*inch) let(rr = 5) ["togpath1-rath",
	["togpath1-rathnode", [  0,  0], ["round", rr]],
	["togpath1-rathnode", [leg,  0], ["round", rr]],
	["togpath1-rathnode", [0  ,leg], ["round", rr]],
];

panel_2d = togmod1_make_polygon(togpath1_rath_to_polypoints(panel_rath));
hole_2d = togmod1_make_circle(d=4.5);
holes_2d = let(y1=inch/4, x1=inch*11/16, x2=inch*(2+11/16))
	["union", for(pos=[[x1,y1], [x2,y1], [y1,x1], [y1,x2]]) ["translate", pos, hole_2d]];

togmod1_domodule(togmod1_linear_extrude_z([0, inch/32], ["difference", panel_2d, holes_2d]));
