// CableFindles0.1

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>

u = 25.4/16;

function make_bortdat(count, rbig) =
let(rlit = 12 - rbig)
[
	for( xm=[ count/2 : -1 : -count/2] ) each [
	[    12 + xm*24,  rbig,    0],
	[  rlit + xm*24,  rbig, rbig],
	[  rlit + xm*24, -rlit, rlit],
	[- rlit + xm*24, -rlit, rlit],
	[- rlit + xm*24,  rbig, rbig],
	[-   12 + xm*24,  rbig, 0   ],
	],

	for( xm=[-count/2 : 1 : count/2] ) each [
	[-   12 + xm*24,  rlit, 0   ],
	[- rbig + xm*24,  rlit, rlit],
	[- rbig + xm*24, -rbig, rbig],
	[  rbig + xm*24, -rbig, rbig],
	[  rbig + xm*24,  rlit, rlit],
	[    12 + xm*24,  rlit, 0   ],
	]
];

the_hull = ["difference",
	//togmod1_make_cuboid([76.2, 38.1, 38.1]),
	togmod1_linear_extrude_x([-38.1,38.1], togmod1_make_polygon([
		[ 12*u,   5*u],
		[  5*u,  12*u],
		[- 5*u,  12*u],
		[-12*u,   5*u],
		[-12*u, -10*u],
		[-10*u, -12*u],
		[ 10*u, -12*u],
		[ 12*u, -10*u],
	])),
	togmod1_linear_extrude_x([-40,40], togmod1_make_polygon([
		[ 10*u,   4*u],
		[  4*u,  10*u],
		[- 4*u,  10*u],
		[-10*u,   4*u],
		[-10*u, - 8*u],
		[- 8*u, -10*u],
		[  8*u, -10*u],
		[ 10*u, - 8*u],
	])),
];

$fn = 24;

mhole = tog_holelib2_hole("THL-1002", depth=3*u, inset=0.5);

bortdat = make_bortdat(3, 9);
bort_rath = ["togpath1-rath", for(bd=bortdat) let(r=bd[2]*u-0.1) ["togpath1-rathnode", [bd[0]*1.3*u + 6*u, bd[1]*u*1.1], if(r > 0 ) ["round", r]]];

// echo("bort rath:", bort_rath);

bort_subtraction = tphl1_extrude_polypoints([-38.1, 0], togpath1_rath_to_polypoints(bort_rath));

thing = ["difference",
	the_hull,
	bort_subtraction,
	for( xm=[-1, 0, 1] ) ["translate", [xm*19.05, 0, 10*u], ["rotate", [180,0,0], mhole]],
];

togmod1_domodule(thing);
