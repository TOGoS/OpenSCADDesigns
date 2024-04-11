// MirrorClip0.1
// 
// For mounting a mirror to the wall.

hole_style = "THL-1001"; // ["THL-1001", "THL-1002"]

module __askjdniu21e__end_params() { }

$fn = $preview ? 16 : 64;

rabbet_depth = 6.5;
hull_size = [19.05, 38.1, 12.7];

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>

hole = tog_holelib2_hole(hole_style, depth=hull_size[2]*2, inset=1);

thing = ["difference",
	["translate", [0,0,hull_size[2]], ["intersection",
		tphl1_make_rounded_cuboid([hull_size[0], hull_size[1], hull_size[2]*2], r=[6.3, 6.3, 3.175], corner_shape="ovoid1"),
		["translate", [0,0,-hull_size[2]], togmod1_make_cuboid(hull_size*2)],
	]],
	["translate", [0, hull_size[1]/2, hull_size[2]], togmod1_make_cuboid([hull_size[0]*2, hull_size[1], rabbet_depth*2])],
	["translate", [0, -hull_size[1]/4, 0], ["rotate", [180,0,0], hole]],
];

togmod1_domodule(thing);
