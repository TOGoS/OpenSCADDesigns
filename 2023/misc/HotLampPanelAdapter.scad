// HotLampPanelAdapter-v0.2
// 
// For attaching stuff to the stem of the hot yellow floor lamp in the farmhouse
// 
// Measurements:
// Bars are ~67.6mm apart, and 11.4mm thick
// 
// v0.2:
// - Add counterbore option (when *_counterbore_diameter is != *hole_diameter)
// - Flip the whole thing so that any counterbores will print nicely

chunk_pitch = 38.1;
hull_size_chunks = [3,3];
// 9.525 = 3/8"
hull_thickness = 9.525;

hole_spacing_chunks = 1;
main_hole_diameter = 8;
main_counterbore_diameter = 8;
alt_hole_diameter = 5;
alt_counterbore_diameter = 5;

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

function hlpa_flat_spaces(eff_groove_diameter) = [
	[-hull_size[0]/2, -post_groove_spacing/2-eff_groove_diameter/2],
	[-post_groove_spacing/2+eff_groove_diameter/2, post_groove_spacing/2-eff_groove_diameter/2],
	[ post_groove_spacing/2+eff_groove_diameter/2, hull_size[0]/2],
];

// I started making a separate list of back_flat_spaces
// for the counterbores, which...might be just fine,
// but will require doing make_slot_row differently,
// either by being smarter about span and radius for each layer,
// or maybe just by making each slot an intersection of two.
front_flat_spaces = hlpa_flat_spaces(post_groove_diameter);

function hlpa__coalesce(a, b) = !is_undef(a) ? a : b;

function make_slot_row(slot_diameter, counterbore_diameter=undef, counterbore_depth=undef) =
let( eff_cb_diam  = hlpa__coalesce(counterbore_diameter, slot_diameter) )
let( eff_cb_depth = hlpa__coalesce(counterbore_depth, slot_diameter/2) )
let( slot_spans = segs(front_flat_spaces, 4 + eff_cb_diam/2))
let( zds =
	eff_cb_diam == slot_diameter ? [[-1,slot_diameter], [hull_size[2]+1, slot_diameter]] :
	[[                         -1,  eff_cb_diam],
	 [             eff_cb_depth  ,  eff_cb_diam],
	 [             eff_cb_depth  ,slot_diameter],
	 [hull_size[2]             +1,slot_diameter]]
)
["union",
	if( slot_diameter > 0 ) for( span=slot_spans )
		tphl1_make_polyhedron_from_layer_function(zds, function(zd) [
			for( p=togpath1_qath_to_polypoints(togpath1_polyline_to_qath([[span[0],0], [span[1],0]], zd[1]/2)) )
				[p[0],p[1],zd[0]]
		])
];

main_slot_row = make_slot_row(main_hole_diameter, main_counterbore_diameter);
alt_slot_row = make_slot_row(alt_hole_diameter, alt_counterbore_diameter);

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

function hlpa__flip(z, thing) = ["translate", [0,0,z], ["rotate",[0,180,0], thing]];

togmod1_domodule(hlpa__flip(hull_size[2], main));
