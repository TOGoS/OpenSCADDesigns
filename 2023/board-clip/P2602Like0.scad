// P2602Like0.2
// 
// A bracket for holding shelves
// where there is a wide gap (e.g. 1") between
// the inside of the box and the shelf
// (e.g. a 24" shelf inside a 26" space, i.e. 1 27" box with 1/2" walls)
// 
// v0.2:
// - Make lip_z adjustable so that p2603 can fix it at 0 instead of +1/4inch

width = "1chunk";
open_counterbore_top = false;
lip_z = "1/4inch";

$fn = 48;

module __p2602like__end_params() { }

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGUnits1.scad>

width_mm = togunits1_to_mm(width);
lip_z_mm = togunits1_to_mm(lip_z);

togmod1_domodule(
	let( inch = togunits1_decode("inch") )
	let( chunk = togunits1_decode("chunk") )
	let( width_chunks = togunits1_decode(width, unit="chunk", xf="round") )
	let( zbev = 3.175 )
	// let( hole = ["rotate", [90,0,0], tog_holelib2_hole("THL-1006", inset=0, depth=38.1, overhead_bore_height=38.1)] )
	let( hole = ["union",
		togmod1_linear_extrude_y([-40, 40      ], togmod1_make_circle(d=9)),
		togmod1_linear_extrude_y([-50, 1/4*inch], ["hull",
			togmod1_make_circle(d=22),
			if( open_counterbore_top ) togmod1_make_circle(d=22, pos=[0,50]),
		]),
	])
	["difference",
		["rotate-xyz", [90,0,-90], tphl1_make_polyhedron_from_layer_function(
			[
				[-width_mm/2       , -zbev],
				[-width_mm/2 + zbev,  0   ],
				[ width_mm/2 - zbev,  0   ],
				[ width_mm/2       , -zbev],
			],
			function(zo) togpath1_rath_to_polypoints(togpath1_offset_rath(["togpath1-rath",
				["togpath1-rathnode", [-3/4*inch, -3/4*inch], ["bevel", 3.175], ["round", 3.5]],
				["togpath1-rathnode", [ 1/4*inch, -3/4*inch], ["round", 3.175]],
				["togpath1-rathnode", [ 3/4*inch, -1/4*inch], ["round", 3.175]],
				["togpath1-rathnode", [ 3/4*inch,  lip_z_mm], ["round", 3.175]],
				["togpath1-rathnode", [ 1/4*inch,  lip_z_mm]                  ],
				["togpath1-rathnode", [ 1/4*inch,  3/4*inch], ["round", 3.175]],
				["togpath1-rathnode", [-3/4*inch,  3/4*inch], ["bevel", 3.175], ["round", 3.5]],
			], zo[1])),
			layer_points_transform = "key0-to-z"
		)],
		
		for( xm=[-width_chunks/2 + 0.5 : 1 : width_chunks/2 - 0.5] )
		["translate", [xm*chunk,1/4*inch,1/4*inch], hole],
	]
);
