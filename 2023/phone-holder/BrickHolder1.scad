// BrickHolder1.3
// 
// Holder for arbitrary 'bricks'
// with mounting holes to attach to gridbeam or togbeam or whatever
//
// v1.0:
// - Basic rounded cuboid - no TOGridPile nubs for now
// - For ThinkPad power brick holder
// v1.1:
// - Add 'spacer' mode
// v1.2:
// - Optional 'top cord slot'
// v1.3:
// - Options for TOGridPile atomic bottom on front/back/bottom

/* [General] */

// width, depth, height (in mm) of object to be held
brick_size = [47.1, 30.0, 108.3];

// Space between brick and holder on each side
margin = 1;

// Size of hole in bottom centered under brick for cords or whatever
bottom_hole_size = [19.05, 19.05];

mode = "holder"; // ["holder", "spacer"]

/* [Holder] */

top_cord_slot_depth    = 0; // 0.01
top_cord_slot_diameter = 0; // 0.01

bottom_segmentation = "none"; // ["none","atom"]
top_segmentation = "none"; // ["none","atom"]
back_segmentation = "none"; // ["none","atom"]
front_segmentation = "none"; // ["none","atom"]
$tgx11_offset = -0.1;

/* [Spacer] */

spacer_thickness = 12.7; // 0.01

module __brickholder_end_params() { }

cavity_size = [
	brick_size[0] + margin*2,
	brick_size[1] + margin*2,
	(brick_size[2] + margin), // Z Might be not relevant...
];

top_slot_width = cavity_size[0] - 6;

atom = 12.7;
chunk = 3*atom;
block_size_unit = [atom,atom,atom];

min_wall_thickness = 4;
floor_thickness = 6.35;

min_side_thickness = [min_wall_thickness, min_wall_thickness, floor_thickness];

block_size = [
	for( d=[0,1,2] ) block_size_unit[d] * ceil((cavity_size[d]+min_side_thickness[d]*2)/block_size_unit[d])
];

use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGHoleLib2.scad>
use <../lib/TOGPath1.scad>
use <../experimental/TGx11.scad>

$fn = 24;

block_hull = ["translate", [0,0,block_size[2]/2], tphl1_make_rounded_cuboid(block_size, 3)];
cavity = ["translate", [0,0,floor_thickness+cavity_size[2]], tphl1_make_rounded_cuboid([cavity_size[0], cavity_size[1], cavity_size[2]*2], [1,1,1])];
function widthcurve(t) = t <= 0 ? 0 : t >= 1 ? 1 : 0.5 - 0.5*cos(t*180);
slot = tphl1_make_polyhedron_from_layer_function([
	//[-100             , [bottom_hole_size[0], block_size[1]+bottom_hole_size[1]]],
	//[block_size[2]+100, [bottom_hole_size[0], block_size[1]+bottom_hole_size[1]]],
	for( z = [-100, for(z=[-1:5:block_size[2]+1]) z, block_size[2]+100] )
		[z, [bottom_hole_size[0] + widthcurve(z / block_size[2]) * (top_slot_width-bottom_hole_size[0]), block_size[1]+bottom_hole_size[1]]],
], function( zs )
	togmod1_rounded_rect_points(zs[1], r=2, pos=[0,-block_size[1]/2, zs[0]])
);

mounting_hole = ["x-debug", ["rotate", [90,0,0], tog_holelib2_hole("THL-1003", depth=block_size[1]-cavity_size[1])]];
mounting_holes = ["union",
	for( xm=[round(-block_size[0]/atom)/2 + 0.5 : 1 : round(block_size[0]/atom)/2] )
	let( x = xm*atom )
	if( x-4 >= -cavity_size[0]/2 && x+4 <= cavity_size[0]/2 )
	for( zm=[1.5 : 1 : round(block_size[2]/atom)] )
	["translate", [xm*atom, cavity_size[1]/2, zm*atom], mounting_hole]
];

function make_oval(r, p0, p1) =
let(diff = p1-p0)
let(ang = atan2(diff[1], diff[0]))
togmod1_make_polygon(togpath1_qath_points(["togpath1-qath",
	["togpath1-qathseg", p0, ang-270, ang-90, r],
	["togpath1-qathseg", p1, ang-90, ang+90, r]
]));

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

brick_holder_ = ["difference",
	block_hull, cavity, ["x-debug", slot], mounting_holes, top_cord_slot
];
brick_holder = ["intersection",
	brick_holder_,
	if( back_segmentation == "atom" ) ["translate", [0, block_size[1]/2, block_size[2]/2], ["rotate", [90,0,0],
		["render", tgx11_atomic_block_bottom(
			[[block_size[0], "mm"], [block_size[2], "mm"], [block_size[1], "mm"]],
			bottom_shape="beveled"// No overhangs allowed
		)]
	]],
	if( front_segmentation == "atom" ) ["translate", [0, -block_size[1]/2, block_size[2]/2], ["rotate", [-90,0,0],
		["render", tgx11_atomic_block_bottom(
			[[block_size[0], "mm"], [block_size[2], "mm"], [block_size[1], "mm"]],
			bottom_shape="beveled"// No overhangs allowed
		)]
	]],
	if( bottom_segmentation == "atom" ) ["render", tgx11_atomic_block_bottom(
		[[block_size[0], "mm"], [block_size[1], "mm"], [block_size[2], "mm"]]
	)],
];

spacer = ["difference",
			 tphl1_make_rounded_cuboid([cavity_size[0]-1, cavity_size[1]-1, spacer_thickness], [3,3,min(spacer_thickness/2,3)]),
	["x-debug", slot]
];

thing =
	mode == "holder" ? brick_holder :
	mode == "spacer" ? spacer :
	assert(false, str("Invalid mode: '", mode, "'"));

togmod1_domodule(thing);
