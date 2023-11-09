// PhoneHolderInsert-v2.0
// 
// Inserts for PhoneHolder-v2
// 
// TODO: Standardize the insert shape;
// maybe '

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGHoleLib2.scad>

style = "PHI-1001"; // ["PHI-1001"]

outer_margin = 0.1;

render_fn = 24;

module __phoneholderinsertv2_end_params() { }

inch = 25.4;
size = [4*inch, 1.25*inch, 1/4*inch];

// PHI-1001 = A very basic phone holder insert

center_hole_size = [3.5*inch, 0.75*inch];
slot_width = 1/2*inch;

$fn = $preview ? 12 : render_fn;

togmod1_domodule(["difference",
	["translate", [0,0,size[2]/2], tphl1_make_rounded_cuboid([size[0]-outer_margin*2, size[1]-outer_margin*2, size[2]], r=[6,6,0])],
	
	["translate", [0,0,size[2]/4], tphl1_make_rounded_cuboid([center_hole_size[0], center_hole_size[1], size[2]*2], r=[1.6,1.6,0])],
	["translate", [0,-size[1]/2,size[2]/4], tphl1_make_rounded_cuboid([slot_width, size[1], size[2]*2], r=[1.6,1.6,0])],
]);
