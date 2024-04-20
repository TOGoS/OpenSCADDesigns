// DuctFanHolder0.1
// 
// Holder for https://www.amazon.com/gp/product/B01M7S46YZ,
// such that the fan can be slid in from the top,
// and point either up or down.
// 
// Flange is just under 1/4" thick (about 6mm),
// 6+3/4" wide, with 19.6mm-wide 'toes' that stick out the inlet side
// an additional 10mm.
// 
// Assuming 7+1/2"-wide holder
// Fan foot starts 3/8" from each side
// Center (don't obstruct front) starts 7/8" from each side

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>

module __asduio21_end_params() { }

inch = 25.4;
hole_fn = $preview ? 24 : 64;
$fn = 16;


the_hull_size = [7.5*inch - 0.2, 3/4*inch-0.2, 3*inch-0.2];

the_hull = ["translate", [0,0,the_hull_size[2]/2], tphl1_make_rounded_cuboid(the_hull_size, [3.175, 3.175, 1], corner_shape="ovoid1")];

flange_cutout_rath =
let( w = (6+3/4)*inch )
let( h = the_hull_size[2] )
let( cops = [["round", 1]] )
let( vops = [["round", 2]] )
["togpath1-rath",
	["togpath1-rathnode", [-w/2 -  1,   h]],
	["togpath1-rathnode", [-w/2 -  1, -10], each cops],
	["togpath1-rathnode", [-w/2 + 20, -10], each cops],
	["togpath1-rathnode", [-w/2 + 20,   0], each vops],
	["togpath1-rathnode", [ w/2 - 20,   0], each vops],
	["togpath1-rathnode", [ w/2 - 20, -10], each cops],
	["togpath1-rathnode", [ w/2 +  1, -10], each cops],
	["togpath1-rathnode", [ w/2 +  1,   h]],
];

flange_cutout = ["translate", [0,0,12.7] ,["rotate", [90,0,0], tphl1_extrude_polypoints([-1/8*inch, 1/8*inch], togpath1_rath_to_polypoints(flange_cutout_rath))]];
body_cutout = ["translate", [0, -1/4*inch, 12.7 + the_hull_size[2]], togmod1_make_cuboid([(5+5/8)*inch, 1/4*inch+2, the_hull_size[2]*2])];

large_mounting_hole = ["rotate", [90,0,0], tog_holelib2_hole("THL-1002", inset=1.5, $fn=hole_fn)];
small_mounting_hole = ["rotate", [90,0,0], tog_holelib2_hole("THL-1001", inset=1.5, overhead_bore_height = 20, $fn=hole_fn)];

mounting_holes = ["union",
	for( xm=[-1.5:1:1.5] ) for(ym=[0.5, 1.5]) ["translate", [xm*38.1, 1/8*inch, ym*38.1], large_mounting_hole],
	for( xm=[-6 : 3 : +6] ) for(ym=[1.5, 4.5]) ["translate", [xm*12.7, 1/8*inch, ym*12.7], small_mounting_hole],
	for( xm=[-7, +7] ) for(ym=[0.5, 5.5]) ["translate", [xm*12.7, -3/8*inch+1, ym*12.7], small_mounting_hole],
];

togmod1_domodule(["difference", the_hull, flange_cutout, body_cutout, mounting_holes]);

