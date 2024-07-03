// PhoneHolderInsert-v2.10
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
// v2.7:
// - Add PHI-1006, an updated insert for the 3"x3"x0.75" USB charger block
// v2.8:
// - Add PHI-1005-sub and mounting holes on PHI-1005
// v2.9:
// - PHI-1005-sub and mounting holes on PHI-1005
// v2.9.1
// - increase sub_offset slightly (from -0.15 -0.20 mm)
// - Add PHI-1005+sub mode, for your convenience
// v2.10:
// - Add 'PHI-1007', 'PHI-1007-IU', and '-IU' variations of some other shapes
// - PHI-1005's connector holes are a little more inset
// - sub_margin is now configurable
// - Underblocks have a slight bevel around their bottom edge

use <../lib/TOGArrayLib1.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGHoleLib2.scad>

// IU=integrated underblock
style = "PHI-1001"; // ["PHI-1001","PHI-1002","PHI-1003","PHI-1004","PHI-1005","PHI-1005-IU","PHI-1005-sub","PHI-1005+sub","PHI-1006","PHI-1006-IU","PHI-1007","PHI-1007-IU","block"]

outer_margin = 0.6;
sub_margin = 0.3;

render_fn = 48;

module __phoneholderinsertv2_end_params() { }

function make_rounded_gap_cutter(size, r) =
assert(tal1_is_vec_of_num(size, 2), "size must be [Num, Num]")
assert(is_num(r), "r[adius] must be a number")
let( actual_r = min(size[1]/2-0.1, r) )
assert(actual_r*2 < size[1], "r[adius] must be less than half of cutter depth")
["difference",
	togmod1_make_rounded_rect([size[0]+2*actual_r, size[1]+4], r=0),
	
	for( xm=[-1, 1] ) ["translate", [xm * (size[0]/2 + actual_r*2), 0],
		togmod1_make_rounded_rect([4*actual_r, size[1]], r=actual_r)]
];

$fn = $preview ? 12 : render_fn;

inch = 25.4;

// The following functions use the following dynamic variables:
// - $block_size :: ideal size of block, before margins subtracted
// - $hull_size  :: actual size of block = $block_size - 2*marign in x,y dimensions

function make_phi_hull() =
	["translate", [0,0,$hull_size[2]/2],
		tphl1_make_rounded_cuboid($hull_size, r=[6,6,0])];

function make_slot_cut(depth, slot_width=1/2*inch) = ["translate",
	[0, -$hull_size[1]/2 + depth/2, 0],
	togmod1_linear_extrude_z($vcut_zrange, make_rounded_gap_cutter([slot_width, depth], r=min(depth/2, 3.175)))];

// Helpers for $vcut_zrange ('Z range of vertical cuts'),
// which is kind of a hack until 2D cuts can be specified
// separately from 3D ones.
function range_mid(r) = (r[0]+r[1])/2;
function range_length(r) = r[1]-r[0];

make_phi_1001_cut = function() ["union",
	["translate", [0,0,range_mid($vcut_zrange)],
		tphl1_make_rounded_cuboid([3.5*inch, 0.75*inch, range_length($vcut_zrange)], r=[1.6,1.6,0])],
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

// USB charger block holder, take 1
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

// USB charger block holder, take 2
// Main cavity is rounded, and there's a big slot in front fir viewing
make_phi_1006_cut = function()
let(cavsize = get_phi_1004_main_cavity_size())
["union",
	["translate", [0, 0, $block_size[2]], tphl1_make_rounded_cuboid([
		cavsize[0],
		cavsize[1],
		cavsize[2]*2,
	], r=[1/4*inch, 0, 1/4*inch])],
	["translate", [0, 0, 0], togmod1_make_cuboid([
		cavsize[0] - 1/4*inch,
		cavsize[1],
		cavsize[2]*2,
	])],
	for( xm=[-1, 1] ) for( d=[1.75] ) ["translate", [xm*d*inch, 0, 0], togmod1_make_cylinder(d=5, zrange=[-1, $block_size[2]+1])],
	make_slot_cut(($hull_size[1]-cavsize[1])/2, slot_width=2*inch),
];

// Good for my phone
make_phi_1005_cut = function()
["union",
	["translate", [0, 0, range_mid($vcut_zrange)], tphl1_make_rounded_cuboid([60, 13, range_length($vcut_zrange)], r=[1.6, 1.6, 0])],
	["translate", [0, 0, 1/4*inch], tphl1_make_rounded_cuboid([92, 20, 1/4*inch], r=[2, 2, 1.6])],
	make_slot_cut(($hull_size[1]-13)/2),
	if( !$integrated_underblock ) for( xm=[-1, +1] ) ["translate", [xm*1.5*inch, 0, 1/8*inch], tog_holelib2_hole("THL-1001", inset=1)],
];

// Smaller center hole, no inset, for easier integrated underblock printing
make_phi_1007_cut = function()
["union",
	["translate", [0, 0, range_mid($vcut_zrange)], tphl1_make_rounded_cuboid([40, 13, range_length($vcut_zrange)], r=[6, 6, 0])],
	make_slot_cut(($hull_size[1]-13)/2),
	if( !$integrated_underblock ) for( xm=[-1, +1] ) ["translate", [xm*1.5*inch, 0, 1/4*inch], tog_holelib2_hole("THL-1001", inset=2)],
];


// TODO: Refactor so that 2D and 3D cuts are specified separately
function get_shape_info(style) =
	style == "PHI-1001" ? [1/4 * inch, make_phi_1001_cut] :
	style == "PHI-1002" ? [3/4 * inch, make_phi_1002_cut] :
	style == "PHI-1003" ? [2   * inch, make_phi_1003_cut] :
	style == "PHI-1004" ? [2   * inch, make_phi_1004_cut] :
	style == "PHI-1005" ? [1/4 * inch, make_phi_1005_cut] :
	style == "PHI-1006" ? [2   * inch, make_phi_1006_cut] :
	style == "PHI-1007" ? [1/8 * inch, make_phi_1007_cut] :
	[1/4 * inch, function() ["union"]];

function make_phi(style) =
	let(shape_info = is_list(style) ? style : get_shape_info(style))
	let($integrated_underblock = is_undef($integrated_underblock) ? false : $integrated_underblock)
	let($block_size = [4*inch, 1.25*inch, shape_info[0]])
	let($vcut_zrange = [-1, $block_size[2]+1])
	let($hull_size = [$block_size[0]-outer_margin*2, $block_size[1]-outer_margin*2, $block_size[2]])
	["difference",
		make_phi_hull(),
		
		shape_info[1](),
	];

bottom_hole_size = [
	2*38.1 + 0.75*inch,
	         1*inch
];
underblock_hull_size = [
	bottom_hole_size[0] - sub_margin*2,
	bottom_hole_size[1] - sub_margin*2,
	1/4*inch
];
burthole = ["rotate", [180,0,0], tog_holelib2_hole("THL-1005", depth=100)];
tgp_y_groove = let(u=inch/16) tphl1_make_polyhedron_from_layer_function([-50,50], function(y) [[-2*u,y,0],[0,y,2*u],[2*u,y,0],[0,y,-2*u]]);

function make_underblock_convex_hull_2d() = togmod1_make_rounded_rect(underblock_hull_size, r=6);

function make_underblock_2d_subtractions(
	include_center_hole=true,
	center_hole_size=[60,13]
) = [
	if( include_center_hole && center_hole_size[0] > 0 ) togmod1_make_rounded_rect(center_hole_size, r=3),
	["translate",
		[0,-underblock_hull_size[1]/2+(underblock_hull_size[1]-center_hole_size[1])/4],make_rounded_gap_cutter([13, (underblock_hull_size[1]-center_hole_size[1])/2], r=3)],
];

function make_underblock_hull_2d(
	include_center_hole=true,
	center_hole_size=[60,13]
) = ["difference",
	make_underblock_convex_hull_2d(),
	each make_underblock_2d_subtractions(include_center_hole=include_center_hole, center_hole_size=center_hole_size),
	//for( xm=[-1,1] ) ["translate", [xm*1.5*inch, 0], togmod1_make_circle(d=3)],
];

function make_underblock_convex_hull(
	height=1/4*inch,
	bottom_bevel_size = 1,
) =
let( hull2d = make_underblock_convex_hull_2d() )
["hull",
	["linear-extrude-zs", [0, (height+bottom_bevel_size)/2],	["offset-rs", -bottom_bevel_size, hull2d]],
	["linear-extrude-zs", [bottom_bevel_size, height], hull2d],
];

function make_underblock_hull(
	height=1/4*inch,
	include_center_hole=true,
	center_hole_size=[60,13],
	bottom_bevel_size = 1,
) = ["difference",
	make_underblock_convex_hull(height=height, bottom_bevel_size=bottom_bevel_size),
	["linear-extrude-zs", [-1, height+1], ["union", each make_underblock_2d_subtractions(include_center_hole=include_center_hole, center_hole_size=center_hole_size)]],
];
//let( hull2d = make_underblock_hull_2d(include_center_hole=include_center_hole, center_hole_size=center_hole_size) )
//["hull",
//	["linear-extrude-zs", [0, (height+bottom_bevel_size)/2],	["offset-rs", -bottom_bevel_size, hull2d]],
//	["linear-extrude-zs", [bottom_bevel_size, height], hull2d],
//];

function make_underblock_groove_subtractions() = [
	for( xm=[-0.5,0.5] ) ["translate", [xm*1.5*inch, 0, 0], tgp_y_groove],
];

function make_underblock_connector_hole_subtractions() = [
	for( xm=[-1,1] ) ["translate", [xm*1.5*inch, 0, 0], burthole],
];

function make_underblock_subtractions(include_connector_holes=true) = [
	each make_underblock_groove_subtractions(),
	if( include_connector_holes ) each make_underblock_connector_hole_subtractions(),
];

function make_underblock(
	height=1/4*inch,
	include_center_hole=true,
	center_hole_size=[60,13],
	bottom_bevel_size = 1.6,
) = ["difference",
	make_underblock_hull(height),
	each make_underblock_subtractions(),
];

function make_phi_with_underblock(style, include_connector_holes=false) =
	let(shape_info = is_list(style) ? style : get_shape_info(style))
	let($block_size = [4*inch, 1.25*inch, shape_info[0]])
	let($hull_size = [$block_size[0]-outer_margin*2, $block_size[1]-outer_margin*2, $block_size[2]])
	let($integrated_underblock = true)
	["difference",
		["union",
			make_underblock_hull(1/4*inch + 1, include_center_hole=false),
			["translate", [0,0,1/4*inch], make_phi_hull()],
		],
		["translate", [0,0,1/4*inch], let($vcut_zrange = [-1/4*inch-1, $block_size[2]+1]) shape_info[1]()],
		each make_underblock_subtractions(include_connector_holes=include_connector_holes),
	];


// PHI-1001 = A very basic phone holder insert

function make_thing(name, integrated_underblock=false) =
	name == "PHI-1005+sub" ? ["union",
		["translate", [0,  38.1, 0], make_thing("PHI-1005")],
		["translate", [0, -38.1, 0], make_thing("PHI-1005-sub")],
	] :
	name == "PHI-1005-sub" ? make_underblock() :
	name == "PHI-1005-IU" ? make_phi_with_underblock("PHI-1005", include_connector_holes=true) :
	name == "PHI-1006-IU" ? make_phi_with_underblock("PHI-1006", include_connector_holes=false) :
	name == "PHI-1007-IU" ? make_phi_with_underblock("PHI-1007", include_connector_holes=true) :
	integrated_underblock ? make_phi_with_underblock(name) : make_phi(name);

thing = make_thing(style);

togmod1_domodule(thing);
