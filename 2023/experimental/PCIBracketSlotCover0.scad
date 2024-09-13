// PCIBracketSlotCover0.1
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

// Makes the shape as seen from inside the computer
function make_back_rath(
	w0 =  21.59 /* width from right edge to left of top */,
	h1 = 112.75 /* about 4+7/16 * inch */,
	b1 =   4.12 /* left bottom bevel */,
	w2 =  18.42 /* main body width */,
	w1 =  10.19 /* bottom stickey-outey bit */,
	h2 =   7.14 /* about 9/32" */,
	h3 =   4.56 /* height of top right stickey-outey bit */,
	h4 =   2.92 /* height of top unbeveled section of top-right stickey-outey bit */,
	h5 =   3.08 /* height of top unbeveled section of top-right cutout */,
	b5 =   2.54 /* width and height of top-right cutout bevel */,
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

function make_side_rath(
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

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>

$fn = 32;

function make_bracket(
	z1 = 64.13 - 59.05 /* front of bracket to center of hole; see [OEM] p73 */,
	z2 = 11.43 /* Overhang */,
	w0 = 21.59,
	w2 =  18.42 /* main body width */,
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
			togmod1_linear_extrude_z([-50,50], togmod1_make_polygon(togpath1_rath_to_polypoints(make_back_rath(h9=100)))),
			togmod1_linear_extrude_x([-50,50], togmod1_make_polygon(togpath1_rath_to_polypoints(make_side_rath(z2=z2, h9=3)))),
		],
		if( connector_bump_height > 0 ) ["translate", [w2/2, (0 - 100.36 - 10.46)/2, -connector_bump_height/2 + 0.1], togmod1_make_cuboid([11,100.36 - 10.46, connector_bump_height+0.2])]
	],
	["translate", [w0, 0, -z1], togmod1_linear_extrude_y([-10,10], togmod1_make_rounded_rect([(w0-18.42+2.21)*2, 4.42], r=2.2))],
	["translate", [(k1+k2)/2, 0, -z2], togmod1_linear_extrude_y([-10,10], togmod1_make_rect([kd, kz*2]))],

	["translate", [w2/2, -15.875, 0], lineup_circle],
	["translate", [w2/2, -92.075, 0], lineup_circle],
];

togmod1_domodule(make_bracket());
