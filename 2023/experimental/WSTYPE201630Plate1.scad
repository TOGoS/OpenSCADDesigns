// WSTYPE201630Plate1.0

stem_width  = 3.175;
head_width  = 6.35;
max_overhang = 1.5;
thickness   = 6.35;
style = "round"; // ["round","tailey"]

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

nub_hole_2d = make_tailey_base_2d(0.05);

inch = 25.4;

nub_hole_positions = [
	for( xm=[-0.5,0.5] ) for( ym=[-0.5,0.5] ) [xm*(3+3/8)*inch, ym*(8+3/8)*inch]
];

gridbeam_hole_positions = [
	for( xm=[-1, 0, 1] ) for( ym=[-3.5, 3.5] ) [xm,ym]*chunk,
];

gridbeam_hole = tog_holelib2_hole("THL-1006");

cake = togmod1_make_polygon(togpath1_rath_to_polypoints(["togpath1-rath",
	["togpath1-rathnode", [0.5*chunk, -0.5*chunk], ["offset", -1.5]],
	["togpath1-rathnode", [0.5*chunk, +0.5*chunk], ["offset", -1.5]],
	["togpath1-rathnode", [0        ,  0        ], ["offset", -1.5]],
]));
cakes = ["union",
   for( r=[0:90:270] ) ["rotate", [0,0,r], cake]
];

togmod1_domodule(["difference",
	togmod1_linear_extrude_z(
		[0,thickness], ["difference",
			togmod1_make_rounded_rect([4.5*inch, 12*inch], r=19.05),
		
			for(pos=nub_hole_positions) ["translate", pos, nub_hole_2d],
			
		   ["intersection",
				togmod1_make_rounded_rect([3*chunk - 12.7, 6*chunk - 12.7], r=(38.1-12.7), $fn=4),
				
				["union", for( xm=[-1:1:1] ) for( ym=[-3.5:1:3.5] ) ["translate", [xm,ym]*chunk, cakes]],
			],
		]
	),
	
	for( pos=gridbeam_hole_positions ) ["translate", [pos[0],pos[1],thickness], gridbeam_hole],
]);
