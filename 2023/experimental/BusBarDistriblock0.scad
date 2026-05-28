// BusBarDistriblock0.1
// 
// TOGridPile-compatible electrical distribution block
// using narrow bus bars that screw into mounting poitns in the enclosure.
// 
// Attach to the bar using screws or alligator clips.

length = "4chunk";
// Lane count is just the number of chunks
width = "2chunk";
// outer_wall_thickness = "1/8inch";
// inner_wall_thickness = "1/8inch";
bar_thickness = "1/8inch";

$fn = 32;
$tgx11_offset = -0.1;

module busbardistriblock0__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TGx11.1Lib.scad>
use <../lib/TOGUnits1.scad>

$togridlib3_unit_table = tgx11_get_default_unit_table();

block_size_ca = togunits1_vec_to_cas([length, width, "chunk"]);
block_size_chunks = togunits1_decode_vec(block_size_ca, unit="chunk", xf="round");
block_size_mm = togunits1_decode_vec(block_size_ca, unit="mm");
chunk_mm = togunits1_to_mm("chunk");

wall_thickness_mm = 6.35;
floor_thickness_mm = 6.35;

function make_lane_cavity() =
	["translate", [0,0,block_size_mm[2]], togmod1_linear_extrude_x(
		[-block_size_mm[0]/2 + wall_thickness_mm/2, block_size_mm[0]/2 - wall_thickness_mm/2],
		togmod1_make_rounded_rect([chunk_mm - wall_thickness_mm, (block_size_mm[2] - floor_thickness_mm)*2], r=3.175)
	)];
	// TODO: Subtract mounting points

togmod1_domodule(
	["difference",
		tgx11_block(
			block_size_ca,
			bottom_segmentation = "chunk",
			top_segmentation = "block",
			bottom_v6hc_style = "none",
			lip_height = 1.6
		),
		
		for( ym=[-block_size_chunks[1]/2 + 0.5 : 1 : block_size_chunks[1]/2 - 0.5] )
		["translate", [0, ym*chunk_mm, 0], make_lane_cavity(/*todo: which lane*/)],
		
		// TODO: Subtract holes through outer (and inner, if >2 chunks wide) walls
		// for screw heads / screw drivers
	]
);
