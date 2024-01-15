// DrillBitBushingJig2.2
// 
// 'Modular' drill bit bushing holder
// intended to be held in a line between two rails
// 
// v2.1:
// - Make flange_width weirdly configurable
// - s/end_margin/hull_xy_margin/, which applies to width, too
// - Center mounting holes between body and flange edge,
//   regardless of screwdown_hole_spacing (previously 'atom_pitch')

// 9.525 = 3/8"
screwdown_hole_spacing = 9.525; // 0.001
chunk_pitch = 38.1;
length_chunks = 2;
flange_height = 6.35;
height = 38.1;
corner_rounding_radius = 25.4/16;
gridbeam_hole_diameter = 25.4*5/16;
// alt_hole_diameter = 25.4*4.5/16;
body_width = 19.05;
flange_width = 38.1;
// How much to subtract from length/width of body+flange
hull_xy_margin = -0.1;
flange_screwdown_holes_enabled = true;

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>

module __alksdlkn_end_params() { }

$fn = $preview ? 24 : 48;

function dbbj2_hull_profile_point_data() =
let(fhw = flange_width/2 - hull_xy_margin)
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

function dbbj2_hull(xrange) =
	let( ppoint_data = dbbj2_hull_profile_point_data() )
	let( ppoints = dbbj2_process_point_data(ppoint_data, corner_rounding_radius) )
	tphl1_make_polyhedron_from_layer_function([xrange[0], xrange[1]], function(x) [
		for( p=ppoints ) [x, p[0], p[1]]
	]);

flange_width_chunks = round(flange_width/chunk_pitch);
length = length_chunks * 38.1 - hull_xy_margin*2;
the_hull = dbbj2_hull([-length/2, length/2]);
bushing_hole  = tphl1_make_z_cylinder(d=12.7, zrange=[-1,height+1]);
gridbeam_hole = ["rotate", [90,0,0], tphl1_make_z_cylinder(d=gridbeam_hole_diameter, zrange=[-30,30])];
flange_screwdown_hole = ["render", tog_holelib2_hole("THL-1001", depth=flange_height+1, inset=max(0.1,flange_height-3.175))];

x_marker_slot = togmod1_make_cuboid([1,2,flange_height*2+1]);
y_marker_slot = togmod1_make_cuboid([2,1,flange_height*2+1]);

length_screwdown_holes = round(length_chunks*chunk_pitch/screwdown_hole_spacing);

the_holes = ["union",
	for( xm=[-length_chunks/2+0.5 : 0.5 : length_chunks/2-0.5] ) ["translate", [xm*chunk_pitch, 0, 0], bushing_hole],
	//for( xm=[-length_chunks/2+0.5 : 1 : length_chunks/2] ) ["translate", [xm*chunk_pitch, 0, height/2], alt_hole],
	for( xm=[-length_chunks/2+0.5 : 0.5 : length_chunks/2-0.5] ) ["translate", [xm*chunk_pitch, 0, height/2], gridbeam_hole],
	if( flange_screwdown_holes_enabled )
		for( xm=[-length_screwdown_holes/2+0.5 : 1 : length_screwdown_holes/2-0.5] )
		for( ym=[-1, 1] )
		["translate", [xm*screwdown_hole_spacing, ym*(body_width+flange_width)/4, flange_height], flange_screwdown_hole],
];
the_marks = ["union",
	for( ym=[-1,1] ) for( xm=[-length_chunks/2+0.5 : 0.5 : length_chunks/2-0.5] )
		["translate", [xm*chunk_pitch, ym*flange_width/2, 0], x_marker_slot],
	for( xm=[-1,1] ) for( ym=[-flange_width_chunks/2+0.5 : 0.5 : flange_width_chunks/2-0.5] )
		["translate", [xm*length/2, ym*chunk_pitch, 0], y_marker_slot],
];
togmod1_domodule(["difference",
	the_hull,
	the_holes,
	the_marks,
]);
