// PegboardHook0.4
//
// v0.2:
// - Reorder line raths to reduce some stickey-outies
// - Replace 'angle' option with simple 'what'
// v0.3:
// - Hook depth is configurable
// v0.4:
// - hook_inner_depth is now interpreted as the distance between inner
//   surfaces of the hook or shelf holder.
// - Adjust default hook_inner_depth_u to 26 so that angled-shelf-holder
//   with default values matches what it was for p1519
//   (http://wherever-files.nuke24.net/uri-res/raw/urn:bitprint:MLHVFWLZ5QDQSS4DF2MPUPNXWCYJMHNG.ZKVOTYBL7B6RT6AEMNQE42EP3P7G22MGHQNFC2A/p1519-PegboardHook0.1-angled-shelf-holder.stl)
// 
// TODO:
// - Round the convex polyline corners
// - Some minimum bracing on bottom

what = "j-hook"; // ["j-hook", "shelf-holder", "angled-shelf-holder"]
// Space between front/back 'prongs'; 26 = 1+5/8", 28 = 1+3/4", 30=1+7/8"
hook_inner_depth_u = 26;

module __pbh0__end_params() { }

use <../lib/TOGComplexLib1.scad>
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

function pbh0_render_shape(shape, line_width) =
	shape[0] == "translate" || shape[0] == "rotate" ?
		[shape[0], shape[1], pbh0_render_shape(shape[2], line_width=line_width)] :
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

thickness_u = 2;
$fn = 48;

inch = 25.4;
u = inch/16;
line_width = 2*u;
line_hwid  = 1*u;
hook_inner_depth = hook_inner_depth_u*u;

function pbh0_normal_bits(length_inches) =
	echo(length_inches=length_inches)
[
	["open-path", ["togpath1-rath", 
		["togpath1-rathnode", [-4*u, 4*u]],
		["togpath1-rathnode", [-4*u, 0*u], ["round", 3*u]],
		["togpath1-rathnode", [ 1*u, 0*u]],
	]],
	for( i=[1:1:length_inches] ) ["translate", [0,-i*inch], ["open-path", ["togpath1-rath", 
		["togpath1-rathnode", [-4*u, 0]],
		["togpath1-rathnode", [ 1*u, 0]],
	]]]
];

j_hook =
let( x0 = line_hwid )
let( x1 = line_hwid + line_width + hook_inner_depth )
let( rr = min(6*u, hook_inner_depth/2) )
["union",
	each pbh0_normal_bits(1),
	
	// The hook/interesting part:
	["open-path", ["togpath1-rath", 
		["togpath1-rathnode", [x0,     0]],
		["togpath1-rathnode", [x0, -16*u]],
		["togpath1-rathnode", [x0, -24*u], ["round", rr]],
		["togpath1-rathnode", [x1, -24*u], ["round", rr]],
		["togpath1-rathnode", [x1, -16*u]],
	]],
];

function make_square_hook(size,angle=0) =
let( floor_vec = tcplx1_rotate([size[0], 0], angle) )
let( front_vec = tcplx1_rotate([0, size[1]], angle) )
let( blunt_vec = tcplx1_rotate([0, size[1] * tan(angle)], angle - 90) )
let( pivot_pos = [ 1*u, -8*u-size[1]] )
["union",
	each pbh0_normal_bits(floor(-(pivot_pos[1] + floor_vec[1])/inch)),
	
	["open-path", ["togpath1-rath", 
		["togpath1-rathnode", [ 1*u,     0]],
		["togpath1-rathnode", pivot_pos],
		["togpath1-rathnode", pivot_pos + floor_vec],
		if( angle == 0 ) ["togpath1-rathnode", pivot_pos + floor_vec + front_vec],
	]],
	
	if( angle != 0 ) ["open-path", ["togpath1-rath", 
		["togpath1-rathnode", pivot_pos + front_vec + blunt_vec],
		["togpath1-rathnode", pivot_pos + front_vec],
		["togpath1-rathnode", pivot_pos],
		["togpath1-rathnode", pivot_pos + [0, floor_vec[1]]],
		["togpath1-rathnode", pivot_pos + floor_vec],
		["togpath1-rathnode", pivot_pos + floor_vec + front_vec],
	]],
];

echo(atan2(3,4));

shelf_holder        = make_square_hook([hook_inner_depth + line_width, 12*u], angle=0);
angled_shelf_holder = make_square_hook([hook_inner_depth + line_width, 12*u], angle=-36.9);

shape =
	what == "j-hook" ? j_hook :
	what == "angled-shelf-holder" ? angled_shelf_holder :
	shelf_holder;

togmod1_domodule(togmod1_linear_extrude_z([0, thickness_u*u], pbh0_render_shape(shape, line_width=3.175)));
