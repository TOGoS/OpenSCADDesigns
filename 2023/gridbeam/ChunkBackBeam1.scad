// ChunkBackBeam1.0
// 
// TOGBeam that is chunked on only one side,
// for use with e.g. atom of hatom-backed FCs (p165x, p186x, etc)

bottom_segmentation = "hatom"; // ["none","hatom"]

size = ["9atom", "1atom", "1atom"];
hole_diameter = 4.5;
$fn = 24;

module chunkbackbeam1__end_params() { }

use <../lib/TGx11.1Lib.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGridLib3.scad>
use <../lib/TOGStringLib1.scad>
use <../lib/TOGPath1.scad>

$togridlib3_unit_table = tgx11_get_default_unit_table();$tgx11_offset = -0.1;

function parse_ca(qstr) =
	let( pr = togstr1_parse_quantity(qstr) )
	[pr[0][0][0] / pr[0][0][1], pr[0][1]];

size_ca = [for(qstr=size) parse_ca(qstr)];
size_mm = togridlib3_decode_vector(size_ca);
size_atoms = togridlib3_decode_vector(size_ca, unit=[1,"atom"]);
atom = togridlib3_decode([1,"atom"]);

bev = togridlib3_decode([1, "tgp-standard-bevel"]);
rnd = bev;
off = $tgx11_offset;

main_hull = togmod1_linear_extrude_z([-size_mm[0]/2, size_mm[2]/2],
	togpath1_make_rounded_beveled_rect(size_mm, bev, rnd, offset=$tgx11_offset)
);

hatom_segmentation_intersectable =
let( cops = [["offset", $tgx11_offset]] )
togmod1_linear_extrude_y([-size_mm[1], size_mm[1]], togpath1_rath_to_polygon(["togpath1-rath",
	["togpath1-rathnode", [-size_mm[0]/2 - 10, size_mm[2]+10], each cops],
	["togpath1-rathnode", [-size_mm[0]/2 - 10,        bev+10], each cops],
	["togpath1-rathnode", [-size_mm[0]/2 + bev,            0], each cops],
	
	for( xa=[-size_atoms[0]/2+1 : 1 : size_atoms[0]/2-1] ) each
	let( x=xa*atom ) [
		["togpath1-rathnode", [x - bev  , 0    ], each cops],
		["togpath1-rathnode", [x - bev/2, bev/2], each cops],
		["togpath1-rathnode", [x + bev/2, bev/2], each cops],
		["togpath1-rathnode", [x + bev  , 0    ], each cops],
	],
	
	["togpath1-rathnode", [ size_mm[0]/2 - bev,            0], each cops],
	["togpath1-rathnode", [ size_mm[0]/2 + 10,        bev+10], each cops],
	["togpath1-rathnode", [ size_mm[0]/2 + 10, size_mm[2]+10], each cops],
]));

bottom_segmentation_intersectable =
	bottom_segmentation == "none" ? togmod1_make_cuboid([size_mm[0]*2, size_mm[1]*2, size_mm[2]]) :
	["translate", [0,0,-size_mm[2]/2], hatom_segmentation_intersectable];

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
