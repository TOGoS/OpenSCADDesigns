// Clarp2508.0.3
// 
// Generalization of Clarp2505.
// Experimental class of shapes defined by offset (from 'top left
// corner of female block') and width of mating surface.
// 
// v0.1:
// - Define female shape
// v0.2:
// - Define male shape
// v0.3:
// - Adjustments to male shape to allow ms_x=1.5u to work
// 
// TODO: Parse ms_* params from a string, like Clarp2508:2.5u,2.5u,1u,
// so that it can be referenced by Clarp2507 or whatever.

part = "Clarp2508-male"; // ["Clarp2508-male","Clarp2508-female"]
ms_pos_u = [2.5, -1.5]; // 0.05
ms_width_u = 1; // 0.05
outer_width_u = 12;
outer_depth_u =  6;
thickness_u = 1.0; // 0.05
length_u = 12;
$fn = 32;

module clarp2508__end_params() { }

u = 254/160;

use <../lib/TOGMod1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGMod1Constructors.scad>

function clarp2508__mirror_point(point) = [-point[0], point[1]];

function clarp2508__mirror_rathnode(node) = [
	node[0],
	clarp2508__mirror_point(node[1]),
	for(i=[2:1:len(node)-1]) node[i]
];

function clarp2508__reverse_list(list) = [
	for(i=[len(list)-1:-1:0]) list[i]
];

function clarp2508__mirror_rathnodes(nodes, translation=0) = [
	each                         [for(n=nodes)                            n ] ,
	each clarp2508__reverse_list([for(n=nodes) clarp2508__mirror_rathnode(n)]),
];

function clarp2508_ms_points(ms_pos, ms_width, x0) = [
	[x0 + ms_pos[0] - ms_width/2, ms_pos[1] - ms_width/2],
	[x0 + ms_pos[0] + ms_width/2, ms_pos[1] + ms_width/2],
];

function clarp2508_make_f_rath(ms_pos, ms_width, outer_width, outer_depth, thickness=1*u, top_inner_bevel=0.5*u, outer_bevel=2*u) =
	let(x0 = -outer_width/2)
	let(y0 = -outer_depth)
	let(ms_points = clarp2508_ms_points(ms_pos, ms_width, x0))
	let(ms_point_a = ms_points[0])
	let(ms_point_z = ms_points[len(ms_points)-1])
	let(ib_y1 = y0+outer_bevel+thickness/2) // Top of inner bevel
	let(sl_y0 = max(ib_y1+0.1, ms_point_a[1]-(ms_point_a[0]-(x0+thickness)))) // bottom of sublip underside
	let(sl_r0 = 2*min(sl_y0-ib_y1, ms_point_a[1]-sl_y0)) // rounding radius of bottom of sublip underside
	["togpath1-rath", each clarp2508__mirror_rathnodes([
		["togpath1-rathnode", [x0+thickness+outer_bevel-thickness/2, y0+thickness], ["round", outer_bevel-thickness]],
		["togpath1-rathnode", [x0+thickness, ib_y1], ["round", outer_bevel-thickness]], // TODO: min(bevel, something) when depth is low
		["togpath1-rathnode", [x0+thickness, sl_y0], if(sl_r0 > 0) ["round", sl_r0]],
		each [for(p=ms_points) ["togpath1-rathnode", p]],
		["togpath1-rathnode", [ms_point_z[0],    0  ], ["bevel", top_inner_bevel]],
		["togpath1-rathnode", [       x0    ,    0  ]],
		["togpath1-rathnode", [       x0    , y0+outer_bevel], ["round", outer_bevel]],
		["togpath1-rathnode", [       x0+outer_bevel, y0    ], ["round", outer_bevel]],
	])];

function clarp2508_make_m_rath(ms_pos, ms_width, outer_width, outer_depth, thickness=1*u, top_inner_bevel=0.5*u, outer_bevel=2*u) =
	let(x0 = -outer_width/2)
	let(y1 =  outer_depth)
	let(ms_points = clarp2508_ms_points(ms_pos, ms_width, x0))
	let(ms_point_a = ms_points[0])
	let(ms_point_z = ms_points[len(ms_points)-1])
	let(r0 = min(ms_width, thickness)*255/256)
	let(r1 = min(thickness*1.5, ms_pos[0]+ms_width/2))
	["togpath1-rath", each clarp2508__mirror_rathnodes([
		["togpath1-rathnode", [x0+thickness, y1-thickness], ["bevel", outer_bevel-thickness*0.6], ["round", outer_bevel-thickness*0.6]],
		["togpath1-rathnode", [x0+thickness, thickness], ["round", max(0, r1-thickness)]],
		["togpath1-rathnode", [ms_point_z[0]+thickness, thickness], ["round", thickness]],
		["togpath1-rathnode", [ms_point_z[0]+thickness, ms_point_a[1]-ms_width+thickness], ["round", r0]],
		["togpath1-rathnode", [ms_point_a[0]+ms_width, ms_point_a[1]-ms_width], ["round", r0]],
		each [for(p=ms_points) ["togpath1-rathnode", p]],
		["togpath1-rathnode", [ms_point_z[0],    0  ], /*["bevel", top_inner_bevel]*/],
		["togpath1-rathnode", [       x0    ,    0  ], ["round", r1]],
		["togpath1-rathnode", [       x0    ,   y1  ], ["bevel", outer_bevel], ["round", outer_bevel]],
	])];

// When this graduates from 'experimental',
// this could be part of Clarp2505, and use clgeneric
function clarp2508_rath_to_part(rath) = togmod1_linear_extrude_z([0, length_u*u], togpath1_rath_to_polygon(rath));

togmod1_domodule(clarp2508_rath_to_part(
	part == "Clarp2508-male" ? clarp2508_make_m_rath(ms_pos_u*u, ms_width_u*u, outer_width_u*u, outer_depth_u*u, thickness=thickness_u*u) :
	part == "Clarp2508-female" ? clarp2508_make_f_rath(ms_pos_u*u, ms_width_u*u, outer_width_u*u, outer_depth_u*u, thickness=thickness_u*u) :
	assert(false, str("Unknown part: '", part, "'"))
));
