// ThreadedGridbeamFoot1.0
// 
// It's just a 2+1/2-4-UNC bolt
// with square pocket in the top for a gridbeam.

height = "2inch";
floor_thickness = "1/2inch";
outer_thread_radius_offset = "-0.2mm";
inner_surface_offset = "-0.3mm";
$tgx11_offset = -0.1;
$fn = 48;

module __aslkdjnasd__end_params() { }

use <../lib/TGx11.1Lib.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGThreads2.scad>
use <../lib/TOGUnits1.scad>

$togridlib3_unit_table = tgx11_get_default_unit_table();

height_ca                     = togunits1_to_ca(height                    );
height_mm                     = togunits1_to_mm(height                    );
floor_thickness_mm            = togunits1_to_mm(floor_thickness           );
inner_surface_offset_mm       = togunits1_to_mm(inner_surface_offset      );
outer_thread_radius_offset_mm = togunits1_to_mm(outer_thread_radius_offset);

togmod1_domodule(
	let( drainage_hole_positions = [[0,0]] ) // [for(xm=[-1,1]) for(ym=[-1,1]) [xm*38.1/4, ym*38.1/4]] )
	let( drainage_hole = tphl1_make_z_cylinder(zds=[
		[                  -1, 9+6],
		[                   2, 9  ],
		[floor_thickness_mm-3, 9  ],
		[floor_thickness_mm+1, 9+6],
	]))
	["difference",
		["intersection",
			tgx11_block(
				[[2, "chunk"], [2, "chunk"], height_ca],
				bottom_segmentation = "chunk",
				top_segmentation = "chunk",
				bottom_foot_bevel = 0.4,
				bottom_v6hc_style = "none",
				top_foot_bevel = 0.4,
				top_v6hc_style = "none",
				lip_height = -1
			),
			togthreads2_make_threads(
				togthreads2_simple_zparams([[0, -1], [height_mm, -1]], taper_length=2, extend=0, inset=2),
				"2+1/2-4-UNC",
				r_offset = outer_thread_radius_offset_mm
			)
		],
		
		tphl1_make_polyhedron_from_layer_function(
			let( bev=3.175 )
			[
				[floor_thickness_mm, -inner_surface_offset_mm],
				[height_mm - bev   , -inner_surface_offset_mm],
				[height_mm + bev   , -inner_surface_offset_mm + bev*2],
			],
			function(zo) togpath1_rath_to_polypoints(
				togpath1_make_rectangle_rath([38.1, 38.1], corner_ops = [
					["round", -inner_surface_offset_mm],
					["offset", zo[1]]
				])
			),
			layer_points_transform="key0-to-z"
		),
		for( pos=drainage_hole_positions )
		["translate", pos, drainage_hole]
	]
);
