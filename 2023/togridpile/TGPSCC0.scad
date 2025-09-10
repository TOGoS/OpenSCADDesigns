// TGSCC0.1
// 
// Use library of same name
// to make multi-component blocks.

components = ["wemos","gx12port"];
block_height = "1inch";

/* [Debug] */

cross_section = false;

/* [Detail] */

lip_height = "1.5mm";
foot_rounding = 0.5; // [0.25:0.1:1]

$fn = 24;
$tgx11_offset = -0.1;

module __tgpscc0__end_params() { }

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

lip_height_mm = togunits1_to_mm(lip_height);

u = togunits1_to_mm("1u");
chunk = togunits1_to_mm("1chunk");
block_height_mm = togunits1_to_mm(block_height);
limit_cavity_width_mm = togunits1_to_mm("1+1/8inch");

block_size_ca = [[len(components), "chunk"],[1, "chunk"],togunits1_to_ca(block_height)];
block_size_chunks = togunits1_decode_vec(block_size_ca, unit=[1,"chunk"]);
block_size_mm = togunits1_decode_vec(block_size_ca);
chunk_size_ca = [[1, "chunk"],[1, "chunk"],togunits1_to_ca(block_height)];
chunk_size_mm = togunits1_decode_vec(chunk_size_ca);

the_block = tgx11_block(
	block_size_ca,
	bottom_segmentation = "chatom",
	bottom_v6hc_style = "none",
	top_segmentation = "chunk",
	lip_height = 1.5
);

notch = togmod1_linear_extrude_z([-1, block_size_mm[2]+lip_height_mm+1],
	let( rr=2*u )
	togpath1_rath_to_polygon(["togpath1-rath",
		["togpath1-rathnode", [ 2*u, 0*u], ["round", rr, 4]],
		["togpath1-rathnode", [ 4*u, 0*u]],
		["togpath1-rathnode", [ 2*u, 0*u], ["round", rr, 4]],
		["togpath1-rathnode", [ 1*u, 1*u]],
		["togpath1-rathnode", [-1*u, 1*u]],
		["togpath1-rathnode", [-2*u, 0*u], ["round", rr, 4]],
		["togpath1-rathnode", [-4*u, 0*u]],
		["togpath1-rathnode", [-2*u, 0*u], ["round", rr, 4]],
		["togpath1-rathnode", [-1*u,-1*u]],
		["togpath1-rathnode", [ 1*u,-1*u]],
	]));

// TODO: Instead, intersect block with extruded shape?
the_block_notched = ["difference",
	the_block,
	
	for( xm=[-block_size_chunks[0]/2 + 1 : 1 : block_size_chunks[0]/2 - 1] )
	for( ym=[-1,1] )
	["translate", [xm*chunk, ym*block_size_mm[1]/2, 0], notch],
];

wemos_cutout = tgpscc0_make_wemos_cutout(
	usb_cutout_style = "v1",
	antenna_support_height = 254/160
);

blank_floor_z = 4.2;

full_cutout = togmod1_make_cuboid([chunk_size_mm[0]+0.1, chunk_size_mm[1], chunk_size_mm[2]*3]);
blank_cutout = togmod1_make_cuboid([chunk_size_mm[0]+0.1, chunk_size_mm[1], (chunk_size_mm[2]-blank_floor_z)*2]);
gx12_port_cutout = tgpscc0_make_gx12_cutout(block_size = chunk_size_mm);

function component_to_togmod(name) =
	name == "gx12port" ? gx12_port_cutout :
	name == "solid" ? ["union"] :
	name == "blank" ? blank_cutout :
	name == "big-hole" ? full_cutout :
	name == "wemos" ? wemos_cutout :
	assert(false, str("Unrecognized component: '", name, "'"));

the_module = ["difference",
	the_block_notched,
   
	["intersection",
		["translate", [0,0,block_size_mm[2]], tgpscc0_make_cavity_limit(block_size_mm, cavity_width=limit_cavity_width_mm)],
		["union",
			for( i=[0 : 1 : len(components)-1] )
			["translate", [(-len(components)/2 + 0.5 + i)*chunk, 0, block_size_mm[2]], component_to_togmod(components[i])]
		]
	],
];

togmod1_domodule(["difference",
	["union",
		the_module,
	],
	
	if( cross_section ) ["translate", [0,-block_size_mm[1]/2,block_size_mm[2]/2], togmod1_make_cuboid([block_size_mm[0]*2,38.1,block_size_mm[2]*3])],
]);
