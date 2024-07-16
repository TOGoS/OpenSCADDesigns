// AlamenSideExt0.1
// 
// Extension side panel.
// Simple, regular hole grid;
// no slots for the ALAMENGTD case.

size_atoms = [3, 15];

thickness = 6.35; // 0.01

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGVecLib0.scad>

module __alamensideext__end_params() { }

n = 24;

inch = 25.4;
atom = inch/2;

hole = tog_holelib2_hole("THL-1001", depth=thickness+1, inset=0.5, $fn=32);
size = [size_atoms[0]*atom, size_atoms[1]*atom, thickness];

thing = ["difference",
	["translate", [0,0,thickness/2], tphl1_make_rounded_cuboid(size, r=[3.175,3.175,0], $fn=24)],
	
	for( xm=[-size_atoms[0]/2+0.5 : 1 : size_atoms[0]/2] )
	for( ym=[-size_atoms[1]/2+0.5 : 1 : size_atoms[1]/2] )
	["translate", [xm*atom, ym*atom, thickness], hole],
];

togmod1_domodule(thing);
