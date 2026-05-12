// LitterBucketHook0.1
// 
// TODO: Option to include the back panel and possibly a French cleat,
// so that these can be used without having to bolt them to something else.

width = "2chunk";
lip_height      = "1/2inch";
lip_thickness   = "3/8inch";
neck_height     = "1inch";
neck_length     = "1/8inch";
chin_hole_style = "THL-1006";

$fn = 32;

module __asdmlkaslkd__end_params() { }

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGVecLib0.scad>
use <../lib/TOGUnits1.scad>

width_mm         = togunits1_to_mm(width);
width_chunks     = togunits1_decode(width, unit="chunk", xf="round");
chunk_mm         = togunits1_to_mm("chunk");
lip_height_mm    = togunits1_to_mm(lip_height);
lip_thickness_mm = togunits1_to_mm(lip_thickness);
neck_height_mm   = togunits1_to_mm(neck_height);
neck_length_mm   = togunits1_to_mm(neck_length);

togmod1_domodule(
	let( chin_hole = ["rotate", [90,0,0], tog_holelib2_hole(chin_hole_style, flange_radius=6)] )
	let( panel_y0 = 0 )
	let( lip_y1 = panel_y0 - neck_length_mm )
	let( lip_y0 = lip_y1 - lip_thickness_mm )
	let( x_bev = 1 )
	let( lip_front_r = lip_thickness_mm * ($fn-1)/($fn*2) )
	let( lip_back_r  = min(lip_height_mm,lip_thickness_mm) * ($fn-1)/($fn*2) )
	let( chin_r = min(neck_height_mm - lip_thickness_mm/2, -lip_y0)*($fn-1)/$fn )
	["difference",
		tphl1_make_polyhedron_from_layer_function(
			[
				[-width_mm/2        , -x_bev],
				[-width_mm/2 + x_bev,  0    ],
				[ width_mm/2 - x_bev,  0    ],
				[ width_mm/2        , -x_bev],
			],
			function(zo) togpath1_rath_to_polypoints(togpath1_offset_rath(["togpath1-rath",
				["togpath1-rathnode", [panel_y0, 0             ]],
				["togpath1-rathnode", [panel_y0, neck_height_mm]],
				["togpath1-rathnode", [  lip_y1, neck_height_mm]],
				["togpath1-rathnode", [  lip_y1, neck_height_mm + lip_height_mm], ["round", lip_back_r]],
				["togpath1-rathnode", [  lip_y0, neck_height_mm + lip_height_mm], ["round", lip_front_r]],
				["togpath1-rathnode", [  lip_y0, 0   ], ["round", chin_r]],
			], zo[1])),
			layer_points_transform = ["lcompose", "key0-to-z", "xyz-to-yzx"]
		),
		
		for( xm=[-width_chunks/2+0.5 : 1 : width_chunks/2-0.5] )
		["translate", [xm*chunk_mm, lip_y0, chunk_mm/2], chin_hole],
	]
);
