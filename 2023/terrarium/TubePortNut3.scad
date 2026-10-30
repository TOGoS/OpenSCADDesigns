// TubePortNut3.0
// 
// v3.1:
// - Shape more configurable

nut_width = "1.5inch";
inner_thread_radius_offset = "0.2mm";
bottom_shape = "footed"; // ["footed", "straight"]
top_shape = "footed"; // ["footed", "straight"]
edge_bevel = "0.5mm";
cavity_diameter = "1inch";
$tgx11_offset = -0.15;
$fn = 48;

cross_section = false;

module __tubeport3nut__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGThreads2.scad>
use <../lib/TOGUnits1.scad>

nut_width_mm       = togunits1_to_mm(nut_width      );
edge_bevel_mm      = togunits1_to_mm(edge_bevel     );
cavity_diameter_mm = togunits1_to_mm(cavity_diameter);
inner_thread_radius_offset_mm = togunits1_to_mm(inner_thread_radius_offset);

togmod1_domodule(
	let( nut_height_mm = 25.4 )
	let( thread_length_mm = min(nut_height_mm/2, 12.7) )
	let( u = 254/160 )
	let( eb = edge_bevel_mm )
	["difference",
		["union",
			tphl1_make_polyhedron_from_layer_function([
				each bottom_shape == "footed" ? [
					[              0     , -u-eb ],
					[              eb    , -u    ],
					[              u     , -u    ],
					[              2*u   ,  0    ],
				] : [
					[              0     ,  0-eb ],
					[              eb    ,  0    ],
				],
				each top_shape == "footed" ? [
					[nut_height_mm-2*u   ,  0    ],
					[nut_height_mm-u     , -u    ],
					[nut_height_mm-eb    , -u    ],
					[nut_height_mm-0     , -u-eb ],
				] : [
					[nut_height_mm-eb    ,  0    ],
					[nut_height_mm-0     ,  0-eb ],
				],
			], function(zo) togpath1_rath_to_polypoints(
				togpath1_make_polygon_rath($fn=8, corner_ops=[["round",3], ["offset",zo[1]+$tgx11_offset]], r=nut_width_mm/2/cos(22.5), rotation=22.5)
			), layer_points_transform="key0-to-z" ),
		],
		
		["union",
			togthreads2_make_threads(
				togthreads2_simple_zparams([[0, 1], [thread_length_mm, 1]], extend=3, taper_length=1.5, inset=1),
				"7/8-10-UNC",
				r_offset = inner_thread_radius_offset_mm
			),
			let(
				cz0 = thread_length_mm-6, // Bottom tip
				cz1 = thread_length_mm  , // Top of threads
				cz2 = nut_height_mm-3-(cavity_diameter_mm - 16.5)/2, // Bottom of top bevel
				cz3 =    nut_height_mm-3, // Top of top bevel
				cz4 =    nut_height_mm+1  // A bit beyond the top
			)
			tphl1_make_z_cylinder(zds=[
				// TODO: Some intersecting or other cleverness to make sure Zs are in order
				[cz0, cavity_diameter_mm-12],
				[cz1, cavity_diameter_mm],
				[cz2, cavity_diameter_mm],
				[cz3, 16.5],
				[cz4, 16.5],
			])
		],
		
		if( cross_section ) ["translate", [-50,-50,0], togmod1_make_cuboid([100,100,200])],
	]
);
