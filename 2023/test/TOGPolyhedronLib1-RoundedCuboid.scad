// Test that rounded cuboid works

use <../lib/TOGMod1.scad>
use <../lib/TOGPolyhedronLib1.scad>

$fn = 24;
spacing = 110;

togmod1_domodule(["union",
	["translate", [-2*spacing, 0,0], tphl1_make_rounded_cuboid([100,100,100], r=[20,25,25])],
	["translate", [-1*spacing,10,0], tphl1_make_rounded_cuboid([100,100,100], r=[50,25,25])],
	["translate", [ 0*spacing,20,0], tphl1_make_rounded_cuboid([100,100,100], r=[50,50,25])],
	["translate", [ 1*spacing,30,0], tphl1_make_rounded_cuboid([100,100,100], r=[50,50,50])],
]);
