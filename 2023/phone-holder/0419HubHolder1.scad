// 0419HubHolder1.0
// 
// Holder for Falwedi USB docking station, model # 0419H
// https://www.amazon.com/Docking-Multiport-DisplayPort-Ethernet-Compatible/dp/B0B9BG7K1Z
// 
// Measured dimensions: 140.4mm x 56.3mm x 15.6mm
// Every side has ports on it, but maybe the last 8mm or so at the
// ends of the long edges could be spared

// TODO: Check measured dimensions.  Product page indicates
// 100.1mm wide, not 56.3.  160.0mm long (maybe that includes a bit of the cable),
// and 18.034mm thick (which is a little more than my 15.6mm).
// Might be that those are the dimensions of a different thing.

use <../lib/TGx11.1Lib.scad>
use <../lib/TOGridLib3.scad>
use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGVecLib0.scad>

module __ankerholder__end_params() { }

$tgx11_offset = -0.1;
$tgx11_gender = "m";
$togridlib3_unit_table = tgx11_get_default_unit_table();
$fn = $preview ? 12 : 48;

hub_cavity_size = [57.3, 141.5, 16.3];

block_size_ca = [[5, "atom"], [13, "atom"], [14, "u"]];
block_size = togridlib3_decode_vector(block_size_ca);
atom_pitch = togridlib3_decode([1, "atom"]);

cavity_depth = hub_cavity_size[2];
lip_height = 1.4;
floor_thickness = block_size[2] - cavity_depth;

bhole = ["rotate", [180,0,0], tog_holelib2_hole("THL-1001", inset = floor_thickness - 1.5, depth=block_size[2]+10)];
fhole = tog_holelib2_hole("THL-1005", inset=2.5, depth=floor_thickness+2);

function xratter(w,h,tr=2,br=2,ye=0.1) = togpath1_rath_to_points(["togpath1-rath",
	["togpath1-rathnode", [-w  , tr*3]],
	["togpath1-rathnode", [-w  ,   ye]],
	["togpath1-rathnode", [-w/2,   ye], ["round", tr]],
	["togpath1-rathnode", [-w/2,   -h], ["round", br]],
	["togpath1-rathnode", [ w/2,   -h], ["round", br]],
	["togpath1-rathnode", [ w/2,   ye], ["round", tr]],
	["togpath1-rathnode", [ w  ,   ye]],
	["togpath1-rathnode", [ w  , tr*3]],
]);

function xratter_xy(w,h,thickness,tr=2,br=2) = tphl1_make_polyhedron_from_layer_function([
	-thickness/2,
	+thickness/2,
], let(xr_points = xratter(w,h,tr=tr,br=br)) function(z) togvec0_offset_points(xr_points, z));

function xratter_xz(w,h,thickness,tr=2,br=2) = ["rotate", [90,0, 0], xratter_xy(w,h,thickness,tr=tr,br=br)];
function xratter_yz(w,h,thickness,tr=2,br=2) = ["rotate", [90,0,90], xratter_xy(w,h,thickness,tr=tr,br=br)];

thing = ["difference",
	tgx11_block(
		block_size_ca = block_size_ca,
		bottom_segmentation = "atom",
		lip_height = lip_height,
		top_segmentation = "block"
	),
	for( xm=[-1,1] ) for( ym=[-1,1] ) ["translate", [xm * (block_size[0]-atom_pitch)/2, ym * (block_size[1]-atom_pitch)/2, 0],
		bhole],
	["translate", [0,0,block_size[2]], tphl1_make_rounded_cuboid([hub_cavity_size[0],hub_cavity_size[1],cavity_depth*2], r=[2,2,0])],
	["translate", [0,0,block_size[2]+lip_height],
		//tphl1_make_rounded_cuboid([35,100,cavity_depth*2], r=[0,0,0])
		xratter_xz(hub_cavity_size[0]-14, cavity_depth+lip_height, block_size[1]+4, tr=4, br=1)
	],
	["translate", [0, 0, block_size[2]+lip_height],
		xratter_yz(hub_cavity_size[1]-14, cavity_depth+lip_height, block_size[0]+4, tr=4, br=1)
	],
	for( xm=[-2 : 1 : 2] ) for( ym=[-block_size[1]/atom_pitch/2+0.5 : 1 : block_size[1]/atom_pitch/2-0.4] )
		["translate", [xm*atom_pitch,ym*atom_pitch,floor_thickness], fhole],
];

togmod1_domodule(thing);
