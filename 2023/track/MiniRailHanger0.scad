// MiniRailHanger0.2
// 
// Can I use a MiniRail as a tiny French cleat?
// This hanger is designed to hold one corner
// (print two to hang both corners) of my 4x4 USB switcher.
// 
// Versions:
// v0.2:
// - Fix placement of top hole

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGVecLib0.scad>

rail_offset = -0.1;

u = 25.4/16;
$fn = 24;
forcefn = 8;

// ba = bottom Y adjust
function kinja_slot_rathnodes(pos=[0,0], off=0, ba=0) =
let( caveopts = off == 0 ? [] : ["round", abs(off)] )
let( os2 = sqrt(2)*off )
let( x0 = 0, x1 = 4*u - off )
[
	["togpath1-rathnode", pos + [x0,  4*u    - os2      ], ["round", 1]],
	["togpath1-rathnode", pos + [x1,  8*u    - os2 - off], caveopts],
	["togpath1-rathnode", pos + [x1, -8*u+ba + os2 + off], caveopts],
	["togpath1-rathnode", pos + [x0, -4*u+ba + os2      ], ["round", 1]],
];

corner_ops = ["round", 2, forcefn]; // For outer corners
tc_ops = ["round", 0.6, forcefn]; // For tiny corners

y0 = -114.3;

function make_front_nodes(sideishness=0) =
let( frontlip_height = 8*u )
let( ybot =  y0+2*u + sideishness*frontlip_height )
let( xli  = 16*u - sideishness * 4*u ) // 4*u is kinda arbitrary
let( xbi  = 6*u + 1*sideishness )
[
	//["togpath1-rathnode", [    6*u, -114.3]],
	["togpath1-rathnode", [   17*u, y0     ], corner_ops],
	["togpath1-rathnode", [   17*u, y0+10*u], tc_ops],
	["togpath1-rathnode", [   16*u, y0+10*u], tc_ops],
	["togpath1-rathnode", [   xli , ybot], tc_ops],
	["togpath1-rathnode", [   xbi , ybot], tc_ops],
	["togpath1-rathnode", [   xbi ,  0     ], corner_ops],
];

function kinja_make_layer_rath(sideishness) = ["togpath1-rath",
	["togpath1-rathnode", [     0,    0  ], corner_ops],
	for( params=[[-0.5, -4*u], [-1.5,0], [-2.5,0]] )
	for( n=kinja_slot_rathnodes(pos=[0,params[0]*38.1], off=rail_offset, ba=params[1]) ) n,
	["togpath1-rathnode", [     0, -114.3], corner_ops],
	each make_front_nodes(sideishness)
];

hanger_body = tphl1_make_polyhedron_from_layer_function([
	[ 0  , 1],
	[ 1*u, 1],
	[ 1*u + 0.1, 0],
	[12*u, 0],
], function(params) 
	let(z=params[0], sideishness=params[1])
	togvec0_offset_points(togpath1_rath_to_polypoints(kinja_make_layer_rath(sideishness)), z)
);

vole = tog_holelib2_hole("THL-1001");
rvole = ["rotate", [0, 90, 0], vole];

togmod1_domodule(["difference",
	hanger_body,
	for( ym=[-12, -36, -60] )
	["translate", [6*u, ym*u, 6*u], rvole]
]);
