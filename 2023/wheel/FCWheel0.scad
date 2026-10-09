// FCWheel0.1
// 
// Maybe it can roll along the top of a French cleat?

$fn = 128;

use <../lib/TOGMod1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>

u = 254/160;
hd = 5*u;

togmod1_domodule(tphl1_make_z_cylinder(
	zds=togpath1_rath_to_polypoints(["togpath1-rath",
		["togpath1-rathnode", [ 6*u, hd]],
		["togpath1-rathnode", [ 6*u, (12+6)*u], ["round", u]],
		["togpath1-rathnode", [ 0*u, (12  )*u], ["round", u]],
		["togpath1-rathnode", [-6*u, (12+6)*u], ["round", u]],
		["togpath1-rathnode", [-6*u, hd]],
		["togpath1-rathnode", [ 6*u, hd]],
	], $fn=min(32,$fn)),
	cap_top = false,
	cap_bottom = false
));
