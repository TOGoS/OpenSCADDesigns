// RoundBowtie0.7
// 
// A curvier 'bowtie' piece.
// 
// diamond_r is the distance from the center of the bowtie
// to the center of one of the 'circles'.
// 
// v0.2:
// - Factor out roundbowtie0_make_bowtie_2d
// v0.3:
// - Add base_size option; if nonzero,
//   will union the bowtie with a rectangular base
// v0.4:
// - Split library from demo
// v0.5:
// - Add option for THL-1001 or THL-1005 holes
// v0.6:
// - Allow arbitrary lobe_count
// v0.7:
// - Allow smaller increments of base_thickness

thickness = 6.35;
diamond_r = 6.35;
offset = -0.1; // 0.01
// diameter of center hole when center_hole_style == "straight"
center_hole_d = 4.5;
// Type of hole/countersink - only 'straight' minds center_hole_d
center_hole_style = "straight"; // ["none","straight","THL-1001","THL-1005"]
lobe_count = 2;
base_width = 12.7;
base_thickness = 0; // 0.01

// Old way of indicating base size,
// before you could have lobe_count <> 2
// base_size = [25.4, 12.7, 0]; // 0.01

$fn = 24;

use <../lib/RoundBowtie0.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGHoleLib2.scad>

eff_base_size = !is_undef(base_size) ? base_size : [diamond_r * 2 * (lobe_count-1) + base_width, base_width, base_thickness];

togmod1_domodule(
	let( hole =
		center_hole_style == "none" ? ["union"] :
		center_hole_style == "straight" ? togmod1_linear_extrude_z([-1, thickness+1], togmod1_make_circle(d=center_hole_d)) :
		["rotate", [180,0,0], tog_holelib2_hole(center_hole_style, depth=thickness+1)]
	)
	["difference",
		["union",
			togmod1_linear_extrude_z([0, thickness], roundbowtie0_make_bowtie_2d(diamond_r, lobe_count=lobe_count, offset=offset)),
			if(eff_base_size[2] > 0) ["difference",
				togmod1_linear_extrude_z([0, eff_base_size[2]], togmod1_make_rounded_rect([eff_base_size[0], eff_base_size[1]], r=3.175)),
				togmod1_linear_extrude_z([eff_base_size[2]/2, eff_base_size[2]+1], ["union",
				   for( xm=[-lobe_count+2 : 2 : lobe_count-2] ) ["translate", [xm*diamond_r, 0, 0],
						togmod1_make_rect([min(6.35, eff_base_size[0]/2), eff_base_size[1]*2])],
					togmod1_make_rect([eff_base_size[0]*2, min(6.35, eff_base_size[1]/2)]),
				])
			],
		],
		for( xm=[-lobe_count + 1 : 2 : lobe_count-1] ) ["translate", [xm*diamond_r,0,0], hole],
	]
);
