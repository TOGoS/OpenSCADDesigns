// HotLampPanelAdapter-v0.1
// 
// For attaching stuff to the stem of the hot yellow floor lamp in the farmhouse
// 
// Measurements:
// Bars are ~67.6mm apart, and 11.4mm thick

chunk_pitch = 38.1;
hull_size_chunks = [3,3];
hull_thickness = 9.525;

hole_spacing_chunks = 1;
main_hole_diameter = 8;
alt_hole_diameter = 5;

post_groove_diameter = 12;
post_groove_spacing  = 67.6;
post_groove_z_adjust =  1;

module __lampmount__end_params() { }

inch = 25.4;
hull_size = [hull_size_chunks[0] * chunk_pitch, hull_size_chunks[1]*chunk_pitch, hull_thickness];

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>

function segs_(space, margin, index=0) = [
	if( space[0] + margin <= space[1] - margin ) [space[0]+margin, space[1]-margin]
];

function segs(spaces, margin) = [
	for( space=spaces ) each segs_(space, margin)
];

function roundto(x, divisor) = round(x/divisor)*divisor;

$fn = $preview ? 16 : 64;

//slot_polypoints = togpath1_qath_to_polypoints(togpath1_polyline_to_qath([[-20,0], [20,0]], hole_diameter/2));
//
//hole =
//	// tphl1_make_z_cylinder( 8, zrange=[-1, hull_size[2]+1] );
//	tphl1_extrude_polypoints([-1, hull_size[2]+1], slot_polypoints);

flat_spaces = [
	[-hull_size[0]/2, -post_groove_spacing/2-post_groove_diameter/2],
	[-post_groove_spacing/2+post_groove_diameter/2, post_groove_spacing/2-post_groove_diameter/2],
	[ post_groove_spacing/2+post_groove_diameter/2, hull_size[0]/2],
];

function make_slot_row(slot_diameter) =
let( slot_spans = segs(flat_spaces, 4 + slot_diameter/2))
["union",
	if( slot_diameter > 0 ) for( span=slot_spans ) tphl1_extrude_polypoints([-1, hull_size[2]+1],
		togpath1_qath_to_polypoints(togpath1_polyline_to_qath([[span[0],0], [span[1],0]], slot_diameter/2))
	)
];

main_slot_row = make_slot_row(main_hole_diameter);
alt_slot_row = make_slot_row(alt_hole_diameter);

main = ["difference",
	["translate", [0,0,hull_size[2]/2], tphl1_make_rounded_cuboid(hull_size, [6,6,2], corner_shape="ovoid1")],
	for( xm=[-1,1] ) ["translate", [xm*post_groove_spacing/2, 0, hull_size[2]+post_groove_z_adjust],
		["rotate", [90,0,0],
			tphl1_make_z_cylinder(d=post_groove_diameter, zrange=[-hull_size[1],hull_size[1]])]],
	for( ym=[roundto(-hull_size[1]/2/chunk_pitch, 0.5) + 0.5 : hole_spacing_chunks : hull_size[1]/2/chunk_pitch-0.4] )
		["translate", [0,ym*chunk_pitch,0], main_slot_row],
	for( ym=[roundto(-hull_size[1]/2/chunk_pitch, 0.5) + 1 : hole_spacing_chunks : hull_size[1]/2/chunk_pitch-0.9] )
		["translate", [0,ym*chunk_pitch,0], alt_slot_row],
];

togmod1_domodule(main);
