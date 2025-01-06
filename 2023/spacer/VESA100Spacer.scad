// VESA100Spacer-v1.2
// 
// When you want to attach a mounting plate to the back of
// a monitor whose mounting screws are inset.
// 
// v1.2:
// - Slightly expand VESA holes into slots that also
//   include hhe nearby gridbeam grid points

vesa_hole_circles = [
	[5,[100,100]],
	[5,[101.6,101.6]],
];

outer_size = [120,120];
outer_corner_radius = 12;
thickness = 9.525;

$fn = $preview ? 24 : 72;

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>

module __hjxhjs_end_params() { }

inch = 25.4;
counterbored_gb_hole_positions = [for( xm=[-2.:1:+2] ) for( ym=[-2:1:+2] ) [xm*19.05, ym*19.05]];

holes = [
	for(xm=[-0.5,0.5]) for(ym=[-0.5,0.5]) ["hull",
		for( v=vesa_hole_circles ) togmod1_make_circle(d=v[0], pos=[v[1][0]*xm, v[1][1]*ym]),
	],
	for( pos=counterbored_gb_hole_positions ) togmod1_make_circle(d=8, pos=pos),
];

togmod1_domodule(["difference",
	["linear-extrude-zs", [0,thickness], ["difference",
		togmod1_make_rounded_rect(outer_size, outer_corner_radius),
		for( h=holes ) h
	]],
	// for( pos=counterbored_gb_hole_positions ) ["translate", pos, togmod1_make_cylinder(d=22.5, zrange=[thickness*1/2, thickness*3/2])]
	["linear-extrude-zs", [thickness/2,thickness+1], ["difference",
		togmod1_make_rounded_rect([(3+7/8)*inch,(3+7/8)*inch], 7/8*inch/2),
		// for( v=vesa_holes ) for(xm=[-0.5,0.5]) for(ym=[-0.5,0.5]) togmod1_make_circle(d=15, pos=[v[1][0]*xm, v[1][1]*ym]),
	]]
]);
