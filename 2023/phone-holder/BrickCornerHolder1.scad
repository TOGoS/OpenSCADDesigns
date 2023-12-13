// BrickCornerHolder1.0
// 
// Two corners to hold a brick.
// Designed to hold wide bricks with just a little bit
// (ledge_width) to hold onto at the sides.
// Use wood screws to attach them to a board or something.

cavity_depth = 35;

side_thickness = 12.7;
floor_thickness = 3.175;
front_thickness = 3.1;

block_height = 38.1;
ledge_width = 6.35;
bevel_size = 3.175;

module __Asdamn1jk_end_params() { }

$fn = $preview ? 12 : 24;

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>

block_depth = cavity_depth + front_thickness;

x4 = side_thickness + ledge_width;
hull_path = [
	[0  + bevel_size, 0                  ],
	[x4             , 0                  ],
	[x4             , block_height - bevel_size],
	[x4 - bevel_size, block_height       ],
	[0  + bevel_size, block_height       ],
	[0              , block_height - bevel_size],
	[0              , bevel_size         ],
];

cavity_path = [
	[side_thickness                  , floor_thickness  ],
	[side_thickness + ledge_width*2  , floor_thickness  ],
	[side_thickness + ledge_width*2  , block_height * 2 ],
	[side_thickness                  , block_height * 2 ],
];

function rounded_path(points, r) =
	let(rath = ["togpath1-rath", for(p=points) ["togpath1-rathnode", p, ["round", r]]])
	togpath1_rath_to_points(rath);

hoal = ["translate", [0,0,block_depth-6.35], ["rotate", [180,0,0], tog_holelib2_hole("THL-1004", depth=block_depth, overhead_bore_height=block_depth)]];

corn = ["difference",
	tphl1_make_polyhedron_from_layer_function([0, block_depth], function(z) [ for(p=rounded_path(hull_path, 2)) [p[0],p[1],z] ]),
	
	for( ym=[0.5 : 1 : round(block_height/12.7 - 0.25)] )
	["translate", [side_thickness/2, ym*12.7, 0], hoal],
	
	tphl1_make_polyhedron_from_layer_function([floor_thickness, block_depth*2], function(z) [ for(p=rounded_path(cavity_path, 1.5)) [p[0],p[1],z] ]),
];

togmod1_domodule(corn);
togmod1_domodule(["translate", [-12.7, 0, 0], ["scale", [-1,1,1], corn]]);
