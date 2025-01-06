// VESA100Spacer-v1.3
// 
// When you want to attach a mounting plate to the back of
// a monitor whose mounting screws are inset.
// 
// v1.2:
// - Slightly expand VESA holes into slots that also
//   include hhe nearby gridbeam grid points
// v1.3:
// - Counterbore corner holes by default for M4 socket caps

outer_size = [120,120];
// 4.5 should be enough for M4 screws?
corner_hole_diameter = 4.75;
// 4 = nominal height of M4 socket caps
corner_hole_counterbore_depth = 4;
// 7 = nominal diameter height of M4 socket caps
corner_hole_counterbore_diameter = 7.75;
outer_corner_radius = 12;
thickness = 9.525;
// Difference between center/side of counterbore; layer height is a good choice?
overhang_remedy_height = 0.3;

$fn = $preview ? 24 : 72;

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>

module __hjxhjs_end_params() { }

inch = 25.4;
counterbored_gb_hole_positions = [for( xm=[-2.:1:+2] ) for( ym=[-2:1:+2] ) [xm*19.05, ym*19.05]];

corner_hole_positions = [
	[50  ,50  ],
	[50.8,50.8],
];
corner_hole_extrapolated_positions = [
	corner_hole_positions[0] + (corner_hole_positions[0] - corner_hole_positions[1]) * 5,
	corner_hole_positions[1] + (corner_hole_positions[1] - corner_hole_positions[0]) * 5,
];

function make_slot(zrange, point_dps) =
	togmod1_linear_extrude_z(zrange, ["hull",
		for(pdp=point_dps) togmod1_make_circle(d=pdp[0], pos=pdp[1])
	]);

vesish_slot = ["union",
	make_slot([-1, thickness+1], [for(pos=corner_hole_positions) [corner_hole_diameter, pos]]),
	
	// Slot with 'overhang remedy'
	if( corner_hole_counterbore_depth > 0 ) ["intersection",
		make_slot([-2, corner_hole_counterbore_depth+0.3], [for(pos=corner_hole_positions) [corner_hole_counterbore_diameter, pos]]),
		["union",
			// Regular counterbore:
			make_slot([-3, corner_hole_counterbore_depth], [for(pos=corner_hole_positions) [corner_hole_counterbore_diameter*2, pos]]),
			// Slightly deeper center for 'remedy'
			make_slot([-4, corner_hole_counterbore_depth+1], [for(pos=corner_hole_extrapolated_positions) [corner_hole_diameter, pos]]),
		]
	]
];

holes = [
	for( pos=counterbored_gb_hole_positions ) togmod1_make_circle(d=8, pos=pos),
];

togmod1_domodule(["difference",
	["linear-extrude-zs", [0,thickness], ["difference",
		togmod1_make_rounded_rect(outer_size, outer_corner_radius),
		for( h=holes ) h
	]],
	
	for(xm=[-1,1]) for(ym=[-1,1]) ["scale", [xm,ym,1], vesish_slot],
	// for( pos=counterbored_gb_hole_positions ) ["translate", pos, togmod1_make_cylinder(d=22.5, zrange=[thickness*1/2, thickness*3/2])]
	["linear-extrude-zs", [max(corner_hole_counterbore_depth+1,thickness/2),thickness+1], ["difference",
		togmod1_make_rounded_rect([(3+7/8)*inch,(3+7/8)*inch], 7/8*inch/2),
		// for( v=vesa_holes ) for(xm=[-0.5,0.5]) for(ym=[-0.5,0.5]) togmod1_make_circle(d=15, pos=[v[1][0]*xm, v[1][1]*ym]),
	]]
]);
