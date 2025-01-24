// Spacer1.0
// 
// Spacer with adjustable size and counterbored holes
// and TOGridPile-beveled corners.

size_chunks = [1,2];
thickness = 6.35;
chunk_hole_style = "THL-1006";
outer_offset = -0.2;
$fn = 72;

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGHoleLib2.scad>
use <../lib/TOGPath1.scad>

togmod1_domodule(
	let(chunk = 38.1, bevel=3.175, round=3.175)
	let(hull_2d = togmod1_make_polygon(togpath1_rath_to_polypoints(togpath1_make_rectangle_rath(size_chunks*chunk,
		corner_ops=[["bevel", bevel], ["round", round], ["offset", outer_offset]]))))
	let(chunk_hole = tog_holelib2_hole(chunk_hole_style, depth=thickness*2))
	["difference",
		togmod1_linear_extrude_z([0, thickness], hull_2d),
		
		for( ym=[-size_chunks[1]/2 + 0.5 : 1 : size_chunks[1]/2] )
		for( xm=[-size_chunks[0]/2 + 0.5 : 1 : size_chunks[0]/2] )
		["translate", [xm*chunk, ym*chunk, thickness], chunk_hole],
	]
);
