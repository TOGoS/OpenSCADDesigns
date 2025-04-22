// WSTYPE201630Nub1.1
// 
// Plays the part of a small screw for attaching
// a WSTYPE-201630 power strip to a board or whatever,
// since #6 screw heads are too thick!
// 
// Wide part of the hole is 19/64" wide.
// Narrow part is 19/128" wide.
// Hole is 19/128" deep.

// 19/64"  = 7.54mm
// 19/128" = 3.77mm

stem_height = 1.8;
stem_width  = 3.175;
head_height = 1.8;
head_width  = 6.35;
base_width  = 6.35;
base_height = 6.35;
max_overhang = 1.5;
style = "round"; // ["round","tailey"]

$fn = 24;

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>

round_thing = tphl1_make_z_cylinder(zds=[
	[-base_height, base_width],
	if( stem_width < base_width ) each [
		[-(base_width-stem_width)/2/max_overhang, base_width],
		[                      0                , stem_width],
	],
	if( stem_width > base_width ) each [
		[   0        , base_width],
		[   0        , stem_width],
	],
	[ stem_height, stem_width],
	[ stem_height, head_width],
	[ stem_height + head_height, head_width],
]);

tailey_thing = ["intersection",
	togmod1_linear_extrude_z(
		[-base_height, stem_height + head_height],
		["union",
			togmod1_make_circle(d=head_width),
			["translate", [0,-head_width/2], togmod1_make_rounded_rect([stem_width, head_width], r=stem_width*63/128)]
		]
	),
	["union",
		["translate", [0,0,stem_height+head_height], togmod1_make_cuboid([100,100,head_height*2])],
		togmod1_linear_extrude_z(
			[-base_height - 1, stem_height+head_height],
			["union",
				togmod1_make_rect([stem_width, 100]),
				["translate", [0,-head_width/2], ["rotate", [0,0,90], togmod1_make_circle(d=head_width, $fn=4)]]
			]
		),
		togmod1_linear_extrude_y([-100,100],
			togmod1_make_polygon([
				[-stem_width*63/128      ,    0             ],
				[-stem_width*63/128 - 100, -100/max_overhang],
				[ stem_width*63/128 + 100, -100/max_overhang],
				[ stem_width*63/128      ,    0             ],
			])
		)
	]
];

thing = style == "round" ? round_thing : tailey_thing;

togmod1_domodule(thing);
