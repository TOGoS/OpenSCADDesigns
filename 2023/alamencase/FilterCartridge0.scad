// TODO:
// - Print bottom and sides separately,
//   since corner screws are not a problem, here.
// - Fractal mesh.
// - Bottom can be TOGridPile (print upwards!)

outer_margin = 0.2;
grating0_thickness = 1;

module __fc0__end_params() { }

inch = 25.4;
size = [4.5*inch, 4.5*inch];
$fn = 24;

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
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


function make_grating(size, cellsize) =
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
		togmod1_linear_extrude_z([-2, inch+1], make_grating(size, [2/8*inch, 2/8*inch])),
		["translate", [0,0,inch], togmod1_make_cuboid([200,200,2*(inch-grating0_thickness)])],
	],
	togmod1_linear_extrude_z([-1, inch+1], the_cutout_hull_2d),
];

togmod1_domodule(["difference",
	togmod1_linear_extrude_z([0, inch], the_hull_2d),
	the_cutout
]);
