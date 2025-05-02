// FrontPanel2.0
// 
// A panel to go on the front/side of a multipart holder thing

size = ["2atom", "12atom", "4u"];
hole_style = "THL-1001";
$fn = 32;

module __frontpanel2__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGUnits1.scad>
use <../lib/TOGHoleLib2.scad>

size_atoms = togunits1_decode_vec(size, [1,"atom"], "round");
size_mm = togunits1_decode_vec(size, [1,"mm"]);
atom = togunits1_decode([1,"atom"]);

hole_positions =
let( x_left  = atom * (-size_atoms[0]/2+0.5) )
let( x_right = atom * ( size_atoms[0]/2-0.5) )
[
	for( ym=[-size_atoms[1]/2+0.5 : 1 : size_atoms[1]/2-0.5] ) [x_left , ym*atom],
	for( ym=[-size_atoms[1]/2+0.5,      size_atoms[1]/2-0.5] ) [x_right, ym*atom],
];

hole = ["render", tog_holelib2_hole(hole_style, inset=2)];

togmod1_domodule(["difference",
	togmod1_linear_extrude_z([0, size_mm[2]], togpath1_make_rounded_beveled_rect([size_mm[0], size_mm[1]], 3.175, 3.175)),
	
	for( pos=hole_positions ) ["translate", [pos[0],pos[1],size_mm[2]], hole],
]);
