// Clurp2507-v0.2
//
// A conduit piece that clips to MiniRail
//
// Changes:
// v0.2:
// - Fix interpretation of rail width when generating rath

rail_width_u = 12;
length_u = 24;
height_u = 16;
inner_corner_extension_u = 0.3;
$fn = 32;

module __clarp2507__end_params() { }

function mirror_point(point) = [-point[0], point[1]];

function translate_rathnode(node, translation) = [
	node[0],
	node[1] + translation,
	for(i=[2:1:len(node)-1]) node[i]
];

function mirror_rathnode(node) = [
	node[0],
	mirror_point(node[1]),
	for(i=[2:1:len(node)-1]) node[i]
];

function reverse_list(list) = [
	for(i=[len(list)-1:-1:0]) list[i]
];

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>

function translate_and_mirror_rathnodes(nodes, translation) = [
	each              [for(n=nodes)                 translate_rathnode(n, translation) ] ,
	each reverse_list([for(n=nodes) mirror_rathnode(translate_rathnode(n, translation))]),
];

function generate_clurp2507_rath(rail_width, clip_height, inner_corner_extension=0.3) =
	let(x0 = rail_width/2)
	let(y1 = clip_height)
	let(ce = inner_corner_extension)
	let(rath_data = [
		["togpath1-rathnode", [ 0, y1-2], ["round", 2]],
		["togpath1-rathnode", [ 2, y1-4], ["round", 2]],
		["togpath1-rathnode", [ 2,    8], ["round", 3]],
		["togpath1-rathnode", [-2,    4], ["round", 0.8]],
		if(ce > 0) ["togpath1-rathnode", [ 0,    4], ["round", 0.8]],
		["togpath1-rathnode", [ 2+ce, 4+ce], /*if(ce > 0) ["round", ce/2]*/],
		["togpath1-rathnode", [-2,    0], ["round", 1.5]],
		["togpath1-rathnode", [ 4,    0], ["round", 1.5]],
		["togpath1-rathnode", [ 4, y1-3], ["round", 3]],
		["togpath1-rathnode", [ 1, y1-0], ["round", 3]],
	])
	["togpath1-rath", each translate_and_mirror_rathnodes(rath_data, [x0,0])];

togmod1_domodule(togmod1_linear_extrude_z([0,length_u*254/160], ["scale", 254/160, togpath1_rath_to_polygon(generate_clurp2507_rath(rail_width_u, height_u, inner_corner_extension=inner_corner_extension_u))]));
