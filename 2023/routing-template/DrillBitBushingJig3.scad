// DrillBitBushingJig3.0

d0 = 17;
d1 = 18.97;
$fn = 48;

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>

togmod1_domodule(
	let(inch = 25.4)
	let(gridbeam_hole = tphl1_make_z_cylinder(zrange=[-100,100], d=8.5))
	["difference",
		tphl1_make_rounded_cuboid([3.5*inch, 1.5*inch, 2*inch], r=[5,5,0]),
		
		tphl1_make_z_cylinder(zds=[
			[-2*inch         , d0],
			[-1*inch + inch/8, d0],
			[-1*inch + inch/8, d1],
			[ 2*inch         , d1]
		]),
		
		for( xm=[-1,+1] ) ["translate", [xm*inch, 0, -1*inch + 3/4*inch], ["rotate", [90,0,0], gridbeam_hole]],
	]
);
