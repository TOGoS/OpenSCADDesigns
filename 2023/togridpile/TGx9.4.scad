// TGx9.5.31 - Full-featured-but-getting-crufty TOGridPile shape w/ option of rounded beveled corners
//
// Version numbering:
// M.I.C.R
// - Major shape version
// - mInor shape variation
// - minor Change to functionality/parameters
// - non-functionality-altering Refactoring
//
// 9.1.0:
// - Initial demo of simple atomic feet
// 9.1.1:
// - Extrude foot shape along path for smooth chunk feet
// - New approach to configurable per-chunk additions/subtractions, using chunk_child_ops.
//   Idea being that applying the modifications per-chunk will allow OpenSCAD
//   to cache the results more easily than going back over the whole block,
//   visiting the chunks twice.
// - Margin/offset is not yet being taken into account!  Probably don't print this.
// 9.1.2:
// - Offset points to be extruded
// 9.1.3:
// - Add THL-1001 holes
// - Note that the `child_ops` thing doesn't actually work; bummersauce!
//   Need to either transpile my own language to OpenSCAD or hack in a way
//   to pass modules by name (["module_name", arg1, arg2, ...] kind of thing)
// - Fix that `atomic_chunk_foot` didn't take or use `offset`
// 9.1.4:
// - Different corner radius for bottom (1/4") and top (3/16", for [near?] compatibility with other designs)
// 9.1.5:
// - Fix to avoid CGAL error for short blocks
// 9.1.6:
// - Refactor child_ops stuff to a more general S-expression system, where 'child' is one possible named module
// 9.1.7:
// - Massive refactoring to replace various unit parameters with the
//   $tgx9_unit_table 'special' (i.e. dynamic scoped) variable
//   and use the new TOGUnitTable-v1.scad library.
// - Still no magnet holes in the bottom lol sorry
// - No cup cavity, either!
// 9.1.8:
// - Configure block X/Y and Z sizes separately,
//   since it's inconvenient to specify them in the same units.
// 9.1.9:
// - Cavity!
// - Add an ad hoc, informally-specified, bug-ridden, slow implementation of lisp,
//   then comment most of it out.
// - Add more types of shapes that tgx9_do_sshape (formerly tgx9_do_module) can do:
//   - translate, the_cup_cavity, tgx9_usermod_1, and tgx9_usermod_2!
// 9.1.10:
// - Give cavity beveled corners using extrude_along_loop technology
// 9.1.11:
// - Make 'label magnet holes' separate from 'top magnet holes' to avoid
//   extraneous cuts into the lip
// 9.1.12:
// - lip_segmentation = "block"|"chunk".
// 9.1.13:
// - Support foot chunk additions when segmentation="block"
// 9.1.13.1:
// - Fix a tab lmao
// 9.2.0:
// - Bevel the outer hull, and then round that, such that it fits within either
//   the requested rounding radius or the standard beveled rectangle.
// - Magnet hole depth is configurable
// 9.2.1:
// - Fix that offset wasn't being taken into account when generating rounded beveled block hull
//   (i.e. tgx9_smooth_foot)
// 9.2.2:
// - Make bevel size configurable, do the math to determine rounded corner squishing accordingly
// - Change default settings to be a simpler block (1x1x1; no magnet/screw holes)
// - Change default magnet hole depth to 2.2mm;
// 9.2.2.1:
// - Don't really need a sqrt2 constant
// 9.3:
// - Add option to subtract tgx1001_v6hc_block_subtractor from lip
// 9.3.1:
// - Adjust default magnet hole depth to 2.4mm
// - Adjust default label width to 10.0mm
// 9.3.2:
// - Trim sublip from above fingerslide
// 9.3.2.1:
// - Refactor some for loops to use tgx9_chunk_xy_positions
// 9.3.2.2:
// - Note that label_width parameter specifies width from edge of cavity
// 9.3.3:
// - Rewrite dimension decoding to use TOGridPileLib-v3
// 9.3.4:
// - tgx9_1_0_block_foot supports 'none' segmentation, which gives you one big cube
// 9.3.5:
// - Fill in body underside between atoms/chunks
// 9.3.6:
// - Fix trimming of sublip above fingerslide to be in the right place
// 9.3.7:
// - Separate option to trim front sublip
// 9.3.8:
// - sublip_slope, defaulting to 2
// 9.3.10:
// - Fix that screw holes got blocked by the block body bottom
// 9.4:
// - Move core function and module definitions to TGx9Lib-v1.scad
// - Simplify some function names
// - Explicitly pass foot_segmentation to tgx9_cup
// 9.4.10:
// - Update `togridpile3` -> `togridlib3` prefixes
// 9.4.11:
// - Move margin and $fn parameters to 'Detail' section
// 9.5.0:
// - Add 'chatom' foot segmentation, which is similar to v6 or v8
// 9.5.1:
// - Different options for chatomic_foot_column_style
// 9.5.2:
// - Allow "atom", "chatom" lip segmentation so long as lip height <= 0
// 9.5.3:
// - Add support for 'tograck' cavity
// 9.5.3.1:
// - Refactor to use "union" sshape
// 9.5.4:
// - Add configuration for TOGRack sublips
// v9.5.5:
// - `label_magnet_holes_enabled` is now deprecated and a synonym for
//   `top_magnet_holes_enabled`.
// - Calculate top magnet hole positions differently based on cavity style
// v9.5.6:
// - Default TOGRack cavity rim modes to 'none' for compatibility with v9.5.3 presets
// - Add experimental TOGRack conduit subtraction option
// v9.5.7:
// - Don't try to make cup cavity with any negative dimension
// - Force cavity corner radius to be at least 1u
// - Bulkhead thickness can be configured, but defaults to -1, which means
//   'wall thickness or 1.2mm, whichever is smaller'
// v9.5.8:
// - Remove special "all" case for chunk-based top magnet holes; 'twas more trouble than it was worth!
// v9.5.9:
// - Allow you to make cup holders by setting cup_holder_radii, cup_holder_depths
// v9.5.13:
// - Deprecate v6hc_subtraction_enabled in favor of v6hc_subtraction_style,
//   which allows v6.1-compatible subtractions.
// v9.5.14:
// - Allow foot_segmentation = "none", which may be useful for making base plates
// v9.5.15:
// - Now you can make bowtie edges!
// v9.5.16:
// - Allow chunk center and edge holes to be configured separately
// - For hole purposes, clamp floor thickness to block height
// v9.5.17:
// - "none" is a valid foot column style
// v9.5.18:
// - s/cup_holder_radii/cup_holder_diameters/ - they were never radius!
// v9.5.19:
// - Actually use u, atom_pitch_u, and chunk_pitch_atoms to construct unit table!
// v9.5.19.1:
// - Explicitly pass cavity_corner_radius to tgx9_cavity_cube,
//   since it's no longer magically derived from global variables
//   in TGx9.4Lib-v1.18
// v9.5.20:
// - 'v6hc_style' option to add 'v6 horizontal columns' across the bottom
// v9.5.21:
// - cavity_corner_radius is now configurable
// - sublip_width is now configurable
// v9.5.22:
// - Add framework-module-holder cavity type
// v9.5.23:
// - Add earrings-holder
// v9.5.24:
// - Fix framework-module-holder's USB-C connector pockets to be wide enough
// v9.5.25:
// - Make framework-module-holder's slots a wee bit deeper (35mm instead of 33mm)
// v9.5.26:
// - Options for mug handle cutout
// - Option to simplify foot in preview mode, for when you're messing with
//   cavity settings and don't want to wait so long between previews
// v9.5.27:
// - 'gencase1' cavity mode, for making 'generic open-sided cases' for things
// v9.5.28:
// - Fix that lip_segmentation was not explicitly passed to tgx9_cup
// v9.5.29:
// - Add 'gencase_brick_size' option, which, if nonzero, alters
//   the gencase0 subtraction and adds a brick to the preview
// - Hack for certain gencases (e.g. p1509) to give them more mounting holes
// v9.5.30:
// - Add cr2032-holder cavity mode
// - Change default margin from 0.075mm to 0.1mm
// v9.5.31:
// - Reduce width and corner radius of overcav[ity]

/* [Atom/chunk/block size] */

// Base unit; 1.5875mm = 1/16"
u = 1.5875; // 0.0001
atom_pitch_u = 8;
chunk_pitch_atoms = 3;
// X/Y block size, in chunks:
block_size_chunks = [1, 1];
// Block height, in 'u', not including lip
block_height_u    = 24;
// Height that lip extends beyond top; 0 for no lip, -1 for an inverted lip; 1.58 is just under 1/16"
lip_height = 2.54;
foot_segmentation = "chunk"; // ["atom","chatom","chunk","block","none"]
// Foot column shape; only applicable when foot_segmentation = "chatom"
chatomic_foot_column_style = "v8.0"; // ["none", "v6.0", "v6.1", "v6.2", "v8.0", "v8.4"]
// Segmentation for lip; 'atom' and 'chatom' not advised unless lip is inverted
lip_segmentation = "block"; // ["atom","chatom","chunk","block"]

// 'standard bevel size', in 'u'; usually the standard bevel size is 2u = 1/8" = 3.175mm
bevel_size_u = 2;

v6hc_style = "none"; // ["none","v6.0","v6.1","v6.2"]

// Deprecated; use v6hc_subtraction_style, instead
v6hc_subtraction_enabled = false;
// Subtract from lip such that blocks with horizontal v6 (or v8) columns can fit?  Recommended value: v6.1
v6hc_subtraction_style = "legacy"; // ["legacy","none","v6.0","v6.1"]

// Squash too-sharp rounded corners to fit in 1/8" bevels
$tgx9_force_bevel_rounded_corners = true;

/* [Connectors] */

magnet_hole_diameter = 6.2; // 0.1
magnet_hole_depth    = 2.4; // 0.1
bottom_magnet_holes_enabled = false;
// Deprecated; just use top_magnet_holes_enabled
label_magnet_holes_enabled = false;
top_magnet_holes_enabled = false;
// Style for both center and edge screws; leave this "none" to configure them separately
screw_hole_style = "none"; // ["none","THL-1001","THL-1002"]
chunk_center_screw_hole_style = "none"; // ["none","THL-1001","THL-1002"]
chunk_edge_screw_hole_style = "none"; // ["none","THL-1001","THL-1002"]
// Note that 'north, east, south, west' is the same order as CSS uses for e.g. margins.
// Whether to put bowtie cutouts along [N,E,S,W] (0 for no, 1 for yes)
bowtie_edges = [0,0,0,0];

/* [Cavity] */

cavity_style = "cup"; // ["none","cup","tograck","framework-module-holder","earrings-holder","gencase1","cr2032-holder"]

wall_thickness     =  2;    // 0.1
floor_thickness    =  6.35; // 0.0001

/* [Cavity (Cup)] */

// Rim width
sublip_width       = 3;
// Inverse slope (Y/X) of underside of rim
sublip_slope       = 2;

// How far label platform sticks out from the inside of the cup
label_width        = 10.0 ; // 0.1
fingerslide_radius = 12.5 ; // 0.1
// dz/dx of sublip; minimum is 1 = 45 degrees, 2 may be gentler
trim_front_sublip  = false;
cavity_bulkhead_positions = [];
cavity_bulkhead_axis = "x"; // ["x", "y"]
// Bulkhead thickness; -1 means default based on min(wall_thickness, 1.2mm)
bulkhead_thickness = -1; // [-1 : 0.1 : 4]
// Radius of cavity corners; -1 defaults to calculation based on outer radius and wall thickness
cavity_corner_radius = -1;

// Diameters (in mm) of cup holder cutouts, from innermost to outermost
cup_holder_diameters = [];
// Depths of cup holder cutouts, from innermost to outermost
cup_holder_depths = [];

mug_handle_cutout_depth = 0;
mug_handle_cutout_width = 0;

/* [Cavity (TOGRack)] */

tograck_upper_cavity_rim_mode = "none"; // ["none","x","full"]
tograck_lower_cavity_rim_mode = "none"; // ["none","x","full"]

// Experimental/unstable
x_tograck_conduit_diameter = 0;

/* [Cavity (gencase)] */

// Whether to leave the [N,E,S,W] sides open for the 'gencase1' cavity
gencase_open_sides = [0,0,0,0];
// Size of brick to be subtracted and shown in preview, if non-zero
gencase_brick_size = [0,0,0];

/* [Detail] */

// Margin for TOGridPile mating surfaces
margin = 0.10; // 0.01
// Margin for bowtie cutouts; Since they are supposed to be tight, I usually leave this zero and rely on Slic3r X/Y compenation.
bowtie_margin = 0.000; // 0.001

render_fn = 36;

/* [Preview] */

preview_fn = 12;
simplify_foot_for_preview = false;

module tgx9__end_params() { }

$fn = $preview ? preview_fn : render_fn;

assert( len(cup_holder_diameters) == len(cup_holder_depths), "Cup holder radius and depth lists should be the same length");

effective_bulkhead_thickness = bulkhead_thickness > 0 ? bulkhead_thickness : min(1.2, wall_thickness);
top_magnet_holes_enabled2 = top_magnet_holes_enabled || label_magnet_holes_enabled;

if( lip_height > 0 ) {
	assert(
		lip_segmentation != "atom" && lip_segmentation != "chatom",
		"'atom' lip segmentation only supported when lip_height <= 0"
	);
}

// use <../lib/TOGShapeLib-v1.scad>
use <../lib/TOGHoleLib-v1.scad>
use <../lib/TOGHoleLib2.scad>
// use <../lib/TOGUnitTable-v1.scad>
use <../lib/TOGridLib3.scad>
include <../lib/TGx9.4Lib.scad>

function volume_is_positive(size, index=0) =
	index == len(size) || (size[index] > 0 && volume_is_positive(size, index+1));

if( false ) undefined_module(); // Doesn't crash OpenSCAD

$tgx9_mating_offset = -margin;

// effective_floor_thickness = min(floor_thickness, block_size[2]);

$togridlib3_unit_table = [
	["u"    , [                u,   "mm"],     "u"],
	["atom" , [     atom_pitch_u,    "u"],  "atom"],
	["chunk", [chunk_pitch_atoms, "atom"], "chunk"],
	each togridlib3_get_unit_table(),
];

atom_pitch  = togridlib3_decode([1, "atom"]);
chunk_pitch = togridlib3_decode([1, "chunk"]);
block_size_ca = [
	[block_size_chunks[0], "chunk"],
	[block_size_chunks[1], "chunk"],
	[block_height_u, "u"]
					  ];
block_size  = [
	block_size_chunks[0] * chunk_pitch,
	block_size_chunks[1] * chunk_pitch,
	block_height_u * u
];

//// Cavity stuff

cavity_size = [
	block_size[0] - wall_thickness*2 + $tgx9_mating_offset*2,
	block_size[1] - wall_thickness*2 + $tgx9_mating_offset*2,
	block_size[2] - floor_thickness
];

module the_label_platform() {
	cs1 = [cavity_size[0]+0.1, cavity_size[1]+0.1]; // For sticking things in the walls
	if( label_width > 0 ) {
		label_angwid = label_width*2*sin(45);
		translate([-cs1[0]/2, 0, 0]) rotate([0,45,0]) cube([label_angwid,block_size[1],label_angwid], center=true);
	}
}

module the_fingerslide() {
	if( fingerslide_radius > 0 ) difference() {
		translate([cavity_size[0]/2, 0, 0])
			cube([fingerslide_radius*2, cavity_size[1]*2, fingerslide_radius*2], center=true);
		translate([cavity_size[0]/2-fingerslide_radius, 0, fingerslide_radius])
			rotate([90,0,0]) cylinder(r=fingerslide_radius, h=cavity_size[1]*3, center=true, $fn=max(24,$fn));
	}
}

function kasjhd_swapxy(vec, swap=true) = [
	swap ? vec[1] : vec[0],
	swap ? vec[0] : vec[1],
	for( i=[2:1:len(vec)-1] ) vec[i]
];

function get_cavity_corner_radius() =
	!is_undef(cavity_corner_radius) && cavity_corner_radius >= 0 ? cavity_corner_radius :
	max(
		togridlib3_decode([1, "u"]),
		togridlib3_decode([1, "f-outer-corner-radius"]) - wall_thickness
	);

module the_cup_cavity() if(volume_is_positive(cavity_size)) difference() {
	cavity_corner_radius    = get_cavity_corner_radius();
	// Double-height cavity size, to cut through any lip protrusions, etc:
	dh_cavity_size = [cavity_size[0], cavity_size[1], cavity_size[2]*2];
	//tog_shapelib_xy_rounded_cube(dh_cavity_size, corner_radius=cavity_corner_radius);

	top_bevel_width = sublip_width;
	top_bevel_height = top_bevel_width*sublip_slope;
	
	union() {
		profile_points = tgx9_offset_points(tgx9_cavity_side_profile_points(
			cavity_size[2], cavity_corner_radius,
			top_bevel_width=top_bevel_width,
			top_bevel_height=top_bevel_height
		));
		
		translate([0,0,-cavity_size[2]])
			tgx9_rounded_profile_extruded_square(dh_cavity_size, cavity_corner_radius, z_offset=0)
				polygon(profile_points);

		if( trim_front_sublip ) {
			// Trim sublip from fingerslide end;
			too_fancy = 0; // -profile_points[len(profile_points)-2][0]*2;
			translate([cavity_size[0]/2-top_bevel_width,0,0]) cube([top_bevel_width*2, cavity_size[1]-cavity_corner_radius*2+too_fancy, top_bevel_height*2], center=true);
		}
	}
	
	the_label_platform();
	translate([0,0,-cavity_size[2]]) the_fingerslide();
	for( i=cavity_bulkhead_positions ) {
		maybeswapxy = cavity_bulkhead_axis == "x" ? function(v) kasjhd_swapxy(v) : function(v) v;
		bulkhead_length = cavity_bulkhead_axis == "x" ? block_size[0] : block_size[1];
		translate(maybeswapxy([i,0,0])) cube(maybeswapxy([effective_bulkhead_thickness, bulkhead_length, block_size[2]*2]), center=true);
	}
}

module tgx9_usermod_1(what, arg0) {
	if( what == "chunk-magnet-holes" ) {
		for( pos=[[-1,-1],[1,-1],[-1,1],[1,1]] ) {
			translate(pos*atom_pitch) cylinder(d=magnet_hole_diameter, h=magnet_hole_depth*2, center=true);
		}
	} else if( what == "chunk-screw-holes" ) {
		for( pos=[[0,-1],[-1,0],[0,1],[1,0],[0,0]] ) {
			translate(pos*atom_pitch) tog_holelib_hole(arg0 == undef ? screw_hole_style : arg0, overhead_bore_height=13);
		}
	} else if( what == "chunk-center-screw-hole" ) {
		for( pos=[[0,0]] ) {
			translate(pos*atom_pitch) tog_holelib_hole(arg0 == undef ? screw_hole_style : arg0, overhead_bore_height=13);
		}
	} else if( what == "chunk-edge-screw-holes" ) {
		for( pos=[[0,-1],[-1,0],[0,1],[1,0]] ) {
			translate(pos*atom_pitch) tog_holelib_hole(arg0 == undef ? screw_hole_style : arg0, overhead_bore_height=13);
		}
	} else {
		assert(false, str("Unrecognized user module argument: '", what, "'"));
	}
}

effective_v6hc_subtraction_style =
	v6hc_subtraction_style == "legacy" ? (v6hc_subtraction_enabled ? "v6.0" : "none") :
	v6hc_subtraction_style;

if( effective_v6hc_subtraction_style != "none" && lip_height <= u-margin ) {
	echo(str(
		"effective_v6hc_subtraction_style = \"",effective_v6hc_subtraction_style, "\", ",
		"but not needed due to low lip (assuming column inset=1u, ",
		"which is standard), so I won't bother to actually subtract it"
	));
}

tograck_lower_cavity_depth = min(block_size[2]-floor_thickness-3.175, 19.05);
tograck_upper_cavity_depth = max(3.175, block_size[2]-tograck_lower_cavity_depth-floor_thickness);
effective_cavity_corner_radius = get_cavity_corner_radius();

function rimless_cavity_sshape(size)   = ["translate", [0,0,8], ["tgx9_cavity_cube", [size[0], size[1], size[2]+8], effective_cavity_corner_radius]];
function y_rimless_cavity_sshape(size) = ["intersection",
	["translate", [0,0,0], ["tgx9_cavity_cube", [size[0], size[1]*2, size[2]], effective_cavity_corner_radius]],
	["translate", [0,0,8], ["tgx9_cavity_cube", [size[0], size[1], size[2]+8], effective_cavity_corner_radius]] // z+8 to clear sublip
];
function modified_cavity_sshape(size, rim_mode="full") =
	rim_mode == "full" ? ["tgx9_cavity_cube", size, effective_cavity_corner_radius] :
	rim_mode == "x"    ? y_rimless_cavity_sshape(size) :
	rim_mode == "none" ? rimless_cavity_sshape(size) :
	assert(false, str("Bad rim_mode to `modified_cavity_sshape`: '", rim_mode, "'"));

function tograck_cavity_sshape() = ["union",
	// TODO: leave sublips on the +x and -x top edges
	// TODO: wire conduit through the otherwise unused space along -y and +y
	modified_cavity_sshape([block_size[0]-wall_thickness*2, 88.9, tograck_upper_cavity_depth], tograck_upper_cavity_rim_mode),
	["translate", [0,0,-tograck_upper_cavity_depth], modified_cavity_sshape([block_size[0]-wall_thickness*2, 63.5, tograck_lower_cavity_depth], tograck_lower_cavity_rim_mode)],
	for( xm=[-(block_size[0]/12.7/2)+0.5 : 1 : block_size[0]/12.7/2-0.4] ) for( ym=[-3, 3] )
		let(pos=[xm*12.7, ym*12.7, -block_size[2]]) ["translate", pos, ["cylinder", 5, (block_size[2]-8)*2]], // -8 to avoid cutting through upper sublip
	for( xm=[0 : 1 : block_size[0]/12.7] ) for( ym=[0] )
		let(pos=[-block_size[0]/2+(xm+0.5)*12.7, ym*12.7, -block_size[2]+floor_thickness]) ["translate", pos, [xm % 3 == 1 ? "THL-1002" : "THL-1001", floor_thickness*2, 2]],
	for( xm=[-(block_size[0]/12.7/2)+1.5 : 3 : block_size[0]/12.7/2-0.4] ) for( ym=[-2, -1, 0, 1, 2] )
		let(pos=[xm*12.7, ym*12.7, -block_size[2]+floor_thickness]) ["translate", pos, ["THL-1001", floor_thickness*2, block_size[2]]],
];

use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGMod1Constructors.scad>

function make_framework_module_holder_cutout(count) =
let( spacing = 12.7 )
// 33 is enough for the modules; 36 should be enough for the uSD card
// and maybe something another mm deeper, in case the need arises
let( module_depth = 36 )
let( usb_c_cutout_size = [10, 3.175, 10] )
let( finger_notch_width = 19.05 )
let( finger_notch_depth = 22 )
["union",
	for( ym=[-count/2 + 0.5 : 1 : count/2] )
	["translate", [0, spacing*ym, 0], ["union",
		tphl1_make_rounded_cuboid([32, 7.5, module_depth*2], r=[0.3, 0.3, 0], $fn=8),
		["translate", [0,0,-module_depth], tphl1_make_rounded_cuboid(
			[usb_c_cutout_size[0], usb_c_cutout_size[1], usb_c_cutout_size[2]*2],
			r=[1.5, 1.5, 0], $fn=8)
		],
	]],
	tphl1_make_rounded_cuboid([finger_notch_width, (count+1)*spacing, finger_notch_depth], r=finger_notch_width/2)
];

function make_earrings_holder_cutout(size) =
let( wall_thickness = 4 )
let( depth = (size[2]-floor_thickness) )
let( magcone = tphl1_make_polyhedron_from_layer_function([
	[-18, 0],
	[  1, 8],
], function(params) togmod1_circle_points(r=params[1], pos=[0,0,params[0]])) )
["difference",
	tphl1_make_rounded_cuboid([size[0]-wall_thickness*2, size[1]-wall_thickness*2, depth*2], r=2),
	
	for( ym=[-size[1]/12.7/2+1 : 1 : size[1]/12.7/2] )
	["translate", [0,ym*12.7,-depth], tphl1_make_rounded_cuboid([size[0], 2, (depth-3)*2], r=1)],
	
	if( top_magnet_holes_enabled ) for( xm=[-1,1] ) for( ym=[-1,1] )
	["translate", [xm*(block_size[0]/2-wall_thickness), ym*(block_size[1]/2-wall_thickness)], magcone],
];

function make_mug_handle_cutout(width, depth, cornervec) =
let( cvx = cornervec[0]-width/3.1, cvy = cornervec[1]-width/3.1 ) // 1/3 pulled out of nowhere but seems to work
["translate", [cvx/2, cvy/2, 0],
	["rotate", [0,0,atan2(cvy,cvx)],
		tphl1_make_rounded_cuboid(
			[sqrt(cvx*cvx + cvy*cvy), width, depth*2],
			r=[width/2, width/2, depth/2],
			corner_shape="ovoid1"
		)
	]
];

function lerp(v0, v1, t) = (1-t)*v0 + t*v1;

// Open-sided box for making 'generic' cases.
// You're expected to put a bunch of hot glue in there or something
// to hold your thing in place.
function make_gencase1_main_subtraction(block_size, floor_thickness, opening_widths=[0,0,0,0]) = tphl1_make_polyhedron_from_layer_function(
	[
		floor_thickness - block_size[2],
		block_size[2]*2 - block_size[2],
	],
	let(open_sides = [for(w=opening_widths) w > 0 ? 1 : 0])
	// TODO: Refactor so that top/bottom/left/right widths can be different
	let(xins1 = (block_size[0]-max(opening_widths[0],opening_widths[2]))/2 )
	let(xins0 = xins1-2)
	let(yins1 = (block_size[1]-max(opening_widths[1],opening_widths[3]))/2 )
	let(yins0 = yins1-2)
	let(x1 = -block_size[0]/2+xins0, x2 = -block_size[0]/2+xins1, x3 = block_size[0]/2-xins1, x4 = block_size[0]/2-xins0)
	let(x0 = lerp(x1, -block_size[0]/2-1, open_sides[3]))
	let(x5 = lerp(x4,  block_size[0]/2+1, open_sides[1]))
	let(y1 = -block_size[1]/2+yins0, y2 = -block_size[1]/2+yins1, y3 = block_size[1]/2-yins1, y4 = block_size[1]/2-yins0)
	let(y0 = lerp(y1, -block_size[1]/2-1, open_sides[2]))
	let(y5 = lerp(y4,  block_size[1]/2+1, open_sides[0]))
	function(z) [
		[x0, y2, z],
		[x1, y2, z],
		[x2, y1, z],
		[x2, y0, z],
		[x3, y0, z],
		[x3, y1, z],
		[x4, y2, z],
		[x5, y2, z],
		[x5, y3, z],
		[x4, y3, z],
		[x3, y4, z],
		[x3, y5, z],
		[x2, y5, z],
		[x2, y4, z],
		[x1, y3, z],
		[x0, y3, z],
	]
);

function make_gencase1_subtraction(block_size, floor_thickness, open_sides=[0,0,0,0], brick_size=[0,0,0]) =
	["union",
		make_gencase1_main_subtraction(block_size, floor_thickness, opening_widths=[
			// Logic to avoid user having to enter opening widths,
			// though maybe that should be possible, with some special
			// value (maybe -1) meaning 'auto'
			open_sides[0] > 0 ? (brick_size[0] == 0 ? block_size - 20 : brick_size[0])-4 : 0,
			open_sides[1] > 0 ? (brick_size[1] == 0 ? block_size - 20 : brick_size[1])-4 : 0,
			open_sides[2] > 0 ? (brick_size[0] == 0 ? block_size - 20 : brick_size[0])-4 : 0,
			open_sides[3] > 0 ? (brick_size[1] == 0 ? block_size - 20 : brick_size[1])-4 : 0,
		]),
		
		if( brick_size[0] > 0 && brick_size[1] > 0 && brick_size[2] > 0 )
		["translate", [0,0,-block_size[2]/2+floor_thickness-0.1], tphl1_make_rounded_cuboid([brick_size[0],brick_size[1],block_size[2]], r=[1,1,0])],
	];

function make_cr2032_subtraction(block_size, cell_size=[22, 4.0]) =
let( overcav_size = [min(cell_size[0]+8, block_size[0]-wall_thickness*4), block_size[1]-wall_thickness*2, 6.35] )
let( spacing = cell_size[1] + 2 )
let( count = floor(overcav_size[1] / spacing) )
// 33 is enough for the modules; 36 should be enough for the uSD card
// and maybe something another mm deeper, in case the need arises
let( finger_notch_width = 16 )
let( xq = (cell_size[0] - finger_notch_width)/2 )
let( finger_notch_depth = cell_size[0]-xq )
["union",
	tphl1_make_rounded_cuboid([overcav_size[0], overcav_size[1], overcav_size[2]*2], r=[6.35, 6.35, 0]),
	for( ym=[-count/2 + 0.5 : 1 : count/2] )
		["translate", [0, spacing*ym, 0], ["union",
			tphl1_make_rounded_cuboid([cell_size[0], cell_size[1], cell_size[0]*2], r=[cell_size[0]/2-0.1, 0, cell_size[0]/2-0.1], $fn=max($fn, 48)),
		]],
	["translate", [0,0,0],
		tphl1_make_rounded_cuboid(
			[finger_notch_width, overcav_size[1]-0.1, finger_notch_depth*2],
			r=[finger_notch_width/2, 0, finger_notch_width/2],
			$fn=max($fn, 24)
		)]
];

// Operations to be done on the block from the top center
cavity_ops = [
	if( cavity_style == "cup" ) if( floor_thickness < block_size[2]) ["subtract",["the_cup_cavity"]],
	if( cavity_style == "cup" ) for(i=[0 : 1 : len(cup_holder_diameters)-1])
		if(cup_holder_diameters[i] > 0 && cup_holder_depths[i] > 0)
			["subtract",["beveled_cylinder",cup_holder_diameters[i],cup_holder_depths[i]*2,u]],
	if( mug_handle_cutout_width > 0 && mug_handle_cutout_depth > 0 )
		["subtract", make_mug_handle_cutout(mug_handle_cutout_width, mug_handle_cutout_depth, [block_size[0]/2-wall_thickness, block_size[1]/2-wall_thickness])],
	if( cavity_style == "tograck" ) ["subtract", tograck_cavity_sshape()],
	if( cavity_style == "framework-module-holder" ) ["subtract", make_framework_module_holder_cutout(block_size[1]/12.7)],
	if( cavity_style == "earrings-holder" ) ["subtract", make_earrings_holder_cutout(block_size)],
	if( cavity_style == "gencase1" ) ["subtract", make_gencase1_subtraction(
		block_size, floor_thickness=floor_thickness, open_sides=gencase_open_sides, brick_size=gencase_brick_size)],
	if( cavity_style == "cr2032-holder" ) ["subtract", make_cr2032_subtraction(block_size)],
];

//// Magnet hole precalculations

// Positions of top magnet holes unless they are on every chunk!
top_magnet_hole_positions =
	!top_magnet_holes_enabled2 ? [] :
	(cavity_style == "earrings-holder") ? [
		for( xm=[-1,1] ) for( ym=[-1,1] ) [xm*(block_size[0]/2 - atom_pitch/2), ym*(block_size[1]/2 - atom_pitch/2)]
	] :
	// TODO: Same for all but 'none', where they are (for dubious performance reasons) chunk based
	// TODO: Place magnet holes anywhere they'll fit, e.g. if wall_thickness > 1/2"
	(cavity_style == "cup" && label_width > atom_pitch/2) ? [
		for( cym=[-block_size_chunks[1]/2+0.5 : 1 : block_size_chunks[1]/2] )
		for( cxm=[-block_size_chunks[0]/2+0.5] )
		for( aym=[-chunk_pitch_atoms/2+0.5, chunk_pitch_atoms/2-0.5] )
		for( axm=[-chunk_pitch_atoms/2+0.5] )
			[cxm*chunk_pitch+axm*atom_pitch, cym*chunk_pitch+aym*atom_pitch]
	] :
	cavity_style == "tograck" ? [
		for( y=[-(block_size[1]+atom_pitch)/2+atom_pitch, (block_size[1]-atom_pitch)/2] )
		for( cxm=[-block_size_chunks[0]/2+0.5 : 1 : block_size_chunks[0]/2] )
		for( axm=[-chunk_pitch_atoms/2+0.5, chunk_pitch_atoms/2-0.5] )
			[cxm*chunk_pitch+axm*atom_pitch, y]
	] :
	cavity_style == "none" ? [
		for( cym=[-block_size_chunks[1]/2+0.5 : 1 : block_size_chunks[1]/2] )
		for( cxm=[-block_size_chunks[0]/2+0.5 : 1 : block_size_chunks[0]/2] )
		for( aym=[-chunk_pitch_atoms/2+0.5, chunk_pitch_atoms/2-0.5] )
		for( axm=[-chunk_pitch_atoms/2+0.5, chunk_pitch_atoms/2-0.5] )
			[cxm*chunk_pitch+axm*atom_pitch, cym*chunk_pitch+aym*atom_pitch]
	] :
	[];

chunk_magnet_hole_positions = [
	for( aym=[-chunk_pitch_atoms/2+0.5, chunk_pitch_atoms/2-0.5] )
	for( axm=[-chunk_pitch_atoms/2+0.5, chunk_pitch_atoms/2-0.5] )
		[axm*atom_pitch, aym*atom_pitch]
];

magnet_hole_sshape = ["cylinder", magnet_hole_diameter, magnet_hole_depth*2];
// Based on 2u outer bevels and 1u foot offset:
v6_0_foot_bevel_size = u * (sqrt(2)/2+1); // The funky one
v6_1_foot_bevel_size = u * sqrt(2); // The normal one
v6hc_foot_bevel_size =
	effective_v6hc_subtraction_style == "v6.0" ? v6_0_foot_bevel_size :
	effective_v6hc_subtraction_style == "v6.1" ? v6_1_foot_bevel_size :
	0.12345; // Not applicable

// This is a hacked-in thing for gencase.
// More general solution might be good.
// Like an array of bottom subtractions.

corner_bottom_up_screw_hole_style = cavity_style == "gencase1" ? "THL-1001" : "none";

bottom_up_hole_positions = [
	if( cavity_style == "gencase1" ) each [
		for( xm=[-1,1] ) for( ym=[-1,1] ) [xm*(block_size[0]/2-atom_pitch/2), ym*(block_size[1]/2-atom_pitch/2), 0],
		// Hack specifically for gencases with a closed left end
		// and enough room there for another row of holes:
		if( gencase_brick_size[0] > 0 && block_size[0] - gencase_brick_size[0] > 0.8*atom_pitch && gencase_open_sides[3] == 0 )
		for( ym=[-round(block_size[1]/atom_pitch)/2+1.5 : 1 : block_size[1]/atom_pitch/2-1] )
			[-1*(block_size[0]/2-atom_pitch/2), ym*atom_pitch, 0],
	]
];

preview_additions = ["union",
	if( cavity_style == "gencase1" && volume_is_positive(gencase_brick_size) )
	echo(gencase_brick_size)
	["translate", [0,0,floor_thickness+gencase_brick_size[2]/2], ["x-debug", togmod1_make_cuboid(gencase_brick_size)]]
];

//// Main

module tgx9_main_cup() tgx9_cup(
	block_size_ca = block_size_ca,
	foot_segmentation = ($preview && simplify_foot_for_preview) ? "none" : foot_segmentation,
	lip_height    = lip_height,
	lip_segmentation = lip_segmentation,
	floor_thickness = floor_thickness,
	wall_thickness = wall_thickness,
	v6hc_style = v6hc_style,
	$tgx9_chatomic_foot_column_style = chatomic_foot_column_style,
	block_top_ops = [
		each cavity_ops,
		if( is_list(top_magnet_hole_positions) ) ["subtract", ["union", for(pos=top_magnet_hole_positions) ["translate", pos, magnet_hole_sshape]]],
		// TODO (maybe, if it increases performance): If lip segmentation = "chunk", do this in lip_chunk_ops instead of for the whole block
		if( effective_v6hc_subtraction_style != "none" && lip_height > u-margin ) ["subtract",
			["tgx1001_v6hc_block_subtractor", block_size_ca, v6hc_foot_bevel_size]],
		if( cavity_style == "tograck" && x_tograck_conduit_diameter > 0 ) ["subtract", ["union",
			for( z=[atom_pitch : atom_pitch : block_size[2]-atom_pitch/2] )
			for( ym=[-1, 1] ) ["translate", [0, ym * (block_size[1]/2-atom_pitch*2/3), z-block_size[2]],
				["rotate", [0,90,0],
					["cylinder", x_tograck_conduit_diameter, block_size[0]*2]
				]
			],
			for( x=[-block_size[0]/2+atom_pitch*2 : atom_pitch : block_size[0]/2-atom_pitch*1.9] ) ["translate", [x, 0, atom_pitch-block_size[2]],
				["rotate", [90,0,0],
					["cylinder", x_tograck_conduit_diameter, block_size[1]*2]
				]
			]
		]],
	],
	lip_chunk_ops = [
		// if( top_magnet_hole_positions == "all" ) ["subtract", ["union", for(pos=chunk_magnet_hole_positions) ["translate", pos, magnet_hole_sshape]]],
	],
	bottom_chunk_ops = [
		["subtract",["translate", [0, 0, min(floor_thickness,block_size[2])], ["tgx9_usermod_1", "chunk-screw-holes", screw_hole_style]]],
		["subtract",["translate", [0, 0, min(floor_thickness,block_size[2])], ["tgx9_usermod_1", "chunk-center-screw-hole", chunk_center_screw_hole_style]]],
		["subtract",["translate", [0, 0, min(floor_thickness,block_size[2])], ["tgx9_usermod_1", "chunk-edge-screw-holes", chunk_edge_screw_hole_style]]],
		if( bottom_magnet_holes_enabled ) ["subtract",["tgx9_usermod_1", "chunk-magnet-holes"]],
	],
	block_bottom_ops = [
		let(hole=["rotate", [180,0,0], tog_holelib2_hole(corner_bottom_up_screw_hole_style, overhead_bore_height=1, inset=max(1, floor_thickness-4), depth=block_size[2]*2)])
			for( pos=bottom_up_hole_positions )
				["subtract", ["translate", pos, hole]]
				
	]
);

include <../lib/BowtieLib-v0.scad>

difference() {
	tgx9_main_cup();

	linear_extrude(100, center=true) {
		edge_bowties(block_size, bowtie_edges=bowtie_edges, offset=bowtie_margin);
	}
}

if( $preview ) tgx9_do_sshape(preview_additions);
