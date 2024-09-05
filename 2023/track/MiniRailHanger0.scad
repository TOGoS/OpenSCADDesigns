// MiniRailHanger0.5
// 
// Can I use a MiniRail as a tiny French cleat?
// This hanger is designed to hold one corner
// (print two to hang both corners) of my 4x4 USB switcher.
// 
// Versions:
// v0.2:
// - Fix placement of top hole
// v0.3:
// - Make width configurable
// - Add 'spacer' mode
// v0.4:
// - Make depth, lip height, and lip thickness adjustable
// - Add 'open-hanger' mode
// - Rename 'hanger' to 'sided-hanger'
// - Automatically choose along-the-rail spacing for holes
// v0.5:
// - Adjustments to allow lip to be as tall as the full block
// - Side is now a bit lower than the lip
// - Overhead bores for the holes through lip

mode = "sided-hanger"; // ["sided-hanger", "open-hanger", "spacer"]
// Surface offset of rail-facing surfaces; negative to give more space
rail_offset     = -0.10; // 0.01
width           = 19.05; // 0.1
hanger_depth    = 27.0 ; // 0.1
hanger_lip_height = 12.7; // 0.1
hanger_lip_thickness = 1.6; // 0.1

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGVecLib0.scad>

module __kinja__end_params() { }

u         = 25.4/16;
atom      = 12.7 ;
halfchunk = 19.05;
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

function kinja_make_back_nodes() = [
	["togpath1-rathnode", [     0,    0  ], corner_ops],
	for( params=[[-0.5, -4*u], [-1.5,0], [-2.5,0]] )
	for( n=kinja_slot_rathnodes(pos=[0,params[0]*38.1], off=rail_offset, ba=params[1]) ) n,
	["togpath1-rathnode", [     0, -114.3], corner_ops],
];

function lerp(r, v0, v1) = (r*v1) + (1-r)*v0;

function make_front_nodes(sideishness=0) =
// Top of block = 0, bottom = y0
let( yl = y0 + hanger_lip_height )
let( y0i   = lerp(sideishness, y0+2*u, max(y0+2*u,min(0,yl)-2*u)) )
let( xbi   = 6*u ) // x back inner (before messing with it to make side)
let( xli   = hanger_depth - hanger_lip_thickness ) // x lip inner (pre-messing)
let( xlti  = xli ) // x lip top inner
let( xbti  = xbi + sideishness * 1*u ) // x back top inner
let( xlbi  = xli - sideishness * (xlti-xbti)*1/3 ) // x lip bottom inner
let( xbbi  = lerp(min(1,max(0,10-abs(y0i))), xbti, xbti + (xlti-xbti)*1/3) ) // x back bottom inner
let( dep   = hanger_depth )
[
	//["togpath1-rathnode", [    6*u, -114.3]],
	["togpath1-rathnode", [   dep    , y0  ], corner_ops],
	["togpath1-rathnode", [   dep    , yl  ], tc_ops    ],
	["togpath1-rathnode", [   xlti   , yl  ], tc_ops    ],
	["togpath1-rathnode", [   xlbi   , y0i ], tc_ops    ],
	["togpath1-rathnode", [   xbbi   , y0i ], tc_ops    ],
	["togpath1-rathnode", [   xbti   ,  0  ], corner_ops],
];

function kinja_make_spacer_rath(sideishness) = ["togpath1-rath",
	["togpath1-rathnode", [   6*u,  0     ], corner_ops],
	each kinja_make_back_nodes(),
	["togpath1-rathnode", [   6*u,  y0    ], corner_ops],
];

function kinja_make_layer_rath(sideishness) = ["togpath1-rath",
	each kinja_make_back_nodes(),
	each make_front_nodes(sideishness)
];

spacer_body = tphl1_make_polyhedron_from_layer_function([
	0,
	width,
], function(z)
	togvec0_offset_points(togpath1_rath_to_polypoints(kinja_make_spacer_rath()), z)
);

/** zses = [z, sideishness] for each layer */
function make_hanger_body(zses) = tphl1_make_polyhedron_from_layer_function(
	zses,
	function(params)
		let(z=params[0], sideishness=params[1])
		togvec0_offset_points(togpath1_rath_to_polypoints(kinja_make_layer_rath(sideishness)), z)
	);

sided_hanger_zses = [
	[ 0        , 1],
	[ 1*u      , 1],
	[ 1*u + 0.1, 0],
	[width     , 0],
];
open_hanger_zses = [
	[ 0   , 0],
	[width, 0],
];

vole = tog_holelib2_hole("THL-1001", overhead_bore_height=hanger_depth*2);
rvole = ["rotate", [0, 90, 0], vole];

// A crappy algorithm for picking
// the best along-the-rails hole spacing

function korg(dividend, divisor) =
	let(q = dividend / divisor)
	abs(q - round(q));

function best(list, scorer, i=0, curbestscore=-1000, curbest=undef) =
	i == len(list) ? curbest :
	let(thisitem  = list[i])
	let(thisscore = scorer(thisitem, i))
	best(list, scorer, i+1,
		thisscore > curbestscore ? thisscore : curbestscore,
		thisscore > curbestscore ? thisitem  : curbest);

zgrid = best([halfchunk, atom], function(x,i) 0 - korg(width, x));
zgrid_count = round((width-3)/zgrid);
rvoles = ["union",
	for( zm=[-zgrid_count/2 + 0.5 : 1 : zgrid_count/2 - 0.4] )
	for( ym=[-12, -36, -60] )
	["translate", [6*u, ym*u, width/2 + zm*zgrid], rvole]
];

function kinja_make_sided_hanger() = ["difference",
	make_hanger_body(sided_hanger_zses),
	rvoles
];

function kinja_make_open_hanger() = ["difference",
	make_hanger_body(open_hanger_zses),
	rvoles
];

function kinja_make_spacer() = ["difference",
	spacer_body,
	rvoles
];

thing =
	mode == "spacer" ? kinja_make_spacer() :
	mode == "sided-hanger" || mode == "hanger" ? kinja_make_sided_hanger() :
	mode == "open-hanger"  ? kinja_make_open_hanger() :
	assert(false, str("Unrecognized mode: ", mode));

togmod1_domodule(thing);
