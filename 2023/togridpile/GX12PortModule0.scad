// GX12PortModule0.2
// 
// Block for holding a GX12 port sideways,
// e.g. for use with WeMosCase0
// 
// Based on WeMosCase0.6.1 
// 
// GX12 port dimensions:
// Neck diameter: About 12mm
// Max neck length: About 4.4mm
// Neck hex nut side-to-side: 15mm
// Neck hex nut corner-to-corner: 17mm
// Bottom of flange to top of mating threads: About 7mm
// 
// v0.1.1:
// - Remove some dead code
// v0.2:
// - Use TGPSCC0
// - Increase neck_hole_diameter from 12.1mm to 12.5mm, and make configurable

neck_hole_diameter = "12.5mm";

cross_section = false;

foot_rounding = 0.5; // [0.25:0.1:1]

$fn = 24;
$tgx11_offset = -0.1;

module __gx12portmodule0__end_params() { }

use <../lib/TGPSCC0.scad>
use <../lib/TGx11.1Lib.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGUnits1.scad>
use <../lib/TOGPolyhedronLib1.scad>

$togridlib3_unit_table = [
	// Hey, this should only apply to the feet, not to the sides of the cup!
	["tgp-m-outer-corner-radius", [255/64*foot_rounding,"u"]],
	each tgx11_get_default_unit_table()
];

block_height = "1inch";
u = togunits1_to_mm("1u");
block_height_mm = togunits1_to_mm(block_height);
limit_cavity_width_mm = togunits1_to_mm("1+1/8inch");

block_size_ca = [[1, "chunk"],[1, "chunk"],togunits1_to_ca(block_height)];
block_size_mm = togunits1_decode_vec(block_size_ca);

the_block = tgx11_block(
	block_size_ca,
	bottom_segmentation = "chatom",
	top_segmentation = "block",
	lip_height = 1.5
);
the_cavity = tgpscc0_make_gx12_cutout(
	block_size = block_size_mm,
	limit_cavity_width = limit_cavity_width_mm + 0.1,
	neck_hole_diameter = togunits1_decode(neck_hole_diameter)
);

the_module = ["difference",
	the_block,
   
	["translate", [0,0,block_size_mm[2]], ["intersection",
		tgpscc0_make_cavity_limit(block_size_mm, cavity_width=limit_cavity_width_mm),
		the_cavity,
	]],
];

togmod1_domodule(["difference",
	["union",
		the_module,
	],
	
	if( cross_section ) ["translate", [0,-block_size_mm[1]/2,block_size_mm[2]/2], togmod1_make_cuboid([block_size_mm[0]*2,38.1,block_size_mm[2]*3])],
]);
