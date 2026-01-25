// EdgeDrillJig2.2
// 
// Has threaded holes, making for a simpler design
// than EdgeDrillJig1.0.
// 
// See also: ../misc/RectangularDonut1.scad / p1882,
// which is the same idea, but on all four sides.
// 
// v2.1:
// - x/y_hole_position are configurable, in case you want them to be
//   somewhere other than half way along their respective leg
// - Option for edge notches, to help you align stuff
// v2.2:
// - x/y_hole_spacing is now configurable

width = "2chunk";
thickness = "3/8inch";

edge_notch_spacing = "1/2inch";
edge_notch_depth   = "0";

x_length = "1+1/2inch";
x_hole_position = "auto";
x_hole_spacing = "1chunk";
x_hole_style = "1-8-UNC";
x_hole_r_offset = "0.2mm";

y_length = "1+1/2inch";
y_hole_position = "auto";
y_hole_spacing = "1chunk";
y_hole_style = "3/4-10-UNC";
y_hole_r_offset = "0.2mm";

$fn = 32;

module __edgedrilljig2__end_params() { }

$togunits1_default_unit = "mm";

use <../lib/TOGMod1.scad>
use <../lib/TOGThreads2.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGUnits1.scad>
use <../lib/TOGVecLib0.scad>

width_mm     = togunits1_to_mm(width);
width_chunks = togunits1_decode(width, unit="chunk");
chunk        = togunits1_to_mm("chunk");
thickness_mm = togunits1_to_mm(thickness);
x_length_mm  = togunits1_to_mm(x_length);
y_length_mm  = togunits1_to_mm(y_length);
x_hole_r_offset_mm = togunits1_to_mm(x_hole_r_offset);
y_hole_r_offset_mm = togunits1_to_mm(y_hole_r_offset);
x_hole_position_mm = x_hole_position == "auto" ? x_length_mm/2 : togunits1_to_mm(x_hole_position);
y_hole_position_mm = y_hole_position == "auto" ? y_length_mm/2 : togunits1_to_mm(y_hole_position);

enat = togunits1_to_mm(edge_notch_spacing);
width_enats = round(width_mm/enat);
edge_notch_depth_mm  = togunits1_to_mm(edge_notch_depth);

togmod1_domodule(
	let( t = thickness_mm )
	let( x1 = x_length_mm, y1 = y_length_mm )
	let( x_hole = togthreads2_make_threads(togthreads2_simple_zparams([[-t/2, 1], [t/2, 1]], 1.6, 3.175), x_hole_style, r_offset=x_hole_r_offset_mm) )
	let( y_hole = togthreads2_make_threads(togthreads2_simple_zparams([[-t/2, 1], [t/2, 1]], 1.6, 3.175), y_hole_style, r_offset=y_hole_r_offset_mm) )
	let( x_hole_z_spacing_unit = togunits1_to_mm(x_hole_spacing) )
	let( y_hole_z_spacing_unit = togunits1_to_mm(y_hole_spacing) )
	["difference",
		let( acops = [["round", t/2]] )
		let( bcops = [["round", t/3]] )
		let( bev   = min(0.8, t/3) )
		let( eno   = edge_notch_depth_mm )
		tphl1_make_polyhedron_from_layer_function([
		   [-width_mm/2      ,  0  , -bev],
		   [-width_mm/2 + bev,  0  ,  0  ],
			if( eno != 0 ) for( zm=[-width_enats/2 + 1 : 1 : width_enats/2-1] ) each [
				[zm*enat - eno,   0  ,  0  ],
				[zm*enat      , -eno ,  0  ],
				[zm*enat + eno,   0  ,  0  ],
			],
		   [ width_mm/2 - bev,  0  ,  0  ],
		   [ width_mm/2      ,  0  , -bev],
		], function(zo) let( z=zo[0], n=zo[1], offset=zo[2] ) togvec0_offset_points(
			togpath1_rath_to_polypoints(togpath1_offset_rath(["togpath1-rath",
				["togpath1-rathnode", [ 0  , 0  ]],
				["togpath1-rathnode", [ 0  ,y1+n], each bcops],
				["togpath1-rathnode", [-t  ,y1+n], each bcops],
				["togpath1-rathnode", [-t  ,-t  ], each acops],
				["togpath1-rathnode", [x1+n,-t  ], each bcops],
				["togpath1-rathnode", [x1+n, 0  ], each bcops],
			], offset)),
			z
		)),
		
		for( z=[-width_mm/2 + x_hole_z_spacing_unit/2 : x_hole_z_spacing_unit : width_mm/2] )
		["translate", [x_hole_position_mm, -t/2, z], ["rotate", [90,0,0], x_hole]],
		
		for( z=[-width_mm/2 + y_hole_z_spacing_unit/2 : y_hole_z_spacing_unit : width_mm/2] )
		["translate", [-t/2, y_hole_position_mm, z], ["rotate", [0,90,0], y_hole]],
	]
);
