// MMP-2315-insert-v1.0
// 
// Insert for MMP-2315 as created by MonitorMountRouterJig-v1.6
// 
// Customize for the size of hole you want so you don't have
// to print a whole new panel for each one!
// 
// For denomstration, some 2MB Memorex card is...
//   9.6mm thick, 19.2mm wide, 71.1mm long
// 
// MMP-2315's 1"x3" hole has, I think, 6mm radius rounded corners.
// 
// This is entirely to work with the thing I already printed,
// WSITEM-200835.  I think that in the future, I might want to
// print the outer thing with inserts in mind, and maybe
// have an overhanging lip or 14-degree walls or something so
// that the insert can be held securely in place.

// Difference in radius between bushing and bit
template_counterbore_r_offset = 2;

inch = 25.4;

use <../lib/TOGPath1.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>

outer_size = [3*inch + template_counterbore_r_offset*2, 1*inch + template_counterbore_r_offset*2];
outer_round = 8; // 6 might do, but to be safe, make it a little bigger
outer_offset = -0.2;

inner_size = [72, 20];
inner_round = 6;
// Inner offset is outwards; negative makes a larger hole
inner_offset = -template_counterbore_r_offset;

thickness = 1/2*inch;

$fn = $preview ? 12 : 72;

function make_rect_rath(size, ops=[]) = ["togpath1-rath",
	["togpath1-rathnode", [-size[0]/2, -size[1]/2], each ops],
	["togpath1-rathnode", [ size[0]/2, -size[1]/2], each ops],
	["togpath1-rathnode", [ size[0]/2,  size[1]/2], each ops],
	["togpath1-rathnode", [-size[0]/2,  size[1]/2], each ops],
];

function mane() =
	let(effective_outer_size = [outer_size[0]+outer_offset*2, outer_size[1]+outer_offset*2])
	let(effective_inner_size = [inner_size[0]-inner_offset*2, inner_size[1]-inner_offset*2])
	echo(effective_outer_size=effective_outer_size, effective_inner_size=effective_inner_size)
	let(effective_size_diff = effective_outer_size - effective_inner_size)
	let(inner_xlation = [0,0] /* effective_size_diff/2 */)
	echo(effective_size_diff=effective_size_diff, inner_xlation=inner_xlation)
	let(outer_rath = make_rect_rath(effective_outer_size, [["round", outer_round]]))
	let(inner_rath = make_rect_rath(effective_inner_size, [["round", inner_round]]))
	let(poly = ["difference",
		togmod1_make_polygon(togpath1_rath_to_points(outer_rath)),
		["translate", inner_xlation, togmod1_make_polygon(togpath1_rath_to_points(inner_rath))]
	])
	togmod1_linear_extrude_z([0, thickness], poly);

togmod1_domodule(mane());
