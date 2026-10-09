// BoxWheel0.1
// 
// A small wheel that you might attach to a box.
// Use any old 1/4" bolt for an axle.

diameter = "1inch";
hole_diameter = "5/16inch";
width = "1/2inch";

$fn = 128;

use <../lib/TOGMod1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGUnits1.scad>

u = 254/160;
wd = togunits1_to_mm(diameter);
wt = togunits1_to_mm(width);
hd = togunits1_to_mm(hole_diameter);

halfn = ($fn-1)/($fn*2);
roun = min((wd-hd)*halfn, wt/3);

togmod1_domodule(tphl1_make_z_cylinder(
	// Note that rounded corners are squashed due to using
	// zds instead of zrs; this is...on purpose.
	zds=togpath1_rath_to_polypoints(["togpath1-rath",
		["togpath1-rathnode", [ wt/2, hd]],
		["togpath1-rathnode", [ wt/2, wd], ["round", roun]],
		["togpath1-rathnode", [-wt/2, wd], ["round", roun]],
		["togpath1-rathnode", [-wt/2, hd]],
		["togpath1-rathnode", [ wt/2, hd]],
	], $fn=min(32,$fn)),
	cap_top = false,
	cap_bottom = false
));
