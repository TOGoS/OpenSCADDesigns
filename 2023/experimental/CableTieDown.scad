// CableTieDown0.6
// 
// v0.2:
// - 45-0-45-degree string trough for better printability
// v0.3:
// - Refactor somewhat, to make string cutout donuts more configurable
// - Deeper groove for string on bottom and sides
// v0.4:
// - Fix interpretation of cable_groove_depth
// - Attempt to have minimum of 2mm floor between string groove
//   and bottom of mounting hole counterbore
//   (v0.3 with default settings had only a single layer!)
// v0.5:
// - Add 'string holes' in case that's useful to you
// v0.6:
// - Give it a TOGridPile-compatible bottom cuz why not lol

block_size = [38.1, 38.1, 19.05]; // 0.01
cable_groove_depth         = 3.8; // 0.1
string_groove_depth_bottom = 6.0; // 0.1
string_groove_depth_top    = 3.0; // 0.1
string_groove_depth_side   = 4.0; // 0.1
string_hole_diameter       = 3;

$tgx11_offset = -0.1;

module __ctd0__end_params() { }

use <../lib/TGx11.1Lib.scad>
use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>

$fn = $preview ? 16 : 48;

/** depth=[top,side,bottom] */
function make_string_cutout(outer_size, depth=[6,6,6]) =
let( dtop=depth[0] )
let( dside=depth[1] )
let( dbottom=depth[2] )
let( x0=-outer_size[0]/2 )
let( xA=-outer_size[0]/2 + 2 )
let( xB=+outer_size[0]/2 - 2 )
let( x1=+outer_size[0]/2 )
let( y0=-outer_size[1]/2 )
let( y1=+outer_size[1]/2 )
let( z0=-outer_size[2]/2 )
let( z1=+outer_size[2]/2 )
["difference",
	togmod1_make_cuboid([outer_size[0], outer_size[1]+8, outer_size[2]+8]),
	//togmod1_make_cuboid([50, 25.4, 19.05-6.35]),
	// TODO: Make the unner surface rounded
	tphl1_make_polyhedron_from_layer_function([
		//for( a=[-180:15:0] ) [3.5*cos(a), 4+3.5*sin(a)]
		[x0, 2],
		[xA, 0],
		[xB, 0],
		[x1, 2],
	], function(xo)
		let(off=xo[1])
		let(rrad=min(
			8,
			min(
				y1-y0 - dside*2,
				z1-z0 - dtop - dbottom
			) - 0.5
		)/2) [
		for(rpp = togpath1_rath_to_polypoints(["togpath1-rath",
			["togpath1-rathnode", [y0 + dside, z0 + dbottom], ["round", rrad], ["offset", off]],
			["togpath1-rathnode", [y1 - dside, z0 + dbottom], ["round", rrad], ["offset", off]],
			["togpath1-rathnode", [y1 - dside, z1 - dtop   ], ["round", rrad], ["offset", off]],
			["togpath1-rathnode", [y0 + dside, z1 - dtop   ], ["round", rrad], ["offset", off]],
		]))
		[xo[0], rpp[0], rpp[1]]
	])
	//tphl1_make_rounded_cuboid([50, 25.4, 19.05-6.35], [0,4,4]),
];

string_groove_width = 6.35;

torus = make_string_cutout(
	[string_groove_width, block_size[1], block_size[2]],
	[string_groove_depth_top, string_groove_depth_side, string_groove_depth_bottom]
);

string_hole =
	string_hole_diameter > 0 ? tphl1_make_z_cylinder(d=string_hole_diameter, zrange=[-block_size[2], +block_size[2]]) :
	["union"];

function ctd0__average(a,b) = (a+b)/2;

cb_floor_z_ideal = string_groove_depth_bottom + 2;
cb_floor_z = min(
	cb_floor_z_ideal,
	ctd0__average(cb_floor_z_ideal, block_size[2] - cable_groove_depth - 2)
);

the_hull = ["intersection",
	tgx11_chunk_unifoot(block_size, $tgx11_gender="m", $togridlib3_unit_table=tgx11_get_default_unit_table()),
	tphl1_make_rounded_cuboid([block_size[0],block_size[1],block_size[2]*2], 4.7625)
];

togmod1_domodule(["difference",
	the_hull,
	["translate", [0,0,cb_floor_z], tog_holelib2_hole("THL-1006", depth=block_size[2], inset=0, overhead_bore_height=block_size[2])],
	["translate", [0,0,block_size[2]], tphl1_make_rounded_cuboid([50,19.05,cable_groove_depth*2], [0,3,3])],
	for(xm=[-1,1]) ["translate", [-25.4/3*xm,0,block_size[2]/2], torus],
	for(r=[0,90,180,270]) ["rotate", [0,0,r], ["translate", [-25.4/3,0,block_size[2]/2], string_hole]],
]);
