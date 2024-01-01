// SimpleJHook1.0
// 
// A simple gridbeam-mountable J-hook

use <../lib/TOGMod1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGMod1Constructors.scad>

width = 25.4;

module __simplejhook1__end_params() { }

$fn = $preview ? 32 : 64;

shape = [
	[-16,-8,  8, 0],
	[ 16,-8,  1, 1],
	[ 16,-6,  1, 1],
	[-14,-6,  6, 0],
	[-14, 6,  6, 0],
	[  0, 6,  1, 1],
	[  0, 8,  1, 1],
	[-16, 8,  8, 0],
];

u = 25.4/16;

function rath_at(ploj) = ["togpath1-rath",
	for(p = shape) ["togpath1-rathnode", [p[0]*u+ploj*p[3], p[1]*u], ["round", p[2]*u-0.5]]
];

body = tphl1_make_polyhedron_from_layer_function([
	let( layercount = max(16, min(32, $fn)) )
	for( z = [0 : 1 : layercount] )
	let( sinval = (z-layercount/2)/layercount*1.25 )
	let( cosval = sqrt(1 - sinval*sinval) )
	[z * width/layercount, width * (cosval-1)]
], function(params)
	let( z = params[0] )
	let( ploj = params[1] )
	let( rathpoints = togpath1_rath_to_points(rath_at(ploj)) )
	[ for(p=rathpoints) [p[0],p[1],z] ]
);

togmod1_domodule(["difference",
	body,
	["translate",
		[8*u, -8*u, width/2], togmod1_linear_extrude_y([-3*u, 3*u],
		togmod1_make_circle(d=5/16*25.4))
	 ]
]);
