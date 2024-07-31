// PegboardHook0.1

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>

// ["solid", rath],
// ["open-path", rath]
// ["closed-path", rath]

/*
function raths_to_hook(shapes, w=3.175, d=3.175) =
	togmod1_linear_extrude_z([0, d], ["union",
		for( r=raths )
	];
*/

$fn = 48;

function pbh0_render_shape(shape, line_width) =
	shape[0] == "translate" ?
		["translate", shape[1], pbh0_render_shape(shape[2], line_width=line_width)] :
	shape[0] == "union" ?
		["union", for(i=[1:1:len(shape)-1]) pbh0_render_shape(shape[i], line_width=line_width)] :
	shape[0] == "solid" ?
		togmod1_make_polygon(togpath1_rath_to_polypoints(togpath1_offset_rath(shape[1], line_width/2))) :
	shape[0] == "open-path" ?
		togmod1_make_polygon(togpath1_rath_to_polypoints(togpath1_polyline_to_rath(
			togpath1_rath_to_polypoints(shape[1]),
			line_width/2
		))) :
	shape[0] == "closed-path" ?
		["difference",
			togmod1_make_polygon(togpath1_rath_to_polypoints(togpath1_offset_rath(shape[1],  line_width/2))),
			togmod1_make_polygon(togpath1_rath_to_polypoints(togpath1_offset_rath(shape[1], -line_width/2))),
		] :
	assert(false, str("Invalid shape: ", shape));

triangle_rath = ["togpath1-rath",
	["togpath1-rathnode", [0,-60]],
	["togpath1-rathnode", [30,-30], ["round", 10]],
	["togpath1-rathnode", [0,0]],
];

inch = 25.4;
u = inch/16;
line_width = 2*u;
line_depth = 2*u;

togmod1_domodule(togmod1_linear_extrude_z([0, line_depth], pbh0_render_shape(["union",
	["open-path", ["togpath1-rath", 
		["togpath1-rathnode", [-4*u, 4*u]],
		["togpath1-rathnode", [-4*u, 0*u], ["round", 3*u]],
		["togpath1-rathnode", [ 1*u, 0*u]],
	]],
	["translate", [0,-inch], ["open-path", ["togpath1-rath", 
		["togpath1-rathnode", [-4*u, 0]],
		["togpath1-rathnode", [ 1*u, 0]],
	]]],
	
	// The hook/interesting part:
	["open-path", ["togpath1-rath", 
		["togpath1-rathnode", [ 1*u,     0]],
		["togpath1-rathnode", [ 1*u, -16*u]],
		["togpath1-rathnode", [ 1*u, -24*u], ["round", 6*u]],
		["togpath1-rathnode", [17*u, -24*u], ["round", 6*u]],
		["togpath1-rathnode", [17*u, -16*u]],
	]],

], line_width=3.175)));
