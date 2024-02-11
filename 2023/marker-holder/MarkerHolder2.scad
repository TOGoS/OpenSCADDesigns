// MarkerHolder2.0

use <../lib/TOGMod1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGHoleLib2.scad>

u = 25.4/16;

$fn = $preview ? 24 : 72;

height_u = 48;
floor_thickness_u = 4;

mounting_hole = ["x-debug", ["rotate", [90,0,0],
	// tog_holelib2_countersunk_hole(15*u, 5*u, 0,
	tog_holelib2_hole1002(
		depth=8*u, overhead_bore_d=9*u, overhead_bore_height=16*u, inset=0.5
	)
]];

togmod1_domodule(["difference",
	["translate", [0,0,height_u/2*u], tphl1_make_rounded_cuboid([16*u, 16*u, 48*u], [2*u, 2*u, 2*u])],
	["translate", [0,0,height_u*u], tphl1_make_rounded_cuboid([12*u, 12*u, (height_u-floor_thickness_u)*2*u], [1*u, 1*u, 0])],
	for( zm=[12:24:height_u] ) ["translate", [0,6*u,zm*u], mounting_hole]
]);
