// P2565Like1.1
// 
// A block with threaded holes staggerdly-positioned

lip_height = 1.5;
$fn = 32;
$tgx11_offset = -0.1;
length = "4inch";
width  = "1chunk";
height = "1chunk";

module p2565like__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TGx11.1Lib.scad>
use <../lib/TOGThreads2.scad>
use <../lib/TOGUnits1.scad>
use <../lib/TOGArrayLib1.scad>
use <../lib/TOGPolyhedronLib1.scad>

$togridlib3_unit_table = tgx11_get_default_unit_table();

block_size_ca = togunits1_vec_to_cas([length, width, height]);
block_size_mm = togunits1_vec_to_mms(block_size_ca);

hole_spacing_mm = 19.05;
top_z = togunits1_to_mm(block_size_ca[2]);
hole =
	let( floor_z = 6.35 )
	["render", ["union",
		togthreads2_make_threads(
			togthreads2_simple_zparams([[floor_z, 0], [top_z, 1]], taper_length=1, inset=4),
			"3/4-10-UNC",
			r_offset = 0.2
		),
		
		let( bhd = 9.525 )
		let( bot_bev = 2.54 )
		tphl1_make_z_cylinder(zds=[
			[     -1  , bhd + 2 * (1 + bot_bev)],
			[  bot_bev, bhd                    ],
			[floor_z-1, bhd + 2 * 1            ],
			[floor_z+1, bhd                    ],
		])
	]];

function median(numbers) =
	let( min_val = tal1_reduce(+9999, numbers, function(a,b) min(a,b)) )
	let( max_val = tal1_reduce(-9999, numbers, function(a,b) max(a,b)) )
	(max_val + min_val) / 2;
function center(numbers) =
	let( med = median(numbers) )
	[
		for( n=numbers ) n - med
	];

hole_proto_x = [-block_size_mm[0]/2 + hole_spacing_mm/2 + 2 : hole_spacing_mm : block_size_mm[0]/2 - hole_spacing_mm/2 - 2];
hole_x_positions = center([each hole_proto_x]); // for now
hole_positions = [
	for( i = [0 : 1 : len(hole_x_positions)-1] )
	[hole_x_positions[i], [-hole_spacing_mm/2 + 2, hole_spacing_mm/2-2][i % 2]]
];

togmod1_domodule(
	["difference",
		tgx11_block(
			block_size_ca,
			bottom_segmentation = "atom",
			bottom_v6hc_style = "none",
			top_segmentation = "block",
			bottom_foot_bevel = 0.4,
			lip_height = lip_height
		),
		
		for( pos=hole_positions )
		["translate", pos, hole],
	]
);
