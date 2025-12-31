// TubePortNut3.0

inner_thread_radius_offset = 0.2;
$tgx11_offset = -0.15;
$fn = 48;

module __tubeport3nut__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGThreads2.scad>
use <../lib/TOGUnits1.scad>

togmod1_domodule(
	let( nut_height_mm = 25.4 )
	let( thread_length_mm = min(nut_height_mm/2, 12.7) )
	let( u = 254/160 )
	["difference",
		["union",
			tphl1_make_polyhedron_from_layer_function([
				[              0     , -u-0.5],
				[              0.5   , -u],
				[              u     , -u],
				[              2*u   ,  0],
				[nut_height_mm-2*u   ,  0],
				[nut_height_mm-u     , -u],
				[nut_height_mm-0.5   , -u],
				[nut_height_mm-0     , -u-0.5],
			], function(zo) togpath1_rath_to_polypoints(
				togpath1_make_polygon_rath($fn=8, corner_ops=[["round",3], ["offset",zo[1]+$tgx11_offset]], r=38.1/2/cos(22.5), rotation=22.5)
			), layer_points_transform="key0-to-z" ),
		],
		
		["union",
			togthreads2_make_threads(
				togthreads2_simple_zparams([[0, 1], [thread_length_mm, 1]], extend=3, taper_length=1.5, inset=1),
				"7/8-10-UNC",
				r_offset = inner_thread_radius_offset
			),
			tphl1_make_z_cylinder(zds=[
				// TODO: Some intersecting or other cleverness to make sure Zs are in order
				[thread_length_mm-6  , 25.4-12],
				[thread_length_mm    , 25.4],
				[   nut_height_mm-7.5, 25.4],
				[   nut_height_mm-3  , 16.5],
				[   nut_height_mm+1  , 16.5],
			])
		]
	]
);
