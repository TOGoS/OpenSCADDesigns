// PencilSlot0.2
// 
// Changes:
// v0.1:
// - 2mm tip hole
// v0.2:
// - 3mm tip hole
// - Add slot

$fn = $preview ? 24 : 64;

use <../lib/TOGMod1.scad>
use <../lib/TOGVecLib0.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>

slab_thickness = 3.175;
pencil_hole_tip_diameter = 3;

slab = tphl1_make_rounded_cuboid([19.05, 19.05, slab_thickness], r=[6.35, 6.35, slab_thickness/2-0.3], corner_shape="ovoid1");

function profiled_polyline_to_polyhedron(points, zds) =
	tphl1_make_polyhedron_from_layer_function(zds, function(zd)
		let(rath = togpath1_polyline_to_rath(points, r=zd[1]/2, end_shape="round"))
		let(polypoints = togpath1_rath_to_polypoints(rath))
		togvec0_offset_points(polypoints, zd[0]));

pencil_hole_zds = [
	[-1, pencil_hole_tip_diameter+0],
	[ 2, pencil_hole_tip_diameter+0],
	[ 8, pencil_hole_tip_diameter+6],
];

pencil_hole = tphl1_make_z_cylinder(zds = pencil_hole_zds);

pencil_slot = profiled_polyline_to_polyhedron([
	[-3.18,-6.35],
	[ 3.18, 6.35],
], pencil_hole_zds);

togmod1_domodule(["difference",
	["translate", [0,0,slab_thickness/2], slab],
	pencil_slot,
	["translate", [4.7625, -3.175, 0], pencil_hole],
]);
