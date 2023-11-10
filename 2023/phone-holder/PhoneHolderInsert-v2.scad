// PhoneHolderInsert-v2.2
// 
// Inserts for PhoneHolder-v2
// 
// TODO: Standardize the insert shape;
// maybe "4-inch x 1+!/4-inch square" is good enough.
// 
// v2.1:
// - PHI-1002
// v2.2:
// - Default outer_margin = 0.6
// - Fix rounded slot depth calculations to take outer_margin into account

use <../lib/TOGArrayLib1.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGHoleLib2.scad>

style = "PHI-1001"; // ["PHI-1001","PHI-1002"]

outer_margin = 0.6;

render_fn = 48;

module __phoneholderinsertv2_end_params() { }

function make_rounded_gap_cutter(size, r) =
assert(tal1_is_vec_of_num(size, 2), "size must be [Num, Num]")
assert(is_num(r), "r(adius) must be anumber")
["difference",
	togmod1_make_rounded_rect([size[0]+2*r, size[1]+4], r=0),
	
	for( xm=[-1, 1] ) ["translate", [xm * (size[0]/2 + r*2), 0],
		togmod1_make_rounded_rect([4*r, size[1]], r=r)]
];


inch = 25.4;

height =
	style == "PHI-1001" ? 1/4 * inch :
	style == "PHI-1002" ? 3/4 * inch :
	1/4 * inch;

size = [4*inch, 1.25*inch, height];

// PHI-1001 = A very basic phone holder insert

slot_width = 1/2*inch;

$fn = $preview ? 12 : render_fn;

function make_slot_cut(depth) =
	["translate", [0, -size[1]/2 + depth/2 + outer_margin, 0],
		togmod1_linear_extrude_z([-1, height+1],
			make_rounded_gap_cutter([slot_width, depth], r=min(depth/2, 3.175)))];

block =
	["translate", [0,0,size[2]/2], tphl1_make_rounded_cuboid([size[0]-outer_margin*2, size[1]-outer_margin*2, size[2]], r=[6,6,0])];

cutout =
	style == "PHI-1002" ? ["union",
		["translate", [0, 0, size[2]/4],
			tphl1_make_rounded_cuboid([60, 12, size[2]*2], r=[3,3,0])],
		["translate", [0, 0, 1/8*inch + size[2]],
			tphl1_make_rounded_cuboid([74, 30, size[2]*2], r=12)],
		for( xm=[-1, 1] ) for( d=[1.625] ) ["translate", [xm*d*inch, 0, 0], togmod1_make_cylinder(d=5, zrange=[-1, size[2]+1])],
		make_slot_cut((size[1]-12)/2-outer_margin),
	] :
	["union",
		["translate", [0,0,size[2]/4],
			tphl1_make_rounded_cuboid([3.5*inch, 0.75*inch, size[2]*2], r=[1.6,1.6,0])],
		make_slot_cut((size[1]-0.75*inch)/2-outer_margin)];

togmod1_domodule(["difference",
	block,
	
	cutout,
]);
