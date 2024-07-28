// DiagBrack0.1
// 
// A bracket for mounting TOGridPile shelves diagonally
// on some TOGBeams or equivalent (0.5" spacing).
// 
// extension_u indicates how much extra width to give the
// 'top' of the shelf (+X).  4u give enough room for a shelf
// 1.75" wide.  Set to 0 if your shelf is exactly 1.5" wide
// (because it is wall-less because your magnets are that good,
// or whatever)

extension_u = 4;

module __diagbrack0__end_params() { }

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>

inch = 25.4;
atom = inch/2;
u    = inch/16;

$fn = $preview ? 24 : 40;

ymin = -extension_u*inch/16;

brackrath =
let(corner_ops=[["round",2]])
let(korner_ops=[["round",8]])
["togpath1-rath",
	["togpath1-rathnode", [ 0  ,   0  ], each corner_ops],
	if( ymin < 0 ) ["togpath1-rathnode", [ 6*u,  ymin], each korner_ops],
	["togpath1-rathnode", [32*u,  ymin], each corner_ops],
	["togpath1-rathnode", [32*u,  24*u], each corner_ops],
];

yohoal = ["translate", [0,0,6], tog_holelib2_hole("THL-1001", depth=20, overhead_bore_height=50)];
yohoak = ["translate", [0,0,3], tog_holelib2_hole("THL-1001", depth=20, overhead_bore_height=50)];
gehoal = tphl1_make_z_cylinder(zds=[[-18,0],[-16,5],[16,5],[18,0]]);

togmod1_domodule(["difference",
	togmod1_linear_extrude_z([0, 12.7], togmod1_make_polygon(togpath1_rath_to_polypoints(brackrath))),
	
	// First and last holes are inset further to avoid screw head protruding
	for( hm=[1.5, 2.5]) ["rotate", [0,0,atan2(3,4)], ["translate", [hm*atom, 0, atom/2], ["rotate", [90,0,0], yohoal]]],
	// Middle holes are inset less 
	for( hm=[0.5, 4.5]) ["rotate", [0,0,atan2(3,4)], ["translate", [hm*atom, 0, atom/2], ["rotate", [90,0,0], yohoak]]],
	for( ym=[0.5 : 1 : 1.5] ) ["translate", [4*atom, ym*atom + ymin/2, atom/2], ["rotate", [0,90,0], gehoal]],
]);
