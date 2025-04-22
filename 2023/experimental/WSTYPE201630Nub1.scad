// WSTYPE201630Nub1.0
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

$fn = 24;

use <../lib/TOGMod1.scad>
use <../lib/TOGPolyhedronLib1.scad>

thingy = tphl1_make_z_cylinder(zds=[
	[-base_height, base_width],
	if( stem_width != base_width ) each [
		[   0        , base_width],
		[   0        , stem_width],
	],
	[ stem_height, stem_width],
	[ stem_height, head_width],
	[ stem_height + head_height, head_width],
]));

togmod1_domodule(thingy);
