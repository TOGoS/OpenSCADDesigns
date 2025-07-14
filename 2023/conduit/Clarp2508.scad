// Clarp2508.0.8
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
// v0.4:
// - Male shape avoids carving into flange when depth insufficient
// - Clarp2508-flangeless-male shape option
// v0.5:
// - Flangeless male can have zero 'depth'
// v0.6:
// - Options for straight holes
// v0.7:
// - Clarp2508-male2 shape, which should be better suited when depth <= 4u
// - Option for second set of holes
// v0.8:
// - Clarp2508-male3 shape, which is similar to male2 but avoiding
//   unprintable overhang when printed horizontally
// 
// TODO: Parse ms_* params from a string, like Clarp2508:2.5u,2.5u,1u,
// so that it can be referenced by Clarp2507 or whatever.

part = "Clarp2508-male"; // ["Clarp2508-male","Clarp2508-male2","Clarp2508-male3","Clarp2508-female","Clarp2508-flangeless-male"]
ms_pos_u = [2.5, -1.5]; // 0.05
ms_width_u = 1; // 0.05
outer_width_u = 12;
outer_depth_u =  6;
thickness_u = 1.0; // 0.05
length_u = 12;
hole_spacing_u = 4;
hole_diameter = 0; // 0.1
hole2_spacing_u = 4;
hole2_diameter = 0; // 0.1
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
	// TODO: Some assertions about minimum width, depth
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

function clarp2508_make_flangeless_m_rath(ms_pos, ms_width, outer_width, outer_depth, thickness=1*u, top_inner_bevel=0.5*u, outer_bevel=2*u) =
	let(x0 = -outer_width/2)
	let(y1 =  outer_depth)
	let(ms_points = clarp2508_ms_points(ms_pos, ms_width, x0))
	let(ms_point_a = ms_points[0])
	let(ms_point_z = ms_points[len(ms_points)-1])
	let(r0 = min(ms_width, thickness)*160/256)
	let(yf = outer_depth-thickness)
	let(yw = ms_point_a[1]-ms_width+thickness) // edge of wall
	["togpath1-rath", each clarp2508__mirror_rathnodes([
		
		["togpath1-rathnode", [ms_point_z[0]+thickness, yf], ["round", min(thickness, (yf-yw)*0.5)]],
		//["togpath1-rathnode", [ms_point_z[0]+thickness, yw], ["round", min(r0, (yf-yw)*0.5)]],
		["togpath1-rathnode", [ms_point_z[0]+thickness, ms_point_a[1]-ms_width], ["round", r0]],
		["togpath1-rathnode", [ms_point_a[0]+ms_width , ms_point_a[1]-ms_width], ["round", r0]],
		each [for(p=ms_points) ["togpath1-rathnode", p]],
		["togpath1-rathnode", [ms_point_z[0],    y1  ], ["round", min(thickness*2, 2*u)]],
	])];

function clarp2508_make_m_rath(ms_pos, ms_width, outer_width, outer_depth, thickness=1*u, top_inner_bevel=0.5*u, outer_bevel=2*u) =
	let(x0 = -outer_width/2)
	let(y1 =  outer_depth)
	let(ms_points = clarp2508_ms_points(ms_pos, ms_width, x0))
	let(ms_point_a = ms_points[0])
	let(ms_point_z = ms_points[len(ms_points)-1])
	let(r0 = min(ms_width, thickness)*255/256)
	let(r1 = min(outer_depth, thickness*1.5, ms_pos[0]+ms_width/2))
	let(flange_inner_depth = outer_depth - thickness*2 )
	let(_outer_bevel = max(0,min(outer_bevel, (outer_depth-r1)*0.6)))
	let(ib = let(b=_outer_bevel-thickness*0.6) b + 2*thickness > outer_depth ? 0 : b)
	assert(outer_depth > 0, str("Too short for this shape; maybe use flangeless-male, instead"))
	["togpath1-rath", each clarp2508__mirror_rathnodes([
		each flange_inner_depth > 0 ? [
			["togpath1-rathnode", [x0+thickness, y1-thickness], if(ib > 0) ["bevel", ib], if(ib > 0)["round", ib]],
			["togpath1-rathnode", [x0+thickness, thickness], ["round", max(0, r1-thickness)]],
			["togpath1-rathnode", [ms_point_z[0]+thickness, thickness], ["round", thickness]],
		] : [
			["togpath1-rathnode", [ms_point_z[0]+thickness, y1-thickness], ["round", thickness]],
		],
		["togpath1-rathnode", [ms_point_z[0]+thickness, ms_point_a[1]-ms_width+thickness], ["round", r0]],
	   ["togpath1-rathnode", [ms_point_a[0]+ms_width, ms_point_a[1]-ms_width], ["round", r0]],
		each [for(p=ms_points) ["togpath1-rathnode", p]],
		["togpath1-rathnode", [ms_point_z[0],    0  ], /*["bevel", top_inner_bevel]*/],
		["togpath1-rathnode", [       x0    ,    0  ], ["round", r1]],
		["togpath1-rathnode", [       x0    ,   y1  ], if(_outer_bevel>0)["bevel", _outer_bevel], if(_outer_bevel>0)["round", _outer_bevel]],
	])];

function clarp2508_make_m2_rath(ms_pos, ms_width, outer_width, outer_depth, thickness=1*u, outer_bevel=2*u) =
	assert( outer_depth >= thickness*2 )
	let(x0 = -outer_width/2)
	let(x1 = -outer_width/2 + outer_bevel)
	let(y0 =  0          )
	let(y1 =  outer_depth)
	let(ms_points = clarp2508_ms_points(ms_pos, ms_width, x0))
	let(ms_point_a = ms_points[0])
	let(ms_point_z = ms_points[len(ms_points)-1])
	let(r0 = min(ms_width, thickness)*255/256)
	let(iy0 = y0 + thickness, iy1 = y1 - thickness)
	let(inner_ydiff = iy1 - iy0)
	let(inner_bevel = min(outer_bevel*0.6, (iy1-iy0)/2))
	assert(outer_depth > 0, str("Too short for this shape; maybe use flangeless-male, instead"))
	["togpath1-rath", each clarp2508__mirror_rathnodes([
		// Inner elbow:
		["togpath1-rathnode", [x1+thickness*0.4, y1-thickness]],
		each (inner_ydiff - inner_bevel*2 > 0) ? [
			["togpath1-rathnode", [x1+thickness*0.4 - inner_bevel, iy1 - inner_bevel]],
			["togpath1-rathnode", [x1+thickness*0.4 - inner_bevel, iy0 + inner_bevel]],
		] : [
			["togpath1-rathnode", [x1+thickness*0.4 - inner_bevel, iy1 - inner_bevel]],
		],
		["togpath1-rathnode", [x1+thickness*0.4, y0+thickness]],
		// Inner clip:
		["togpath1-rathnode", [ms_point_z[0]+thickness, thickness], ["round", thickness]],
		["togpath1-rathnode", [ms_point_z[0]+thickness, ms_point_a[1]-ms_width+thickness], ["round", r0]],
	   ["togpath1-rathnode", [ms_point_a[0]+ms_width, ms_point_a[1]-ms_width], ["round", r0]],
		// Outer clip:
		each [for(p=ms_points) ["togpath1-rathnode", p]],
		["togpath1-rathnode", [ms_point_z[0],    0  ]],
		// Outer elbow:
		["togpath1-rathnode", [       x1,    0  ], ["round", outer_bevel/2]],
		each y0+outer_bevel < y1-outer_bevel ? [
			["togpath1-rathnode", [       x0    ,  y0+outer_bevel  ], ["round", outer_bevel/2]],
			["togpath1-rathnode", [       x0    ,  y1-outer_bevel  ], ["round", outer_bevel/2]],
		] : [
			["togpath1-rathnode", [       x0    ,  y0+outer_bevel  ], ["round", outer_bevel/2]],
		],
		["togpath1-rathnode", [       x1,   y1  ], ["round", outer_bevel/2]],
	])];

function clarp2508_make_m3_rath(ms_pos, ms_width, outer_width, outer_depth, thickness=1*u, outer_bevel=2*u) =
	assert( outer_depth >= thickness*2 )
	let(x0 = -outer_width/2)
	let(x1 = -outer_width/2 + outer_bevel)
	let(y0 =  0          )
	let(y1 =  outer_depth)
	let(ms_points = clarp2508_ms_points(ms_pos, ms_width, x0))
	let(ms_point_a = ms_points[0])
	let(ms_point_z = ms_points[len(ms_points)-1])
	let(r0 = min(ms_width, thickness)*255/256)
	let(iy0 = thickness*0.5, iy1 = y1 - thickness)
	let(inner_ydiff = iy1 - iy0)
	let(inner_bevel1 = min(ms_point_z[0]-x0, ms_point_z[0]-x0, inner_ydiff))
	let(inner_bevel2 = min(inner_ydiff - inner_bevel1, outer_bevel-1.3))
	assert(outer_depth > 0, str("Too short for this shape; maybe use flangeless-male, instead"))
	["togpath1-rath", each clarp2508__mirror_rathnodes([
		// Inner elbow:
		each inner_ydiff > inner_bevel1 ? [
			["togpath1-rathnode", [ms_point_z[0]-inner_bevel1+thickness + inner_bevel2, iy1             ]],
			["togpath1-rathnode", [ms_point_z[0]-inner_bevel1+thickness               , iy1-inner_bevel2]],
			["togpath1-rathnode", [ms_point_z[0]-inner_bevel1+thickness, thickness*0.4+inner_bevel1]],
		] : [
			["togpath1-rathnode", [ms_point_z[0]-inner_bevel1+thickness, thickness*0.4+inner_bevel1], ["round", min(0.5*u, inner_bevel1)]],
		],
		["togpath1-rathnode", [ms_point_z[0]             +thickness, thickness*0.4], ["round", min(1*u, inner_bevel1)]],
		// Inner clip:
		["togpath1-rathnode", [ms_point_z[0]+thickness, ms_point_a[1]-ms_width+thickness], ["round", r0]],
	   ["togpath1-rathnode", [ms_point_a[0]+ms_width, ms_point_a[1]-ms_width], ["round", r0]],
		// Outer clip:
		each [for(p=ms_points) ["togpath1-rathnode", p]],
		["togpath1-rathnode", [ms_point_z[0],    0  ]],
		// Outer elbow:
		["togpath1-rathnode", [       x1,    0  ], ["round", outer_bevel/2]],
		each y0+outer_bevel < y1-outer_bevel ? [
			["togpath1-rathnode", [       x0    ,  y0+outer_bevel  ], ["round", outer_bevel/2]],
			["togpath1-rathnode", [       x0    ,  y1-outer_bevel  ], ["round", outer_bevel/2]],
		] : [
			["togpath1-rathnode", [       x0    ,  y0+outer_bevel  ], ["round", outer_bevel/2]],
		],
		["togpath1-rathnode", [       x1,   y1  ], ["round", outer_bevel/2]],
	])];

// When this graduates from 'experimental',
// this could be part of Clarp2505, and use clgeneric
function clarp2508_rath_to_part(rath, holespecs) =
	["difference",
		togmod1_linear_extrude_z([0, length_u*u], togpath1_rath_to_polygon(rath)),
		
	 	for( h=holespecs ) let(hole=h[0], hole_spacing_u=h[1]) for( zm=[1/2 : 1 : length_u/hole_spacing_u] ) ["translate", [0,0,zm*hole_spacing_u*u], hole],
	];

function mkhole(hole_diameter) =
	hole_diameter > 0 ? ["rotate", [90,0,0], togmod1_linear_extrude_z([-outer_depth_u*u*2-100, outer_depth_u*u*2+100], togmod1_make_circle(d=hole_diameter))] :
	["union"];

togmod1_domodule(
	let( hole  = mkhole( hole_diameter) )
	let( hole2 = mkhole(hole2_diameter) )
	let( rath =
		part == "Clarp2508-flangeless-male" ? clarp2508_make_flangeless_m_rath(
			ms_pos_u*u, ms_width_u*u, outer_width_u*u, outer_depth_u*u, thickness=thickness_u*u) :
		part == "Clarp2508-male" ? clarp2508_make_m_rath(
		   ms_pos_u*u, ms_width_u*u, outer_width_u*u, outer_depth_u*u, thickness=thickness_u*u) :
		part == "Clarp2508-male2" ? clarp2508_make_m2_rath(
		   ms_pos_u*u, ms_width_u*u, outer_width_u*u, outer_depth_u*u, thickness=thickness_u*u) :
		part == "Clarp2508-male3" ? clarp2508_make_m3_rath(
		   ms_pos_u*u, ms_width_u*u, outer_width_u*u, outer_depth_u*u, thickness=thickness_u*u) :
		part == "Clarp2508-female" ? clarp2508_make_f_rath(
			ms_pos_u*u, ms_width_u*u, outer_width_u*u, outer_depth_u*u, thickness=thickness_u*u) :
		assert(false, str("Unknown part: '", part, "'"))
	)
	clarp2508_rath_to_part(rath, holespecs=[[hole, hole_spacing_u], [hole2, hole2_spacing_u]])
);
