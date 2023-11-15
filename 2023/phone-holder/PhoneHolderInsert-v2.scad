// PhoneHolderInsert-v2.6
// 
// Inserts for PhoneHolder-v2
// 
// TODO: Standardize the insert shape;
// maybe "4-inch x 1+!/4-inch square" is good enough.
// But it may be useful to specify min. corner radius
// or bevel or something.
// 
// v2.1:
// - PHI-1002
// v2.2:
// - Default outer_margin = 0.6
// - Fix rounded slot depth calculations to take outer_margin into account
// v2.3:
// - PHI-1003, which is just PHI-1002 but 2" tall
//   and with a horizontal hole for the side plug/button
// v2.4:
// - PHI-1004, which is to hold a 3"x0.75" block
// v2.5:
// - Refactor to use separate function for each style,
//   make_phi(style) function to make entire piece
// v2.5.1:
// - Refactor to use $hull_size[1] instead of $block_size[1] for
//   calculating slot depth.
// v2.6:
// - Add PHI-1005, an insert for holding an actual phone!

use <../lib/TOGArrayLib1.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGHoleLib2.scad>

style = "PHI-1001"; // ["PHI-1001","PHI-1002","PHI-1003","PHI-1004","PHI-1005","block"]

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

$fn = $preview ? 12 : render_fn;

inch = 25.4;

// The following functions use the following dynamic variables:
// - $block_size :: ideal size of block, before margins subtracted
// - $hull_size  :: actual size of block = $block_size - 2*marign in x,y dimensions

function make_phi_hull() =
	["translate", [0,0,$hull_size[2]/2],
		tphl1_make_rounded_cuboid($hull_size, r=[6,6,0])];

slot_width = 1/2*inch;

function make_slot_cut(depth) = ["translate",
	[0, -$hull_size[1]/2 + depth/2, 0],
	togmod1_linear_extrude_z([-1, $block_size[2]+1],
		make_rounded_gap_cutter([slot_width, depth], r=min(depth/2, 3.175)))];

make_phi_1001_cut = function() ["union",
	["translate", [0,0,$block_size[2]/4],
		tphl1_make_rounded_cuboid([3.5*inch, 0.75*inch, $block_size[2]*2], r=[1.6,1.6,0])],
	make_slot_cut(($hull_size[1]-0.75*inch)/2)
];

function make_phi_1002_or_1003_cut(style) = ["union",
	["translate", [0, 0, $block_size[2]/4],
		tphl1_make_rounded_cuboid([60, 12, $block_size[2]*2], r=[3,3,0])],
	["translate", [0, 0, 1/8*inch + $block_size[2]],
		tphl1_make_rounded_cuboid([74, 30, $block_size[2]*2], r=12)],
	for( xm=[-1, 1] ) for( d=[1.625] ) ["translate", [xm*d*inch, 0, 0], togmod1_make_cylinder(d=5, zrange=[-1, $block_size[2]+1])],
	make_slot_cut(($hull_size[1]-12)/2),
	if( style == "PHI-1003" ) ["translate", [0, 0, 1/8*inch + 20], tphl1_make_rounded_cuboid([$block_size[0]*2, 12, 24], 6)]
];

make_phi_1002_cut = function() make_phi_1002_or_1003_cut("PHI-1002");
make_phi_1003_cut = function() make_phi_1002_or_1003_cut("PHI-1003");

function get_phi_1004_main_cavity_size() = [3*inch + 3, 0.75*inch + 2, $block_size[2]-1/4*inch];

make_phi_1004_cut = function()
let(cavsize = get_phi_1004_main_cavity_size())
["union",
	["translate", [0, 0, $block_size[2]], togmod1_make_cuboid([
		cavsize[0],
		cavsize[1],
		cavsize[2]*2,
	])],
	["translate", [0, 0, 0], togmod1_make_cuboid([
		cavsize[0] - 1/4*inch,
		cavsize[1],
		cavsize[2]*2,
	])],
	for( xm=[-1, 1] ) for( d=[1.75] ) ["translate", [xm*d*inch, 0, 0], togmod1_make_cylinder(d=5, zrange=[-1, $block_size[2]+1])],
];

// Good for my phone
make_phi_1005_cut = function()
["union",
	["translate", [0, 0, 1/16*inch], tphl1_make_rounded_cuboid([60, 13, 1/4*inch], r=[1.6, 1.6, 0])],
	["translate", [0, 0, 1/4*inch], tphl1_make_rounded_cuboid([92, 20, 1/4*inch], r=[2, 2, 1.6])],
	make_slot_cut(($hull_size[1]-13)/2),
];

function get_shape_info(style) =
	style == "PHI-1001" ? [1/4 * inch, make_phi_1001_cut] :
	style == "PHI-1002" ? [3/4 * inch, make_phi_1002_cut] :
	style == "PHI-1003" ? [2   * inch, make_phi_1003_cut] :
	style == "PHI-1004" ? [2   * inch, make_phi_1004_cut] :
	style == "PHI-1005" ? [1/4 * inch, make_phi_1005_cut] :
	[1/4 * inch, function() ["union"]];

function make_phi(style) =
	let(shape_info = get_shape_info(style))
	let($block_size = [4*inch, 1.25*inch, shape_info[0]])
	let($hull_size = [$block_size[0]-outer_margin*2, $block_size[1]-outer_margin*2, $block_size[2]])
	["difference",
		make_phi_hull(),
		
		shape_info[1](),
	];

// PHI-1001 = A very basic phone holder insert

togmod1_domodule(make_phi(style));
