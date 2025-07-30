// FHTVPSPlate1.0
//
// Plate for the farmhouse TV power strip
//
// Versions:
// v1.0:
// - Based on WSTYPE201630Plate1.2

thickness   = 6.35;

$fn = 24;

module __whatever__end_params() { }

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>

function make_tailey_base_2d(offset=0) =
	["union",
		togmod1_make_circle(d=head_width + offset*2),
		["translate", [0,-head_width/2], togmod1_make_rounded_rect([stem_width+offset*2, head_width+offset*2], r=stem_width*63/128)]
	];

chunk = 38.1;

nub_hole = ["rotate", [180,0,0], tog_holelib2_hole("THL-1005", inset=2.5)];

inch = 25.4;

nub_hole_positions = [
	for( xm=[-0.5,0.5] ) for( ym=[-0.5,0.5] ) [xm*(3+7/8)*inch, ym*(6+5/8)*inch]
];

gridbeam_hole_positions = [
	for( xm=[-1 : 1 : 1] ) for( ym=[-2, 2] ) [xm,ym]*chunk,
];

gridbeam_hole = tog_holelib2_hole("THL-1005", inset=2.5);

// One triangle
cake = togmod1_make_polygon(togpath1_rath_to_polypoints(
let(cops=[["round", 3.175], ["offset", -25.4/15]])
["togpath1-rath",
	["togpath1-rathnode", [0.5*chunk, -0.5*chunk], each cops],
	["togpath1-rathnode", [0.5*chunk, +0.5*chunk], each cops],
	["togpath1-rathnode", [0        ,  0        ], each cops],
]));
// Four triangles
cakes = ["union",
   for( r=[0:90:270] ) ["rotate", [0,0,r], cake]
];
function make_bake(offset) = togmod1_make_rounded_rect([chunk-3.175+offset*2, chunk-3.175+offset*2], r=25.4/8);

function make_lake(rect_size, offset) = ["intersection",
	//togmod1_make_rect([3*chunk-12.7, 8*chunk]),
	// togmod1_make_rounded_rect([3*chunk+offset*2, 6*chunk+offset*2], r=55+offset)
	togpath1_make_rounded_beveled_rect(rect_size, 38.1, 12.7, offset=offset),
];

togmod1_domodule(["difference",
	togmod1_linear_extrude_z(
		[0,thickness], ["difference",
			togmod1_make_rounded_rect([4.5*inch, 7.5*inch], r=9),
		   
		   ["intersection",
				make_lake([3*chunk, 4*chunk], -3.175),
				["union", for( xm=[-1:1:1] ) for( ym=[-1:1:1] ) ["translate", [xm,ym]*chunk, cakes]],
			],
		]
	),
	
	for( pos=nub_hole_positions ) ["translate", pos, nub_hole],

	for( pos=gridbeam_hole_positions ) ["translate", [pos[0],pos[1],thickness], gridbeam_hole],

   // Hackety hack
	togmod1_linear_extrude_z([thickness/2, thickness*3/2],
		let(bake=make_bake(0.1))
		["intersection",
			make_lake([3*chunk,6*chunk], 0),
			["union", for( xm=[-1:1:1] ) for( ym=[-1:1:1] ) ["translate", [xm,ym]*chunk, bake]],
		]
	),
]);
