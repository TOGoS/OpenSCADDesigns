// SlottedPlate1.0
// 
// A simple slotted plate for attaching 2020 rails or gridbeams or whatever.

chunk_pitch = 20;
size_chunks = [3,3];
slot_size = [12.0, 4.0];

thickness = 4;
alternate_slot_direction = true;

$fn = 20;

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>

togmod1_domodule(
	let(rath2poly = function(rath) togmod1_make_polygon(togpath1_rath_to_polypoints(rath)))
	let(slot = rath2poly(togpath1_make_rectangle_rath(slot_size, corner_ops=[["round", min(slot_size[0],slot_size[1])/2.01]])))
	togmod1_linear_extrude_z([0,thickness], ["difference",
		rath2poly(togpath1_make_rectangle_rath(size_chunks*chunk_pitch, corner_ops=[["round", 3]])),
		
		for( cy=[-size_chunks[1]/2 + 0.5 : 1 : size_chunks[1]/2] )
		for( cx=[-size_chunks[0]/2 + 0.5 : 1 : size_chunks[0]/2] )
		["translate", [cx,cy]*chunk_pitch, ["rotate", [0,0,(alternate_slot_direction?90:0)*(floor(cx)+floor(cy))], slot]],
	])
);
