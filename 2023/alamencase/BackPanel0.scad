// BackPanel0.1
// 
// 5"x7.5" panel for the back of the AlamenCase.
// You should be able to mount a 120mm fan behind it.
// Or something else.  Whatever you want.

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGVecLib0.scad>

u = 25.4/16;
atom = 12.7;

thl_1001 = tog_holelib2_hole("THL-1001", depth=20, overhead_bore_height=20, inset=0.1, $fn=16);
thl_1005 = tog_holelib2_hole("THL-1005", depth=20, overhead_bore_height=20, inset=0.1);
5mm_hole = tphl1_make_z_cylinder(d=5, zrange=[-100,100], $fn=24);

togmod1_domodule(["difference",
	togmod1_linear_extrude_z([0    ,atom], ["difference",
		togmod1_make_rounded_rect([10*atom, 15*atom], r=3*u, $fn=24),
		["intersection",
			togmod1_make_circle(d=120, $fn=72),
			togmod1_make_rect([8.1*atom, 10*atom]),
		],
	]),
	togmod1_linear_extrude_z([3.175,atom+1], togmod1_make_rounded_rect([ 8*atom, 13*atom], r=1*u, $fn=24)),
	
	// Fan mounting holes
	for( xm=[-1,1] ) for( ym=[-1,1] ) ["translate", [xm*105/2, ym*105/2, 3.175], thl_1005],

	// Counutbored TOGBeam holes
	for( xm=[-4.5,4.5] ) for( ym=[-7,-6,-5,-3,3,5,6,7] ) ["translate", [xm*atom, ym*atom, atom], thl_1001],
	for( xm=[-4.5 : 1 : 4.5] ) for( ym=[-7,7] ) ["translate", [xm*atom, ym*atom, atom], thl_1001],
	
	for( xm=[-3.5 : 1 : 3.5] ) ["translate", [xm*atom, 0, atom/2], ["rotate", [90,0,0], 5mm_hole]],
	for( ym=[-6,each [-5:1:5],6] ) ["translate", [0, ym*atom, atom/2], ["rotate", [0,90,0], 5mm_hole]],
]);
