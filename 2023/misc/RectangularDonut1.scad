// RectangularDonut1.0
// 
// Gridbeam size tester / center marker

outer_offset = -0.1;
inner_offset = -0.1;
$fn = 64;

module rectangulardonut1__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>

inch = 25.4;
atom = 12.7;
outer_r = 3/16*inch;

hole = tphl1_make_z_cylinder(zrange=[-50,50], d=3/4*inch+0.06);

togmod1_domodule(["difference",
	tphl1_make_rounded_cuboid([4*atom+outer_offset*2, 4*atom+outer_offset*2, 4*atom], r=[outer_r, outer_r, 0]),
	
	tphl1_make_rounded_cuboid([3*atom-inner_offset*2, 3*atom-inner_offset*2, 5*atom], r=[0.5,0.5,0]),
	for( a=[0,90] ) ["rotate-xyz", [90,0,a], hole],
	// TODO: Pencil holes
]);
