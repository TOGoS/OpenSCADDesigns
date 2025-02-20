// TerrariumLid0.3
// 
// A panel for the top of those terrarium sections.
//
// I guess it should be printed in thin, clear PETG to let light in,
// and have holes for ventilation or other components.
// Going with 1+1/4" holes (32mm being slightly over 1+1/4") for now.
//
// v0.2:
// - Back corners means +y, not -y
// - Configurable outer offset, default -0.1mm
// - Optional ridge
// v0.3:
// - Fix ridge insetting

thickness = 3.175;
size_atoms = [9,9];
component_hole_positioning = "center"; // ["none", "center", "back-corners"]
// Subtract this much around the edge of the panel
outer_offset = -0.1; // 0.1

/* [Ridge] */

// Height of ridge, if you want one; this can help the lid stay on top of a terrarium section without screws
ridge_height = 0; // 0.1
// Inset from ideal edge of ridge
ridge_inset_atoms = 1; // 0.25
ridge_extra_inset = 0.5; // 0.1

/* [Detail] */

$fn = 64;

use <../lib/TOGridLib3.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>

use <./TerrariumSegment0.scad>

thing =
let(size_ca = [for(s=size_atoms) [s, "atom"]])
let(size = togridlib3_decode_vector(size_ca))
let(actual_outer_size = [size[0]+outer_offset*2, size[1]+outer_offset*2, thickness])
let(outer_hull_2d = togmod1_make_rounded_rect(actual_outer_size, r=6.35))
let(squavoiden = terrariumsegment0_make_squavoiden(size_ca))
let(component_hole = togmod1_make_circle(d = 32))
let(component_hole_positions =
	component_hole_positioning == "none" ? [] :
	component_hole_positioning == "center" ? [[0,0]] :
	component_hole_positioning == "back-corners" ? [[-size[0]/2+38.1, size[1]/2-38.1], [+size[0]/2-38.1, size[1]/2-38.1]] :
	assert(false, str("Unrecognized component hole positioning scheme: '", component_hole_positioning, "'"))
)
let(screw_hole_positions = squavoiden_to_hole_positions(squavoiden))
let(screw_hole = togmod1_make_circle(d=4.5))
let( ridge_top_z = thickness + ridge_height )
let( ridge_width = 3.175 )
let( ridge_rect_size = [
	size[0] - togridlib3_decode([ridge_inset_atoms,"atom"])*2 - ridge_extra_inset*2 - ridge_width,
	size[1] - togridlib3_decode([ridge_inset_atoms,"atom"])*2 - ridge_extra_inset*2 - ridge_width,
])
let( ridge_rath = togpath1_make_rectangle_rath(ridge_rect_size, [["round", 6.35]]) )
let( ridge_2d = ["difference",
	togmod1_make_polygon(togpath1_rath_to_polypoints(togpath1_offset_rath(ridge_rath,  ridge_width/2))),
	togmod1_make_polygon(togpath1_rath_to_polypoints(togpath1_offset_rath(ridge_rath, -ridge_width/2))),
])
["difference",
	["union",
		togmod1_linear_extrude_z([0, thickness], outer_hull_2d),
		togmod1_linear_extrude_z([thickness-1, ridge_top_z], ridge_2d),
	],
	
	togmod1_linear_extrude_z([-1, ridge_top_z+1], ["union",			
		for(hp=screw_hole_positions) ["translate", hp, screw_hole],
		for(hp=component_hole_positions) ["translate", hp, component_hole],
	]),
];

togmod1_domodule(thing);
