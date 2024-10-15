// TerrariumLid0.1
// 
// A panel for the top of those terrarium sections.
//
// I guess it should be printed in thin, clear PETG to let light in,
// and have holes for ventilation or other components.
// Going with 1+1/4" holes (32mm being slightly over 1+1/4") for now.

thickness = 3.175;
size_atoms = [9,9];
component_hole_positioning = "center"; // ["none", "center", "back-corners"]
$fn = 64;

use <../lib/TOGridLib3.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>

use <./TerrariumSegment0.scad>

thing =
let(size_ca = [for(s=size_atoms) [s, "atom"]])
let(size = togridlib3_decode_vector(size_ca))
let(outer_hull_2d = togmod1_make_rounded_rect(size, r=6.35))
let(squavoiden = terrariumsegment0_make_squavoiden(size_ca))
let(component_hole = togmod1_make_circle(d = 32))
let(component_hole_positions =
	component_hole_positioning == "none" ? [] :
	component_hole_positioning == "center" ? [[0,0]] :
	component_hole_positioning == "back-corners" ? [[-size[0]/2+38.1, -size[1]/2+38.1], [+size[0]/2-38.1, -size[1]/2+38.1]] :
	assert(false, str("Unrecognized component hole positioning scheme: '", component_hole_positioning, "'"))
)
let(screw_hole_positions = squavoiden_to_hole_positions(squavoiden))
let(screw_hole = togmod1_make_circle(d=4.5))
togmod1_linear_extrude_z([0, thickness], ["difference",
	outer_hull_2d,
	
	for(hp=screw_hole_positions) ["translate", hp, screw_hole],
	for(hp=component_hole_positions) ["translate", hp, component_hole],
]);

togmod1_domodule(thing);
