// BackPanel0.4
// 
// 5"x7.5" panel for the back of the AlamenCase.
// You should be able to mount a 120mm fan behind it.
// Or something else.  Whatever you want.
// 
// v0.2:
// - Add 'frame' style.
// v0.3:
// - FIX HEIGHT!  Was supposed to be 6.5", to fit between top and bottom,
//   not 7.5", the height of the whole case.
// - Rename frame+fan-panel style, because it does include a frame,
//   and I might want 'fan-panel' to be just a panel.
// v0.4:
// - Add 'spacer' mode

style = "frame+fan-panel"; // ["frame+fan-panel","frame","spacer"]

module __bp0__end_params() { }

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

fan_panel = ["difference",
	togmod1_linear_extrude_z([0    ,atom], ["difference",
		togmod1_make_rounded_rect([10*atom, 13*atom], r=3*u, $fn=24),
		["intersection",
			togmod1_make_circle(d=120, $fn=72),
			togmod1_make_rounded_rect([8.1*atom, 10*atom], r=2*u, $fn=16),
		],
	]),
	togmod1_linear_extrude_z([3.175,atom+1], togmod1_make_rounded_rect([ 8*atom, 11*atom], r=1*u, $fn=24)),
	
	// Fan mounting holes
	for( xm=[-1,1] ) for( ym=[-1,1] ) ["translate", [xm*105/2, ym*105/2, 3.175], thl_1005],

	// Counutbored TOGBeam holes
	for( xm=[-4.5,4.5] ) for( ym=[-6,-5,-3,3,5,6] ) ["translate", [xm*atom, ym*atom, atom], thl_1001],
	for( xm=[-4.5 : 1 : 4.5] ) for( ym=[-6,6] ) ["translate", [xm*atom, ym*atom, atom], thl_1001],
	
	for( xm=[-3.5 : 1 : 3.5] ) ["translate", [xm*atom, 0, atom/2], ["rotate", [90,0,0], 5mm_hole]],
	for( ym=[-5,each [-5:1:5],5] ) ["translate", [0, ym*atom, atom/2], ["rotate", [0,90,0], 5mm_hole]],
];

frame = ["difference",
	togmod1_linear_extrude_z([0    ,atom], ["difference",
		togmod1_make_rounded_rect([10*atom, 13*atom], r=3*u, $fn=24),
		togmod1_make_rounded_rect([ 8*atom, 11*atom], r=2*u, $fn=16),
	]),
	
	// Counutbored TOGBeam holes
	for( xm=[-4.5,4.5] ) for( ym=[-6 : 1 : 6] ) ["translate", [xm*atom, ym*atom, atom], thl_1001],
	for( xm=[-4.5 : 1 : 4.5] ) for( ym=[-6,6] ) ["translate", [xm*atom, ym*atom, atom], thl_1001],
	
	for( xm=[-3.5 : 1 : 3.5] ) ["translate", [xm*atom, 0, atom/2], ["rotate", [90,0,0], 5mm_hole]],
	for( ym=[-5,each [-5:1:5],5] ) ["translate", [0, ym*atom, atom/2], ["rotate", [0,90,0], 5mm_hole]],
];

spacer =
let( vhole_positions=[
	for( xm=[-4.5,4.5] ) for( ym=[-6 : 1 : 6] ) [xm*atom, ym*atom],
	for( xm=[-4.5 : 1 : 4.5] ) for( ym=[-6,6] ) [xm*atom, ym*atom],
])
let( hole_post = togmod1_make_circle(d=9, $fn=16) )
["difference",
	togmod1_linear_extrude_z([0    ,atom], ["difference",
		togmod1_make_rounded_rect([10*atom, 13*atom], r=3*u, $fn=24),
		
		["difference",
			togmod1_make_rounded_rect([8.67*atom, 11.67*atom], r=2*u, $fn=16),
			
			for( pos=vhole_positions ) ["translate", pos, hole_post],
		]
	]),
	
	for( pos=vhole_positions ) ["translate", pos, 5mm_hole],
	
	//for( xm=[-3.5 : 1 : 3.5] ) ["translate", [xm*atom, 0, atom/2], ["rotate", [90,0,0], 5mm_hole]],
	//for( ym=[-5,each [-5:1:5],5] ) ["translate", [0, ym*atom, atom/2], ["rotate", [0,90,0], 5mm_hole]],
];

thing =
	style == "frame+fan-panel" ? fan_panel :
	style == "spacer" ? spacer :
	frame;

togmod1_domodule(thing);
