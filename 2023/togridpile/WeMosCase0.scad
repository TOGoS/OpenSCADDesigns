// WeMosCase0.7
// 
// A three-part case for holding WeMos D1 minis by their 'legs'
// (i.e. long-legged 'dupont' headers, pins down)
// in the form of a TOGridPile block.
// p2072 seems to work pretty well.
// 
// v0.3:
// - Based on WeMosClip0.2
// - Optionally includes each of case, clip, and grating,
//   together or separated (by part_offset)
// v0.4:
// - Change how grating is generated to ease FDM printing
// v0.5:
// - Changes based on findings from p2070a print, 2025-08-08T15:36-KM;
//   all are done so that p2070 result is as it was,
//   except for grating corner rounding
// - Case changes:
//   - Make pincav_floor_z configurable, default to 1/16" instead of 2/16"
//   - Additional cutouts for USB port and plug
// - Grating changes:
//   - Add a bump to support the antenna end of the board
//   - Round the corners a little bit
//   - Layer height is configurable
// v0.6:
// - Widen USB port cutout
// - More margin around grating
// - Option for case bump, which will replace the USB port notches
//   on one side if antenna_support_height > 0
// - Make the clip a wee bit shorter
// v0.6.1:
// - Add description comment, options for usb_cutout_style
// v0.7:
// - Start process of moving cavity generation to a TGPSCC0 library,
//   so that different cavities can be more easily mixed and matched
//   in different designs
//   - 'cavity_generator' = "tgpscc0" to generate the case cavity using the library
//   - Not all options are passed in; e.g. library acts as if pincav_length hardcoded to 8/10".
// - Categorize 'block', 'experimental', and 'detail' parameters
// - lip_height option

// Space for a pin; should probably be about half a pin width, ie 0.3175mm
pin_margin     = "0.32mm";
pin_spacing    = "9/10inch";
clip_thickness = "1/16inch";
clip_height    = "3/16inch";
// Should be slightly longer than the length of the clip
pincav_length  = "8/10inch";
pincav_floor_z = "1/16inch";
// For grating-generation purposes
layer_thickness = "0.4mm";
// A bump on the grating, if you want that.  Probably you want antenna_support_height instead.
grating_bump_size = ["1/2inch","1/2inch","0inch"];
antenna_support_height = "0inch";

usb_cutout_style = "none"; // ["none","v1"]
include_case = true;
include_clip = true;
include_grating = true;
part_offset = 0;

cross_section = false;

/* [Block] */

lip_height = "2.54mm";

/* [Experimental] */

cavity_generator = "original"; // ["original","tgpscc0"]

/* [Detail] */

$tgx11_offset = -0.1;
$fn = 24;

module wemoscase0__end_params() { }

use <../lib/TGPSCC0.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGUnits1.scad>
use <../lib/TOGPolyhedronLib1.scad>

$togridlib3_unit_table = tgx11_get_default_unit_table();

function reverse_list(list) =
	[for(i=[len(list)-1 : -1 : 0]) list[i]];

function mirror_rathnodes(nodes) = [
	for(n=nodes) n,
	for(n=reverse_list(nodes)) [n[0], [-n[1][0], n[1][1]], for(i=[2:1:len(n)-1]) n[i]],
];

pin_margin_mm       = togunits1_to_mm(pin_margin    );
pin_spacing_mm      = togunits1_to_mm(pin_spacing   );
clip_thickness_mm   = togunits1_to_mm(clip_thickness);
clip_height_mm      = togunits1_to_mm(clip_height   );
pincav_length_mm    = togunits1_to_mm(pincav_length );
center_gap_width_mm = 25.4/4 + 0.1;
clip_length_mm      = pincav_length_mm - 0.5;
lip_height_mm       = togunits1_to_mm(lip_height    );

the_clip_2d = togpath1_rath_to_polygon(
	let( ct = clip_thickness_mm                 )
	let( x0 = -pin_spacing_mm/2 + pin_margin_mm )
	let( y0 = -clip_height_mm                   )
	let( y1 = y0 + ct                           )
	let( y3 =  0                                )
	let( y2 = y3 - ct                           )
	let( fold_positions = [each [x0 + ct*3.5 : ct * 4 : -center_gap_width_mm/2 - ct*1.4 ]] )
	let( last_fold_position = fold_positions[len(fold_positions)-1] )
	let( ocops = [["round", ct]]         )
	let( icops = [["round", ct*127/256]] )
	["togpath1-rath", each mirror_rathnodes([
		for( cx = reverse_list(fold_positions) ) each [
			["togpath1-rathnode", [cx+0.5*ct, y3], each ocops],
			["togpath1-rathnode", [cx+0.5*ct, y1], each icops],
			["togpath1-rathnode", [cx-0.5*ct, y1], each icops],
			["togpath1-rathnode", [cx-0.5*ct, y3], each ocops],
		],
		["togpath1-rathnode", [x0     , y3], each ocops],
		["togpath1-rathnode", [x0     , y0], each icops],
		["togpath1-rathnode", [x0+1*ct, y0], each icops],
		["togpath1-rathnode", [x0+1*ct, y2], each icops],
		for( cx = fold_positions ) each let(cx0 = cx - ct*1.5, cx1 = cx == last_fold_position ? -center_gap_width_mm/2 : cx + ct*1.5 ) [
			["togpath1-rathnode", [cx0, y2], each icops],
			["togpath1-rathnode", [cx0, y0], each ocops],
			["togpath1-rathnode", [cx1, y0], each ocops],
			["togpath1-rathnode", [cx1, y2], each icops],
		],
	])]
);

the_clip = togmod1_linear_extrude_x([-clip_length_mm/2, clip_length_mm/2], the_clip_2d);

// togmod1_domodule(togmod1_linear_extrude_z([0, length_mm], the_clip_2d));

use <../lib/TGx11.1Lib.scad>

block_height = "1inch";
u = 254/160;
pin_z0 = togunits1_to_mm(pincav_floor_z);
block_height_mm = togunits1_to_mm(block_height);
deck_z = pin_z0 + 6*u;

grating_thickness_mm = 1*u;

pincav_size = [pincav_length_mm, pin_spacing_mm+pin_margin_mm*2];

block_size_ca = [[1, "chunk"],[1, "chunk"],togunits1_to_ca(block_height)];
block_size_mm = togunits1_decode_vec(block_size_ca);

antenna_support_height_mm = togunits1_decode(antenna_support_height);


notch_xms = antenna_support_height_mm > 0 ? [-1] : [-1,+1];

the_case_cavity = cavity_generator == "original" ? ["union",
	["difference",
		// Main cavity
		["translate", [0,0,togunits1_to_mm(block_height)], togmod1_make_cuboid(togunits1_decode_vec(["2inch","1+1/8inch",(block_height_mm-deck_z)*2]))],
		
		if( antenna_support_height_mm > 0 ) ["translate", [block_size_mm[0]/2, 0, deck_z],
			tphl1_make_rounded_cuboid([block_size_mm[0], 12.7, antenna_support_height_mm*2], r=antenna_support_height_mm*127/128)]
	],
		
	// Grating cavity
	["translate", [0,0,deck_z], togmod1_make_cuboid(togunits1_decode_vec(["10.2/10inch","10.2/10inch","2/16inch"]))],

   // Pin cavity
	["difference",
		["translate", [0,0,togunits1_to_mm(block_height)], togmod1_make_cuboid([
			pincav_size[0], pincav_size[1], (block_height_mm-pin_z0)*2
		])],
		
		togmod1_linear_extrude_x([-100, 100], ["translate", [0,deck_z - grating_thickness_mm - clip_height_mm], togmod1_make_rounded_rect([4*u, (clip_height_mm-clip_thickness_mm)*2], r=u*1.5)]),
	],
	
	// USB plug outer cutout
	if( usb_cutout_style == "v1" ) for( xm=notch_xms ) ["translate", [xm*block_size_mm[0]/2,0,deck_z], tphl1_make_rounded_cuboid([6.35, 15, 6.35], r=2)],
	// USB plug inner cutout
	if( usb_cutout_style == "v1" ) for( xm=notch_xms ) ["translate", [xm*block_size_mm[0]/2,0,deck_z], tphl1_make_rounded_cuboid([25.4, 9, 4], r=1)],
] :
cavity_generator == "tgpscc0" ? ["translate", [0,0,block_size_mm[2]], ["intersection",
	tgpscc0_make_cavity_limit(block_size_mm, lip_height=lip_height_mm),
	tgpscc0_make_wemos_cutout(floor_z = -block_size_mm[2] + 1*u)]
] :
assert(false, str("Unrecognized cavity algorithm: '", cavity_generator, "'"));

the_case = ["difference",
	tgx11_block(
		block_size_ca,
		bottom_segmentation = "chatom",
		top_segmentation = "block",
		lip_height = lip_height_mm
	),
   
	the_case_cavity
];

layer_thickness_mm = togunits1_decode(layer_thickness);

grating_size_mm = [25.4, 25.4, grating_thickness_mm];
grating_bump_size_mm = togunits1_decode_vec(grating_bump_size);

the_grating =
let(layer_count = round(grating_thickness_mm / layer_thickness_mm))
let(beam_width_mm = 254/200)
let(beam_2d = togmod1_make_rect([25, beam_width_mm]))
["union",
	["difference",
		togmod1_linear_extrude_z([0, grating_size_mm[2]], togmod1_make_rounded_rect([grating_size_mm[0]-0.1, grating_size_mm[1]-0.1], r=1)),
		
		["difference",
			togmod1_linear_extrude_z([-1, grating_size_mm[2]+1], togmod1_make_rect([grating_size_mm[0] - u, grating_size_mm[1] - u])),
			
			for( i = [0 : 1 : layer_count-1] )
			togmod1_linear_extrude_z( [i, i+1.01]*layer_thickness_mm,
				["rotate", [0,0,(i%2)*90], ["union",
					for( j=[-5 : 1 : 5] ) ["translate", [0, j*254/100], beam_2d]
				]]
			)			
		]
	],
	
	let( grating_bump_min_dim = min(grating_bump_size_mm[0], grating_bump_size_mm[1], grating_bump_size_mm[2]) )
	let( grating_bump_min_corner_rad = min(grating_bump_size_mm[0], grating_bump_size_mm[1], grating_bump_size_mm[2]+grating_thickness_mm)*127/256 )
	grating_bump_min_dim <= 0 ? ["union"] :
	["translate", [(grating_size_mm[1] - grating_bump_size_mm[0])/2, 0, (grating_bump_size_mm[2]+grating_thickness_mm)/2],
		tphl1_make_rounded_cuboid(
			[grating_bump_size_mm[0], grating_bump_size_mm[1], grating_bump_size_mm[2]+grating_thickness_mm],
			r = min(3.175, grating_bump_min_corner_rad),
			corner_shape = "ovoid1"
		)],
];


togmod1_domodule(["difference",
	["union",
		if( include_case ) the_case,
		
		if( include_clip ) ["translate", [0,part_offset*1,deck_z - grating_thickness_mm], the_clip],
		if( include_grating ) ["translate", [0,part_offset*-1,deck_z - grating_thickness_mm], the_grating],
	],
	
	if( cross_section ) ["translate", [-19.05,-19.05,19.05], togmod1_make_cuboid([38.1,38.1,100])],
]);
