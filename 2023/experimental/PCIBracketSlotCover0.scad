// PCIBracketSlotCover0.0
// 
// See
// - https://web.archive.org/web/20221220092125/https://www.overclock.net/threads/guide-to-drawing-pci-e-and-atx-mitx-rear-io-bracket-for-a-custom-case.1589018/
// - https://web.archive.org/web/20201112014246/http://read.pudn.com/downloads166/ebook/758109/PCI_Express_CEM_1.1.pdf
//
// Width between slots = 20.32mm

// Makes the shape as seen from inside the computer
function make_back_rath(
	w0 =  21.59 /* width from right edge to left of top */,
	h1 = 112.75 /* about 4+7/16 * inch */,
	b1 =   4.12 /* left bottom bevel */,
	b2 =   4.11 /* right bottom bevel */,
	w1 =  10.19 /* bottom stickey-outey bit */,
	h2 =   7.14 /* about 9/32" */,
	h3 =   4.56 /* height of top right stickey-outey bit */,
	h4 =   2.92 /* height of top unbeveled section of top-right stickey-outey bit */,
	h5 =   3.08 /* height of top unbeveled section of top-right cutout */,
	b5 =   2.54 /* width and height of top-right cutout bevel */,
	h9 =   0.86 /* thickness of top bit */,
	er =   1    /* extra rounding, not part of spec */
) = ["togpath1-rath",
	["togpath1-rathnode", [0 + b5          , 0 + h9       ], ["round", er]],
	["togpath1-rathnode", [0 + b5          , 0 - h5       ]],
	["togpath1-rathnode", [0               , 0 - h5 - b5  ], ["round", er]],
	["togpath1-rathnode", [0               , 0 - h1 + b1  ], ["round", er]],
	["togpath1-rathnode", [0 + b1          , 0 - h1       ]],
	["togpath1-rathnode", [0 + b1          , 0 - h1 - h2  ], ["round", 1.91]],
	["togpath1-rathnode", [0 + b1 + w1     , 0 - h1 - h2  ], ["round", 1.91]],
	["togpath1-rathnode", [0 + b1 + w1     , 0 - h1       ]],
	["togpath1-rathnode", [0 + b1 + w1 + b2, 0 - h1 + b2  ], ["round", er]],
	["togpath1-rathnode", [0 + b1 + w1 + b2, 0 - h3       ]],
	["togpath1-rathnode", [0 + w0 - h3 + h4, 0 - h3       ], ["round", er]],
	["togpath1-rathnode", [0 + w0          , 0 - h4       ], ["round", er]],
	["togpath1-rathnode", [0 + w0          , 0 + h9       ], ["round", er]],
];

use <../lib/TOGMod1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>

$fn = 32;

togmod1_domodule( tphl1_extrude_polypoints([0,1], togpath1_rath_to_polypoints(make_back_rath())) );
