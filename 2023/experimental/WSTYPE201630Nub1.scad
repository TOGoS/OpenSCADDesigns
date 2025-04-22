// WSTYPE201630Nub1.2
// 
// Plays the part of a small screw for attaching
// a WSTYPE-201630 power strip to a board or whatever,
// since #6 screw heads are too thick!
// 
// Wide part of the hole is 19/64" wide.
// Narrow part is 19/128" wide.
// Hole is 19/128" deep.
//
// 19/64"  = 7.54mm
// 19/128" = 3.77mm
// 
// v0.2:
// - Replaced `max_overhang` with `base_slope` and `head_slope`
// - 'oscar' mode

style = "round"; // ["round","oscar","tailey"]
stem_height = 1.8;
stem_width  = 3.175;
head_height = 1.8;
head_width  = 6.35;
// Only use when moe = 'round'; otherwise head_with is used
base_width  = 6.35;
base_height = 6.35;
base_slope  = 0; // 0.1
head_slope  = 0; // 0.1

$fn = 24;

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>

oscarsection =
	togmod1_linear_extrude_y([-100,100],
		togmod1_make_polygon([
			[ stem_width*63/128 + 100,           0 - 300           ],
			[ stem_width*63/128 + 100,           0 - 100*base_slope],
			[ stem_width*63/128      ,           0                 ],
			[ stem_width*63/128      , stem_height                 ],
			[ stem_width*63/128 + 100, stem_height + 100*head_slope],
			[ stem_width*63/128 + 100, stem_height + 300           ],
			[-stem_width*63/128 - 100, stem_height + 300           ],
			[-stem_width*63/128 - 100, stem_height + 100*head_slope],
			[-stem_width*63/128      , stem_height                 ],
			[-stem_width*63/128      ,           0                 ],
			[-stem_width*63/128 - 100,           0 - 100*base_slope],
			[-stem_width*63/128 - 100,           0 - 300           ],
		])
	);

round_thing = tphl1_make_z_cylinder(zds=[
	[-base_height, base_width],
	if( stem_width < base_width ) each [
		[0 - (base_width-stem_width)*base_slope/2, base_width],
		[0                                       , stem_width],
	],
	if( stem_width > base_width ) each [
		[   0        , base_width],
		[   0        , stem_width],
	],
	[ stem_height                                       , stem_width],	
	[ stem_height + (head_width-stem_width)*head_slope/2, head_width],
	[ stem_height + head_height                         , head_width],
]);

oscar_thing = ["intersection",
	tphl1_make_z_cylinder(zrange=[-base_height, stem_height+head_height], d=head_width),
	oscarsection
];

tailey_thing = ["intersection",
	togmod1_linear_extrude_z(
		[-base_height, stem_height + head_height],
		["union",
			togmod1_make_circle(d=head_width),
			["translate", [0,-head_width/2], togmod1_make_rounded_rect([stem_width, head_width], r=stem_width*63/128)]
		]
	),
	["union",
		// ["translate", [0,0,stem_height+head_height], togmod1_make_cuboid([100,100,head_height*2])],
		togmod1_linear_extrude_z(
			[-base_height - 1, stem_height+head_height],
			["union",
				togmod1_make_rect([stem_width, 100]),
				["translate", [0,-head_width/2], ["rotate", [0,0,90], togmod1_make_circle(d=head_width, $fn=4)]]
			]
		),
		oscarsection
	]
];

thing =
	style == "round" ? round_thing :
	style == "oscar" ? oscar_thing :
	style == "tailey" ? tailey_thing :
	assert(false, str("Unrecognized style: '", style, "'"));

togmod1_domodule(thing);
