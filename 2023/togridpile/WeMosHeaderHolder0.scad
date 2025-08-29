// WeMosHeaderHolder0.2
// 
// Holds two rows of 'female dupont' headers
// straight so that you can set your WeMos D1 mini on top
// (CPU side down, by convention) and solder the legs on.
// 
// Changes:
// v0.2:
// - Allow header_cutout_size[0] = "auto", which makes it the full
//   width with rounded corners, similar to the central cavity

block_size      = ["1chunk","1chunk","3/8inch"];
header_cutout_size = ["8/10inch","1/10inch","1/4inch"];
header_cutout_row_spacing = "9/10inch";
header_cutout_margin  = "0.1mm";

cross_section = false;

$fn = 24;
$tgx11_offset = -0.1;

use <../lib/TGx11.1Lib.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGUnits1.scad>
use <../lib/TOGPolyhedronLib1.scad>

$togridlib3_unit_table = tgx11_get_default_unit_table();

function reverse_list(list) =
	[for(i=[len(list)-1 : -1 : 0]) list[i]];

function mirror_rathnodes(nodes) = [
	for(n=nodes) n,
	for(n=reverse_list(nodes)) [n[0], [-n[1][0], n[1][1]], for(i=[2:1:len(n)-1]) n[i]],
];

block_size_ca = togunits1_vec_to_cas(block_size);
block_size_mm = togunits1_decode_vec(block_size_ca);
header_cutout_margin_mm      = togunits1_decode(    header_cutout_margin     );

central_cavity_width_mm = block_size_mm[0] - 2*3.175;

header_cutout_size_fixed = [
	header_cutout_size[0] == "auto" ? central_cavity_width_mm - header_cutout_margin_mm*2 : header_cutout_size[0],
	header_cutout_size[1],
	header_cutout_size[2],
];

header_cutout_size_mm        = togunits1_decode_vec(header_cutout_size_fixed );
header_cutout_row_spacing_mm = togunits1_decode(    header_cutout_row_spacing);



// togmod1_domodule(togmod1_linear_extrude_z([0, length_mm], the_clip_2d));

deck_z = block_size_mm[2];

header_cutout = togmod1_linear_extrude_z([-header_cutout_size_mm[2], 1],
	togmod1_make_rounded_rect([
		header_cutout_size_mm[0] + header_cutout_margin_mm*2,
		header_cutout_size_mm[1] + header_cutout_margin_mm*2,
	], r = header_cutout_size[0] == "auto" ? min(header_cutout_size_mm[0],header_cutout_size_mm[1]+header_cutout_margin_mm*2)*127/255 : 0)
);

the_cavity = ["union",
	// HEader holders
	for( ym=[-1,1] ) ["translate", [0,ym*header_cutout_row_spacing_mm/2,deck_z], header_cutout],
	
   // Central 'decorative' cavity
	["translate", [0,0,deck_z],
	   tphl1_make_rounded_cuboid([
			central_cavity_width_mm,
			header_cutout_row_spacing_mm - header_cutout_size_mm[1] - 2*254/160,
			(deck_z-25.4*3/16)*2
		], r=[3.175,3.175,0], corner_shape="ovoid1")],
];

the_thing = ["difference",
	tgx11_block(
		block_size_ca,
		bottom_segmentation = "chatom",
		bottom_foot_bevel = 0.4,
		top_segmentation = "block",
		lip_height = 1.5
	),
	
	the_cavity
];

togmod1_domodule(["difference",
	the_thing,
	
	if( cross_section ) ["translate",
		[-block_size_mm[0]/2,-block_size_mm[1]/2,block_size_mm[2]/2],
		togmod1_make_cuboid([block_size_mm[0], block_size_mm[1], block_size_mm[2]*2])
	],
]);
