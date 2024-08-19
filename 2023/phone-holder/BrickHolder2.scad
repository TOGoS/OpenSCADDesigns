// BrickHolder2.4
// 
// Replace specialized holders with
// standard sizes + corresponding inserts,
// similar to PhoneHolder, but slightly chunkier.
// Everything is multiples of 1-atom dimensions.
// 
// v2.0:
// - Based on BrickHolder1.6.2.
// - Changed some stuff until it mostly works.
// - Cavity and bottom hole size are fixed based on block size.
// - Front slot size fixed for now.
// - No 'spacer' mode; on the theory that different parts should
//   be different designs, and that standardization of cavity sizes
//   means the holder and spacer are not as closely coupled,
//   this design is just the holder, for now.
// - Inner corners are 2mm rounded, which should accomodate
//   TOGridPile bevels and feet just fine.
// v2.1:
// - Bottom hole, front slot, and mounting holes are optional
// v2.2:
// - Experimental 'shift feet around a bit' version
//   to see if that improves STL exports (it did not)
// v2.3:
// - Apply 'randomization' to $tgx11_offset
// v2.4:
// - Fix to enable top cord slot
// 
// TODO: actually apply top_segmentation!
// TODO: horizontal-only atomic segmentation modes?

/* [General] */

block_size_atoms = [6,6,12];

bottom_hole_style = "standard"; // ["none","standard"]
front_slot_style = "standard"; // ["none","standard"]
back_mounting_hole_style = "THL-1003"; // ["none","THL-1003"]

// mode = "holder"; // ["holder", "spacer"]

/* [Holder] */

top_cord_slot_depth    = 0; // 0.01
top_cord_slot_diameter = 0; // 0.01

bottom_segmentation = "none"; // ["none","block","chunk","chatom","atom"]
top_segmentation    = "none"; // ["none","block","chunk","chatom","atom"]
side_segmentation   = "none"; // ["none","block","chunk","chatom","atom"]
back_segmentation   = "none"; // ["none","block","chunk","chatom","atom"]
front_segmentation  = "none"; // ["none","block","chunk","chatom","atom"]

/* [Detail] */

// Offset of cavity walls and bottom hole
inner_offset = -0.2;
// Offset of TOGridPile surfaces
$tgx11_offset = -0.1;

render_fn = 24;

/* [Preview] */

preview_fn = 24;
debug_holes_enabled = false;
debug_front_slot_enabled = false;

module __brickholder_end_params() { }

use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGHoleLib2.scad>
use <../lib/TOGPath1.scad>
use <../lib/TGx11.1Lib.scad>
use <../lib/TOGridLib3.scad>

function maybedebug(db=false, item) = db ? ["x-debug", item] : item;

$togridlib3_unit_table = tgx11_get_default_unit_table();

mode = "holder";
spacer_thickness = 12.7;

block_size_ca = [for(d=block_size_atoms) [d, "atom"]];

block_size = togridlib3_decode_vector(block_size_ca);

cavity_size_ca = [
	[block_size_atoms[0] - 1  , "atom"],
	[block_size_atoms[1] - 1  , "atom"],
	[block_size_atoms[2] - 0.5, "atom"],
];

cavity_actual_size = [for(d=togridlib3_decode_vector(cavity_size_ca)) d - inner_offset*2];

bottom_hole_size_ca = [
	[block_size_atoms[0] - 2  , "atom"],
	[block_size_atoms[1] - 2  , "atom"],
];

bottom_hole_actual_size = [for(d=togridlib3_decode_vector(bottom_hole_size_ca)) d - inner_offset*2];

atom  = togridlib3_decode([1, "atom"]);
chunk = togridlib3_decode([1, "chunk"]);

top_slot_width = cavity_actual_size[0] - 6;
bottom_slot_width = atom; // Or whatever; could be configurable

min_wall_thickness = 4;
floor_thickness = 6.35;

min_side_thickness = [min_wall_thickness, min_wall_thickness, floor_thickness];

function dimstr(dims, suffix, i=0) =
	len(dims) == i ? "" :
	str(i > 0 ? " x " : "", dims[i], suffix, dimstr(dims, suffix, i+1));


echo(str("Block size = ", dimstr(block_size, "mm"), ", or ", dimstr(block_size/25.4, "in")));

$fn = $preview ? preview_fn : render_fn;

block_hull = ["translate", [0,0,block_size[2]/2], tphl1_make_rounded_cuboid(block_size, 3)];
cavity = ["translate", [0,0,block_size[2]], tphl1_make_rounded_cuboid([cavity_actual_size[0], cavity_actual_size[1], cavity_actual_size[2]*2], [2,2,0])];
function widthcurve(t) = t <= 0 ? 0 : t >= 1 ? 1 : 0.5 - 0.5*cos(t*180);
front_slot = tphl1_make_polyhedron_from_layer_function([
	//[-100             , [bottom_hole_size[0], block_size[1]+bottom_hole_size[1]]],
	//[block_size[2]+100, [bottom_hole_size[0], block_size[1]+bottom_hole_size[1]]],
	for( z = [-100, for(z=[-1:5:block_size[2]+1]) z, block_size[2]+100] )
		[z, [bottom_slot_width + widthcurve(z / block_size[2]) * (top_slot_width-bottom_slot_width), block_size[1]]],
], function( zs )
	togmod1_rounded_rect_points(zs[1], r=2, pos=[0,-block_size[1]/2, zs[0]])
);

bottom_hole = tphl1_make_rounded_cuboid([bottom_hole_actual_size[0], bottom_hole_actual_size[1], block_size[2]*3], [2,2,0]);

mounting_hole = maybedebug(debug_holes_enabled, ["rotate", [90,0,0], tog_holelib2_hole(back_mounting_hole_style, depth=block_size[1]-cavity_actual_size[1])]);
mounting_holes = ["union",
	for( xm=[round(-block_size[0]/atom)/2 + 0.5 : 1 : round(block_size[0]/atom)/2] )
	let( x = xm*atom )
	if( x-4 >= -cavity_actual_size[0]/2 && x+4 <= cavity_actual_size[0]/2 )
	for( zm=[1.5 : 1 : round(block_size[2]/atom)] )
	["translate", [xm*atom, cavity_actual_size[1]/2, zm*atom], mounting_hole]
];

// TODO for fanciness: Round around the hole!
top_cord_slot =
	(top_cord_slot_depth <= 0 || top_cord_slot_diameter <= 0) ? ["union"] :
	togmod1_linear_extrude_x(
		[-block_size[0], block_size[0]],
		let(sr = top_cord_slot_diameter/2)
		let(sd = top_cord_slot_depth)
		let(bt = block_size[2]+0.01)
		let(sb = bt - sd)
		let(st = bt + sr*4) // a point well above the top
		let(tr = 2) // Smaller radius for rounding at the top
		togmod1_make_polygon(togpath1_rath_to_points(["togpath1-rath",
			["togmod1-rathnode", [-sr-sr, st]],
			["togmod1-rathnode", [-sr-sr, bt]],
			["togmod1-rathnode", [-sr   , bt], ["round", tr]],
			["togmod1-rathnode", [-sr   , sb], ["round", sr]],
			["togmod1-rathnode", [ sr   , sb], ["round", sr]],
			["togmod1-rathnode", [ sr   , bt], ["round", tr]],
			["togmod1-rathnode", [ sr+sr, bt]],
			["togmod1-rathnode", [ sr+sr, st]],
			["togmod1-rathnode", [-sr-sr, st]],
		]))
);

use <../lib/TOGMod1.scad>

features = []; // Might make configurable as an 'escape hatch' of sorts
               // to allow further customization than enable/disable/style
               // options can represent.

effective_features = [
	each features,
	if(bottom_hole_style == "standard") "bottom-hole",
	if(front_slot_style == "standard") "front-slot",
	if(top_cord_slot_diameter > 0 && top_cord_slot_depth > 0) "top-cord-slot",
];

unsegmented_brick_holder = ["difference",
	block_hull,
	
	cavity,
	for( f=effective_features )
		f == "" ? ["union"] :
		f == "bottom-hole" ? bottom_hole :
		f == "front-slot" ? maybedebug(debug_front_slot_enabled, front_slot) :
		f == "top-cord-slot" ? top_cord_slot :
		assert(false, str("Unrecognized feature: '", f, "'")),
	mounting_holes,
];

left_side_intersection = side_segmentation != "none" ? ["translate", [-block_size[0]/2, 0, block_size[2]/2], ["rotate", [0,90,0],
	["render", tgx11_atomic_block_bottom(
		[[block_size[2], "mm"], [block_size[1], "mm"], [block_size[0], "mm"]],
		segmentation = side_segmentation,
		bottom_shape = "beveled", // No overhangs allowed
		$tgx11_gender = "m"
	)]
]] : undef;

brick_holder = ["intersection",
	unsegmented_brick_holder,
	
	if( side_segmentation != "none" ) ["intersection",
		for( xs=[-1,1] ) ["scale", [xs,1,1], ["translate", [0,0,0], left_side_intersection]]
	],
	if( back_segmentation != "none" ) ["translate", [0, block_size[1]/2, block_size[2]/2], ["rotate", [90,0,0],
		["render", tgx11_block_bottom(
			[block_size_ca[0], block_size_ca[2], block_size_ca[1]],
			segmentation = back_segmentation,
			bottom_shape = "beveled", // No overhangs allowed
			$tgx11_gender = "m",
			$tgx11_offset = $tgx11_offset + 1/1024
		)]
	]],
	if( front_segmentation != "none" ) ["translate", [0, -block_size[1]/2, block_size[2]/2], ["rotate", [-90,0,0],
		["render", tgx11_atomic_block_bottom(
			[[block_size[0], "mm"], [block_size[2], "mm"], [block_size[1], "mm"]],
			segmentation = front_segmentation,
			bottom_shape = "beveled", // No overhangs allowed
			$tgx11_gender = "m",
			$tgx11_offset = $tgx11_offset + 2/1024
		)]
	]],
	if( bottom_segmentation != "none" ) ["translate", [0, 0, 0], ["rotate", [0,0,0],
		["render", tgx11_atomic_block_bottom(
			[[block_size[0], "mm"], [block_size[1], "mm"], [block_size[2], "mm"]],
			segmentation = bottom_segmentation,
			bottom_shape = "footed",
			$tgx11_gender = "m",
			$tgx11_offset = $tgx11_offset - 1/1024
		)]
	]],
];

spacer = ["difference",
	tphl1_make_rounded_cuboid([cavity_actual_size[0]-1, cavity_actual_size[1]-1, spacer_thickness], [3,3,min(spacer_thickness/2,3)]),
	front_slot
];

thing =
	mode == "holder" ? brick_holder :
	mode == "spacer" ? spacer :
	assert(false, str("Invalid mode: '", mode, "'"));

togmod1_domodule(thing);
