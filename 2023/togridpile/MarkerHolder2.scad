// MarkerHolder2.3
// 
// v2.1:
// - Round edges more nicely
// v2.2:
// - Allow different thumb slot placement
// v2.3:
// - Option for thumb_slot_top_width; if blank, slot sides are 'straight'
// - Slight alterations to bevels and such

block_size = ["4chunk", "1chunk", "1inch"];
slot_depth = "0.85inch";
slot_width = "0.75inch";
thumb_slot_width = "1chunk";
thumb_slot_top_width = "";
thumb_slot_depth = "1atom";
thumb_slot_position = "0inch";

bottom_foot_bevel = 0.4; // 0.1
foot_rounding = 0.5; // [0.25:0.1:1]

$tgx11_offset = -0.15;
$fn = 24;

module __markerholder2__end_params() { }

use <../lib/TGx11.1Lib.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGUnits1.scad>
use <../lib/TOGVecLib0.scad>

$togridlib3_unit_table = [
	["tgp-m-outer-corner-radius", [255/64*foot_rounding,"u"]],
	each tgx11_get_default_unit_table()
];

block_size_ca = togunits1_vec_to_cas(block_size);
block_size_mm = togunits1_vec_to_mms(block_size_ca);
slot_width_mm = togunits1_to_mm(slot_width);
slot_depth_mm = togunits1_to_mm(slot_depth);
thumb_slot_bottom_width_mm = togunits1_to_mm(thumb_slot_width);
thumb_slot_top_width_mm    = thumb_slot_top_width == "" ? thumb_slot_bottom_width_mm : togunits1_to_mm(thumb_slot_top_width);
thumb_slot_depth_mm = togunits1_to_mm(thumb_slot_depth);
thumb_slot_x_mm = togunits1_to_mm(thumb_slot_position);
atom          = togunits1_to_mm([1,"atom"]);
chunk         = togunits1_to_mm([1,"chunk"]);

function better_slot_rath(depth, botwidth, topwidth, bev=3.175, offset=0) =
depth <= 0 || botwidth <= 0 || topwidth <= 0 ? ["togpath1-rath"] :
let( bottom_r = min(botwidth*96/256, (depth-bev)*255/256) )
["togpath1-rath",
	["togpath1-rathnode", [-topwidth/2 - bev*10,  bev*9  ],                             ["offset", offset]],
	["togpath1-rathnode", [-topwidth/2         , -bev    ],                             ["offset", offset]],
	["togpath1-rathnode", [-botwidth/2         , -depth  ], ["round", bottom_r, $fn/4], ["offset", offset]],
	["togpath1-rathnode", [ botwidth/2         , -depth  ], ["round", bottom_r, $fn/4], ["offset", offset]],
	["togpath1-rathnode", [ topwidth/2         , -bev    ],                             ["offset", offset]],
	["togpath1-rathnode", [ topwidth/2 + bev*10,  bev*9  ],                             ["offset", offset]],
];

function better_slot_z(zrange, rath_func) =
	tphl1_make_polyhedron_from_layer_function(
		is_num(zrange) ? [[-zrange/2, 0], [zrange/2, 0]] : zrange,
		function(zo) togvec0_offset_points(
			togpath1_rath_to_polypoints(rath_func(zo[1])),
			// togpath1_rath_to_polypoints(better_slot_rath(size, bev, zo[1])),
			zo[0]
		)
	);

togmod1_domodule(
	let(block_hull = tgx11_block(block_size_ca,
	   bottom_segmentation = "chatom",
		bottom_v6hc_style = "none",
		bottom_foot_bevel = bottom_foot_bevel,
	   atom_bottom_subtractions = [togmod1_linear_extrude_z([-1,2.4], togmod1_make_circle(d=6.2))],
		top_segmentation = "block"
	))
	// let(block_hull = togmod1_linear_extrude_z([0, block_size_mm[2]], togmod1_make_rect([block_size_mm[0], block_size_mm[1]])))
	let( slot_bottom_r = min(slot_width_mm, slot_depth_mm*2)*127/256 )
	// TODO: Round intersection of slots
	// Basically: make a custom polyhedron from a cross shape
	let(slot = ["translate", [0,0,block_size_mm[2]],
		["rotate-xyz", [90,0,90],
			better_slot_z(block_size_mm[0]-6.35, function(offset) better_slot_rath( slot_depth_mm, slot_width_mm, slot_width_mm, bev=1.6, offset=offset))
		]])
	let(thumb_slot = ["translate", [thumb_slot_x_mm,0,block_size_mm[2]],
		["rotate-xyz", [90,0,0], better_slot_z(
			let(obev=2)
			let(ibev=max(0, (slot_depth_mm - thumb_slot_depth_mm)*128/256) )
			[
				[-block_size_mm[1]/2-obev , obev*2],
				[-block_size_mm[1]/2+obev , 0],
				[-slot_width_mm/2-ibev*1/4, 0],
				[-slot_width_mm/2+ibev*3/4, ibev*1],
				[ slot_width_mm/2-ibev*3/4, ibev*1],
				[ slot_width_mm/2+ibev*1/4, 0],
				[ block_size_mm[1]/2-obev , 0],
				[ block_size_mm[1]/2+obev , obev*2],
			],
			function(offset) better_slot_rath(thumb_slot_depth_mm, thumb_slot_bottom_width_mm, thumb_slot_top_width_mm, bev=2.1, offset=offset)
		)]
	])
	["difference",
		block_hull,
		
		slot,
		thumb_slot
	]
);
