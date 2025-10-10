// MarkerHolder2.0

block_size = ["4chunk", "1chunk", "1inch"];
slot_depth = "0.85inch";
slot_width = "0.75inch";

bottom_foot_bevel = 0.4; // 0.1
foot_rounding = 0.5; // [0.25:0.1:1]

$tgx11_offset = -0.15;
$fn = 24;

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TGx11.1Lib.scad>
use <../lib/TOGUnits1.scad>
use <../lib/TOGPolyhedronLib1.scad>

$togridlib3_unit_table = [
	["tgp-m-outer-corner-radius", [255/64*foot_rounding,"u"]],
	each tgx11_get_default_unit_table()
];

block_size_ca = togunits1_vec_to_cas(block_size);
block_size_mm = togunits1_vec_to_mms(block_size_ca);
slot_width_mm = togunits1_to_mm(slot_width);
slot_depth_mm = togunits1_to_mm(slot_depth);
atom          = togunits1_to_mm([1,"atom"]);
chunk         = togunits1_to_mm([1,"chunk"]);

togmod1_domodule(
	let(block_hull = tgx11_block(block_size_ca,
	   bottom_segmentation = "chatom",
		bottom_v6hc_style = "none",
		bottom_foot_bevel = bottom_foot_bevel,
	   atom_bottom_subtractions = [togmod1_linear_extrude_z([-1,2.4], togmod1_make_circle(d=6.2))],
		top_segmentation = "block"
	))
	let( slot_bottom_r = min(slot_width_mm, slot_depth_mm*2)*127/256 )
	// TODO: Round top corners of slot
	// TODO: Round intersection of slots
	// Basically: make a custom polyhedron from a cross shape
	let(slot = ["translate", [0,0,block_size_mm[2]], tphl1_make_rounded_cuboid(
		[block_size_mm[0]-6.35, slot_width_mm, slot_depth_mm*2],
		r = [0, slot_bottom_r, slot_bottom_r]
	)])
	let(thumb_slot = ["translate", [0,0,block_size_mm[2]], tphl1_make_rounded_cuboid(
		[chunk, block_size_mm[1]*2, min(slot_depth_mm, block_size_mm[2]-atom)*2],
		r = min(slot_width_mm, slot_depth_mm*2)*127/256
	)])
	["difference",
		block_hull,
		
		slot,
		thumb_slot
	]
);
