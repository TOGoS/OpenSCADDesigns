// AdapterWasher1.0
// 
// Has a smaller hole for a smaller screw,
// and fits into larger holes

hole_diameter   = 4.5;
post_diameter   = 7.5;
post_height     = 3.1;
flange_diameter = 9.0;
flange_height   = 3.1;
$fn = 32;

use <../lib/TOGMod1.scad>
use <../lib/TOGPolyhedronLib1.scad>

togmod1_domodule(
let( flange_bevel = min(1, flange_height/3, (flange_diameter-post_diameter)/3) )
let( post_bevel   = min(1,   post_height/2,                   post_diameter/3) )
let( total_height = flange_height + post_height )
["difference",
	tphl1_make_z_cylinder(zds=[
		[0                           , flange_diameter - flange_bevel*2],
		[flange_bevel                , flange_diameter                 ],
		[flange_height - flange_bevel, flange_diameter                 ],
		[flange_height               , flange_diameter - flange_bevel*2],
		[flange_height               , post_diameter                   ],
		[total_height - post_bevel   , post_diameter                   ],
		[total_height                , post_diameter - post_bevel*2    ],
	]),
	
	tphl1_make_z_cylinder(zrange=[-1, total_height+1], d=hole_diameter),
]);
