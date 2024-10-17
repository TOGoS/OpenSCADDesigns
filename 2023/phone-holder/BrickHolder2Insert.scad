// BrickHolder2Insert v2.1
// 
// v2.1:
// - Fix offsets by multiplying by 2 and by u where appropriate

outer_offset = -0.1;
$fn = 64;

use <../lib/TOGridLib3.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGVecLib0.scad>

togmod1_domodule(["difference",
	tphl1_make_polyhedron_from_layer_function([
		[0, -5],
		[1, -4],
		[4, -4],
		[4, -1],
		[5,  0],
		[8,  0]
	], function(zo)
		let(atom = togridlib3_decode([1,"atom"]))
		let(u = togridlib3_decode([1,"u"]))
		let(rath = togpath1_make_rectangle_rath(
			[5*atom + zo[1]*2*u + outer_offset*2, 5*atom + zo[1]*2*u + outer_offset*2],
			corner_ops = [["round", 4*u]]
		))
		togvec0_offset_points(togpath1_rath_to_polypoints(rath), zo[0]*u)
	)
]);
