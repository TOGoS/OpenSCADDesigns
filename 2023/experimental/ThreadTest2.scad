// ThreadTest2.1
// 
// A bar with threaded holes generated with different r_offsets.
// Comes with labels for each hole and for the block!
// 
// Versions:
// v2.0:
// - defaults equivalent to p1859
// v2.1:
// - Additional option for text thickening
// - Include thread type in bottom label
// - No text on bottom

threads = "#6-32-UNC";
block_width = 19.05;
block_thickness = 6.35;
offsets = [0.00, 0.050, 0.10, 0.15, 0.20, 0.25, 0.30];
label = "p1859";
text_size = 4;
text_font = "Prototype";
text_thickening = 0.00; // 0.1
$tgx11_offset = -0.01;
$togthreads2_polyhedron_algorithm = "v3";
preview_fn = 16;
render_fn = 64;

module threadtest2__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGThreads2.scad>
use <../lib/Prototype.ttf>

$fn = $preview ? preview_fn : render_fn;

togmod1_domodule(
	let( hole_spacing = block_width*2/3 )
	let( block_size = [block_width + hole_spacing * (len(offsets)-1) , block_width, block_thickness] )
	echo( block_size = block_size )
	let( block_label = togmod1_linear_extrude_z( [-0.6, +0.6],
		["offset-ds", text_thickening, togmod1_text(str(label, "   ", threads, "   ", "$fn = ", $fn), text_size, text_font, halign="center", valign="center")]
	))
	["difference",
		togmod1_linear_extrude_z([0, block_thickness], togpath1_make_rounded_beveled_rect(block_size, 3.175, 3.175, $tgx11_offset)),
		
		for( i=[0 : 1 : len(offsets)-1] )
		let( xm = i - len(offsets)/2 + 0.5 )
		let( x = xm * hole_spacing )
		let( r_offset = offsets[i] )
		let( hole_label = togmod1_linear_extrude_z( [-0.6, +0.6],
			["offset-ds", text_thickening, togmod1_text(str(r_offset), text_size, text_font, halign="center", valign="center")]
		))
		["union",
			["translate", [x, 0, 0],
				["render", togthreads2_make_threads(
					togthreads2_simple_zparams([[0, 1], [block_thickness, 1]], 0.2),
					threads,
					r_offset = r_offset,
					end_mode = "blunt"
				)]
			],
			["translate", [x, block_width*3/10, block_thickness], hole_label],
			// ["translate", [x, block_width*3/10, 0], ["rotate", [0,180,0], hole_label]],
		],
		
		["translate", [0, -block_width*3/10, block_thickness], block_label],
		// ["translate", [0, -block_width*3/10, 0], ["rotate", [0,180,0], block_label]],
	]
);
