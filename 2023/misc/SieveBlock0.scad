// SieveBlock0.2
// 
// TOGridPile block with a grating at the bottom,
// for whatever purpose you like.
// 
// May be (if 4.5" chosen as block size) compatible with FilterCartridge0.6 assemblies
// (they'll stack and have the same corner hole positions).
// 
// v0.2:
// - bottom_foot_bevel option

block_size_chunks = [3,3];
block_height   = "3inch";
wall_thickness = "1/4inch";
beam_thickness_x = 1.2;
beam_thickness_z = 0.8;
beam_spacing = 12;
grating_thickness = "1/4inch";
bottom_foot_bevel = "0.6mm";

$tgx11_offset = -0.15;
$fn = 24;

// TODO: Imports were copy-pasted from FilterCartridge0.scad;
// delete those that are not needed.
use <../lib/TGx11.1Lib.scad>
use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGrat1.scad>
use <../lib/TOGridLib3.scad>
use <../lib/TOGUnits1.scad>
use <../lib/TOGVecLib0.scad>

$togridlib3_unit_table = tgx11_get_default_unit_table();

block_height_ca = togunits1_to_ca(block_height);

atom = togunits1_decode([1,"atom"]);
block_size_ca = [[block_size_chunks[0],"chunk"],[block_size_chunks[1],"chunk"],block_height_ca];
block_size_mm = togunits1_vec_to_mms(block_size_ca);
wall_thickness_mm = togunits1_to_mm(wall_thickness);
grating_thickness_mm = togunits1_to_mm(grating_thickness);
bottom_foot_bevel_mm = togunits1_to_mm(bottom_foot_bevel);

grating_config = tograt1_make_multi_grating([
	for( i=[0:1:grating_thickness_mm/beam_thickness_z] ) tograt1_make_grating([beam_thickness_x, beam_thickness_z], beam_spacing, i*60, (i+0.5)*beam_thickness_z),
]);

cavity_size_mm = [block_size_mm[0] - wall_thickness_mm*2, block_size_mm[1] - wall_thickness_mm*2];

corner_bolt_hole_positions = [
	for( xm=[-1,1] ) for( ym=[-1,1] ) [xm*(block_size_mm[0]-atom)/2, ym*(block_size_mm[1]-atom)/2]
];

corner_bolt_hole = togmod1_linear_extrude_z([-1, block_size_mm[2]+1], togmod1_make_circle(d=5));

togmod1_domodule(["difference",
	tgx11_block(
		block_size_ca,
		bottom_segmentation = "block",
		bottom_foot_bevel = bottom_foot_bevel_mm,
		top_segmentation = "block"
	),
	
	["difference",
		togmod1_linear_extrude_z([-1, block_size_mm[2]+1], togmod1_make_rounded_rect(
			cavity_size_mm,
			r = atom
		)),
		
		if( grating_thickness_mm > 0 ) tograt1_grating_to_togmod([cavity_size_mm[0]+1, cavity_size_mm[1]+1], grating_config),
	],
	
	for( pos=corner_bolt_hole_positions ) ["translate", pos, corner_bolt_hole],
]);
