// TGx9.5.8 - experimental simplified (for OpenSCAD rendering purposes) TOGridPile shape
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

/* [Atom/chunk/block size] */

// Base unit; 1.5875mm = 1/16"
u = 1.5875; // 0.0001
atom_pitch_u = 8;
chunk_pitch_atoms = 3;
// X/Y block size, in chunks:
block_size_chunks = [1, 1];
// Block height, in 'u', not including lip
block_height_u    = 24;
// Height that lip extends beyond top; 0 for no lip, -1 for an inverted lip
lip_height = 2.54;
foot_segmentation = "chunk"; // ["atom","chatom","chunk","block"]
// Foot column shape; only applicable when foot_segmentation = "chunk"
chatomic_foot_column_style = "v8.0"; // ["v6.0", "v6.1", "v6.2", "v8.0", "v8.4"]
// Segmentation for lip; 'atom' and 'chatom' not advised unless lip is inverted
lip_segmentation = "block"; // ["atom","chatom","chunk","block"]

// 'standard bevel size', in 'u'; usually the standard bevel size is 2u = 1/8" = 3.175mm
bevel_size_u = 2;

// Subtract from lip such that blocks with horizontal v6 (or v8) columns can fit
v6hc_subtraction_enabled = false;

// Squash too-sharp rounded corners to fit in 1/8" bevels
$tgx9_force_bevel_rounded_corners = true;

/* [Connectors] */

magnet_hole_diameter = 6.2; // 0.1
magnet_hole_depth    = 2.4; // 0.1
bottom_magnet_holes_enabled = false;
// Deprecated; just use top_magnet_holes_enabled
label_magnet_holes_enabled = false;
top_magnet_holes_enabled = false;
screw_hole_style = "none"; // ["none","THL-1001","THL-1002"]

/* [Cavity] */

cavity_style = "cup"; // ["none","cup","tograck"]

wall_thickness     =  2;    // 0.1
floor_thickness    =  6.35; // 0.0001
sublip_slope       = 2;

/* [Cavity (Cup)] */

// How far label platform sticks out from the inside of the cup
label_width        = 10.0 ; // 0.1
fingerslide_radius = 12.5 ; // 0.1
// dz/dx of sublip; minimum is 1 = 45 degrees, 2 may be gentler
trim_front_sublip  = false;
cavity_bulkhead_positions = [];
cavity_bulkhead_axis = "x"; // ["x", "y"]
// Bulkhead thickness; -1 means default based on min(wall_thickness, 1.2mm)
bulkhead_thickness = -1; // [-1 : 0.1 : 4]

/* [Cavity (TOGRack)] */

tograck_upper_cavity_rim_mode = "none"; // ["none","x","full"]
tograck_lower_cavity_rim_mode = "none"; // ["none","x","full"]

// Experimental/unstable
x_tograck_conduit_diameter = 0;

/* [Detail] */

margin = 0.075; // 0.001

preview_fn = 12;
render_fn = 36;

$fn = $preview ? preview_fn : render_fn;

module tgx9__end_params() { }

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
// use <../lib/TOGUnitTable-v1.scad>
use <../lib/TOGridLib3.scad>
include <../lib/TGx9.4Lib.scad>

if( false ) undefined_module(); // Doesn't crash OpenSCAD

$tgx9_mating_offset = -margin;

// effective_floor_thickness = min(floor_thickness, block_size[2]);

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

module the_cup_cavity() if(cavity_size[0] > 0 && cavity_size[1] > 0 && cavity_size[2] > 0) difference() {
	outer_corner_radius     = togridlib3_decode([1, "f-outer-corner-radius"]);
	cavity_corner_radius    = max(togridlib3_decode([1, "u"]), outer_corner_radius - wall_thickness);
	// Double-height cavity size, to cut through any lip protrusions, etc:
	dh_cavity_size = [cavity_size[0], cavity_size[1], cavity_size[2]*2];
	//tog_shapelib_xy_rounded_cube(dh_cavity_size, corner_radius=cavity_corner_radius);

	top_bevel_width = 3;
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
			translate(pos*atom_pitch) tog_holelib_hole(arg0 == undef ? screw_hole_style : arg0);
		}
	} else {
		assert(false, str("Unrecognized user module argument: '", what, "'"));
	}
}

if( v6hc_subtraction_enabled && lip_height <= u-margin ) {
	echo("v6hc_subtraction_enabled enabled but not needed due to low lip (assuming column inset=1u, which is standard), so I won't bother to actually subtract it");
}

tograck_lower_cavity_depth = min(block_size[2]-floor_thickness-3.175, 19.05);
tograck_upper_cavity_depth = max(3.175, block_size[2]-tograck_lower_cavity_depth-floor_thickness);

function rimless_cavity_sshape(size)   = ["translate", [0,0,8], ["tgx9_cavity_cube", [size[0], size[1], size[2]+8]]];
function y_rimless_cavity_sshape(size) = ["intersection",
	["translate", [0,0,0], ["tgx9_cavity_cube", [size[0], size[1]*2, size[2]]]],
	["translate", [0,0,8], ["tgx9_cavity_cube", [size[0], size[1], size[2]+8]]] // z+8 to clear sublip
];
function modified_cavity_sshape(size, rim_mode="full") =
	rim_mode == "full" ? ["tgx9_cavity_cube", size] :
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

cavity_ops = [
	if( cavity_style == "cup" ) if( floor_thickness < block_size[2]) ["subtract",["the_cup_cavity"]],
	if( cavity_style == "tograck" ) ["subtract", tograck_cavity_sshape()]
];

//// Magnet hole precalculations

// Positions of top magnet holes unless they are on every chunk!
top_magnet_hole_positions =
	!top_magnet_holes_enabled2 ? [] :
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

//// Main

tgx9_cup(
	block_size_ca = block_size_ca,
	foot_segmentation = foot_segmentation,
	lip_height    = lip_height,
	floor_thickness = floor_thickness,
	wall_thickness = wall_thickness,
	$tgx9_chatomic_foot_column_style = chatomic_foot_column_style,
	block_top_ops = [
		each cavity_ops,
		if( is_list(top_magnet_hole_positions) ) ["subtract", ["union", for(pos=top_magnet_hole_positions) ["translate", pos, magnet_hole_sshape]]],
		// TODO (maybe, if it increases performance): If lip segmentation = "chunk", do this in lip_chunk_ops instead of for the whole block
		if( v6hc_subtraction_enabled && lip_height > u-margin ) ["subtract", ["tgx1001_v6hc_block_subtractor", block_size_ca]],
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
		["subtract",["translate", [0, 0, floor_thickness], ["tgx9_usermod_1", "chunk-screw-holes"]]],
		if( bottom_magnet_holes_enabled ) ["subtract",["tgx9_usermod_1", "chunk-magnet-holes"]],
	]
);
