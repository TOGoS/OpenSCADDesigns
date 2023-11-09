// PhoneHolder-v2.5
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

/* [Margins] */

outer_margin = 0.2;
inner_margin = 0.6;
togridpile_margin = 0.4;

/* [Bottom] */

foot_segmentation = "chatom"; // ["chatom", "chunk", "block", "none"]
foot_v6hc_style = "v6.2"; // ["none","v6.2"]

/* [Detail] */

render_fn = 24;

module __asd123sudifn_end_params() { }


function make_rounded_gap_cutter(size, r) =
assert(tal1_is_vec_of_num(size, 2), "size must be [Num, Num]")
assert(is_num(r), "r(adius) must be anumber")
["difference",
	togmod1_make_rounded_rect([size[0]+2*r, size[1]+4], r=0),
	
	for( xm=[-1, 1] ) ["translate", [xm * (size[0]/2 + r*2), 0],
		togmod1_make_rounded_rect([4*r, size[1]], r=r)]
];


assert(front_height_chunks <= back_height_chunks, "front height must be <= back height, for now");

block_height_chunks = max(front_height_chunks, back_height_chunks);
block_size_ca = [[block_width_chunks, "chunk"], [block_depth_chunks, "chunk"], [block_height_chunks, "chunk"]];

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
front_panel_y0 = cavity_size[1]/2 + inner_margin;
front_panel_y1 = block_size[1]/2 - outer_margin;

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

bottom_hole_y0 = bottom_hole_size[1]/2;

front_cutout_height = (back_height - front_height) * 2;
echo(front_height=front_height, back_height=back_height, front_cutout_height=front_cutout_height);

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
	if( front_cutout_height > 0 )
	["translate", [0, panel_thickness+block_size[1], back_height], togmod1_linear_extrude_x([-block_size[0], block_size[0]],
		togmod1_make_rounded_rect([block_size[1]*3, front_cutout_height], r=6.35))],
	// Front slot (panel section)
	["translate", [0, (front_panel_y1 + front_panel_y0)/2, 0],
		togmod1_linear_extrude_z([bottom_thickness, block_size[2]+1], make_rounded_gap_cutter([front_slot_width, front_panel_y1 - front_panel_y0], slot_rounding_r))
	],
	// Front slot (bottom section)
	["translate", [0, (front_panel_y1 + bottom_hole_y0)/2, 0],
		togmod1_linear_extrude_z([-1, bottom_thickness+1], make_rounded_gap_cutter([front_slot_width, front_panel_y1 - bottom_hole_y0], slot_rounding_r))
	],
	// Bottom hole
	togmod1_linear_extrude_z([-1, bottom_thickness+1], togmod1_make_rounded_rect(bottom_hole_size, r=0.125*inch)),

	// Mounting holes
	for( xm=[-block_width_chunks/2+0.5 : 1 : block_width_chunks/2] )
	for( ym=[0.5 : 1 : back_height_chunks] )
	["translate", [xm*chunk_pitch, -block_size[1]/2 + panel_thickness, ym*chunk_pitch],
		["rotate", [-90,0,0], tog_holelib2_hole("THL-1002", overhead_bore_height=block_size[1])]
	]
]);

use <../lib/TGx9.4Lib.scad>
use <../lib/TOGridLib3.scad>

// phv2 puts front panel at +Y, but we want it at -Y actually lol
// TODO, maybe: refactor phv2_main so it's the right way around in the first place
rotate([0,0,180]) intersection() {
	phv2_main();

	tgx9_block_foot(
		block_size_ca     = block_size_ca,
		foot_segmentation = foot_segmentation,
		corner_radius     = togridlib3_decode([1, "m-outer-corner-radius"]),
		v6hc_style        = foot_v6hc_style,
		$tgx9_mating_offset = -togridpile_margin
	);
}
