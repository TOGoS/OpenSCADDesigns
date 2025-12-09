// DrillyMcSandCone0.2
//
// Can I make something that I can stick in the drill
// (or a hex socket which is attached to the drill)
// and can sort of sand down other things?
// Maybe if I sprinkle grit on it?
// Maybe it'll melt itself?
// 
// v0.2:
// - Slight adjustment to how positions are calculated

drive_diameter = 12.7;
drive_offset = -0.2;
major_diameter = 25.4;
nose_angle = 90;
$fn = 144;

module __drillymcwhatever_end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>

function map(f, arr) = [for(i=arr) f(i)];

togmod1_domodule(
	let( cone_d1 = major_diameter, cone_d3 = 0 )
	let( cone_z0 = drive_diameter * 3/4, cone_z1 = cone_z0 + cone_d1*2/6, cone_z2 = cone_z1 + 1, cone_z3 = cone_z2 + cone_d1*cos(nose_angle/2)/sin(nose_angle/2)/2 )
	// let( hex = togpath1_rath_to_polygon(togpath1_make_polygon_rath($fn=6, r=6.35/cos(30), corner_ops=[["round",1], ["offset", drive_offset]])) )
   ["union",
		// Drive
		tphl1_make_polyhedron_from_layer_function([
			[  0    , -1],
			[  1    ,  0],
			[cone_z1,  0],
			[(cone_z1+cone_z3)/2, -drive_diameter/4],
		], function(zo) map(
			function(p) [p[0], p[1], zo[0]],
			let( off = drive_offset + zo[1] )
			togpath1_rath_to_polypoints(togpath1_make_polygon_rath($fn=6, r=6.35/cos(30), corner_ops=[["round",max(1,-off*192/128)], ["offset", off]]))
		)),

		// Cone
		// Point 4 is the tip, if it were cut off 2mm below point 3
		let( cone_z4 = cone_z3 - 2, cone_d4 = cone_d1 + (cone_d3-cone_d1) * (cone_z4-cone_z2)/(cone_z3-cone_z2) )
		tphl1_make_z_cylinder(zds=[[cone_z0, 0], [cone_z1, cone_d1], [cone_z2, cone_d1], [cone_z4, cone_d4]]),
	]
);
