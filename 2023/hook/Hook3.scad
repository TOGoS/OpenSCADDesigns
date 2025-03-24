// Hook3.2
// 
// Hook intended for mounting on hatomic-backed FCs.
// 
// Versions
// v3.1:
// - Fix rounding of tips
// v3.2:
// - Increase overhead bore height to punch through hook
// - Lower back corner is square, for stremgth
// - Multiple hooks!
// 
// For the future:
// Maybe allow multiple hooks along the back?

description = "";
width_atoms = 2;
back_height_atoms = 12;
hook_spacing_atoms = 6;
depth_atoms = 3;
thickness = 5;
front_height = 19.05;
back_hole_style = "THL-1001";
$fn = 24;

module __hook3__end_params() { }

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGVecLib0.scad>

atom = 127/10;
   u = 254/160;

y1 = 0;
y0 = -back_height_atoms * atom;

back_2d =
let( x0 = 0, x1 = 100 )
togpath1_rath_to_polygon(["togpath1-rath",
	["togpath1-rathnode", [x1    , y1    ]],
	["togpath1-rathnode", [x0+2*u, y1    ]],
	["togpath1-rathnode", [x0+0  , y1-2*u]],
	
	for( ym=[1 : 1 : back_height_atoms-1] ) each [
		["togpath1-rathnode", [x0  , -ym*atom + 2*u]],
		["togpath1-rathnode", [x0+u, -ym*atom + 1*u]],
		["togpath1-rathnode", [x0+u, -ym*atom - 1*u]],
		["togpath1-rathnode", [x0  , -ym*atom - 2*u]],
	],
	
	["togpath1-rathnode", [x0+0  , y0 + 2*u]],
	["togpath1-rathnode", [x0+2*u, y0      ]],
	["togpath1-rathnode", [x1    , y0      ]],	
]);

function hook_rath(tip_inset, top_inset) =
let( back_r  = depth_atoms*atom/2 * 0.99 )
let( front_r = depth_atoms*atom/2 * 0.99 )
let( tipround = thickness*0.4 )
let( ye = y0 + depth_atoms*atom/2 + front_height - tip_inset ) // Y position of front tip
let( x0 = 0, x1 = depth_atoms*atom )
let( majorpc = max($fn,64)/4 )
["togpath1-rath",
	["togpath1-rathnode", [x0            , y1 - top_inset], ["round", tipround]],
	["togpath1-rathnode", [x0            , y0            ], ["round", /*back_r*/ tipround , majorpc]],
	["togpath1-rathnode", [x1            , y0            ], ["round", front_r, majorpc]],
	["togpath1-rathnode", [x1            , ye            ], ["round", tipround]],
	["togpath1-rathnode", [x1 - thickness, ye            ], ["round", tipround]],
	["togpath1-rathnode", [x1 - thickness, y0 + thickness], ["round", front_r-thickness, majorpc]],
	["togpath1-rathnode", [x0 + thickness, y0 + thickness], ["round", back_r-thickness , majorpc]],
	["togpath1-rathnode", [x0 + thickness, y1 - top_inset], ["round", tipround]],
];

hook_positions = [
	for(ym=[0 : hook_spacing_atoms : back_height_atoms])
	y0 + ym*atom
];

hook = //togmod1_linear_extrude_z([0, width_atoms*atom], hook_2d);
	tphl1_make_polyhedron_from_layer_function(
		[
			for( i=[-128/256 : 8/256 : 128/256] )
			let( ang = asin(i*1.2) )
			[width_atoms*atom*i, 1 - cos(ang)]
		],
		function(zi) togvec0_offset_points(
			togpath1_rath_to_polypoints(
				hook_rath(
					tip_inset = zi[1]*width_atoms*atom  ,
					top_inset = zi[1]*width_atoms*atom/2
				)
			), zi[0])
	);

hook_height = front_height + depth_atoms*atom/2;

hook_front_ranges = [
	for( y=hook_positions ) [y, y+hook_height]
];

// Given positions of hooks, what kind of hole
// can go in the back at position Y?
function hole_type_at(y, index=0) =
	index >= len(hook_front_ranges) ? "normal" :
	y < hook_front_ranges[index][0] ? "normal" :
	y < hook_front_ranges[index][0] + depth_atoms*atom/4 ? "none" :
	y < hook_front_ranges[index][1] - 7 ? "deep" :
	y <= hook_front_ranges[index][1] ? "normal" :
	hole_type_at(y, index+1);

togmod1_domodule(
	let( bhole1 = ["rotate", [0,90,0], ["render", tog_holelib2_hole(back_hole_style)]] )
	let( bhole2 = ["rotate", [0,90,0], ["render", tog_holelib2_hole(back_hole_style, overhead_bore_height=depth_atoms*atom)]] )

	["difference",
		["intersection",
			togmod1_linear_extrude_z([-width_atoms*atom, width_atoms*atom], back_2d),

			["union",
				for( y=hook_positions )
				["translate", [0, y-y0, 0], hook]
			]
		],
		
		for( ym=[0.5 : 1 : back_height_atoms] )
		let( y = -ym*atom )
		let( hole_type = hole_type_at(y) )
		for( zm=[-width_atoms/2+0.5 : 1 : width_atoms/2] )
		let( bhole =
			hole_type == "none" ? ["union"] :
			hole_type == "deep" ? bhole2 :
			bhole1 )
		["translate", [thickness, -ym*atom, zm*atom],
			bhole],
	]
);
