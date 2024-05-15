// SimpleHangerWasher1.0
// 
// It's a washer for a #6 or maybe #8 screw
// that can then have a wire hung over it, e.g.
// to hang a picture on

module __anjmikdoshuie32__end_params() { }

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGPolyhedronLib1.scad>

$fn = 32;

u  = 25.4/16;
2u = 25.4/8;

the_hull = tphl1_make_z_cylinder(zds=[
	[0*u, 5*2u],
	[0.5*u, 5*2u],
	[1*u, 4.5*2u],
	[1*u, 3*2u],
	[1*u, 3*2u],
	[2*u, 3*2u],
	[3*u, 4*2u],
	[4*u, 4*2u],
	[5*u, 3*2u],
]);

the_hole = tog_holelib2_hole("THL-1001", inset=1*u);

the_thing = ["difference", the_hull, ["translate", [0,0,5*u], the_hole]];

togmod1_domodule(the_thing);
