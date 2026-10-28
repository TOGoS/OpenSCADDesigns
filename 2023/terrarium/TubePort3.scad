// Tubeport3.5
// 
// Idea:
// - Adapter between 1/2" (ID) tubing and 1/4" (OD) tubing,
//   based on (and thread-compatible with) these ones I bought:
//   http://picture-files.nuke24.net/uri-res/raw/urn:bitprint:P24W2T2COKIS2FWD3MZHX2ECAEAV25H6.LVHJ4FYFKLPDT66H2UHM2V3BD35M2MR3PT43BDA/20251103_164301.jpg
// 
// v3.1
// - Option to use TubePort4 library instead of own `make_qport_hole`;
//   result should be pretty much identical.
// v3.1.1:
// - Refactoring:
//   - Always use tubeport4_make_qport to make the Q-port
//   - Separate the all-the-way-through hole from the Q-port
// v3.2:
// - top_port can be 'h-barb' (barb for half-inch ID tubing) or 'q-port'
// - shaft_length is now customizable
// v3.3:
// - qport_thread_radius_offset, shaft_thread_radius_offset, and
//   hbarb_thread_radius_offset are now all customizable
// v3.3.1:
// - Use tubeport4_make_hbarb for generating the H-barb
// v3.4:
// - Options to omit shaft and head
// - Options for midriff cuts
// v3.5:
// - Fix generation of H-barb threads when they start at z != 0

top_port = "h-barb"; // ["h-barb", "q-port"]
bottom_port = "q-port"; // ["q-port", "straight"]
head_height = "1/4inch";
shaft_length = "3/4inch";
qport_thread_radius_offset = "0.2mm";
shaft_thread_radius_offset = "-0.1mm";

hbarb_thread_radius_offset = "-0.1mm";
hbarb_thread_length = "254/16mm";

midriff_width = "infinity";
midriff_z0 = "1/4inch";
midriff_z1 = "2/4inch";

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
use <../lib/TubePort4.scad>

$togridlib3_unit_table = tgx11_get_default_unit_table();
$togunits1_default_unit = "mm";

qport_thread_style = "3/4-10-UNC";
qport_thread_r_offset_mm = togunits1_to_mm(qport_thread_radius_offset);
shaft_thread_r_offset_mm = togunits1_to_mm(shaft_thread_radius_offset);
hbarb_thread_r_offset_mm = togunits1_to_mm(hbarb_thread_radius_offset);
hbarb_thread_length_mm = togunits1_to_mm(hbarb_thread_length);
qtube_diameter = 6.35 + 0.5;

midriff_width_mm = midriff_width == "infinity" ? 100 : togunits1_to_mm(midriff_width);
midriff_z0_mm = togunits1_to_mm(midriff_z0);
midriff_z1_mm = togunits1_to_mm(midriff_z1);

function tubeport3_make_block(size) =
let( size_ca = [[round(size[0]/chunk),"chunk"], [round(size[1]/chunk),"chunk"], [size[2],"mm"]] )
["translate", [0,0,-size[2]/2], tgx11_block(size_ca,
	bottom_segmentation = "chunk",
	bottom_foot_bevel = 0.4,
	top_segmentation = "none"
)];

togmod1_domodule(
	let( qport_depth_mm = togunits1_to_mm("4/8inch") )
	let( u = 254/160 )
	let( head_height = togunits1_decode(head_height, unit="mm") )
	let( shaft_length = togunits1_decode(shaft_length, unit="mm") )
	let( qport = ["render",
		tubeport4_make_qport(depth=qport_depth_mm, thread_style=qport_thread_style, thread_r_offset=qport_thread_r_offset_mm, outer_diameter=19.55),
	])
	let( pzart0 =  ["difference",
		["union",
			if( head_height > 0 ) tphl1_make_polyhedron_from_layer_function(
				head_height > 3*u ? [
					[0             , -u-0.5],
					[0.5           , -u    ],
					[u             , -u    ],
					[2*u           ,  0    ],
					[head_height-1 ,  0    ],
					[head_height   , -1    ],
				] : [
					[0             ,  0    ],
					[head_height   ,  0    ],
				],
				function(zo) togpath1_rath_to_polypoints(
					togpath1_make_polygon_rath($fn=8, corner_ops=[["round",3], ["offset",zo[1]+$tgx11_offset]], r=38.1/2/cos(22.5), rotation=22.5)
				),
				layer_points_transform="key0-to-z"
			),
			
			if( shaft_length > 0 ) togthreads2_make_threads(
				togthreads2_simple_zparams([[4, 0], [head_height+shaft_length, -1]], 3, inset=1),
				"1+1/4-7-UNC",
				r_offset = shaft_thread_r_offset_mm
			),
			
			each top_port == "h-barb" ? [
				// Do our own threads instead of leaving it to tubeport4_make_hbarb
				// so we can do weird things to it
				let(hbarb_z0 = head_height+shaft_length)
				togthreads2_make_threads(
					togthreads2_simple_zparams([[max(0, hbarb_z0-1), hbarb_z0 == 0 ? -1 : 0], [hbarb_z0+hbarb_thread_length_mm, -1]], 3, inset=1),
					"7/8-10-UNC",
					r_offset = hbarb_thread_r_offset_mm
				),
				["translate",
					[0, 0, head_height+shaft_length+hbarb_thread_length_mm],
					tubeport4_make_hbarb(
						hbarb_thread_length = 0,
						hbarb_thread_r_offset = hbarb_thread_r_offset_mm
					)
				]
			] : []
		],
		
		tphl1_make_z_cylinder(zrange=[-2,200], d=qtube_diameter),
		
		each bottom_port == "q-port" ? [
			["rotate", [180,0,0], qport],
		] : [],
		
		each top_port == "q-port" ? [
			["translate", [0,0,head_height + shaft_length], qport],
		] : [],
	])
	// TODO: Large parts may require not hardcoding '100' for various things
	let( pzart1 = midriff_width_mm >= 100 ? pzart0 :
		["intersection", pzart0, togmod1_linear_extrude_y([-100,100],
			let( x1 = midriff_width_mm/2 )
			togmod1_make_polygon([
				[ x1 + 100, midriff_z0_mm - 50],
				[ x1      , midriff_z0_mm],
				[ x1      , midriff_z1_mm],
				[ x1 + 100, midriff_z1_mm + 50],
				[ x1 + 100, midriff_z1_mm + 100],
				[-x1 - 100, midriff_z1_mm + 100],
				[-x1 - 100, midriff_z1_mm + 50],
				[-x1      , midriff_z1_mm],
				[-x1      , midriff_z0_mm],
				[-x1 - 100, midriff_z0_mm - 50],
			])
		)]
	)
	pzart1
);
