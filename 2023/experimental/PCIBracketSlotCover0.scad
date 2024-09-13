// PCIBracketSlotCover0.3
// 
// See
// - [OC] https://web.archive.org/web/20221220092125/https://www.overclock.net/threads/guide-to-drawing-pci-e-and-atx-mitx-rear-io-bracket-for-a-custom-case.1589018/
// - [CEM] https://web.archive.org/web/20201112014246/http://read.pudn.com/downloads166/ebook/758109/PCI_Express_CEM_1.1.pdf
//
// Width between slots = 20.32mm
// Width of main part of bracket = 18.42 (b1 + w1 + b2)
// 
// Connector opening is 12.06mm wide and roughly centered on the tab at the bottom of the bracket,
// Assuming this is centered on the main section, that would be x = 3.18mm to 15.24mm.
// 89.90mm tall, from -100.36mm to -10.46mm (See [CEM] p73)
// 
// Versions:
// v0.1 (p1597):
// - 1mm thick bracket
// - stickey-outey bit to test if it actually fits in the 'connector opening'
//   (it does, at least in the AlamenCase)
// v0.2 (p1598):
// - 'buzpwr flacket' - bracket without top clip for holding
//   a momentary button (one of Jon's smaller ones because I ran out of my usual bulky ones)
//   and a round 11.7mm-diameter buzzer
// v0.3 (p1599):
// - The top clip thing
// - Remove "_make" prefixes from function names

module __pcibsc0__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>

$fn = 32;


pcibsc0_default_z1 = 64.13 - 59.05; /* front of bracket to center of hole; see [OEM] p73 */
pcibsc0_default_thickness = 0.9;
pcibsc0_default_body_width = 18.42; /* main body width */
pcibsc0_default_overhang = 11.43;

pcibsc0_lineup_post_center_x = pcibsc0_default_body_width/2;

//pcibsc0_visible_hole_positions = [-15.875, -92.075]; // -5/8 and -3-5/8
//pcibsc0_alt_hole_positions = [-15.875, -79.375]; // -5/8 and -2-5/8

function pcibsc0_z_hole_positions( atoms ) = [for(a=atoms) a*12.7 - 9.525];

pcibsc0_visible_hole_positions = pcibsc0_z_hole_positions([-0.5, -6.5]);
pcibsc0_alt_hole_positions = pcibsc0_z_hole_positions([-0.5, -4.5]);

// Makes the shape as seen from inside the computer
function pcibsc0_back_rath(
	w0 =  21.59 /* width from right edge to left of top */,
	h1 = 112.75 /* about 4+7/16 * inch */,
	b1 =   4.12 /* left bottom bevel */,
	w2 = pcibsc0_default_body_width,
	w1 =  10.19 /* bottom stickey-outey bit */,
	h2 =   7.14 /* about 9/32" */,
	h3 =   4.56 /* height of top right stickey-outey bit */,
	h4 =   2.92 /* height of top unbeveled section of top-right stickey-outey bit */,
	h5 =   3.08 /* height of top unbeveled section of top-right cutout */,
	b5 =   2.54 /* width and height of top-left cutout bevel */,
	h9 =   0.86 /* thickness of top bit */,
	er =   1    /* extra rounding, not part of spec */
) =
let( b2 = w2 - w1 - b1 /* right bottom bevel, 4.11mm */ )
["togpath1-rath",
	["togpath1-rathnode", [0 + b5          , 0 + h9       ], ["round", er]],
	["togpath1-rathnode", [0 + b5          , 0 - h5       ]],
	["togpath1-rathnode", [0               , 0 - h5 - b5  ], ["round", er]],
	["togpath1-rathnode", [0               , 0 - h1 + b1  ], ["round", er]],
	["togpath1-rathnode", [0 + b1          , 0 - h1       ]],
	["togpath1-rathnode", [0 + b1          , 0 - h1 - h2  ], ["round", 1.91]],
	["togpath1-rathnode", [0 + b1 + w1     , 0 - h1 - h2  ], ["round", 1.91]],
	["togpath1-rathnode", [0 + b1 + w1     , 0 - h1       ]],
	["togpath1-rathnode", [0 + w2          , 0 - h1 + b2  ], ["round", er]],
	["togpath1-rathnode", [0 + w2          , 0 - h3       ]],
	["togpath1-rathnode", [0 + w0 - h3 + h4, 0 - h3       ], ["round", er]],
	["togpath1-rathnode", [0 + w0          , 0 - h4       ], ["round", er]],
	["togpath1-rathnode", [0 + w0          , 0 + h9       ], ["round", er]],
];

function pcibsc0_side_rath(
	z2 = 11.43 /* Overhang; [OEM] p75 */,
	z3 =  1 /* Thickness */,
	h9 =  3 /* thickness of top */,
	er =  1,
) = ["togpath1-rath",
	["togpath1-rathnode", [   0, 0 ]],
	["togpath1-rathnode", [   0,-z2]],
	["togpath1-rathnode", [  h9,-z2]],
	["togpath1-rathnode", [  h9, z3], ["round", er]],
	["togpath1-rathnode", [-200, z3]],
	["togpath1-rathnode", [-200, 0 ]],
];

function pcibsc0_bracket(
	z1 = pcibsc0_default_z1,
	z2 = pcibsc0_default_overhang /* Overhang */,
	w0 = 21.59,
	w2 = pcibsc0_default_body_width,
	h9 = 3,
// k... are all for the little square hole.
// I'm not bothering to fold it in for pinching the rail.
	k1 = 10.92, k2 = 13.97, kz = 3.81,
	lineup_circle = togmod1_linear_extrude_z([-50,50], togmod1_make_circle(d=4.5)),
	connector_bump_height = 3
) =
let( kd = k2-k1 )
["difference",
	["union",
		["intersection",
			togmod1_linear_extrude_z([-50,50], togmod1_make_polygon(togpath1_rath_to_polypoints(pcibsc0_back_rath(h9=100)))),
			togmod1_linear_extrude_x([-50,50], togmod1_make_polygon(togpath1_rath_to_polypoints(pcibsc0_side_rath(z2=z2, h9=3)))),
		],
		if( connector_bump_height > 0 ) ["translate", [w2/2, (0 - 100.36 - 10.46)/2, -connector_bump_height/2 + 0.1], togmod1_make_cuboid([11,100.36 - 10.46, connector_bump_height+0.2])]
	],
	["translate", [w0, 0, -z1], togmod1_linear_extrude_y([-10,10], togmod1_make_rounded_rect([(w0-18.42+2.21)*2, 4.42], r=2.2))],
	["translate", [(k1+k2)/2, 0, -z2], togmod1_linear_extrude_y([-10,10], togmod1_make_rect([kd, kz*2]))],

	for( y=pcibsc0_visible_hole_positions ) ["translate", [w2/2, y, 0], lineup_circle],
];

// Flacket = bracket not including the overhang

function pcibsc0_flacket_side_rath(
	body_thickness,
	bottom_tab_thickness = 0.9,
	bottom_tab_y0 = -200 /* Bottom of bottom tab; large negative number because this will be intersected */,
	bottom_tab_y1 = -100 /* Top of bottom tab, below whick thickness = bottom_tab_thickness */,
	bt_bevel_size = 8 /* Bevel between tab and body */,
	lr =  6,  // Large radius
	er =  1,  // Extra radius
) = let(
	btt = bottom_tab_thickness,
	bdt = body_thickness,
	btb = min(bt_bevel_size, bdt - btt - er*2 - 0.1),
	bty0 = bottom_tab_y0,
	bty1 = bottom_tab_y1,
	bty2 = bty1 + bdt - btt
) ["togpath1-rath",
	["togpath1-rathnode", [    0      , 0            ]],
	["togpath1-rathnode", [    0      , 0 + bdt      ]],
	//["togpath1-rathnode", [ bty1 + btb, 0 + bdt      ], ["round", er]],
	//["togpath1-rathnode", [ bty1 + btb, 0 + btt + btb], ["round", er]],
	["togpath1-rathnode", [ bty2      , 0 + bdt      ], ["round", lr]],
	["togpath1-rathnode", [ bty1      , 0 + btt      ], ["round", lr]],
	["togpath1-rathnode", [ bty0      , 0 + btt      ]],
	["togpath1-rathnode", [ bty0      , 0            ]],
];

function pcibsc0_pseudohex_rath( xmin, xmaj, ymaj, offset=0) =
let(
	ops = offset > 0 ? [["offset", offset]] : []
) ["togpath1-rath",
	["togpath1-rathnode", [ xmaj/2, 0     ], each ops],
	["togpath1-rathnode", [ xmin/2, ymaj/2], each ops],
	["togpath1-rathnode", [-xmin/2, ymaj/2], each ops],
	["togpath1-rathnode", [-xmaj/2, 0     ], each ops],
	["togpath1-rathnode", [-xmin/2,-ymaj/2], each ops],
	["togpath1-rathnode", [ xmin/2,-ymaj/2], each ops],
];

function pcibsc0_pseudohex( xmin, xmaj, ymaj, offset=0) =
	togmod1_make_polygon(togpath1_rath_to_polypoints(pcibsc0_pseudohex_rath(xmin, xmaj, ymaj, offset=offset)));

function pcibsc0_lineup_post_2d(offset=0) =
	pcibsc0_pseudohex(6.35, 7.9375, 3.175, offset=offset);

function pcibsc0_flacket(
	thickness = pcibsc0_default_thickness,
	w2 = pcibsc0_default_body_width,
	hs_hole = togmod1_linear_extrude_y([-10,10], togmod1_make_circle(d=5))
) = let(
	clip_lineup_hole = togmod1_linear_extrude_z([-1,thickness+1], togmod1_make_circle(d=4.5)),
	clip_lineup_profile = pcibsc0_lineup_post_2d(offset=0.1),
	clip_lineup_slot = togmod1_linear_extrude_z([-1,thickness+1], clip_lineup_profile)
) ["difference",
	["intersection",
		togmod1_linear_extrude_z([0,thickness*2], togmod1_make_polygon(togpath1_rath_to_polypoints(pcibsc0_back_rath(h9=0)))),
		togmod1_linear_extrude_x([-50,50], togmod1_make_polygon(togpath1_rath_to_polypoints(pcibsc0_flacket_side_rath(thickness)))),
	],
	
	for( z=[ 6.35 : 12.7 : thickness-3.175] )	["translate", [w2/2, 0, z], hs_hole],
	
	["translate", [w2/2, 0, 0], clip_lineup_slot],
	
	for( y=pcibsc0_alt_hole_positions ) ["translate", [w2/2, y, 0], clip_lineup_hole],
];

function pcibsc0_buzpwr_flacket(
	thickness = 19.05
) = let(
	w2 = pcibsc0_default_body_width
) ["difference",
	pcibsc0_flacket(thickness),
		
	// Underside rack, which is hard to print and also too tight:
	//["translate", [w2/2, (-1.5-3/8)*25.4, 0], togmod1_make_cuboid([12.7 + 0.4, 76.2 + 0.4, 12.7])],
	//["translate", [w2/2, (-1.5-3/8)*25.4, 0], togmod1_make_cuboid([12.7 + 0.2, 50.8 + 0.4, thickness*3])],
	
	// Power button hole
	["translate", [w2/2, 25.4 * (-9/8), 0], tphl1_make_z_cylinder(zds=[[-1, 12.7], [14,12.7], [16,8.5], [thickness+1, 8.5]])],
	
	// Buzzer hole
	["translate", [w2/2, 25.4 * (-17/8), 0], tphl1_make_z_cylinder(zds=[[-1, 6.35], [6.35,6.35], [6.35,12.7], [thickness+1,12.7]])]
];

function pcibsc0_top_rath(
	back_depth  = 25.4,
	front_depth = pcibsc0_default_overhang,
	z1 = pcibsc0_default_z1,
	w0 = 21.59,
	w2 = pcibsc0_default_body_width,
	k1 = 10.92, k2 = 13.97, kz = 3.81,
	shd = 5 // 4.42 // screw hole diameter; nominally 4.42, but I add some margin
) = ["togpath1-rath",
	["togpath1-rathnode", [w0      , - back_depth]],
	["togpath1-rathnode", [w0      ,   z1 + shd/2]],
	["togpath1-rathnode", [w2-shd/2,   z1 + shd/2], ["round", shd/2-0.1]],
	["togpath1-rathnode", [w2-shd/2,   z1 - shd/2], ["round", shd/2-0.1]],
	["togpath1-rathnode", [w0      ,   z1 - shd/2]],
	["togpath1-rathnode", [w0      ,  front_depth]],
	["togpath1-rathnode", [k2      ,  front_depth]],
	["togpath1-rathnode", [k2      ,  front_depth - kz]],
	["togpath1-rathnode", [k1      ,  front_depth - kz]],
	["togpath1-rathnode", [k1      ,  front_depth]],
	["togpath1-rathnode", [2.54    ,  front_depth]],
	["togpath1-rathnode", [2.54    , - back_depth]],
];

function pcibsc0_top_clip(back_depth, thickness) = let(
	cx = pcibsc0_lineup_post_center_x,
	hs_hole = togmod1_linear_extrude_z([-10,10], togmod1_make_circle(d=4.5))
) ["difference",
	["intersection",
		["union",
			togmod1_linear_extrude_z([0, thickness+1], togmod1_make_polygon(togpath1_rath_to_polypoints(pcibsc0_top_rath(back_depth)))),
			["translate", [cx,0,0], togmod1_linear_extrude_y([-back_depth, 0], pcibsc0_lineup_post_2d(0.1))],
		],
		togmod1_linear_extrude_z([-50, thickness], togmod1_make_rect([100,100])),
	],
	for( y=[ 6.35 : 12.7 : back_depth-3.175] ) ["translate", [cx, -y, 0], hs_hole],
];

//togmod1_domodule(pcibsc0_bracket());
//togmod1_domodule(pcibsc0_buzpwr_flacket());

togmod1_domodule(pcibsc0_top_clip(25.4, 3.175));
