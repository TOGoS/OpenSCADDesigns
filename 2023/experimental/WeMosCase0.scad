// WeMosCase0.4
// 
// v0.3:
// - Based on WeMosClip0.2
// - Optionally includes each of case, clip, and grating,
//   together or separated (by part_offset)
// v0.4:
// - Change how grating is generated to ease FDM printing

// Space for a pin; should probably be about half a pin width, ie 0.3175mm
pin_margin     = "0.32mm";
pin_spacing    = "9/10inch";
clip_thickness = "1/16inch";
clip_height    = "3/16inch";
// Should be slightly longer than the length of the clip
pincav_length  = "8/10inch";

include_case = true;
include_clip = true;
include_grating = true;
part_offset = 0;

cross_section = false;

$fn = 24;
$tgx11_offset = -0.1;

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGUnits1.scad>

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
clip_length_mm      = pincav_length_mm - 0.3;

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
pin_z0 = 2*u;
block_height_mm = togunits1_to_mm(block_height);
deck_z = pin_z0 + 6*u;

grating_thickness_mm = 1*u;

pincav_size = [pincav_length_mm, pin_spacing_mm+pin_margin_mm*2];

the_case = ["difference",
	tgx11_block(
		[[1, "chunk"],[1, "chunk"],togunits1_to_ca(block_height)],
		bottom_segmentation = "chatom",
		top_segmentation = "block"
	),
   
	// Main cavity
	["translate", [0,0,togunits1_to_mm(block_height)], togmod1_make_cuboid(togunits1_decode_vec(["2inch","1+1/8inch",(block_height_mm-deck_z)*2]))],
	
	// Grating cavity
	["translate", [0,0,deck_z], togmod1_make_cuboid(togunits1_decode_vec(["10.08/10inch","10.08/10inch","2/16inch"]))],

   // Pin cavity
	["difference",
		["translate", [0,0,togunits1_to_mm(block_height)], togmod1_make_cuboid([
			pincav_size[0], pincav_size[1], (block_height_mm-pin_z0)*2
		])],
		
		togmod1_linear_extrude_x([-100, 100], ["translate", [0,deck_z - grating_thickness_mm - clip_height_mm], togmod1_make_rounded_rect([4*u, (clip_height_mm-clip_thickness_mm)*2], r=u*1.5)]),
	]
];

// Hmm: Might be better for printability to use TOGratLib approach with alternating x/y beams
the_grating_take1 = togmod1_linear_extrude_z([0, u],
	let( grating_hole = togmod1_make_rect([1.3, 1.3]) )
	["difference",
		togmod1_make_rect([25.3, 25.3]),
		for( ym=[-4.5 : 1 : 4.5] )
		for( xm=[-4.5 : 1 : 4.5] )
		["translate", [xm*254/100, ym*254/100], grating_hole],
	]
);

layer_thickness_mm = 0.4;

the_grating_take2 =
let(layer_count = floor(grating_thickness_mm / layer_thickness_mm))
let(beam_width_mm = 254/200)
let(beam_2d = togmod1_make_rect([25, beam_width_mm]))
["union",
	["difference",
		togmod1_linear_extrude_z([0, u], togmod1_make_rect([25.3, 25.3])),
		
		["difference",
			togmod1_linear_extrude_z([-100, 100], togmod1_make_rect([25.3 - u, 25.3 - u])),
			
			for( i = [0 : 1 : layer_count-1] )
			togmod1_linear_extrude_z( [i, i+1.01]*layer_thickness_mm,
				["rotate", [0,0,(i%2)*90], ["union",
					for( j=[-5 : 1 : 5] ) ["translate", [0, j*254/100], beam_2d]
				]]
			)			
		]
	]
];

the_grating = the_grating_take2;


togmod1_domodule(["difference",
	["union",
		if( include_case ) the_case,
		
		if( include_clip ) ["translate", [0,part_offset*1,deck_z - grating_thickness_mm], the_clip],
		if( include_grating ) ["translate", [0,part_offset*-1,deck_z - grating_thickness_mm], the_grating],
	],
	
	if( cross_section ) ["translate", [-19.05,-19.05,19.05], togmod1_make_cuboid([38.1,38.1,100])],
]);
