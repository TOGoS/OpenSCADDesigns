// ThreadedGridbeamFoot2.0
// 
// A block with a 2+1/2-4-UNC hole through the middle.

height = "3inch";
width = "3inch";
inner_thread_radius_offset = "0.2mm";
$tgx11_offset = -0.1;
$fn = 48;

module __aslkdjnasd__end_params() { }

use <../lib/TGx11.1Lib.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGThreads2.scad>
use <../lib/TOGUnits1.scad>
use <../lib/ChunkBeam2Lib.scad>

$togridlib3_unit_table = tgx11_get_default_unit_table();

height_ca                     = togunits1_to_ca(height                    );
height_chunks                 = togunits1_decode(height,      unit="chunk");
height_mm                     = togunits1_to_mm(height                    );
width_mm                      = togunits1_to_mm(width                     );
width_chunks                  = togunits1_decode(width,       unit="chunk");
inner_thread_radius_offset_mm = togunits1_to_mm(inner_thread_radius_offset);

chunk = togunits1_to_mm("chunk");
chunk_column = chunkbeam2_make_chunkbeam_hull(height_chunks);

togmod1_domodule(
	let( core_inset_mm = 3.25 )
	["difference",
		["union",
			for( xm=[-width_chunks/2+0.5 : 1 : width_chunks/2-0.5] )
			for( ym=[-width_chunks/2+0.5 : 1 : width_chunks/2-0.5] )
			["translate", [xm*chunk,ym*chunk,0], chunk_column],
			
			togmod1_linear_extrude_z([-height_mm/2+core_inset_mm, height_mm/2-core_inset_mm],
				togmod1_make_rounded_rect([width_mm-core_inset_mm*2, width_mm-core_inset_mm*2, ], r=core_inset_mm)
			),
		],
		
		togthreads2_make_threads(
			togthreads2_simple_zparams([[-height_mm/2, 1], [height_mm/2, 1]], taper_length=3, extend=1, inset=3),
			"2+1/2-4-UNC",
			r_offset = inner_thread_radius_offset_mm
		),
	]
);
