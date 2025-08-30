// ChunkyPlate0.1
// 
// Baseplate that intentionally 'comes in between chunks'
// to leave room for string/tape

block_size = ["2chunk","1chunk","1/4inch"];
bottom_segmentation = "chunk";
bottom_v6hc_style = "none"; // ["none","v6.1"]
bottom_foot_bevel = "0.4mm";
top_segmentation = "chunk";
top_v6hc_style = "none"; // ["none","v6.1"]
foot_rounding = 0.7; // [0.25:0.1:1]
notch_depth = "1/8inch";
notch_width = "1/4inch";
lip_height = 1.5;

cross_section = false;

$fn = 24;
$tgx11_offset = -0.1;

module __chunkyplate0__end_params() { }

use <../lib/TOGArrayLib1.scad>
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

bottom_foot_bevel_mm = togunits1_decode(bottom_foot_bevel);
chunk = togunits1_decode([1,"chunk"]);
block_size_ca = togunits1_vec_to_cas(block_size);
block_size_mm = togunits1_decode_vec(block_size_ca);
block_size_chunks = togunits1_decode_vec(block_size_ca, unit=[1,"chunk"]);
notch_size_mm = togunits1_decode_vec([notch_width, notch_depth]);

notch_bev_mm = tal1_reduce(1000, notch_size_mm, function(a,b) min(a,b));

// TODO: Allow for wider notches
x_face_notch = togmod1_linear_extrude_z(
	[-1, block_size_mm[2]+lip_height+1],
	togpath1_rath_to_polygon(["togpath1-rath",
		["togpath1-rathnode", [ notch_size_mm[0]/2+5, -8  ]],
		["togpath1-rathnode", [ notch_size_mm[0]/2+5, -0.1]],
		["togpath1-rathnode", [ notch_size_mm[0]/2  ,  0  ], ["round", notch_bev_mm/2]],
		["togpath1-rathnode", [ notch_size_mm[0]/2-notch_bev_mm/2, notch_size_mm[1]/2], ["round", notch_bev_mm/2]],
		["togpath1-rathnode", [-notch_size_mm[0]/2+notch_bev_mm/2, notch_size_mm[1]/2], ["round", notch_bev_mm/2]],
		["togpath1-rathnode", [-notch_size_mm[0]/2  ,  0  ], ["round", notch_bev_mm/2]],
		["togpath1-rathnode", [-notch_size_mm[0]/2-5, -0.1]],
		["togpath1-rathnode", [-notch_size_mm[0]/2-5, -8  ]],
	])
);

the_block = ["difference",
	tgx11_block(
		block_size_ca,
		bottom_segmentation = bottom_segmentation,
		bottom_v6hc_style = bottom_v6hc_style,
		bottom_foot_bevel = bottom_foot_bevel_mm,
		top_segmentation = top_segmentation,
		top_v6hc_style = top_v6hc_style,
		lip_height = lip_height
	),
	
	// Front and back notches
	for( ystuf=[[-block_size_chunks[1]/2, 0], [block_size_chunks[1]/2, 180]] )
	for( xm=[-block_size_chunks[0]/2 + 1 : 1 : block_size_chunks[0]/2-0.9] )
	["translate", [xm*chunk, ystuf[0]*chunk, 0], ["rotate",[0,0,ystuf[1]],x_face_notch]],
	// Side notches
	for( xstuf=[[-block_size_chunks[0]/2, -90], [block_size_chunks[0]/2, 90]] )
	for( ym=[-block_size_chunks[1]/2 + 1 : 1 : block_size_chunks[1]/2-0.9] )
	["translate", [xstuf[0]*chunk, ym*chunk, 0], ["rotate",[0,0,xstuf[1]],x_face_notch]],
];
the_module = ["difference",
	the_block,
];

togmod1_domodule(["difference",
	["union",
		the_module,
	],
	
	if( cross_section ) ["translate", [-19.05,-19.05,19.05], togmod1_make_cuboid([38.1,38.1,100])],
]);
