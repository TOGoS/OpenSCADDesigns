// P2332Like v1.0
// 
// A rounded rectangular frame.
// Maybe use it as a spacer?

use <../lib/TOGMod1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>

width_mm = 114.3;
height_mm = 114.3;
thickness_mm = 6.35;
frame_width_mm = 19.05;

togmod1_domodule(
	let( frame_xz_rath = togpath1_make_rectangle_rath([frame_width_mm, thickness_mm], corner_ops=[["round", min(frame_width_mm, thickness_mm)*127/256]]) )
	let( frame_xz_points = togpath1_rath_to_polypoints(frame_xz_rath, $fn=24) )
	tphl1_make_polyhedron_from_layer_function(
		[
			each frame_xz_points,
			frame_xz_points[0],
		],
		function(fxz) togpath1_rath_to_polypoints(
			togpath1_make_rectangle_rath([width_mm-frame_width_mm, height_mm-frame_width_mm], corner_ops=[
				["round", frame_width_mm*129/256],
				["offset", fxz[0]],
			]), $fn=96
		),
		cap_bottom = false,
		cap_top    = false,
		layer_points_transform = "key1-to-z"
	)
);
