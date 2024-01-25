// Square1.0

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGHoleLib2.scad>

inch = 25.4;

main_length = 3*inch;
main_width = 3*inch;
panel_thickness = 3.175;
lip_width = 3.175;
lip_thickness = 3.175;

body = tphl1_extrude_polypoints([[-main_length/2, 0, 0], [+main_length/2, 0, 0]], [
	[0, -main_width, 0],
	[0,   lip_width, 0],
	[0,   lip_width, panel_thickness + lip_thickness],
	[0,           0, panel_thickness + lip_thickness],
	[0,           0, panel_thickness],
	[0, -main_width, panel_thickness],
]);

/*
pencil tip
thickness = 0.28
length    = ~0.6
so diameter is about distance from tip/2

(/ 5 16.0)
(/ 3 8.0)
*/

function pencil_hole(depth) = tog_holelib2_countersunk_hole(depth/2+1, 1.5, depth-2, depth+1);

//hole1 = ["rotate", [180,0,0], tog_holelib2_hole("THL-1001", depth=panel_thickness+1, $fn=24)];
hole1 = ["rotate", [180,0,0], pencil_hole(panel_thickness, $fn=24)];

hole_spacing = 6.35;

holes = ["union",
	for( xm=[round(-main_length/2/hole_spacing) : 1 : main_length/2/hole_spacing] )
	for( ym=[-1 : -1 : round(-main_width/hole_spacing)] )
	["translate", [xm*hole_spacing, ym*hole_spacing, 0], hole1]
];

togmod1_domodule(["difference", body, holes]);
