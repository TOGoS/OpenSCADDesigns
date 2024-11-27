// AdapterWasher1.1
// 
// Has a smaller hole for a smaller screw,
// and fits into larger holes
// 
// Versions:
// v1.1:
// - Configurable, zero-able bevels

hole_diameter   = 4.5;
post_diameter   = 7.5;
post_height     = 3.1;
// Max size of bevel on tip of post
post_bevel      = 1.0;
flange_diameter = 9.0;
flange_height   = 3.1;
// Max size of bevel on top/bottom of flange
flange_bevel    = 1.0;
$fn = 32;

use <../lib/TOGMod1.scad>
use <../lib/TOGPolyhedronLib1.scad>

togmod1_domodule(
// fb_a = flange_bevel (actual value)
let( fb_a = min(flange_bevel, flange_height/3, (flange_diameter-post_diameter)/3) )
let( pb_a   = min(post_bevel,   post_height/2,                   post_diameter/3) )
let( total_height = flange_height + post_height )
["difference",
	tphl1_make_z_cylinder(zds=[
		             [0                   , flange_diameter - fb_a*2],
		if(fb_a > 0) [fb_a                , flange_diameter         ],
		if(fb_a > 0) [flange_height - fb_a, flange_diameter         ],
		             [flange_height       , flange_diameter - fb_a*2],
		             [flange_height       , post_diameter           ],
		             [total_height - pb_a , post_diameter           ],
		if(pb_a > 0) [total_height        , post_diameter   - pb_a*2],
	]),
	
	tphl1_make_z_cylinder(zrange=[-1, total_height+1], d=hole_diameter),
]);
