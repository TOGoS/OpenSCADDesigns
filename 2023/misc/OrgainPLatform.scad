// OrgainPlatform-v1.0
// 
// Platform to hold a teeter-totter for Renee's Orgain

use <../lib/TOGMod1.scad>
use <../lib/TOGPolyhedronlib1.scad>
use <../lib/TOGHoleLib2.scad>

module __asda_end_params() { }

fan_hole_spacing = 105;
fan_hole_diameter = 5; // *shrug*
// 5m will be fine for a #6 (0.138 = 3.51mm) and
// probably #8 (0.164" = 4.17mm) 3.96875

inch = 25.4;
hull_size = [
	5*inch, 5*inch, 0.25*inch
];
$fn = $preview ? 24 : 72;

cshole = tog_holelib2_hole("THL-1005", depth=hull_size[2]*2);

togmod1_domodule(["difference",
	["translate", [0,0,hull_size[2]/2], tphl1_make_rounded_cuboid(hull_size, [9.525, 9.525, 0])],
	for( xm=[-1,1] ) for( ym=[-1,1] ) ["translate", [xm*fan_hole_spacing/2, ym*fan_hole_spacing/2, hull_size[2]], cshole],
	for( ym=[-1,0,1] ) ["translate", [0,ym*19.05,0], ["rotate", [180,0,0], cshole]],
]);
