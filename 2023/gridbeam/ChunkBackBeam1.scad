// ChunkBackBeam1.1
// 
// TOGBeam that is chunked on only one side,
// for use with e.g. atom of hatom-backed FCs (p165x, p186x, etc)
// 
// Versions:
// v1.0:
// - Original; only segmentation options are "none" and "hatom"
// v1.1:
// - Add 'vatom', 'atom', and 'atom+v6hc' segmentation options
// - Add 'bottom_foot_bevel' option
// - Footed instead of beveled feet

size = ["9atom", "1atom", "1atom"];
hole_diameter = 4.5;
bottom_segmentation = "hatom"; // ["none","hatom","vatom","atom","atom+v6hc"]
bottom_foot_bevel = 0.4;
$fn = 24;

module chunkbackbeam1__end_params() { }

use <../lib/TGx11.1Lib.scad>
use <../lib/TOGArrayLib1.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGridLib3.scad>
use <../lib/TOGStringLib1.scad>
use <../lib/TOGPath1.scad>

$togridlib3_unit_table = [
	["tgp-m-outer-corner-radius", [3, "u"]],
	each tgx11_get_default_unit_table(),
];
$tgx11_offset = -0.1;

function parse_ca(qstr) =
	let( pr = togstr1_parse_quantity(qstr) )
	[pr[0][0][0] / pr[0][0][1], pr[0][1]];

size_ca = [for(qstr=size) parse_ca(qstr)];
size_mm = togridlib3_decode_vector(size_ca);
size_atoms = togridlib3_decode_vector(size_ca, unit=[1,"atom"]);
atom = togridlib3_decode([1,"atom"]);

bev = togridlib3_decode([1, "tgp-standard-bevel"]);
hlfbev = togridlib3_decode([1/2, "tgp-standard-bevel"]);
qrtbev = togridlib3_decode([1/4, "tgp-standard-bevel"]);
botbev = bottom_foot_bevel;
rnd = bev;
off = $tgx11_offset;

main_hull = togmod1_linear_extrude_z([-size_mm[0]/2, size_mm[2]/2],
	togpath1_make_rounded_beveled_rect(size_mm, bev, rnd, offset=$tgx11_offset)
);

function make_hatom_rath(size) =
assert( tal1_is_vec_of_num(size, 2), str("make_hatom_rath expected size : [num, num], got: ", size))
let( length = size[0], height = size[1] )
let( length_atoms = length/12.7 ) // TODO: Do ti right
let( cops = [["offset", $tgx11_offset]] )
["togpath1-rath",
	["togpath1-rathnode", [-length/2 - 10             ,     height+10], each cops],
	["togpath1-rathnode", [-length/2 - 10             ,        bev+10], each cops],
	["togpath1-rathnode", [-length/2 + hlfbev         ,     hlfbev   ], each cops],
	["togpath1-rathnode", [-length/2 + hlfbev         ,     botbev   ], each cops],
	["togpath1-rathnode", [-length/2 + hlfbev + botbev,             0], each cops],
	
	for( xa=[-length_atoms/2+1 : 1 : length_atoms/2-1] ) each
	let( x=xa*atom ) [
		["togpath1-rathnode", [x - hlfbev - botbev, 0            ], each cops],
		["togpath1-rathnode", [x - hlfbev         , botbev       ], each cops],
		["togpath1-rathnode", [x - hlfbev         , hlfbev       ], each cops],
		["togpath1-rathnode", [x - qrtbev         , hlfbev+qrtbev], each cops],
		["togpath1-rathnode", [x + qrtbev         , hlfbev+qrtbev], each cops],
		["togpath1-rathnode", [x + hlfbev         , hlfbev       ], each cops],
		["togpath1-rathnode", [x + hlfbev         , botbev       ], each cops],
		["togpath1-rathnode", [x + hlfbev + botbev, 0            ], each cops],
	],
	
	["togpath1-rathnode", [ length/2 - hlfbev - botbev,             0], each cops],
	["togpath1-rathnode", [ length/2 - hlfbev         ,     botbev   ], each cops],
	["togpath1-rathnode", [ length/2 - hlfbev         ,     hlfbev   ], each cops],
	["togpath1-rathnode", [ length/2 + 10             ,        bev+10], each cops],
	["togpath1-rathnode", [ length/2 + 10             ,     height+10], each cops],
];

function make_hatom_segmentation_intersectable(size_mm) =
	togmod1_linear_extrude_y([-size_mm[1], size_mm[1]], togpath1_rath_to_polygon(make_hatom_rath([size_mm[0], size_mm[2]])));

function make_vatom_segmentation_intersectable(size_mm) =
	togmod1_linear_extrude_x([-size_mm[0], size_mm[0]], togpath1_rath_to_polygon(make_hatom_rath([size_mm[1], size_mm[2]])));

bottom_segmentation_intersectable =
	bottom_segmentation == "none" ? togmod1_make_cuboid([size_mm[0]*2, size_mm[1]*2, size_mm[2]]) :
	bottom_segmentation == "hatom" ? ["translate", [0,0,-size_mm[2]/2], make_hatom_segmentation_intersectable(size_mm)] :
	bottom_segmentation == "vatom" ? ["translate", [0,0,-size_mm[2]/2], make_vatom_segmentation_intersectable(size_mm)] :
	bottom_segmentation == "atom" ? ["translate", [0,0,-size_mm[2]/2], tgx11_block_bottom(size_ca, segmentation="atom", foot_bevel=bottom_foot_bevel, v6hc_style="none")] :
	bottom_segmentation == "atom+v6hc" ? ["translate", [0,0,-size_mm[2]/2], tgx11_block_bottom(size_ca, segmentation="atom", foot_bevel=bottom_foot_bevel, v6hc_style="v6.1")] :
	assert(false, str("Unrecognized segmentation: '", bottom_segmentation, "'"));

hole = let(len=max(size_mm[1],size_mm[2])+1 ) togmod1_linear_extrude_z([-len/2, len/2], togmod1_make_circle(d=hole_diameter));
crosshole = ["render", ["union", hole, ["rotate", [90,0,0], hole]]];

// TODO: A hole the long way?

togmod1_domodule(["difference",
	["intersection",
		main_hull,
		bottom_segmentation_intersectable,
	],
	
	for( xa=[-size_atoms[0]/2+0.5 : 1 : size_atoms[0]/2-0.4] )
	for( ya=[-size_atoms[1]/2+0.5 : 1 : size_atoms[1]/2-0.4] )
	for( za=[-size_atoms[2]/2+0.5 : 1 : size_atoms[2]/2-0.4] )
	["translate", [xa*atom,ya*atom,za*atom], crosshole],
]);
