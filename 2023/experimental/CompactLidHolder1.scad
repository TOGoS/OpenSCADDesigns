// CompactLidHolder1.1
// 
// this design based on pairs of 'combs'
// to be connected with 2+3/4" spacers of some sort.

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGVecLib0.scad>

inch = 25.4;
u = inch/16;
atom = 12.7;

comb_thickness = 3.175;

comb_length_u = 6*16;
comb_height_u = 3*16;

$fn = $preview ? 16 : 48;

comb_corner_ops = [["bevel", 2*u], ["round", 2*u]];
comb_inner_ops = [["round", 2]];
comb_tip_ops = [["round", 1]];

function make_comb_rath_u(backoff=0) = ["togpath1-rath",
	for( x=[-comb_length_u/2 + 8 : 8 : comb_length_u/2-8] ) each [
		// TOGridPile atomic bottom!!
		// (could be really fancy and do it in the Z direction also. P-:)
		["togpath1-rathnode", [x-2, 0], ["round", 2*u]],
		["togpath1-rathnode", [x  , 2]],
		["togpath1-rathnode", [x+2, 0], ["round", 2*u]],
	],

	["togpath1-rathnode", [ comb_length_u/2,             0], each comb_corner_ops],
	["togpath1-rathnode", [ comb_length_u/2, comb_height_u], each comb_corner_ops],

	for( x = [comb_length_u/2 - 11 : -6 : -comb_length_u/2 + 7] ) each [
		["togpath1-rathnode", [x  , comb_height_u], each comb_tip_ops],
		// Backoff = Y offset of 'back'; hardcoded multipliers based on assumed 3/28 slope follow:
		["togpath1-rathnode", [x+3 - backoff*3/28, 14+backoff], each comb_inner_ops],
		["togpath1-rathnode", [x-1 - backoff*3/28, 14+backoff], each comb_inner_ops],
		["togpath1-rathnode", [x-4, comb_height_u], each comb_tip_ops],
	],

	["togpath1-rathnode", [-comb_length_u/2, comb_height_u], each comb_tip_ops],
	["togpath1-rathnode", [-comb_length_u/2,             0], each comb_corner_ops],
];

function scale_rath_points(rath, scale) = [rath[0],
	for( i=[1:1:len(rath)-1] ) [rath[i][0], rath[i][1]*scale, for(j=[2:1:len(rath[i])-1]) rath[i][j]]
];

function make_comb_rath(backoff=0) = scale_rath_points(make_comb_rath_u(backoff), u);

plate = tphl1_make_polyhedron_from_layer_function([
	[0               , 0],
	[comb_thickness/2, 1],
	[comb_thickness  , 0],
], function(zo) togvec0_offset_points(togpath1_rath_to_polypoints(make_comb_rath(zo[1])), zo[0]));

hole_positions = [
	for( xu=[-comb_length_u/2 + 4 : 8 : comb_length_u/2-3] ) [xu*u, 4*u],
	[(-comb_length_u/2+4)*u, 12*u],
	for( yu=[12 : 8 : comb_height_u-1] ) [(comb_length_u/2-4)*u, yu*u],
];

hole = tog_holelib2_hole("THL-1001", depth=comb_thickness*2, inset=0.5);

comb = ["difference",
	plate,
	for( hp=hole_positions ) ["translate", [hp[0], hp[1], comb_thickness], hole]
];

togmod1_domodule(["union",
	["translate", [0, 12.7,0], comb],
	["translate", [0,-12.7,0], ["scale", [1,-1,1], comb]],
]);
