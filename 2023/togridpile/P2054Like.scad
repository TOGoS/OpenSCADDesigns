// P2054Like v1.0
// 
// TGx11.1-based holder with rectangular slots

block_size = ["1chunk","1chunk","1+2/6chunk"];
slot_size = ["30mm","8mm","1+1/6chunk"];
slot_wall_thickness = "3mm";

/* [Lip] */

lip_height = "1.5mm";

/* [Foot] */

bottom_segmentation = "atom";
bottom_shape = "footed"; // ["footed","beveled"]
bottom_foot_bevel = 0.4; // 0.1
bottom_v6hc_style = "none"; // ["v6.1", "none"]
foot_rounding = 0.5; // [0.25:0.1:1]

/* [Detail] */

$tgx11_offset = -0.1;
preview_fn = 12;
render_fn = 24;

module __tgx11_end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGridLib3.scad>
use <../lib/TGx11.1Lib.scad>
use <../lib/TOGHoleLib2.scad>
use <../lib/TOGVecLib0.scad>
use <../lib/TOGUnits1.scad>

$fn = $preview ? preview_fn : render_fn;

$togridlib3_unit_table = [
	// Hey, this should only apply to the feet, not to the sides of the cup!
	["tgp-m-outer-corner-radius", [255/64*foot_rounding,"u"]],
	each tgx11_get_default_unit_table()
];

block_size_ca = [for(d=block_size) togunits1_to_ca(d)];
block_size_mm = togridlib3_decode_vector(block_size_ca);
lip_height_mm = togunits1_decode(lip_height);
slot_size_mm = togunits1_decode_vec(slot_size);
slot_wall_thickness_mm = togunits1_decode(slot_wall_thickness);

slot_pitch_mm = slot_size_mm[1] + slot_wall_thickness_mm;
slot_count = floor( (block_size_mm[1]-slot_wall_thickness_mm)/slot_pitch_mm );

slot = togmod1_make_cuboid([slot_size_mm[0], slot_size_mm[1], slot_size_mm[2]*2]);

togmod1_domodule(["difference",
	tgx11_block(
		block_size_ca,
		top_segmentation = "block",
		lip_height = lip_height_mm,
		bottom_segmentation = bottom_segmentation,
		bottom_shape        = bottom_shape,
		bottom_foot_bevel   = bottom_foot_bevel,
		bottom_v6hc_style   = bottom_v6hc_style
	),
	
	["translate", [0,0,block_size_mm[2]], togmod1_linear_extrude_y([-block_size_mm[1], block_size_mm[1]],
		togmod1_make_circle(d=19.05)
	)],
	
   for( ym=[-slot_count/2 + 0.5 : 1 : slot_count/2 - 0.5] )
	["translate", [0, ym*slot_pitch_mm, block_size_mm[2]], slot],
]);
