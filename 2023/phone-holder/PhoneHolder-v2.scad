// PhoneHolder-v2.10
// 
// Minimal outer box, designed to hold 
// 
// Changes:
// v2.1:
// - Margins
// v2.2:
// - Put a TGx9.4 chatomic foot on it because why not
// v2.3:
// - Option of foot_v6hc_style = "v6.2" for slight reinforcement
// v2.4:
// - Block size configurable, with separate front/back heights
// - Default foot_v6hc_style = "v6.2"
// - Default outer margins doubled
// - Default inner margin tripled
// v2.5:
// - Round around the slot
// - Flip around so front is at -Y
// v2.6:
// - Fix passing of togridpile_margin into tgx9_block_foot
// v2.7:
// - Add bottom TOGridPile magnet holes
// v2.8:
// - Add side holes for cables or whatever
// v2.9:
// - Round front to match fillet in back
// - Bevel, for lack of time to do something nicer at the moment,
//   the top corners of the front slot
// v2.10:
// - Add option for 'swoopy' front slot
// - Refactor to naturally put front slot at -Y
// - Increase default render_fn fronm 24 to 48
// - Change side slots to 2-chunk-high pattern

use <../lib/TOGMod1.scad>
use <../lib/TOGArrayLib1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGHoleLib2.scad>

/* [Block Size] */

front_height_chunks = 1;
back_height_chunks  = 1;
block_depth_chunks  = 1;
block_width_chunks  = 3;

/* [Slots] */

// 'swoopy' may be more approprate for blocks with full-height fronts
front_slot_style = "standard"; // ["standard","swoopy"]

/* [Margins] */

outer_margin = 0.2;
inner_margin = 0.6;
// Recommend 0.2 if you're not applying X/Y compensation in slic3r, 0.1 if you are.
togridpile_margin = 0.2;

/* [Bottom] */

foot_segmentation = "chatom"; // ["chatom", "chunk", "block", "none"]
foot_v6hc_style = "v6.2"; // ["none","v6.2"]
bottom_magnet_hole_diameter = 6.4; // 0.1
bottom_magnet_hole_depth    = 2.4; // 0.1

/* [Detail] */

render_fn = 48;

module __asd123sudifn_end_params() { }


function make_rounded_gap_cutter(size, r) =
assert(tal1_is_vec_of_num(size, 2), "size must be [Num, Num]")
assert(is_num(r), "r(adius) must be anumber")
["difference",
	togmod1_make_rounded_rect([size[0]+2*r, size[1]+4], r=0),
	
	for( xm=[-1, 1] ) ["translate", [xm * (size[0]/2 + r*2), 0],
		togmod1_make_rounded_rect([4*r, size[1]], r=r)]
];

function make_corner_rounding_cutter(r, corner=[-1,-1]) = ["difference",
	togmod1_make_rounded_rect([r*2, r*2], 0),
	["translate", [corner[0]*r, corner[1]*r], togmod1_make_rounded_rect([r*2, r*2], r)]
];


assert(front_height_chunks <= back_height_chunks, "front height must be <= back height, for now");

block_height_chunks = max(front_height_chunks, back_height_chunks);
block_size_ca = [[block_width_chunks, "chunk"], [block_depth_chunks, "chunk"], [block_height_chunks, "chunk"]];

atom_pitch   = togridlib3_decode([1, "atom"]);
chunk_pitch  = togridlib3_decode([1, "chunk"]);
block_width  = togridlib3_decode([block_width_chunks       , "chunk"]);
block_depth  = togridlib3_decode([block_depth_chunks , "chunk"]);
front_height = togridlib3_decode([front_height_chunks, "chunk"]);
back_height  = togridlib3_decode([back_height_chunks , "chunk"]);

inch = 25.4;
block_size   = togridlib3_decode_vector(block_size_ca);
cavity_size  = [
	block_width-chunk_pitch + 1*inch,
	block_depth-chunk_pitch + 1.25*inch,
	block_size[2]
];
front_panel_y0 = -block_size[1]/2 + outer_margin;
front_panel_y1 = -cavity_size[1]/2 - inner_margin;

panel_thickness = (block_size[1] - cavity_size[1])/2;
side_thickness  = (block_size[0] - cavity_size[0])/2;
bottom_thickness = 0.25*inch;
corner_rad = 1.6;
front_slot_width = 0.5*inch;
slot_rounding_r = 1;

$fn = $preview ? 8 : render_fn;

bottom_hole_size = [
	block_width-chunk_pitch + 0.75*inch,
	block_depth-chunk_pitch + 1*inch
];

bottom_hole_y0 = -bottom_hole_size[1]/2;

front_cutout_height = (back_height - front_height) * 2;
echo(front_height=front_height, back_height=back_height, front_cutout_height=front_cutout_height);

function phv2_standard_front_slot() = ["union",
	// Front slot (panel section)
	["translate", [0, (front_panel_y1 + front_panel_y0)/2, 0],
		togmod1_linear_extrude_z([bottom_thickness, block_size[2]+1], make_rounded_gap_cutter([front_slot_width, front_panel_y1 - front_panel_y0], slot_rounding_r))
	],
	// Front slot (bottom section)
	["translate", [0, (front_panel_y0 + bottom_hole_y0)/2, 0],
		togmod1_linear_extrude_z([-1, bottom_thickness+1], make_rounded_gap_cutter([front_slot_width, bottom_hole_y0 - front_panel_y0], slot_rounding_r))
	],
	// Use a blunt tool to make top of front slot less sharp
	["translate", [0, -block_size[1]/2 + outer_margin + panel_thickness/2, front_height],
		let( bevel_size = chunk_pitch/2 )
		// Abuse rounded cuboid to make a diamond, lmao
		tphl1_make_rounded_cuboid([bevel_size * 2, panel_thickness*2, bevel_size * 2], [bevel_size, 0, bevel_size], $fn=4)
	]
];

function phv2_cos_curve(t) = t <= 0 ? 0 : t >= 1 ? 1 : 0.5 - 0.5*cos(t*180);

function phv2_swoopy_width_curve(t,trange=[0,1]) = t <= trange[0] ? 0 : t >= trange[1] ? 1 :
	let(trangemag =  trange[1]-trange[0]   )
	phv2_cos_curve((t-trange[0])/trangemag);

function phv2_swoopy_front_slot() =
let(slot_width_at_bottom = front_slot_width)
let(slot_width_at_top    = block_size[0] - 19.05)
tphl1_make_polyhedron_from_layer_function([
	//[-100             , [bottom_hole_size[0], block_size[1]+bottom_hole_size[1]]],
	//[block_size[2]+100, [bottom_hole_size[0], block_size[1]+bottom_hole_size[1]]],
	for( z = [-100, for(z=[-1:5:block_size[2]+1]) z, block_size[2]+100] ) [z, [
		slot_width_at_bottom + (slot_width_at_top-slot_width_at_bottom) * phv2_swoopy_width_curve(
			z / block_size[2],
			[0.25,0.65]
		),
		block_size[1]+bottom_hole_size[1]
	]],
], function( zs )
	togmod1_rounded_rect_points(zs[1], r=2, pos=[0,-block_size[1]/2, zs[0]])
);

function phv2_front_slot(style) =
	style == "standard" ? phv2_standard_front_slot() :
	style == "swoopy" ? phv2_swoopy_front_slot() :
	assert(false, str("Unrecognized front slot style: '", style, "'"));

// Returns list of [slot Z position, slot height] in chunks
function side_slot_grid(zrange=[0,front_height_chunks]) = [
	for( z=[zrange[0] : 2 : zrange[1]-0.1] )
		let(top=min(z+2,zrange[1]))
			 [(z+top)/2, top-z]
];
/*
	(zrange[1]-zrange[0] <= 2) ? [[(zrange[1]+zrange[0])/2, zrange[1]-zrange[0]]] :
	[
		for( subzrange=[
			[zrange[0]  ,zrange[0]+2],
			[zrange[0]+2,zrange[1]  ]
		] ) each side_slot_grid(zrange=subzrange)
	];
*/
module phv2_main() render() togmod1_domodule(["difference",
	["translate", [0,0,block_size[2]/2], tphl1_make_rounded_cuboid([
	   block_size[0]-outer_margin*2,
	   block_size[1]-outer_margin*2,
	   block_size[2]-outer_margin*2,
	], corner_rad)],
	
	// Main cavity
	["translate", [0,0,block_size[2]/2+bottom_thickness], togmod1_make_cuboid([
		cavity_size[0] + inner_margin*2,
		cavity_size[1] + inner_margin*2,
		cavity_size[2]
	])],
	// Top/front cutout
	if( front_cutout_height > 0 ) ["union",
		["translate", [0, -panel_thickness+block_size[1], back_height], togmod1_linear_extrude_x([-block_size[0], block_size[0]],
			togmod1_make_rounded_rect([block_size[1]*3, front_cutout_height], r=6.35))],
		["translate", [0, -block_size[1]/2 + outer_margin, front_height],
			togmod1_linear_extrude_x([-block_size[0], block_size[0]],
				make_corner_rounding_cutter(6.35, [-1,-1]))],
	],
	phv2_front_slot(front_slot_style),
	
	// Bottom hole
	togmod1_linear_extrude_z([-1, bottom_thickness+1], togmod1_make_rounded_rect(bottom_hole_size, r=0.125*inch)),

	// Side holes
	for( ss=side_slot_grid() ) echo(ss=ss) ["translate",
		[0,0,ss[0]*chunk_pitch],
		tphl1_make_rounded_cuboid([block_size[0]+2, chunk_pitch/2, ss[1]*chunk_pitch-chunk_pitch/2], [0, chunk_pitch/4, chunk_pitch/4])
	],

	// Mounting holes
	for( xm=[-block_width_chunks/2+0.5 : 1 : block_width_chunks/2] )
	for( ym=[0.5 : 1 : back_height_chunks] )
	["translate", [xm*chunk_pitch, block_size[1]/2 - panel_thickness, ym*chunk_pitch],
		["rotate", [90,0,0], tog_holelib2_hole("THL-1002", overhead_bore_height=block_size[1])]
	],
	
	// Magnet holes
	if( bottom_magnet_hole_diameter > 0 && bottom_magnet_hole_depth > 0 )
	for( xm=[-1, 1] )
	for( ym=[-1, 1] )
	["translate", [xm*(block_size[0]-atom_pitch)/2, ym*(block_size[1]-atom_pitch)/2, 0],
		togmod1_make_cylinder(d=bottom_magnet_hole_diameter, zrange=[-1, bottom_magnet_hole_depth])],
]);

use <../lib/TGx9.4Lib.scad>
use <../lib/TOGridLib3.scad>

// phv2 puts front panel at +Y, but we want it at -Y actually lol
intersection() {
	phv2_main();

	tgx9_block_foot(
		block_size_ca     = block_size_ca,
		foot_segmentation = foot_segmentation,
		corner_radius     = togridlib3_decode([1, "m-outer-corner-radius"]),
		v6hc_style        = foot_v6hc_style,
		offset            = -togridpile_margin
	);
}
