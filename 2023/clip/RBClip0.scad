// RBClip0.1
// 
// Clip for attaching gridbeam (or whatever) to the lip of the plastic
// raised plant planter that I have in the backyard.

width = "1chunk";
length = "2chunk";
thickness = "3/8inch";
slot_width = "8mm";
slot_frequency = 2;

$fn = 32;

module __rbclip0__end_params() { }

use <../lib/TOGUnits1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGMod1.scad>

width_mm      = togunits1_to_mm(width     );
width_chunks  = togunits1_decode(width, unit="chunk");
length_mm     = togunits1_to_mm(length    );
thickness_mm  = togunits1_to_mm(thickness );
slot_width_mm = togunits1_to_mm(slot_width);
chunk         = togunits1_to_mm("chunk");

togmod1_domodule(
	let( l = length_mm )
	let( t = thickness_mm )
	let( bev = 2 )
	let( r = t*127/256 )
	let( slot_length_mm = length_mm - t*2 - bev*2 - 3 )
	let( slot = tphl1_make_polyhedron_from_layer_function(
			[
				[-t/2-1  , bev+1],
				[-t/2+bev,     0],
				[ t/2-bev,     0],
				[ t/2+1  , bev+1],
			],
			function(zo) togpath1_rath_to_polypoints(
				togpath1_make_rectangle_rath([slot_length_mm, slot_width_mm], corner_ops=[["round", min(slot_length_mm,slot_width_mm)*127/256], ["offset", zo[1]]])
			),
			layer_points_transform = "key0-to-z"
		)
	)
	["difference",
		["rotate", [90,0,0], tphl1_make_polyhedron_from_layer_function(
			[
				[-width_mm/2    , -bev],
				[-width_mm/2+bev,  0  ],
				[ width_mm/2-bev,  0  ],
				[ width_mm/2    , -bev],
			],
			function(zo) togpath1_rath_to_polypoints(["togpath1-rath",
				["togpath1-rathnode", [ l/2    , -t], ["round", r], ["offset", zo[1]]],
				["togpath1-rathnode", [ l/2    ,  t], ["round", r], ["offset", zo[1]]],
				["togpath1-rathnode", [ l/2 - t,  t], ["round", r], ["offset", zo[1]]],
				["togpath1-rathnode", [ l/2 - t,  0],               ["offset", zo[1]]],
				["togpath1-rathnode", [-l/2    ,  0], ["round", r], ["offset", zo[1]]],
				["togpath1-rathnode", [-l/2    , -t], ["round", r], ["offset", zo[1]]],
			]),
			layer_points_transform = "key0-to-z"
		)],
		
		for( ym=[-width_chunks/2 + 0.5 : 1/slot_frequency : width_chunks/2 - 0.5] )
		["translate", [0, ym*chunk, -t/2], slot],
	]
);
