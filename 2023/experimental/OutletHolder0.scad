// OutletHolder0.2
// 
// v0.1:
// - Prototype to see if it even fits
// v0.2:
// - Change hole spacing from 3.281" to simply 3+1/4"

$fn = 24;

use <../lib/TOGMod1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGHoleLib2.scad>

// Trying to determine a reasonable minimum
// for the cavity size.

inch = 25.4;
atom = inch/2;

hole_spacing  = 3.25*inch;
hole_diameter = 5;

the_hull_size     = [2*inch       , 4.5*inch    , 1.25*inch];
upper_cavity_size = [1.75*inch+0.1, (4+1/4)*inch, 0.25*inch];
lower_cavity_size = [1.75*inch    , (2+7/8)*inch, (1+1/8)*inch];

floor_thickness = the_hull_size[2] - lower_cavity_size[2];

hole = tphl1_make_z_cylinder(zrange=[-1, the_hull_size[2]+1], d=hole_diameter);

small_back_mounting_hole = tog_holelib2_hole("THL-1001", depth=the_hull_size[2], overhead_bore_height=the_hull_size[2], inset=1);
big_back_mounting_hole = tog_holelib2_hole("THL-1002", depth=the_hull_size[2], overhead_bore_height=the_hull_size[2], inset=1);

function doubleheight(size) = [size[0], size[1], size[2]*2];

togmod1_domodule(["difference",
	["translate", [0,0,the_hull_size[2]/2], tphl1_make_rounded_cuboid(the_hull_size, r=[4.7625, 3.175, 3.175])],
	["translate", [0,0,the_hull_size[2]  ], ["union",
		tphl1_make_rounded_cuboid(doubleheight(upper_cavity_size), [2,2,0.6], corner_shape="ovoid1"),
		tphl1_make_rounded_cuboid(doubleheight(lower_cavity_size), [3,3,1.5], corner_shape="ovoid1")
	]],
	for( ym=[-0.5, 0.5] ) ["translate", [0,ym*hole_spacing,0], hole],
	["translate", [0,0,floor_thickness], big_back_mounting_hole],
	for( ym=[-2 : 1 : 2] ) for( xm=[-1,0,1] )
		if( xm != 0 || (abs(ym) != 3 && abs(ym) != 0) )
			["translate", [xm*atom, ym*atom, floor_thickness], small_back_mounting_hole]
]);
