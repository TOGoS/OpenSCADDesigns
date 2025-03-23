// Hook3.0
// 
// Hook intended for mounting on hatomic-backed FCs.
// 
// For the future:
// Maybe allow multiple hooks along the back?

width_atoms = 2;
back_height_atoms = 12;
depth_atoms = 3;
thickness = 5;
front_height = 19.05;
back_hole_style = "THL-1001";
$fn = 24;

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGVecLib0.scad>

atom = 127/10;
   u = 254/160;

back_2d =
let( y1 = 0, y0 = -back_height_atoms * atom )
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
let( y1 = 0, y0 = -back_height_atoms * atom )
let( ye = y0 + depth_atoms*atom/2 + front_height - tip_inset ) // Y position of front tip
let( x0 = 0, x1 = depth_atoms*atom )
let( majorpc = max($fn,64)/4 )
["togpath1-rath",
	["togpath1-rathnode", [x0            , y1 - top_inset], ["round", tipround]],
	["togpath1-rathnode", [x0            , y0            ], ["round", back_r , majorpc]],
	["togpath1-rathnode", [x1            , y0            ], ["round", front_r, majorpc]],
	["togpath1-rathnode", [x1            , ye            ], ["round", tipround]],
	["togpath1-rathnode", [x1 - thickness, ye            ], ["round", tipround]],
	["togpath1-rathnode", [x1 - thickness, y0 + thickness], ["round", front_r-thickness, majorpc]],
	["togpath1-rathnode", [x0 + thickness, y0 + thickness], ["round", back_r-thickness , majorpc]],
	["togpath1-rathnode", [x0 + thickness, y1 - top_inset], ["round", tipround]],
];

hook = //togmod1_linear_extrude_z([0, width_atoms*atom], hook_2d);
	tphl1_make_polyhedron_from_layer_function(
		[
			for( i=[-0.5 : 0.1 : 0.5] ) [width_atoms*atom*i, 1 - cos(90*i)]
		],
		function(zi) togvec0_offset_points(
			togpath1_rath_to_polypoints(
				hook_rath(
					tip_inset = zi[1]*width_atoms*atom  ,
					top_inset = zi[1]*width_atoms*atom/2
				)
			), zi[0])
	);

togmod1_domodule(
	let( bhole = ["rotate", [0,90,0], ["render", tog_holelib2_hole(back_hole_style)]] )

	["difference",
		["intersection",
			togmod1_linear_extrude_z([-width_atoms*atom, width_atoms*atom], back_2d),
			hook,
		],
		
		for( ym=[0.5 : 1 : back_height_atoms - depth_atoms/2] )
		for( zm=[-width_atoms/2+0.5 : 1 : width_atoms/2] )
		["translate", [thickness, -ym*atom, zm*atom], bhole],
	]
);
