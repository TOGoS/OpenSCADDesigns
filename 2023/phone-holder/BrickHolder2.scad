// BrickHolder2.12
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
// v2.5:
// - Add can subtraction
// v2.6:
// - 'hatom' segmentation (probably buggy lmao)
// - actually apply top_segmentation!
// v2.7:
// - Use tgx11_block_bottom instead of tgx11_atomic_block_bottom
//   (tgx11_atomic_block_bottom doesn't handle 'block' segmentation properly;
//   it should probably throw an error instead of doing it wrong)
// v2.8:
// - Option for 'centered-gridbeam-9mm-holes' instead of front slot.
//   These will line up with the atom-spaced holes in the back
//   only when width/height is an odd number of atoms.
// v2.9:
// - 'centered-gridbeam-9mm-holes' will actually make two columns of holes
//   if width is even multiple of atoms
// v2.10:
// - inner_rounding_radius can be specified
// - bottom_hole_style = "full" to have no floor
// v2.11:
// - Optional bottom_hole_size, and handle some corner cases when it's zero or very small
// v2.12:
// - 'standard2' front slot, which is just rounded a bit at the top,
//   because Renee asked for that

description = "";

/* [General] */

block_size_atoms = [6,6,12];

// Diameter of cylinder to additionally subtract from main cavity, e.g. for a soda can.  Set to 0 to skip it.
can_diameter = 0;

bottom_hole_style = "standard"; // ["none","standard","full"]
// Size of bottom hole when there is one; -1 for automatic (taking inner_offset into account)
bottom_hole_size = [-1,-1]; // 0.1
front_slot_style = "standard"; // ["none","standard","standard2","centered-gridbeam-9mm-holes"]
back_mounting_hole_style = "THL-1003"; // ["none","THL-1003"]

top_cord_slot_depth    = 0; // 0.01
top_cord_slot_diameter = 0; // 0.01

bottom_segmentation = "none"; // ["none","block","chunk","chatom","atom"]
top_segmentation    = "none"; // ["none","block","chunk","chatom","atom"]
side_segmentation   = "none"; // ["none","block","chunk","chatom","atom","hatom"]
back_segmentation   = "none"; // ["none","block","chunk","chatom","atom","hatom"]
front_segmentation  = "none"; // ["none","block","chunk","chatom","atom","hatom"]

/* [Detail] */

// Offset of cavity walls and bottom hole
inner_offset = -0.2;
inner_rounding_radius = 2;
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
use <../lib/TOGVecLib0.scad>

function maybedebug(db=false, item) = db ? ["x-debug", item] : item;

$togridlib3_unit_table = tgx11_get_default_unit_table();

mode = "holder";
spacer_thickness = 12.7;

block_size_ca = [for(d=block_size_atoms) [d, "atom"]];

block_size = togridlib3_decode_vector(block_size_ca);

cavity_size_ca = [
	[block_size_atoms[0] - 1  , "atom"],
	[block_size_atoms[1] - 1  , "atom"],
	bottom_hole_style == "full" ? [block_size_atoms[2]*2, "atom"] : [block_size_atoms[2] - 0.5, "atom"],
];

cavity_actual_size = [for(d=togridlib3_decode_vector(cavity_size_ca)) d - inner_offset*2];

bottom_hole_size_ca = [
	[block_size_atoms[0] - 2  , "atom"],
	[block_size_atoms[1] - 2  , "atom"],
];

bottom_hole_actual_size = [
	for(i=[0,1]) max(0, bottom_hole_size[i] == -1 ? togridlib3_decode(bottom_hole_size_ca[i]) - inner_offset*2 : bottom_hole_size[i])
];

u     = togridlib3_decode([1, "u"    ]);
atom  = togridlib3_decode([1, "atom" ]);
chunk = togridlib3_decode([1, "chunk"]);

function dimstr(dims, suffix, i=0) =
	len(dims) == i ? "" :
	str(i > 0 ? " x " : "", dims[i], suffix, dimstr(dims, suffix, i+1));


echo(str("Block size = ", dimstr(block_size, "mm"), ", or ", dimstr(block_size/25.4, "in")));

$fn = $preview ? preview_fn : render_fn;

catapiller_hull =
let(
	x0 = -block_size[0]/2 + ( side_segmentation == "hatom" ? 0 : -20),
	x1 =  block_size[0]/2 + ( side_segmentation == "hatom" ? 0 :  20),
	y0 = -block_size[1]/2 + (front_segmentation == "hatom" ? 0 : -20),
	y1 =  block_size[1]/2 + ( back_segmentation == "hatom" ? 0 :  20)
)
let(layer_rath_offsets = [0+$tgx11_offset, -1*u+$tgx11_offset])
let(layer_pointses = [for(off=layer_rath_offsets)
	togpath1_rath_to_polypoints(
		togpath1_polypoints_to_rath(
			[[x0,y0],[x1,y0],[x1,y1],[x0,y1]],
			[["bevel", 2*u], ["round", 2*u], ["offset", off]]
		)
	)
])
let( z2off = $tgx11_offset*(sqrt(2)-1) )
tphl1_make_polyhedron_from_layer_function([
	[   0*u, 1],
	for(c=[0:1:block_size[2]/atom-1]) each [
		// TODO: sqrt(2)-1 or whatever for the z offset
		[   c *atom + 1*u - z2off, 1],
		[   c *atom + 2*u - z2off, 0],
		[(c+1)*atom - 2*u + z2off, 0],
		[(c+1)*atom - 1*u + z2off, 1],
		[(c+1)*atom - 0*u        , 1],
	]
], function(zo) togvec0_offset_points(
	// Temporary solution
	// TODO: rath based on the cube with appropriate offsets
	//togmod1_rounded_rect_points([catapiller_size[0]+zo[1]*2, catapiller_size[1]+zo[1]*2], r=3.175),
	layer_pointses[zo[1]],
	zo[0]
));

block_hull = ["intersection",
	["translate", [0,0,block_size[2]/2], tphl1_make_rounded_cuboid(block_size, 3)],
	catapiller_hull
];

cavity_2d = ["union",
	togmod1_make_rounded_rect(cavity_actual_size, r=inner_rounding_radius),
	if( can_diameter > 0 ) togmod1_make_circle(d=can_diameter, $fn=max($fn,48))
];

cavity = //["translate", [0,0,block_size[2]], tphl1_make_rounded_cuboid([cavity_actual_size[0], cavity_actual_size[1], cavity_actual_size[2]*2], [2,2,0])];
	togmod1_linear_extrude_z([block_size[2]-cavity_actual_size[2], block_size[2]*2],
		cavity_2d
	);

function widthcurve(t) = t <= 0 ? 0 : t >= 1 ? 1 : 0.5 - 0.5*cos(t*180);
function make_front_slot(zparams) = tphl1_make_polyhedron_from_layer_function(zparams, function( zs )
	togmod1_rounded_rect_points(zs[1], r=2, pos=[0,-block_size[1]/2, zs[0]])
);

function make_standard_front_slot(bottom_slot_width, top_slot_width) = make_front_slot([
	for( z = [-100, for(z=[-1:5:block_size[2]+1]) z, block_size[2]+100] )
		[z, [bottom_slot_width + widthcurve(z / block_size[2]) * (top_slot_width-bottom_slot_width), block_size[1]]],
]);
function make_toprounded_front_slot(bottom_slot_width, top_slot_width, r) =
	let( cz = block_size[2]-r )
make_front_slot([
	for( z = [-100, for(z=[-1:5:cz]) z] )
		[z, [bottom_slot_width + widthcurve(z / cz) * (top_slot_width-bottom_slot_width), block_size[1]]],
	for( i=[0:1:$fn/4] ) let(a=i*360/$fn)
		[cz + r*sin(a), [top_slot_width + 2*r*(1-cos(a)), block_size[1]]],
	[block_size[2]+100, [top_slot_width + 2*r, block_size[1]]],
]);


bottom_hole_min_dim = min(bottom_hole_actual_size[0], bottom_hole_actual_size[1]);
bottom_hole_corner_r = min(bottom_hole_min_dim*127/256, 2);

bottom_hole = bottom_hole_min_dim == 0 ? ["union"] :
	tphl1_make_rounded_cuboid([bottom_hole_actual_size[0], bottom_hole_actual_size[1], block_size[2]*3], [bottom_hole_corner_r,bottom_hole_corner_r,0]);

mounting_hole = maybedebug(debug_holes_enabled, ["rotate", [90,0,0], tog_holelib2_hole(back_mounting_hole_style, depth=block_size[1]-cavity_actual_size[1])]);
mounting_holes = ["union",
	for( xm=[round(-block_size[0]/atom)/2 + 0.5 : 1 : round(block_size[0]/atom)/2] )
	let( x = xm*atom )
	if( x-4 >= -cavity_actual_size[0]/2 && x+4 <= cavity_actual_size[0]/2 )
	for( zm=[(bottom_hole_style == "full" ? 0.5 : 1.5) : 1 : round(block_size[2]/atom)] )
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
	if(front_slot_style == "standard") "standard-front-slot",
	if(front_slot_style == "standard2") "standard2-front-slot",
	if(front_slot_style == "centered-gridbeam-9mm-holes") "front-centered-gridbeam-9mm-holes",
	if(top_cord_slot_diameter > 0 && top_cord_slot_depth > 0) "top-cord-slot",
];

front_gridbeam_holes =
let( hole = ["rotate", [90,0,0], tphl1_make_z_cylinder(zrange=[-block_size[1]/2, block_size[1]/2], d=8)] )
["union",
	for(xm = block_size_atoms[0] % 2 == 1 ? [0] : [-0.5, +0.5]) // I am complectifying oops lmao
	for(ym = [1.5 : 3 : block_size_atoms[2]])
	["translate", [xm*atom, -block_size[1]/2, ym*atom], hole]
];

pre_tgx_segmented_brick_holder = ["difference",
	block_hull,
	
	cavity,
	for( f=effective_features )
		f == "" ? ["union"] :
		f == "bottom-hole" ? bottom_hole :
		f == "standard-front-slot" ? maybedebug(debug_front_slot_enabled, make_standard_front_slot(bottom_slot_width=atom, top_slot_width = cavity_actual_size[0] - 6)) :
		f == "standard2-front-slot" ? maybedebug(debug_front_slot_enabled, make_toprounded_front_slot(bottom_slot_width=atom, top_slot_width = cavity_actual_size[0] - 6.35, r=3.175)) :
		f == "front-centered-gridbeam-9mm-holes" ? front_gridbeam_holes :
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

function is_tgx_segmentation(seg) =
	seg != "none" && seg != "hatom";

brick_holder = ["intersection",
	pre_tgx_segmented_brick_holder,
	
	if( is_tgx_segmentation(top_segmentation) ) ["translate", [0, 0, block_size[2]], ["rotate", [180,0,0],
		["render", tgx11_block_bottom(
			[[block_size[0], "mm"], [block_size[1], "mm"], [block_size[2]+10, "mm"]],
			segmentation = top_segmentation,
			bottom_shape = "footed",
			$tgx11_gender = "m",
			$tgx11_offset = $tgx11_offset - 1/1024
		)]
	]],
	if( is_tgx_segmentation(side_segmentation) ) ["intersection",
		for( xs=[-1,1] ) ["scale", [xs,1,1], ["translate", [0,0,0], left_side_intersection]]
	],
	if( is_tgx_segmentation(back_segmentation) ) ["translate", [0, block_size[1]/2, block_size[2]/2], ["rotate", [90,0,0],
		["render", tgx11_block_bottom(
			[block_size_ca[0], block_size_ca[2], block_size_ca[1]],
			segmentation = back_segmentation,
			bottom_shape = "beveled", // No overhangs allowed
			$tgx11_gender = "m",
			$tgx11_offset = $tgx11_offset + 1/1024
		)]
	]],
	if( is_tgx_segmentation(front_segmentation) ) ["translate", [0, -block_size[1]/2, block_size[2]/2], ["rotate", [-90,0,0],
		["render", tgx11_block_bottom(
			[[block_size[0], "mm"], [block_size[2], "mm"], [block_size[1], "mm"]],
			segmentation = front_segmentation,
			bottom_shape = "beveled", // No overhangs allowed
			$tgx11_gender = "m",
			$tgx11_offset = $tgx11_offset + 2/1024
		)]
	]],
	if( is_tgx_segmentation(bottom_segmentation) ) ["translate", [0, 0, 0], ["rotate", [0,0,0],
		["render", tgx11_block_bottom(
			[[block_size[0], "mm"], [block_size[1], "mm"], [block_size[2]+10, "mm"]],
			segmentation = bottom_segmentation,
			bottom_shape = "footed",
			$tgx11_gender = "m",
			$tgx11_offset = $tgx11_offset - 1/1024
		)]
	]],
];

thing = brick_holder;

togmod1_domodule(thing);
