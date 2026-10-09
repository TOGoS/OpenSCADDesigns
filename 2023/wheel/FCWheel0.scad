// FCWheel0.2
// 
// Maybe it can roll along the top of a French cleat?
// 
// v0.2:
// - Use zrs instead of zds, for tighter curves

$fn = 128;

use <../lib/TOGMod1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>

u = 254/160;
hd = 5*u;

togmod1_domodule(tphl1_make_z_cylinder(
	zrs=togpath1_rath_to_polypoints(["togpath1-rath",
		["togpath1-rathnode", [ 6*u, hd/2]],
		["togpath1-rathnode", [ 6*u, (6+3)*u], ["round", u]],
		["togpath1-rathnode", [ 0*u, (6  )*u], ["round", u]],
		["togpath1-rathnode", [-6*u, (6+3)*u], ["round", u]],
		["togpath1-rathnode", [-6*u, hd/2]],
		["togpath1-rathnode", [ 6*u, hd/2]],
	], $fn=min(32,$fn)),
	cap_top = false,
	cap_bottom = false
));
