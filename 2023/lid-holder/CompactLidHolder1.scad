// CompactLidHolder1.11
// 
// this design based on pairs of 'combs'
// to be connected with 2+3/4" spacers of some sort.
// 
// v1.2:
// - Add 'spacer' mode
// v1.3:
// - Fix calculation of comb_length_u
// v1.4:
// - Fix comb back Y position
// v1.5:
// - Add 'spacer2' mode
// v1.6:
// - comb_depth_u is configurable
// v1.7:
// - Option for 1/2" square notches near ends of comb
// v1.8:
// - spacer3, spacer4
// v1.9:
// - Small holes in spacer2, spacer3, spacer4
// v1.10:
// - Add 'sidepanel' mode
// v1.11:
// - Put a notch every chunk on the combs

comb_length_chunks = 4;
mode = "combs"; // ["combs", "spacer", "spacer2", "spacer3", "spacer4", "sidepanel"]

/* [Comb Options] */
// Depth of comb, in 1/16"; 28 or 34 recommended
comb_depth_u = 28;
comb_little_notches_enabled = true;
comb_big_notches_enabled = false;

module __clh1__askjdniu24tr_end_params() { }

use <../lib/TOGridLib3.scad>
use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGVecLib0.scad>
use <../lib/TGx11.1Lib.scad>

$togridlib3_unit_table = tgx11_get_default_unit_table();

u = togridlib3_decode([1, "u"]);
atom = togridlib3_decode([1, "atom"]);

comb_thickness = togridlib3_decode([2, "u"]);

// TODO: Shouldn't need to 'round'; decode should be precise when possible!
comb_length_u = round(togridlib3_decode([comb_length_chunks, "chunk"], unit=[1, "u"]));
comb_height_u = 3*16;

bottom_segmentation = "none";

$tgx11_offset = -0.1;
$fn = $preview ? 16 : 48;

comb_corner_ops = [["bevel", 2*u], ["round", 2*u]];
comb_inner_ops = [["round", 2]];
comb_tip_ops = [["round", 1]];

/*
// If you want fewer notches, you could do it this way
comb_big_notch_positions_u = [-comb_length_u/2 + 12, if(comb_length_chunks%2==1) 0, comb_length_u/2 - 12];

function in_array(needle, haystack, index=0) =
	len(haystack) > index && (
		haystack[index] == needle || in_array(needle, haystack, index+1)
	);

function comb_has_notch_at_u( u ) =
	in_array(u, comb_big_notch_positions_u);
*/

function comb_has_notch_at_u( u ) =
	(u + comb_length_chunks*12)%24 == 12;

function make_comb_rath_u(depth_u) =
["togpath1-rath",
	for( x=[-comb_length_u/2 + 8 : 8 : comb_length_u/2-8] ) each
	let( mode =
		comb_big_notches_enabled && comb_has_notch_at_u(x + 4) ? "up"   :
		comb_big_notches_enabled && comb_has_notch_at_u(x - 4) ? "down" :
		comb_little_notches_enabled ? "notch" : "flat"
	)
	mode == "notch" ? [
		// TOGridPile atomic bottom!!
		// (could be really fancy and do it in the Z direction also. P-:)
		["togpath1-rathnode", [x-2, 0], ["round", 2*u]],
		["togpath1-rathnode", [x  , 2]],
		["togpath1-rathnode", [x+2, 0], ["round", 2*u]],
	] :
	mode == "up" ? [
		["togpath1-rathnode", [x-2, 0], ["round", 2*u]],
		["togpath1-rathnode", [x  , 2], ["round", 2*u]],
		["togpath1-rathnode", [x  , 8], ["round", 1*u]],
	] :
	mode == "down" ? [
		["togpath1-rathnode", [x  , 8], ["round", 1*u]],
		["togpath1-rathnode", [x  , 2], ["round", 2*u]],
		["togpath1-rathnode", [x+2, 0], ["round", 2*u]],
	] :
	[],
	
	["togpath1-rathnode", [ comb_length_u/2,             0], each comb_corner_ops],
	["togpath1-rathnode", [ comb_length_u/2, comb_height_u], each comb_corner_ops],

	for( x = [comb_length_u/2 - 11 : -6 : -comb_length_u/2 + 7] ) each [
		["togpath1-rathnode", [x  , comb_height_u], each comb_tip_ops],
		// Backoff = Y offset of 'back'; hardcoded multipliers based on assumed 3/28 slope follow:
		["togpath1-rathnode", [x  +depth_u*3/28, comb_height_u-depth_u], each comb_inner_ops],
		["togpath1-rathnode", [x-4+depth_u*3/28, comb_height_u-depth_u], each comb_inner_ops],
		["togpath1-rathnode", [x-4, comb_height_u], each comb_tip_ops],
	],

	["togpath1-rathnode", [-comb_length_u/2, comb_height_u], each comb_tip_ops],
	["togpath1-rathnode", [-comb_length_u/2,             0], each comb_corner_ops],
];

function scale_rath_points(rath, scale) = [rath[0],
	for( i=[1:1:len(rath)-1] ) [rath[i][0], rath[i][1]*scale, for(j=[2:1:len(rath[i])-1]) rath[i][j]]
];

function make_comb_rath(comb_depth_u=28) = scale_rath_points(make_comb_rath_u(comb_depth_u), u);

plate = tphl1_make_polyhedron_from_layer_function([
	[0               , 0],
	[comb_thickness/2, 1],
	[comb_thickness  , 0],
], function(zo) togvec0_offset_points(togpath1_rath_to_polypoints(make_comb_rath(comb_depth_u-zo[1]/u)), zo[0]));

comb_hole_positions = [
	for( xu=[-comb_length_u/2 + 4 : 8 : comb_length_u/2-3] ) [xu*u, 4*u],
	[(-comb_length_u/2+4)*u, 12*u],
	for( yu=[12 : 8 : comb_height_u-1] ) [(comb_length_u/2-4)*u, yu*u],
];

hole = tog_holelib2_hole("THL-1001", depth=comb_thickness*2, inset=0.5);

spacer_big_hole   = tog_holelib2_hole("THL-1002", depth=50, inset=0.1, overhead_bore_height=50, $fn=min($fn,48));
spacer_small_hole = tog_holelib2_hole("THL-1001", depth=50, inset=0.1, overhead_bore_height=50, $fn=min($fn,32));

comb = ["difference",
	plate,
	for( hp=comb_hole_positions ) ["translate", [hp[0], hp[1], comb_thickness], hole]
];

spacer_length = togridlib3_decode([44,"u"]);
spacer_width  = togridlib3_decode([24,"u"]);
spacer_thickness = togridlib3_decode([1, "atom"]);
spacer_end_hole_diameter = 3;
spacer_end_hole_depth = 12;
// spacer_long_end_hole  = ["rotate", [0,90,0], tphl1_make_z_cylinder(zrange=[-spacer_length, +spacer_length], d=spacer_end_hole_diameter)];
spacer_short_end_hole = ["rotate", [0,90,0],
	tphl1_make_z_cylinder(zds=[
		[-spacer_end_hole_depth, 0],
		[-spacer_end_hole_depth+3, spacer_end_hole_diameter], 
		[ spacer_end_hole_depth-3, spacer_end_hole_diameter], 
		[ spacer_end_hole_depth, 0],
	], $fn=min($fn,16))
];

spacer_side_hole_depth = 3;
spacer_side_hole_positions = [
	for( y=[-spacer_width/2, spacer_width/2] ) for( xm=[round(-spacer_length/12.7/2) + 1 : 0.5 : round(spacer_length/12.7/2) - 0.9] )
	[xm*12.7, y]
];
spacer_side_hole = ["rotate", [90,0,0],
	tphl1_make_z_cylinder(zds=[
		[-spacer_side_hole_depth, 0],
		[-0.1                   , spacer_end_hole_diameter], 
		[ 0.1                   , spacer_end_hole_diameter], 
		[ spacer_side_hole_depth, 0],
	], $fn=min($fn,16))
];


spacer_small_hole_positions = [
	for( y=[-8*u, 8*u] ) for( xm=[round(-spacer_length/12.7/2) + 1 : 1 : spacer_length/12.7/2 - 0.5] )
	[xm*12.7, y]
];
spacer2_small_hole_positions = spacer_small_hole_positions;

function make_spacer() = ["difference",
	["intersection",
		tphl1_make_rounded_cuboid([spacer_length, 24*u, spacer_thickness], r=[3*u, 3*u, 1*u], corner_shape="ovoid1"),
		if( bottom_segmentation == "chatom" ) ["translate", [0,0,-spacer_thickness/2], tgx11_atomic_block_bottom(
			[
				[ceil(spacer_length/12.7), "atom"],
				[ceil(spacer_width/12.7), "atom"],
				[round(spacer_thickness*2/12.7), "atom"],
			],
			$tgx11_gender = "m"
		)]
	],
	for( xm=[-0.5,0,0.5] ) ["translate", [xm*24*u, 0, spacer_thickness/2 - 2*u], spacer_big_hole],
	//for( y=[-8*u, 8*u] ) ["translate", [0,y,0], spacer_long_end_hole],
	for(ym=[-8 : 4 : 8]) for( xm=[-0.5,0.5] ) ["translate", [xm*spacer_length,ym*u,0], spacer_short_end_hole],
	for(pos=spacer_small_hole_positions) ["translate", [pos[0], pos[1], spacer_thickness/2-2*u], spacer_small_hole],
	for(pos=spacer_side_hole_positions) ["translate", pos, spacer_side_hole],
];

function make_spacer2_rath(corner_ops) = ["togpath1-rath",
	["togpath1-rathnode", [ spacer_length/2, 0                        ], each corner_ops],
	["togpath1-rathnode", [ spacer_length/2     , spacer_thickness    ], each corner_ops],
	["togpath1-rathnode", [ spacer_length/2- 4*u, spacer_thickness    ], each corner_ops],
	["togpath1-rathnode", [ spacer_length/2-10*u, spacer_thickness-6*u], each corner_ops],
	["togpath1-rathnode", [-spacer_length/2+10*u, spacer_thickness-6*u], each corner_ops],
	["togpath1-rathnode", [-spacer_length/2+ 4*u, spacer_thickness    ], each corner_ops],
	["togpath1-rathnode", [-spacer_length/2     , spacer_thickness    ], each corner_ops],
	["togpath1-rathnode", [-spacer_length/2, 0                        ], each corner_ops],
];

function make_spacer2(end_hole_yus=[-8 : 4 : 8]) = ["difference",
	tphl1_make_polyhedron_from_layer_function(
		[
			[-12*u  , -1],
			[-12*u+1,  0],
			[ 12*u-1,  0],
			[ 12*u  , -1],
		],
		function(yo) [ for(p=togpath1_rath_to_polypoints(make_spacer2_rath([["round", 2*u], ["offset", yo[1]]]))) [p[0], -yo[0], p[1]] ]
	),
	for( xm=[-0.5,0,0.5] ) ["translate", [xm*24*u, 0, 2*u], spacer_big_hole],
	for(ym=end_hole_yus) for( xm=[-0.5,0.5] ) ["translate", [xm*spacer_length,ym*u,spacer_thickness/2], spacer_short_end_hole],
	for(pos=spacer2_small_hole_positions) ["translate", [pos[0], pos[1], 2*u], spacer_small_hole],
];

function make_spacer3() =
let( comb_x0_u = -24, comb_x1_u = -22 )
let( wall_x0_u = -32, wall_x1_u = -28 )
let( dubmarg = 0.2 ) // 'double margin' on each side of comb
let( tun=["rotate", [0,90,0], tphl1_make_z_cylinder(d=5, zrange=[-12,12])] )
["difference",
	["union",
		make_spacer2(end_hole_yus=[-8,8]),
		for( xs=[1,-1] ) ["scale", [xs,1,1], ["union",
			["translate", [(wall_x1_u+comb_x0_u-dubmarg)/2*u,0,4*u], ["difference",
				tphl1_make_rounded_cuboid([(comb_x0_u-dubmarg-wall_x1_u)*u, spacer_width, spacer_thickness], 1),
				for(ym=[-8,8]) ["translate", [0,ym*u,0], tun],
			]],
			["translate", [(comb_x0_u+comb_x1_u)/2*u,0,4*u], tphl1_make_rounded_cuboid([8*u, 8*u, spacer_thickness], 1*u)],
		]],
	],
	for( xm=[1,-1] ) ["translate", [wall_x0_u*u*xm,0,spacer_thickness/2], spacer_short_end_hole]
];

function make_spacer4() =
let( comb_x0_u = -24, comb_x1_u = -22 )
let( wall_x0_u = -32, wall_x1_u = -28 )
let( tun=["rotate", [0,90,0], tphl1_make_z_cylinder(d=5, zrange=[-12,12])] )
["difference",
	["union",
		make_spacer2(end_hole_yus=[-8,8]),
		for( xs=[1,-1] ) ["scale", [xs,1,1], ["union",
			/*["translate", [(wall_x1_u+comb_x0_u-0.2)/2*u,0,4*u], ["difference",
				tphl1_make_rounded_cuboid([(comb_x0_u-0.2-wall_x1_u)*u, spacer_width, spacer_thickness], 1),
				for(ym=[-8,8]) ["translate", [0,ym*u,0], tun],
			]],*/
			["translate", [(wall_x1_u+comb_x1_u+4)/2*u,0,4*u], tphl1_make_rounded_cuboid([(comb_x1_u+4-wall_x1_u)*u, 8*u, spacer_thickness], 1*u)],
		]],
	],
	for( xm=[1,-1] ) ["translate", [wall_x0_u*u*xm,0,spacer_thickness/2], spacer_short_end_hole]
];

function make_sidepanel() =
let(length = togridlib3_decode([comb_length_chunks, "chunk"]))
let(height = 3*25.4)
let(thickness = 2*u)
let(dp = 19.05)
let(diamond = togmod1_make_polygon([[0,-8],[8,0],[0,8],[-8,0]]))
["difference",
	togmod1_linear_extrude_z([0, thickness], ["difference",
		togmod1_make_polygon(togpath1_rath_to_polypoints(["togpath1-rath",
			["togpath1-rathnode", [  length/2, -height/2], each comb_corner_ops],
			["togpath1-rathnode", [  length/2,  height/2], each comb_corner_ops],
			["togpath1-rathnode", [ -length/2,  height/2], each comb_corner_ops],
			["togpath1-rathnode", [ -length/2, -height/2], each comb_corner_ops],
		])),
		
		for( ym=[-round(height/dp)/2+1 : 1 : round(height/dp)/2-1] )
		for( xm=[-round(length/dp)/2+0.5 : 1 : round(length/dp)/2-0.5] )
		["translate", [xm*dp, ym*dp, 0], diamond],
		
		for( ym=[-round(height/dp)/2+1.5 : 1 : round(height/dp)/2-1.5] )
		for( xm=[-round(length/dp)/2+1 : 1 : round(length/dp)/2-1] )
		["translate", [xm*dp, ym*dp, 0], diamond]
	]),
	
	for( ym=[-round(height/12.7)/2 + 0.5, round(height/12.7)/2-0.5] )
	for( xm=[-round(length/12.7)/2 + 0.5 : 1 : length/12.7/2] )
	["translate", [xm*12.7, ym*12.7, thickness], hole]
];

thing =
	mode == "combs" ? ["union",
		["translate", [0, 12.7,0], comb],
		["translate", [0,-12.7,0], ["scale", [1,-1,1], comb]],
	] :
	mode == "spacer"  ? ["translate", [0,0,spacer_thickness/2], make_spacer()] :
	mode == "spacer2" ? make_spacer2() :
	mode == "spacer3" ? make_spacer3() :
	mode == "spacer4" ? make_spacer4() :
	mode == "sidepanel" ? make_sidepanel() :
	assert(false, str("Unrecognized mode: '", mode, "'"));

togmod1_domodule(thing);
