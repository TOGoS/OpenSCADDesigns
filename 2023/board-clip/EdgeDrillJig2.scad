// EdgeDrillJig2.3
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
// v2.3:
// - x/y_hole_position = "auto" will give one hole per chunk if arm is longer than one chunk
// - x_hole_x_frequency, y_hole_y_frequency, x_hole_z_frequency, and y_hole_z_frequency
//   can all be set to e.g. 2 to put holes between the other holes
//   without changing the position of the first and last.
// - It is apparent now that 'position' and 'spacing' without indicating axis
//   were bad names for variables.  I think NarrowBeam0's naming,
//   with explicit 'x/y_spacing' would be the way to go for EdgeDrillJig3,
//   but keeping 'frequency' separate from 'spacing' to allow for
//   doubling without missing chunk centers.

width = "2chunk";
thickness = "3/8inch";

edge_notch_spacing = "1/2inch";
edge_notch_depth   = "0";

// Length of X arm
x_length = "1+1/2inch";
// Position of X-arm holes along X axis; 'auto' for centered or per chunk, depending on length
x_hole_position = "auto";
// Frequency of holes in between first and last
x_hole_x_frequency = 1;
// Spacing of X-arm holes along Z axis
x_hole_spacing = "1chunk";
x_hole_z_frequency = 1;
x_hole_style = "1-8-UNC";
x_hole_r_offset = "0.2mm";

// Length of Y arm
y_length = "1+1/2inch";
// Position of Y-arm holes along Y axis; 'auto' for centered or per chunk, depending on length
y_hole_position = "auto";
// Frequency of holes in between first and last
y_hole_y_frequency = 1;
// Spacing of Y-arm holes along Z axis
y_hole_spacing = "1chunk";
y_hole_z_frequency = 1;
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

function along_arm_positions(arm_length, chunk, freq) =
	arm_length <= chunk ? [arm_length/2] :
	let(arm_length_chunks = arm_length/chunk)
	[for(x=[0.5 : 1/freq : arm_length_chunks-0.4]) x*chunk];

chunk        = togunits1_to_mm("chunk");
width_mm     = togunits1_to_mm(width);
width_chunks = togunits1_decode(width, unit="chunk");
thickness_mm = togunits1_to_mm(thickness);
x_length_mm  = togunits1_to_mm(x_length);
y_length_mm  = togunits1_to_mm(y_length);
x_hole_r_offset_mm = togunits1_to_mm(x_hole_r_offset);
y_hole_r_offset_mm = togunits1_to_mm(y_hole_r_offset);
x_hole_positions_mm = x_hole_position == "auto" ? along_arm_positions(x_length_mm, chunk, x_hole_x_frequency) : [togunits1_to_mm(x_hole_position)];
y_hole_positions_mm = y_hole_position == "auto" ? along_arm_positions(y_length_mm, chunk, y_hole_y_frequency) : togunits1_to_mm(y_hole_position);

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
		
		for( z=[-width_mm/2 + x_hole_z_spacing_unit/2 : x_hole_z_spacing_unit/x_hole_z_frequency : width_mm/2-0.1] )
		for( x=x_hole_positions_mm )
		["translate", [x, -t/2, z], ["rotate", [90,0,0], x_hole]],
		
		for( z=[-width_mm/2 + y_hole_z_spacing_unit/2 : y_hole_z_spacing_unit/y_hole_z_frequency : width_mm/2-0.1] )
		for( y=y_hole_positions_mm )
		["translate", [-t/2, y, z], ["rotate", [0,90,0], y_hole]],
	]
);
