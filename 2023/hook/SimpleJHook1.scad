// SimpleJHook1.1
// 
// A simple gridbeam-mountable J-hook
//
// Changes:
// v1.1:
// - Make hole_diameter configurable
// - Make hook_depth configurable
// v1.2:
// - Allow thickness to be customized
// - Change how hole is placed

use <../lib/TOGMod1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGMod1Constructors.scad>

// Width, in mm
width         = 25.4; // 0.001
// Diameter of hole, in mm
hole_diameter = 7.9375; // 0.001

// Outer depth of hook, in mm
hook_depth    = 25.4; // 0.001
head_height   = 25.4;
thickness     = 3.175; // 0.001

module __simplejhook1__end_params() { }

$fn = $preview ? 32 : 64;

u = 25.4/16;

w_u = width/u;
d_u = hook_depth/u;
r_u = d_u/2;
t_u = thickness/u;
h_u = head_height/u;

shape = [
	[-r_u- 8    ,-r_u    ,r_u    , 0],
	[   h_u,    ,-r_u    ,      1, 1],
	[   h_u,    ,-r_u+t_u,      1, 1],
	[-r_u- 8+t_u,-r_u+t_u,r_u-t_u, 0],
	[-r_u- 8+t_u, r_u-t_u,r_u-t_u, 0],
	[      0    , r_u-t_u,      1, 1],
	[      0    , r_u    ,      1, 1],
	[-r_u- 8    , r_u    ,r_u    , 0],
];

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
		[max(h_u/2,h_u-w_u/2)*u, (-r_u+t_u/2)*u, width/2], togmod1_linear_extrude_y([-t_u*u, t_u*u],
		togmod1_make_circle(d=hole_diameter))
	 ]
]);
