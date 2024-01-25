// Square1.1
// 
// Changelog:
// v1.1:
// - Enlarge interior pencil tip holes
// - Put a THL-1001 every third hole
// - Allow size to be specified in chunks/atoms/us
// - Larger default size and lip width

size_chunks = [4,4];
lip_width_u = 8;

chunk_pitch_atom = 6;
atom_pitch_u = 4;
u = 1.5875;

module __asdasd__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGHoleLib2.scad>

inch = 25.4;

chunk_pitch = u*atom_pitch_u*chunk_pitch_atom;

main_length = size_chunks[0]*chunk_pitch;
main_width  = size_chunks[1]*chunk_pitch;
panel_thickness = 3.175;
lip_width = lip_width_u*u;
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

function make_edge_pencil_hole(depth)     = tog_holelib2_countersunk_hole(depth, 0, depth, depth+1, 1.5, $fn = 24);
//function make_interior_pencil_hole(depth) = tog_holelib2_countersunk_hole(depth, 2, depth-2, depth+1, $fn = 24);
function make_interior_pencil_hole(depth) = tog_holelib2_countersunk_hole(depth, 0, depth, depth+1, 2.5, $fn = 24);

thl_1001_hole        = ["rotate", [180,0,0], tog_holelib2_hole("THL-1001", depth=panel_thickness+1, $fn = 24)];
edge_pencil_hole     = ["rotate", [180,0,0], make_edge_pencil_hole(panel_thickness+1)];
interior_pencil_hole = ["rotate", [180,0,0], make_interior_pencil_hole(panel_thickness+1)];

hole_spacing = atom_pitch_u*u;

holes =
let(xm0 = round(-main_length/2/hole_spacing))
let(xm1 = round( main_length/2/hole_spacing))
let(ym0 = -1)
let(ym1 = round(-main_width/hole_spacing))
["union",
	for( xm=[xm0 : 1 : xm1] )
	for( ym=[ym0 : -1 : ym1] )
	["translate", [xm*hole_spacing, ym*hole_spacing, 0],
		(xm == xm0 || xm == xm1 || ym == ym1) ? edge_pencil_hole :
		((xm % 3) == 0 && (ym % 3) == 0) ? thl_1001_hole :
		interior_pencil_hole]
];

togmod1_domodule(["difference", body, holes]);
