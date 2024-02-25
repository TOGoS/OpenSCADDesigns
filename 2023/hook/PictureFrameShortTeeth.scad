// PictureFrameShortTeeth-v1.0
// 
// This one assumes that there's more depth than height,
// i.e. the frame is thick, and you're going to attach
// to the bottom side of the top of the frame rather
// than to some solid surface within the frame
// 
// This is for hanging a fox thing that Sara's mom made.

module __end_params_xy123lk() { }

u = 1.5875;
width     = 36*u;
height    = 12*u;
depth     = 10*u;
thickness = 2*u;
tooth_depth = 2*u;

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGHoleLib2.scad>

$fn = $preview ? 24 : 72;

screw_hole = tog_holelib2_hole("THL-1001", depth=thickness*2, inset=1);
nail_hole  = tphl1_make_z_cylinder(d=1, zrange=[-1,thickness+1]);

function toothy_point_data(count) = [
	[-count/2,8],
	for( x=[-count/2 : 1 : (count-1)/2] ) each [
		[ x    , 0  ],
		[ x+0.5,-0.5],
   ],
	[ count/2,0],
	[ count/2,8],
];

mouth_width = 12*u;

the_hull = ["intersection",
	tphl1_make_rounded_cuboid([width, height, thickness*2], 2*u),
	["translate", [0,0,10], togmod1_make_cuboid([100,100,20])],
];

tooth_size = 2*u;

the_teeth_subtraction = ["translate", [0,0,thickness], ["rotate", [90,0,0],
	tphl1_extrude_polypoints([-depth, depth], toothy_point_data(7) * tooth_size),
]];
the_screw_holes = ["union",
	for(xm=[-1,1]) ["translate", [xm*12*u, 0, 0], ["union",
		["translate", [0,0,thickness], screw_hole],
		for( dx=[-3*u, 3*u] ) for( dy=[-3*u, 3*u] ) ["translate", [dx,dy,0], nail_hole],
	]],
];

the_center_hole = ["translate", [0,0,thickness/2], tphl1_make_rounded_cuboid(
	[15*u, depth-tooth_depth*2, thickness*2],
	[2*u, 2*u, 0]
)];

togmod1_domodule(["difference",
	the_hull,
	the_teeth_subtraction,
	the_center_hole,
	the_screw_holes,
]);
