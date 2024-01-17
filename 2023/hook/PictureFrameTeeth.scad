// PictureFrameTeeth-v1.0

module __end_params_xy123lk() { }

u = 1.5875;
width     = 36*u;
height    = 12*u;
thickness = 6*u;

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGHoleLib2.scad>

$fn = $preview ? 24 : 72;

screw_hole = tog_holelib2_hole("THL-1001", depth=thickness*2, inset=1);

toothy_point_data = [
	[-6,-8],
	[ 6,-8],
	[ 6,-1],
	[ 4, 1],
	[ 2,-1],
	[ 0, 1],
	[-2,-1],
	[-4, 1],
	[-6,-1],
];
toothy_points = [ for(p=toothy_point_data) u*p ];

mouth_width = 12*u;

the_hull = ["intersection",
	tphl1_make_rounded_cuboid([width, height, thickness*2], 2*u),
	["translate", [0,0,10], togmod1_make_cuboid([100,100,20])],
];
the_teeth_subtraction = ["union",
   tphl1_make_rounded_cuboid([mouth_width, height*2, 6*u], u),
	tphl1_extrude_polypoints([-1, thickness+1], toothy_points),
];
the_screw_holes = ["union",
	for(xm=[-1,1]) ["translate", [xm*12*u, 0, thickness], screw_hole],
];

togmod1_domodule(["difference",
	the_hull,
	the_teeth_subtraction,
	the_screw_holes,
]);
