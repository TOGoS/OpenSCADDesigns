// TerrariumLid0.5
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
// v0.4:
// - Additional hole options
// v0.5:
// - Option for 2.1mm barrel connector bump/cutout

thickness = 3.175;
size_atoms = [9,9];
component_hole_positioning = "center"; // ["none", "center", "back-corners","corners+center"]
// Subtract this much around the edge of the panel
outer_offset = -0.1; // 0.1
lampmount_hole_positioning = "none"; // ["none", "center-x-axis"]
barrel_inlet_positioning = "none"; // ["none", "center", "front-left"]

/* [Ridge] */

// Height of ridge, if you want one; this can help the lid stay on top of a terrarium section without screws
ridge_height = 0; // 0.1
// Inset from ideal edge of ridge
ridge_inset_atoms = 1; // 0.25
ridge_extra_inset = 0.5; // 0.1

/* [Detail] */

// Z difference between levels of 'overhang remedy' for FDM printing, extrusion thickness being a good choice
overhang_remedy_depth = 0.4;

$fn = 64;

module terrariumlid0__end_params() { }

use <../lib/TOGridLib3.scad>
use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>

use <./TerrariumSegment0.scad>

wire_hole_positioning = "none"; // ["none","front-corner"]

thing =
let(size_ca = [for(s=size_atoms) [s, "atom"]])
let(size = togridlib3_decode_vector(size_ca))
let(actual_outer_size = [size[0]+outer_offset*2, size[1]+outer_offset*2, thickness])
let(outer_hull_2d = togmod1_make_rounded_rect(actual_outer_size, r=6.35))
let(squavoiden = terrariumsegment0_make_squavoiden(size_ca))
let(component_hole = togmod1_make_circle(d = 32))
let(cp = [size[0]/2-38.1, size[1]/2-38.1] )
let(component_hole_positions =
	component_hole_positioning == "none" ? [] :
	component_hole_positioning == "center" ? [[0,0]] :
	component_hole_positioning == "back-corners" ? [for( m=[[-1,1],[1,1]] ) [m[0]*cp[0], m[1]*cp[1]]] :
	component_hole_positioning == "corners+center" ? [for( m=[[-1,-1],[-1,1],[1,1],[1,-1],[0,0]] ) [m[0]*cp[0], m[1]*cp[1]]] :
	assert(false, str("Unrecognized component hole positioning scheme: '", component_hole_positioning, "'"))
)
let(barrel_inlet_positions =
	barrel_inlet_positioning == "none" ? [] :
	barrel_inlet_positioning == "center" ? [[0,0]] :
	barrel_inlet_positioning == "front-left" ? [for( m=[[-1,-1]] ) [m[0]*cp[0], m[1]*cp[1]]] :
	assert(false, str("Unrecognized barrel inlet hole positioning scheme: '", barrel_inlet_positions, "'")))
let(lampmount_hole = togmod1_make_circle(d = 8))
let(lampmount_hole_positions =
	lampmount_hole_positioning == "none" ? [] :
	lampmount_hole_positioning == "center-x-axis" ? [for( m=[[-1,0],[1,0]] ) [m[0]*cp[0], m[1]*cp[1]]] :
	assert(false, str("Unrecognized lampmount hole positioning scheme: '", lampmount_hole_positioning, "'"))
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
let( barrel_inlet_bump = togmod1_linear_extrude_z([thickness/2, 9.525], togmod1_make_circle(d=15.875)) )
let( barrel_inlet_hole = ["rotate", [180,0,0], tog_holelib2_hole("THL-1014", depth=20, remedy_depth=overhang_remedy_depth)])
["difference",
	["union",
		togmod1_linear_extrude_z([0, thickness], outer_hull_2d),
		togmod1_linear_extrude_z([thickness/2, ridge_top_z], ridge_2d),
		for(pos=barrel_inlet_positions ) ["translate", pos, barrel_inlet_bump],
	],
	
	togmod1_linear_extrude_z([-1, ridge_top_z+1], ["union",			
		for(hp=screw_hole_positions    ) ["translate", hp, screw_hole],
		for(hp=component_hole_positions) ["translate", hp, component_hole],
		for(hp=lampmount_hole_positions) ["translate", hp, lampmount_hole],
	]),

	for(hp=barrel_inlet_positions  ) ["translate", hp, barrel_inlet_hole],
];

togmod1_domodule(thing);
