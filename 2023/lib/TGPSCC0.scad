// TGPSCC0.2
// 
// 'TOGridPile Small Component Cavities'
// 
// Library of component cutouts for making cases similar to WeMosCase0, etc.
// 
// v0.2:
// - Round ends and top of cavity limit

// Preliminary design:
// Components cut a cavity slightly wider than what they need.
// The union of those cavities will then be intersected with a Y-limited
// cuboid that is the actual cavity width common to all the sections.

use <./Flangify0.scad>
use <./TOGMod1Constructors.scad>
use <./TOGPolyhedronLib1.scad>
use <./TOGUnits1.scad>

inch = 25.4;

function tgpscc0_make_cavity_limit(
	block_size = togunits1_decode_vec(["1chunk", "1chunk", "10chunk"]),
	cavity_width = togunits1_decode("1+1/8inch"),
	lip_height = 2.54
) = ["rotate", [90,0,90],
   flangify0_extrude_z(
		flangify0_spec_to_zrs(flangify0_extend(10, 10, ["zdopses",
			["zdops", [-block_size[0]/2, 10]],
			["zdops", [-block_size[0]/2,  0], ["round", 3, 8]],
			["zdops", [ block_size[0]/2,  0], ["round", 3, 8]],
			["zdops", [ block_size[0]/2, 10]],
		])),
		["togpath1-rath",
			["togpath1-rathnode", [ cavity_width/2, -block_size[2]*2]],
			["togpath1-rathnode", [ cavity_width/2,         0 + $tgx11_offset], ["round", 3.1, 8]],
			["togpath1-rathnode", [ cavity_width/2 + 100, 100 + $tgx11_offset]],
			["togpath1-rathnode", [-cavity_width/2 - 100, 100 + $tgx11_offset]],
			["togpath1-rathnode", [-cavity_width/2,         0 + $tgx11_offset], ["round", 3.1, 8]],
			["togpath1-rathnode", [-cavity_width/2, -block_size[2]*2]],
		]
	)
];

function tgpscc0_make_wemos_cutout(
	usb_cutout_style="none",
	floor_z = -inch*15/16,
	antenna_support_height = 0,
	deck_z = -inch*9/16, // floor_z + 6*u
	pincav_size = [
		inch * 8/10,
		inch * 9/10 + 0.32 * 2,
	],
	grating_thickness = inch*1/16,
	clip_height = inch*3/16,
	clip_thickness = inch*1/16,
	u = inch/16
) =
	let( chunk = togunits1_decode([1,"chunk"]) )
	let( notch_xms = antenna_support_height > 0 ? [-1] : [-1,+1] )
	["union",
		["difference",
			// Main cavity
			togmod1_make_cuboid([2*inch,2*inch,-deck_z*2]),
			
			if( antenna_support_height > 0 ) ["translate", [chunk/2, 0, deck_z],
				tphl1_make_rounded_cuboid([chunk, 12.7, antenna_support_height*2], r=antenna_support_height*127/128)]
		],
		
		// Grating cavity
		["translate", [0,0,deck_z], togmod1_make_cuboid(togunits1_decode_vec([inch*10.2/10,inch*10.2/10,inch*2/16]))],
	
	   // Pin cavity
		["difference",
		   togmod1_make_cuboid([pincav_size[0], pincav_size[1], -floor_z*2]),
			
			togmod1_linear_extrude_x([-100, 100], ["translate", [0,deck_z - grating_thickness - clip_height], togmod1_make_rounded_rect([4*u, (clip_height-clip_thickness)*2], r=u*1.5)]),
		],
		
		// USB plug outer cutout
		if( usb_cutout_style == "v1" ) for( xm=notch_xms ) ["translate", [xm*chunk/2,0,deck_z], tphl1_make_rounded_cuboid([6.35, 15, 6.35], r=2)],
		// USB plug inner cutout
		if( usb_cutout_style == "v1" ) for( xm=notch_xms ) ["translate", [xm*chunk/2,0,deck_z], tphl1_make_rounded_cuboid([25.4, 9, 4], r=1)],
	];
