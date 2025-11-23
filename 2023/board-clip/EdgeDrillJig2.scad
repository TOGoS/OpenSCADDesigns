// EdgeDrillJig2.0
// 
// Has threaded holes, making for a simpler design
// than EdgeDrillJig1.0.
// 
// See also: ../misc/RectangularDonut1.scad / p1882,
// which is the same idea, but on all four sides.

width = "2chunk";
thickness = "3/8inch";
x_length = "1+1/2inch";
y_length = "1+1/2inch";
x_hole_style = "1-8-UNC";
x_hole_r_offset = "0.2mm";
y_hole_style = "3/4-10-UNC";
y_hole_r_offset = "0.2mm";
$fn = 32;

module __edgedrilljig2__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGThreads2.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGUnits1.scad>
use <../lib/TOGVecLib0.scad>

width_mm     = togunits1_to_mm(width);
width_chunks = togunits1_decode(width, unit="chunk");
chunk        = togunits1_to_mm("chunk");
thickness_mm = togunits1_to_mm(thickness);
x_hole_r_offset_mm = togunits1_to_mm(x_hole_r_offset);
y_hole_r_offset_mm = togunits1_to_mm(y_hole_r_offset);

togmod1_domodule(
	let( t = thickness_mm )
	let( x1 = togunits1_to_mm(x_length), y1 = togunits1_to_mm(y_length) )
	let( x_hole = togthreads2_make_threads(togthreads2_simple_zparams([[-t/2, 1], [t/2, 1]], 1.6, 1), x_hole_style, r_offset=x_hole_r_offset_mm) )
	let( y_hole = togthreads2_make_threads(togthreads2_simple_zparams([[-t/2, 1], [t/2, 1]], 1.6, 1), y_hole_style, r_offset=y_hole_r_offset_mm) )
	["difference",
		let( acops = [["round", t/2]] )
		let( bcops = [["round", t/3]] )
		let( bev   = min(0.8, t/3) )
		tphl1_make_polyhedron_from_layer_function([
		   [-width_mm/2      , -bev],
		   [-width_mm/2 + bev,  0  ],
		   [ width_mm/2 - bev,  0  ],
		   [ width_mm/2      , -bev],
		], function(zo) togvec0_offset_points(
			togpath1_rath_to_polypoints(togpath1_offset_rath(["togpath1-rath",
				["togpath1-rathnode", [ 0, 0]],
				["togpath1-rathnode", [ 0,y1], each bcops],
				["togpath1-rathnode", [-t,y1], each bcops],
				["togpath1-rathnode", [-t,-t], each acops],
				["togpath1-rathnode", [x1,-t], each bcops],
				["togpath1-rathnode", [x1, 0], each bcops],
			], zo[1])),
			zo[0]
		)),
		
		for( zm=[-width_chunks/2+0.5 : 1 : width_chunks/2-0.5] )
		for( pr = [
			[[x1/2, -t/2, zm*chunk], [90,0,0], x_hole],
			[[-t/2, y1/2, zm*chunk], [0,90,0], y_hole],
		] )
		["translate", pr[0], ["rotate", pr[1], pr[2]]],
	]
);
