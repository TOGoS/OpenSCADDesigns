// VESA100Spaver-v1.0
// 
// When you want to attach a mounting plate to the back of
// a monitor whose mounting screws are inset.

holes = [[5,[100,100]]];

outer_size = [120,120];
outer_corner_radius = 12;
thickness = 7.5;

$fn = $preview ? 24 : 72;

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>

togmod1_domodule(["linear-extrude-zs", [0,thickness], ["difference",
	togmod1_make_rounded_rect(outer_size, outer_corner_radius),
	for( h=holes ) for(xm=[-0.5,0.5]) for(ym=[-0.5,0.5]) echo(h=h) togmod1_make_circle(r=h[0]/2, pos=[h[1][0]*xm, h[1][1]*ym])
]]);
