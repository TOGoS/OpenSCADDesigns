// DrillyMcSandCone0.1
//
// Can I make something that I can stick in the drill
// (or a hex socket which is attached to the drill)
// and can sort of sand down other things?
// Maybe if I sprinkle grit on it?
// Maybe it'll melt itself?

drive_offset = -0.2;
$fn = 144;

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>

function map(f, arr) = [for(i=arr) f(i)];

togmod1_domodule(
	let( cone_d1 = 25.4 )
	let( cone_z0 = 12.7 - 4, cone_z1 = cone_z0 + cone_d1*2/6, cone_z2 = cone_z1 + 1, cone_z3 = cone_z2 + cone_d1/2 )
	// let( hex = togpath1_rath_to_polygon(togpath1_make_polygon_rath($fn=6, r=6.35/cos(30), corner_ops=[["round",1], ["offset", drive_offset]])) )
   ["union",
		tphl1_make_polyhedron_from_layer_function([
			[  0    , -1],
			[  1    ,  0],
			[cone_z1,  0]
		], function(zo) map(
			function(p) [p[0], p[1], zo[0]],
			let( off = drive_offset + zo[1] )
			togpath1_rath_to_polypoints(togpath1_make_polygon_rath($fn=6, r=6.35/cos(30), corner_ops=[["round",max(1,-off*192/128)], ["offset", off]]))
		)),
		tphl1_make_z_cylinder(zds=[[cone_z0, 0], [cone_z1, cone_d1], [cone_z2, cone_d1], [cone_z3, 0]]),
	]
);
