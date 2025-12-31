// Tubeport3.0
// 
// Idea:
// - Adapter between 1/2" (ID) tubing and 1/4" (OD) tubing,
//   based on (and thread-compatible with) these ones I bought:
//   http://picture-files.nuke24.net/uri-res/raw/urn:bitprint:P24W2T2COKIS2FWD3MZHX2ECAEAV25H6.LVHJ4FYFKLPDT66H2UHM2V3BD35M2MR3PT43BDA/20251103_164301.jpg

$tgx11_offset = -0.15;
$fn = 48;

module __tubeport3__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGThreads2.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGHoleLib2.scad>
use <../lib/TGx11.1Lib.scad>
use <../lib/TOGUnits1.scad>

$togridlib3_unit_table = tgx11_get_default_unit_table();
$togunits1_default_unit = "mm";

qport_thread_style = "3/4-10-UNC";
qport_thread_r_offset =  0.2;
qtube_diameter = 6.35 + 0.5;

function tubeport3_make_block(size) =
let( size_ca = [[round(size[0]/chunk),"chunk"], [round(size[1]/chunk),"chunk"], [size[2],"mm"]] )
["translate", [0,0,-size[2]/2], tgx11_block(size_ca,
	bottom_segmentation = "chunk",
	bottom_foot_bevel = 0.4,
	top_segmentation = "none"
)];

function make_qport_hole(
	port_depth,
	total_depth
) =
let( donut_bevel_mm = 6.35 )
["union",
	["intersection",
		togthreads2_make_threads(
			togthreads2_simple_zparams([[0, 1], [port_depth + donut_bevel_mm, 0]], taper_length=2, inset=1),
			qport_thread_style,
			qport_thread_r_offset
		),
		
		tphl1_make_z_cylinder(zds=[
			[-1                         , qtube_diameter + donut_bevel_mm*2],
			[port_depth                 , qtube_diameter + donut_bevel_mm*2],
			[port_depth + donut_bevel_mm, qtube_diameter                   ],
		]),
	],
	tphl1_make_z_cylinder(zrange=[-2,999], d=qtube_diameter),
];

togmod1_domodule(
	let( qport_depth_mm = togunits1_to_mm("4/8inch") )
	let( u = 254/160 )
	let( head_height = 6.35 )
	let( shaft_length = 19.05 )
	let( hport_threads_length = 254/16 )
	["difference",
		["union",
			tphl1_make_polyhedron_from_layer_function([
				[0     , -u-0.5],
				[0.5   , -u],
				[u     , -u],
				[2*u   ,  0],
				[head_height-1 ,  0],
				[head_height   , -1],
			], function(zo) togpath1_rath_to_polypoints(
				togpath1_make_polygon_rath($fn=8, corner_ops=[["round",3], ["offset",zo[1]+$tgx11_offset]], r=38.1/2/cos(22.5), rotation=22.5)
			), layer_points_transform="key0-to-z" ),
			togthreads2_make_threads(
				togthreads2_simple_zparams([[4, 0], [head_height+shaft_length, -1]], 3, inset=1),
				"1+1/4-7-UNC",
				r_offset = -0.1
			),
			togthreads2_make_threads(
				togthreads2_simple_zparams([[head_height+shaft_length-1, 0], [head_height+shaft_length+hport_threads_length, -1]], 3, inset=1),
				"7/8-10-UNC",
				r_offset = -0.1
			),
			let(z3 = head_height+shaft_length+hport_threads_length)
			let(z4 = z3 + 254/16 )
			tphl1_make_z_cylinder(zds=[
				[z3     , 12],
				[z3 + 10, 12],
				[z3 + 11, 9*u],
				[z4     , 11],
				[z4     ,  9],
				[z4 - 2 ,  5],
			]),
		],
		
		make_qport_hole(qport_depth_mm, 999),
	]
);
