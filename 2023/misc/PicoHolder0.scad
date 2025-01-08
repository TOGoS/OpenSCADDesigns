// PicoHolder0.1
// 
// MiniRail-mounted holder for Pi Pico [W]

board_margin = 0.1;
minirail_margin = 0.1;
usb_cutout_depth = 2;
$fn = 48;

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>

module picoholder0__end_params() { }

inch = 25.4;

pico_board_size = [21,1,51];
overhead_cutout_width = 15;
usb_plug_cutout_width = 12;

pico_cutout =
let( expanded_board_size = [for(d=pico_board_size) d+board_margin] )
let( xxpanded_board_size = [expanded_board_size[0], expanded_board_size[1], 500] )
let( overhead_cutout_size = [overhead_cutout_width, 40, 100] )
let( board_end_z = -pico_board_size[2]/2 )
let( ucd = usb_cutout_depth )
["union",
	["translate", [0,      pico_board_size[1]/2, board_end_z + 0 + xxpanded_board_size[2]/2], togmod1_make_cuboid(xxpanded_board_size)],
	["translate", [0, overhead_cutout_size[1]/2, board_end_z + 5 + overhead_cutout_size[2]/2], togmod1_make_cuboid(overhead_cutout_size)],
	["translate", [0, 0,                         board_end_z], togmod1_linear_extrude_x(
		[-usb_plug_cutout_width/2, usb_plug_cutout_width/2],
		togmod1_make_polygon([
			[- ucd,     0  ],
			[  0.5, ucd+0.5],
			[  0.5,    20  ],
			[ 10  ,    20  ],
			[ 10  ,  -200  ],
			[- 3  ,  -200  ],
		])
	)]
];

minirail_cutout =
let( caveops = [["offset", minirail_margin], ["round", max(0.05,minirail_margin)]] )
let(  vexops = [["offset", minirail_margin], ["round", 1]] )
togmod1_linear_extrude_z([-500,500], togmod1_make_polygon(togpath1_rath_to_polypoints(["togpath1-rath",
	["togpath1-rathnode", [-1/2*inch,  1/4*inch], each caveops],
	["togpath1-rathnode", [-1/4*inch,    0*inch], each  vexops],
	["togpath1-rathnode", [-100     ,    0*inch], each caveops],
	["togpath1-rathnode", [-100     , -100     ], each caveops],
	["togpath1-rathnode", [ 100     , -100     ], each caveops],
	["togpath1-rathnode", [ 100     ,    0*inch], each caveops],
	["togpath1-rathnode", [ 1/4*inch,    0*inch], each  vexops],
	["togpath1-rathnode", [ 1/2*inch,  1/4*inch], each caveops],
])));

board_pos = [0, 3/8*inch, 3/8*inch];
hull_size = [1.25*inch, 0.5*inch, 2*inch];

if( $preview ) togmod1_domodule(["x-color", "green", ["translate", board_pos + [0, pico_board_size[1]/2, 0], togmod1_make_cuboid(pico_board_size)]]);
togmod1_domodule(["difference",
	["translate", [0,hull_size[1]/2,0], tphl1_make_rounded_cuboid(hull_size, r=[6,6,0])],
	
	["translate", board_pos, pico_cutout],
	minirail_cutout,
]);
