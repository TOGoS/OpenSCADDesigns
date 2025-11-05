// TubePort1.4
// 
// Similar idea to TubePort0,
// but using external 1+1/4"-UNC threads,
// and allowing for compound ports.
// 
// v1.4:
// - Forked from TubePort0.3

$fn = 48;
$tgx11_offset = -0.15;

port_hole_diameter = "6.55mm";
port_hole_count = 2; // [0:1:4]

part_name = "Bolt"; // ["Bolt","Cap"]

/* [Bolt parameters] */

bolt_thread_length = "3/4inch";

/* [Cap parameters] */

cap_rim_thickness = "1/8inch";
cap_rim_diameter  = "1+3/32inch";
cap_stem_diameter = "15/16inch";
cap_total_height  = "1/2inch";

module __tubeport0__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGThreads2.scad>
use <../lib/TOGHoleLib2.scad>
use <../lib/TOGUnits1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGVecLib0.scad>

inch  = togunits1_to_mm("1inch");
chunk = togunits1_to_mm("1chunk");

bolt_thread_length_mm = togunits1_to_mm(bolt_thread_length);
bolt_thread_style = "1+1/4-7-UNC";
bolt_thread_r_offset = -0.1;
port_hole_diameter_mm = togunits1_to_mm(port_hole_diameter);
donut_bevel = 3.175;

cap_rim_thickness_mm = togunits1_to_mm(cap_rim_thickness);
cap_rim_diameter_mm  = togunits1_to_mm(cap_rim_diameter);
cap_stem_diameter_mm = togunits1_to_mm(cap_stem_diameter);
cap_total_height_mm  = togunits1_to_mm(cap_total_height);

bolt_cap_width_mm = chunk;
bolt_cap_thickness_mm = 6.35;

function get_port_hole_xy_positions(count) =
	count == 0 ? [] :
	count == 1 ? [[0,0]] :
	let( dist = inch/4 )
	[for(i=[0:1:count-1]) let(a=i*360/count) dist*[cos(a),sin(a)]];

function make_port_hole(depth) = tphl1_make_z_cylinder(zds=[
	[-depth         , port_hole_diameter_mm],
	[0 - donut_bevel, port_hole_diameter_mm],
	[0 + 1          , port_hole_diameter_mm + donut_bevel*2 + 2],
]);

function make_port_hole_array(depth, port_hole_count, position=[0,0,0]) =
	let( positions = get_port_hole_xy_positions(port_hole_count) )
	let( port_hole = make_port_hole(depth) )
	["union", for( p=positions ) ["translate", [position[0]+p[0],position[1]+p[1],position[2]], port_hole] ];


// Copied from Threads2.scad
function make_rath_base(rath, height, r=0.6) =
	let(quarterfn=ceil($fn/4))
	let(r3=r+$tgx11_offset)
	tphl1_make_polyhedron_from_layer_function([
		for( a=[0:1:quarterfn] ) [     0 + r + r3 * sin(270 + a*90/quarterfn), -r + r3 * cos(270 + a*90/quarterfn)],
		for( a=[0:1:quarterfn] ) [height - r + r3 * sin(  0 + a*90/quarterfn), -r + r3 * cos(  0 + a*90/quarterfn)],
	], function(zo) togvec0_offset_points(togpath1_rath_to_polypoints(togpath1_offset_rath(rath, zo[1])), zo[0]));

// Copied from Threads2.scad
function make_polygon_base(sidecount, width, height) =
	let( r1 = min(3, width/10) )
	let( r2 = min(0.6, r1/2) )
	let( c_to_c_r = width/2 / cos(360/sidecount/2) )
	// echo(str("corner-to-center = ", c_to_c_r))
	make_rath_base(
		togpath1_make_polygon_rath(r=c_to_c_r, $fn=sidecount, corner_ops=[["round", r1]], rotation=90+180/sidecount),
		height, r=r2
	);


the_bolt =
let( total_height_mm = bolt_cap_thickness_mm + bolt_thread_length_mm )
let( port_hole = make_port_hole(total_height_mm+1) )
["difference",
	["union",
		make_polygon_base(8, bolt_cap_width_mm, bolt_cap_thickness_mm),
		//["translate", [0,0,bolt_cap_thickness_mm/2], tphl1_make_rounded_cuboid([bolt_cap_width_mm, bolt_cap_width_mm, bolt_cap_thickness_mm], r=[inch*3/16, inch*3/16, 1], corner_shape="ovoid1")],
		togthreads2_make_threads(
			togthreads2_simple_zparams([[bolt_cap_thickness_mm-0.5, 0], [total_height_mm, -1]], 3, extend=0),
			bolt_thread_style,
			bolt_thread_r_offset
		)
	],
	
	make_port_hole_array(total_height_mm+1, port_hole_count, [0,0,total_height_mm]),
];

the_cap =
let( port_hole = make_port_hole(cap_rim_thickness_mm+1) )
let( cap_bevel_mm = (cap_rim_diameter_mm - cap_stem_diameter_mm)/2 )
["difference",
	tphl1_make_z_cylinder(zds=[
		[               0                 , cap_stem_diameter_mm],
		// Bevel for auto-centering!
		[cap_total_height_mm-1-cap_bevel_mm, cap_stem_diameter_mm],
		[cap_total_height_mm-1, cap_rim_diameter_mm],
		[cap_total_height_mm                   , cap_rim_diameter_mm],
	]),
	
	make_port_hole_array(cap_total_height_mm+1, port_hole_count, [0,0,cap_total_height_mm]),
];

togmod1_domodule(["union",
	part_name == "Bolt" ? the_bolt :
	part_name == "Cap" ? the_cap :
	assert(false, str("Unknown part: '", part_name, "'"))
]);
