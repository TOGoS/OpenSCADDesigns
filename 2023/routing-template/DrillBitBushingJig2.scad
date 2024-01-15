// DrillBitBushingJig2.3
// 
// 'Modular' drill bit bushing holder
// intended to be held in a line between two rails
// 
// v2.1:
// - Make flange_width weirdly configurable
// - s/end_margin/hull_xy_margin/, which applies to width, too
// - Center mounting holes between body and flange edge,
//   regardless of screwdown_hole_spacing (previously 'atom_pitch')
// v2.3:
// - body_extents_x controls whether body extends all the way to the left/right
// - Use two rounded cuboids instead of one linear extruded thing
// - Additional Y-centered screwdown hole at each end
// - Optional TOGridPile-compatible foot!

// 9.525 = 3/8"
length_chunks = 2;
chunk_pitch = 38.1;
flange_height = 6.35;
height = 38.1;
bushing_hole_diameter    = 12.7;    // 0.0001
gridbeam_hole_diameter   =  7.9375; // 0.0001
// How much body should extend beyond the left/right ends, in flange widths (usually 0 or negative)
body_extents_x = [0,0];
// Width of body; flange_width is (chunk_pitch-body_width)/2
body_width = 19.05;

/* [Screwdown Holes] */

screwdown_holes_enabled = true;
// Spacing of screwdown holes; -1 means 'use flange width'
screwdown_hole_spacing = -1; // 0.001

/* [Detail] */

xy_corner_rounding_radius = 4.7625; // 0.0001
z_corner_rounding_radius  = 1.5875; // 0.0001

// How much to subtract from length/width of body+flange
hull_xy_margin = -0.1;

preview_fn = 24;
render_fn = 48;

/* [TOGridPile Compatibility] */
foot_segmentation = "none"; // ["none","chunk"]

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>

module __alksdlkn_end_params() { }

$fn = $preview ? preview_fn : render_fn;

function dbbj2_count(list, val, index=0, a=0) =
	len(list) == index ? a :
	dbbj2_count(list, val, index+1, a+(list[index] == val ? 1 : 0));
function dbbj2_sum(list, index=0, a=0) =
	len(list) == index ? a :
	dbbj2_sum(list, index+1, a+list[index]);

/*
function dbbj2_hull_profile_point_data() =
let(fhw = chunk_pitch/2 - hull_xy_margin)
let(bhw =   body_width/2 - hull_xy_margin)
let(fh  = flange_height )
let(bh  = height   )
[
	[[ fhw,  0], 0],
	[[ fhw, fh], 1],
	[[ bhw, fh], 0],
	[[ bhw, bh], 1],
	[[-bhw, bh], 1],
	[[-bhw, fh], 0],
	[[-fhw, fh], 1],
	[[-fhw,  0], 0],
];

function dbbj2_process_point_data(pdats, round_rad) =
	let( rath=["togpath1-rath", for(pd=pdats) ["togpath1-rath", pd[0], if( pd[1] > 0 ) ["round", round_rad]]] )
	togpath1_rath_to_points(rath);

function dbbj2_old_x_extruded_hull(xrange) =
	let( ppoint_data = dbbj2_hull_profile_point_data() )
	let( ppoints = dbbj2_process_point_data(ppoint_data, corner_rounding_radius) )
	tphl1_make_polyhedron_from_layer_function([xrange[0], xrange[1]], function(x) [
		for( p=ppoints ) [x, p[0], p[1]]
	]);
*/

corner_rounding_radius = [xy_corner_rounding_radius, xy_corner_rounding_radius, z_corner_rounding_radius];

flange_width = (chunk_pitch - body_width)/2;

effective_screwdown_hole_spacing = screwdown_hole_spacing == -1 ? flange_width : screwdown_hole_spacing;

length = length_chunks * 38.1 - hull_xy_margin*2;

body_length = length + flange_width * dbbj2_sum(body_extents_x, 0);
body_offset = (body_extents_x[1] - body_extents_x[0]) * flange_width/2;

use <../lib/TGx11.1Lib.scad>
$tgx11_offset = -0.1;
$tgx11_gender = "m";
$togridlib3_unit_table = tgx11_get_default_unit_table();

the_foot =
	foot_segmentation == "none" ?
		["translate", [0,0,height], togmod1_make_cuboid([length*2,chunk_pitch*2,height*2])] :
	foot_segmentation == "chunk" ? 
		let(chunk_foot = tgx11_chunk_unifoot([chunk_pitch, chunk_pitch, height]))
		["union", for(xm=[-length_chunks/2+0.5 : 1 : length_chunks/2]) ["translate", [xm*chunk_pitch,0,0], chunk_foot]] :
	assert(false, str("Unrecognized foot_segmentation: '", foot_segmentation, "'"));

the_hull = ["intersection",
	the_foot,
	// dbbj2_old_x_extruded_hull([-length/2, length/2]),
	["union",
		["translate", [body_offset,0,0], tphl1_make_rounded_cuboid([body_length, body_width, height*2], corner_rounding_radius, corner_shape="ovoid2")],
		tphl1_make_rounded_cuboid([length, chunk_pitch, flange_height*2], corner_rounding_radius, corner_shape="ovoid2"),
	],
];

bushing_hole  = tphl1_make_z_cylinder(d=bushing_hole_diameter, zrange=[-1,height+1]);
gridbeam_hole = ["rotate", [90,0,0], tphl1_make_z_cylinder(d=gridbeam_hole_diameter, zrange=[-30,30])];
screwdown_hole = ["render", tog_holelib2_hole("THL-1001", depth=flange_height+1, inset=max(0.1,flange_height-3.175), overhead_bore_height=height)];

x_marker_slot = togmod1_make_cuboid([1,2,flange_height*2+1]);
y_marker_slot = togmod1_make_cuboid([2,1,flange_height*2+1]);

length_screwdown_holes = round(length_chunks*chunk_pitch/effective_screwdown_hole_spacing);

screwdown_hole_positions = [
	for( xm=[-length_screwdown_holes/2+0.5 : 1 : length_screwdown_holes/2-0.5] ) for( ym=[-1, 1] )
		[xm*effective_screwdown_hole_spacing, ym*(body_width+chunk_pitch)/4],
	for( xm=[-length_screwdown_holes/2+0.5, length_screwdown_holes/2-0.5] ) for( ym=[0] )
		each let( x=xm*effective_screwdown_hole_spacing )
			true /*(x < body_offset - body_length/2 || x > body_offset + body_length/2)*/ ? [[x, ym*(body_width+chunk_pitch)/4]] : [],
];

the_holes = ["union",
	for( xm=[-length_chunks/2+0.5 : 0.5 : length_chunks/2-0.5] ) ["translate", [xm*chunk_pitch, 0, 0], bushing_hole],
	//for( xm=[-length_chunks/2+0.5 : 1 : length_chunks/2] ) ["translate", [xm*chunk_pitch, 0, height/2], alt_hole],
	for( xm=[-length_chunks/2+0.5 : 0.5 : length_chunks/2-0.5] ) ["translate", [xm*chunk_pitch, 0, height/2], gridbeam_hole],
	for( p=screwdown_holes_enabled ? screwdown_hole_positions : [] )
		["translate", [p[0], p[1], flange_height], screwdown_hole],
];
the_marks = ["union",
	for( ym=[-1,1] ) for( xm=[-length_chunks/2+0.5 : 0.5 : length_chunks/2-0.5] )
		["translate", [xm*chunk_pitch, ym*chunk_pitch/2, 0], x_marker_slot],
	for( xm=[-1,1] ) for( ym=[-1/2+0.5 : 0.5 : 1/2-0.5] )
		["translate", [xm*length/2, ym*chunk_pitch, 0], y_marker_slot],
];
togmod1_domodule(["difference",
	the_hull,
	the_holes,
	the_marks,
]);
