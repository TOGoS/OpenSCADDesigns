// TOGPolyhedronLib1-RoundedCuboid
// 
// Test that rounded cuboid works,
// including all the edge cases I can think of
// (different relationships between size and x/y/z radius)

use <../lib/TOGMod1.scad>
use <../lib/TOGPolyhedronLib1.scad>

spacing = 110;

// Large radius
lrad = 50;
// Small radius
srad = 25;
// Tiny radius
trad = 10;

/* [Detail] */

preview_fn = 24;
render_fn = 48;

$fn = $preview ? preview_fn : render_fn;

for( p=[[-1, "ellipsoid"], [0, "ovoid1"], [1, "ovoid2"]] )
let( yoff=p[0]*spacing )
let( corner_shape=p[1] )
togmod1_domodule(["union",
	["translate", [-3*spacing,yoff+30,0], tphl1_make_rounded_cuboid([100,100,100], r=[lrad, 0,  srad], corner_shape=corner_shape)],
	["translate", [-2*spacing,yoff+30,0], tphl1_make_rounded_cuboid([100,100,100], r=[lrad, 0,     0], corner_shape=corner_shape)],
	["translate", [-1*spacing,yoff+30,0], tphl1_make_rounded_cuboid([100,100,100], r=[lrad,srad,   0], corner_shape=corner_shape)],
	["translate", [ 0*spacing,yoff+ 0,0], tphl1_make_rounded_cuboid([100,100,100], r=[trad,srad,trad], corner_shape=corner_shape)],
	["translate", [ 1*spacing,yoff+10,0], tphl1_make_rounded_cuboid([100,100,100], r=[lrad,srad,trad], corner_shape=corner_shape)],
	["translate", [ 2*spacing,yoff+20,0], tphl1_make_rounded_cuboid([100,100,100], r=[lrad,lrad,trad], corner_shape=corner_shape)],
	["translate", [ 3*spacing,yoff+30,0], tphl1_make_rounded_cuboid([100,100,100], r=[lrad,lrad,lrad], corner_shape=corner_shape)],
]);
