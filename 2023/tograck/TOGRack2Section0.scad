// TOGRack2Section0.2
// 
// Vertically-printable section of TOGRack
// that clips to a Clarp2505-male or hangs on a MiniRail
// 
// v0.2:
// - Deeper clarp cutouts
// - Option for diamond-shaped holes

length_atoms = 3;
total_height_u = 24;
hole_diameter = 3.5; // 0.1
// Set to -1 to use $fn as hole_fn also; set to 4 to make diamonds (and increase hole_diameter accordingly!)
hole_fn = -1;
$fn = 48;

module tr2s0__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>


function tr2s0__mirror_point(point) = [-point[0], point[1]];

function tr2s0__mirror_rathnode(node) = [
	node[0],
	tr2s0__mirror_point(node[1]),
	for(i=[2:1:len(node)-1]) node[i]
];

function tr2s0__reverse_list(list) = [
	for(i=[len(list)-1:-1:0]) list[i]
];

function tr2s0__translate_rathnode(node, translation) = [
	node[0], node[1] + translation, for(i=[2:1:len(node)-1]) node[i]
];

function tr2s0__mirror_rathnodes(nodes, translation=[0,0], betwixt=[]) = [
	each                     [for(n=nodes) tr2s0__translate_rathnode(                       n , translation)] ,
	each betwixt,
	each tr2s0__reverse_list([for(n=nodes) tr2s0__translate_rathnode(tr2s0__mirror_rathnode(n), translation)]),
];

u    = 254/160;
atom = 254/20;
width_u = 3*24;

function make_clarp2505_cutout_rathnodes(pos) = tr2s0__mirror_rathnodes([
	["togpath1-rathnode", [-10  *u, 0  ], ["round", 1*u]],
	["togpath1-rathnode", [- 9  *u, 1*u]],
	["togpath1-rathnode", [- 9  *u, 2*u]],
	["togpath1-rathnode", [-10.5*u, 3.5*u]],
	["togpath1-rathnode", [- 8.5*u, 5.5*u]],
], pos);

function make_notch_rathnodes(pos) =
let(notch_width=1)
tr2s0__mirror_rathnodes([
	["togpath1-rathnode", [-notch_width/2, 0  ], ["round", 1*u]],
	["togpath1-rathnode", [-notch_width/2, 4*u], ["round", notch_width*127/256]],
], pos);

function tr2s0_make_hull2d() =
	let(x0_u = -width_u/2)
	let(r0_y1_u = total_height_u)
	let(r0_x1_u = x0_u + 7)
	let(r1_y1_u = total_height_u - 4)
	let(r1_x1_u = x0_u + 15)
	let(floor_y_u = 8)
	togpath1_rath_to_polygon(["togpath1-rath",
		each tr2s0__mirror_rathnodes([
			["togpath1-rathnode", [(r1_x1_u)*u, floor_y_u*u], ["round", 2*u]],
			["togpath1-rathnode", [(r1_x1_u)*u, r1_y1_u*u], ["round", 1*u]],
			["togpath1-rathnode", [(r0_x1_u)*u, r1_y1_u*u]],
			["togpath1-rathnode", [(r0_x1_u)*u, r0_y1_u*u], ["round", 1*u]],
			["togpath1-rathnode", [(x0_u)*u, total_height_u*u]],
			["togpath1-rathnode", [(x0_u)*u, 0], ["round", 1*u]],
		], betwixt=[
			//for( params=[[-1,"c"],[-0.5,"n"],[0,"c"],[0.5,"n"],[1,"c"]] )
			for( params=[[-1,"c"],[0,"c"],[1,"c"]] )
				each let(pos=[params[0]*3*atom, 0], type=params[1])
					type == "c" ? make_clarp2505_cutout_rathnodes(pos) :
					make_notch_rathnodes(pos)
	   ]),
	]);

hollow_cutout_2d =
	let(x0_u = -width_u/2 + 2)
	let(x1_u = -width_u/2 + 13)
	let(y0_u = 8)
	let(y1_u = total_height_u - 8)
	togpath1_rath_to_polygon(["togpath1-rath",
		["togpath1-rathnode", [x0_u*u,y0_u*u], ["round", 2*u]],
		["togpath1-rathnode", [x1_u*u,y0_u*u], ["round", 2*u]],
		["togpath1-rathnode", [x1_u*u,y1_u*u], ["round", 2*u]],
		["togpath1-rathnode", [x0_u*u,y1_u*u], ["round", 2*u]],
	]);

function tr2s0_make_shape2d() =
	["difference",
		tr2s0_make_hull2d(),
		
		for( xm=[-1,1] )
		["scale", [xm,1,1], hollow_cutout_2d]
	];

hole = togmod1_linear_extrude_y([-100,100], togmod1_make_circle(d=hole_diameter, $fn=!is_undef(hole_fn) && hole_fn > 0 ? hole_fn : $fn));

togmod1_domodule(["difference",
	togmod1_linear_extrude_z([0, length_atoms*atom], tr2s0_make_shape2d()),
	
   for( xm=[-4*atom, -3*atom, 3*atom, 4*atom] )
	for( zm=[0.5 : 1 : length_atoms] )
	["translate", [xm,0,zm*atom], hole],
]);
