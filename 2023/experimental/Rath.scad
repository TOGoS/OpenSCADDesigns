// Rath = ["togpath1-rath", RathNode...]
// RathNode = ["togpath1-rathpoint",[x,y], RathOp...]
// RathOp = ["bevel", size] | ["round", radius]

use <../lib/TOGComplexLib1.scad>
use <../lib/TOGPath1.scad>

function xx__bevel(pa, pb, pc, bevel_size) =
	let( ba_normalized = tcplx1_normalize(pa-pb) )
	let( bc_normalized = tcplx1_normalize(pc-pb) )
	[pb + ba_normalized * bevel_size, pb + bc_normalized * bevel_size];

function xx__offset(pa, pb, pc, offset) =
	let( ab_normalized = tcplx1_normalize(pb-pa) )
	let( turn = tcplx1_relative_angle_abc(pa, pb, pc) )
	let( ov_forward = tan(turn/2) )
	let( ovec = tcplx1_multiply(ab_normalized, [0,-1]) + tcplx1_multiply(ab_normalized, [ov_forward,0]) )
	[pb + ovec*offset];

function xx__round(pa, pb, pc, radius) =
	let( ab_normalized = tcplx1_normalize(pb-pa) )
	let( turn = tcplx1_relative_angle_abc(pa, pb, pc) )
	let( ov_forward = tan(turn/2) )
	let( ovec = tcplx1_multiply(ab_normalized, [0,-1]) + tcplx1_multiply(ab_normalized, [ov_forward,0]) )
	let( fulc = pb - ovec*radius )
	let( a0 = togpath1__line_angle(pa, pb)-90 )
	let( a1 = a0+turn )
	let( vcount = ceil(abs(a1 - a0) * max($fn,1) / 360) )
	assert( vcount >= 1 )
	[
		for( vi = [0:1:vcount] )
		// Calculate angles in such a way that first and last are exact
		let( a = a0 * (vcount-vi)/vcount + a1 * vi/vcount )
		[fulc[0] + cos(a) * radius, fulc[1] + sin(a) * radius]
	];

function xx__rathnode_apply_op(pa, pb, pc, op) =
	op[0] == "bevel" ? xx__bevel(pa, pb, pc, op[1]) :
	op[0] == "round" ? xx__round(pa, pb, pc, op[1]) :
	op[0] == "offset" ? xx__offset(pa, pb, pc, op[1]) :
	assert(false, str("Unrecognized rath node op, '", op, "'"));

function xx__rathnode_to_points(pa, pb, pc, rathnode, opindex) =
	assert(is_list(pa))
	assert(is_list(pb))
	assert(is_list(pc))
	assert(is_list(rathnode))
	assert(is_num(opindex))
	opindex == len(rathnode) ? [pb] :
	let( newpoints = [pa, each xx__rathnode_apply_op(pa, pb, pc, rathnode[opindex]), pc] )
	[ for( i=[1:1:len(newpoints)-2] ) each xx__rathnode_to_points(newpoints[i-1], newpoints[i], newpoints[i+1], rathnode, opindex+1) ];

function xx_rath_to_points(rath) =
	assert(rath[0] == "togpath1-rath")
	let(points = [ for(i=[1:1:len(rath)-1]) rath[i][1] ])
[
	for(i=[0:1:len(points)-1])
	let( pa = points[ (i-1+len(points))%len(points) ] )
	let( pb = points[ (i              )           ] )
	let( pc = points[ (i+1            )%len(points) ] )
	each xx__rathnode_to_points(pa, pb, pc, rath[i+1], 2)
];


//// Demo

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>

$fn = 24;

togmod1_domodule(togmod1_make_polygon(xx_rath_to_points(["togpath1-rath",
	["togpath1-rathseg", [-10,-10], ["offset", 3], ["bevel", 4], ["round", 2]],
	["togpath1-rathseg", [ 10,-10], ["bevel", 4]],
	["togpath1-rathseg", [ 10, 10], ["round", 2]],
	["togpath1-rathseg", [-10, 10], ["round", 4]],
])));
