// TubePort1.8
// 
// Similar idea to TubePort0,
// but using external 1+1/4"-UNC threads,
// and allowing for compound ports.
// 
// v1.4:
// - Forked from TubePort0.3
// v1.5:
// - Bolt2 shape, which lacks a head
// - slicey_mcthickness parameter
// v1.6:
// - Slight donut bevel on bottoms of things
//   - TODO: Only if there's enough length to bevel!
// - Option for bolt cap flange
// v1.7
// - bolt_total_length as an alternative to bolt_thread_length
// v1.7.1
// - Print thread_length_mm
// v1.8
// - Option for a blockage halfway along the tube

$fn = 48;
$tgx11_offset = -0.15;

port_hole_diameter = "6.55mm";
port_hole_count = 2; // [0:1:4]
// "auto" to guess a reasonable thickness for a blockage
port_hole_blockage_thickness = "0mm";

part_name = "Bolt"; // ["Bolt","Bolt2","Cap"]

// Take the middle this much in the Y dimension; may be useful for printing sideways!
slicey_mcthickness = "999mm";

/* [Bolt parameters] */

bolt_thread_length = "3/4inch";
// Alternative to specifying bolt_thread_length; empty string means undefined and use the other one
bolt_total_length = "";
// If wider than the bolt head, adds a built-in round flange under (over) the bolt head
bolt_cap_flange_diameter = "0inch";

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

$togunits1_default_unit = "mm";

inch  = togunits1_to_mm("1inch");
chunk = togunits1_to_mm("1chunk");

function is_blank(v) = is_undef(v) || v == "";

bolt_thread_length_mm = is_blank(bolt_thread_length) ? undef : togunits1_to_mm(bolt_thread_length);
bolt_total_length_mm = is_blank(bolt_total_length) ? undef : togunits1_to_mm(bolt_total_length);
assert( is_undef(bolt_thread_length_mm) || is_undef(bolt_total_length_mm), "Only one of bolt_thread_length or bolt_total_length should be defined" );

bolt_thread_style = "1+1/4-7-UNC";
bolt_thread_r_offset = -0.1;
bolt_cap_flange_diameter_mm = togunits1_to_mm(bolt_cap_flange_diameter);
port_hole_diameter_mm = togunits1_to_mm(port_hole_diameter);
donut_bevel = 3.175;

cap_rim_thickness_mm = togunits1_to_mm(cap_rim_thickness);
cap_rim_diameter_mm  = togunits1_to_mm(cap_rim_diameter);
cap_stem_diameter_mm = togunits1_to_mm(cap_stem_diameter);
cap_total_height_mm  = togunits1_to_mm(cap_total_height);
slicey_mcthickness_mm = togunits1_to_mm(slicey_mcthickness);

bolt_cap_width_mm = chunk;
bolt_cap_thickness_mm = 6.35;

function get_port_hole_xy_positions(count) =
	count == 0 ? [] :
	count == 1 ? [[0,0]] :
	let( dist = inch/4 )
	[for(i=[0:1:count-1]) let(a=i*360/count) dist*[cos(a),sin(a)]];

function generate_blockage_for_hole(hole_zrange, blockage_thickness) =
	let( hole_length = hole_zrange[1]-hole_zrange[0] )
	let( zmid = (hole_zrange[0]+hole_zrange[1])/2 )
	let( bt =
		blockage_thickness == "auto" ? max(2, min(hole_length/3, hole_length-25.4)) :
		togunits1_to_mm(blockage_thickness)
	)
	bt > 0 ? echo(port_hole_blockage_thickness_mm=bt) tphl1_make_z_cylinder(zrange=[zmid-bt/2, zmid+bt/2], d=port_hole_diameter_mm*3, $fn=4) :
	["union"];

function make_symmetrical_port_hole(length) =
let(cyl = tphl1_make_z_cylinder(zds=[
	[-length/2 - 1          , port_hole_diameter_mm + donut_bevel*2 + 2],
	[-length/2 + donut_bevel, port_hole_diameter_mm],
	[ length/2 - donut_bevel, port_hole_diameter_mm],
	[ length/2 + 1          , port_hole_diameter_mm + donut_bevel*2 + 2],
]))
let( blockage = generate_blockage_for_hole([-length/2, length/2], port_hole_blockage_thickness) )
["difference", cyl, blockage];

function make_port_hole(depth) =
let( tdbev = donut_bevel   )
let( bdbev = donut_bevel/2 )
let( cyl = tphl1_make_z_cylinder(zds=[
	[-depth - 1      , port_hole_diameter_mm + bdbev*2 + 2],
	[-depth + bdbev  , port_hole_diameter_mm],
	[     0 - tdbev  , port_hole_diameter_mm],
	[     0 + 1      , port_hole_diameter_mm + tdbev*2 + 2],
]))
let( blockage = generate_blockage_for_hole([-depth, 0], port_hole_blockage_thickness) )
["difference", cyl, blockage];

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

function make_the_bolt() =
assert( !is_undef(bolt_total_length_mm) || !is_undef(bolt_thread_length_mm), "Neither bolt_total_length_mm nor bolt_thread_length_mm is defined")
let( flange_overhang_mm = max(0, bolt_cap_flange_diameter_mm - bolt_cap_width_mm)/2 )
let( flange_top_z = bolt_cap_flange_diameter_mm > 0 ? 1 + flange_overhang_mm + bolt_cap_thickness_mm : bolt_cap_thickness_mm )
let( total_height_mm = !is_undef(bolt_total_length_mm) ? bolt_total_length_mm : flange_top_z + bolt_thread_length_mm )
echo( flange_top_z=flange_top_z, total_height_mm=total_height_mm, thread_length_mm=(total_height_mm - flange_top_z) )
let( port_hole = make_port_hole(total_height_mm) )
["difference",
	["intersection", slicey_mccuboid, ["union",
		if( flange_top_z > bolt_cap_thickness_mm ) tphl1_make_z_cylinder(zds=[
		   [bolt_cap_thickness_mm - 0.4                 , bolt_cap_width_mm - 0.4],
		   [bolt_cap_thickness_mm + flange_overhang_mm    , bolt_cap_flange_diameter_mm],
		   [bolt_cap_thickness_mm + flange_overhang_mm + 1, bolt_cap_flange_diameter_mm],
		]),
		make_polygon_base(8, bolt_cap_width_mm, max(bolt_cap_thickness_mm, flange_top_z - 0.5)),
		//["translate", [0,0,bolt_cap_thickness_mm/2], tphl1_make_rounded_cuboid([bolt_cap_width_mm, bolt_cap_width_mm, bolt_cap_thickness_mm], r=[inch*3/16, inch*3/16, 1], corner_shape="ovoid1")],
		togthreads2_make_threads(
			togthreads2_simple_zparams([[flange_top_z-0.5, 0], [total_height_mm, -1]], 3, extend=0),
			bolt_thread_style,
			bolt_thread_r_offset
		)
	]],
	
	make_port_hole_array(total_height_mm, port_hole_count, [0,0,total_height_mm]),
];

slicey_mccuboid = togmod1_make_cuboid([1000,slicey_mcthickness_mm,1000]);

function make_the_bolt_2() =
assert( !is_undef(bolt_total_length_mm) || !is_undef(bolt_thread_length_mm), "Neither bolt_total_length_mm nor bolt_thread_length_mm is defined")
let( total_height_mm = !is_undef(bolt_total_length_mm) ? bolt_total_length_mm : bolt_thread_length_mm )
echo( total_height_mm=total_height_mm )
let( port_hole_xy_positions = get_port_hole_xy_positions(port_hole_count) )
let( port_hole = make_symmetrical_port_hole(total_height_mm) )
["difference",
	["intersection", slicey_mccuboid, ["union",
		togthreads2_make_threads(
			togthreads2_simple_zparams([[-total_height_mm/2, -1], [total_height_mm/2, -1]], 3, extend=0),
			bolt_thread_style,
			bolt_thread_r_offset
		)
	]],
	
	for( pos=port_hole_xy_positions )
		["translate", [pos[0],pos[1],0], port_hole],
];

function make_the_cap() =
let( port_hole = make_port_hole(cap_rim_thickness_mm) )
let( cap_bevel_mm = (cap_rim_diameter_mm - cap_stem_diameter_mm)/2 )
["difference",
	["intersection", slicey_mccuboid, tphl1_make_z_cylinder(zds=[
		[               0                 , cap_stem_diameter_mm],
		// Bevel for auto-centering!
		[cap_total_height_mm-1-cap_bevel_mm, cap_stem_diameter_mm],
		[cap_total_height_mm-1, cap_rim_diameter_mm],
		[cap_total_height_mm                   , cap_rim_diameter_mm],
	])],
	
	make_port_hole_array(cap_total_height_mm, port_hole_count, [0,0,cap_total_height_mm]),
];

togmod1_domodule(["union",
	part_name == "Bolt" ? make_the_bolt() :
	part_name == "Bolt2" ? make_the_bolt_2() :
	part_name == "Cap" ? make_the_cap() :
	assert(false, str("Unknown part: '", part_name, "'"))
]);
