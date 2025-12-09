// TubePort0.4
// 
// Idea:
// - Port is an inset cylinder with threads and a snig tube-sized hole
// - Put a nute on the tube and the tube in the hole
// - Tighten the nut (which actually has threads on the outside) into the port;
//   the nut is tapered on the inside to push ~something~ into the tube to tighten it.
//   - Maybe ~something~ is a donut of silicone caulk?
//   - Or maybe it's three prongs of PLA?
// 
// v0.2:
// - Add full block
// - Slightly larger hole through bolt
// v0.3:
// - TOGridPile block shapes, just so they can stack somewhere a little more nicely when not in use
// v0.4:
// - `part` specifies which part(s) to make
//   - this was going to be `parts`, but OpenSCAD 2024 doesn't like parameters that are arrays of strings.
// - `block_height`, `port_depth`, `bolt_thread_length`, and `donut_bevel` may be customized
// - 1mm thread inset on the bolts and ports

part = "all"; // ["all","half-block","bolt","full-block"]
block_height = "1chunk";
port_depth = "3/8inch";
bolt_thread_length = "1/2inch";
donut_bevel = "1/8inch";
$tgx11_offset = -0.15;
$fn = 48;

module __tubeport0__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGThreads2.scad>
use <../lib/TOGHoleLib2.scad>
use <../lib/TGx11.1Lib.scad>
use <../lib/TOGUnits1.scad>

$togridlib3_unit_table = tgx11_get_default_unit_table();
$togunits1_default_unit = "mm";

block_height_mm = togunits1_to_mm(block_height);
port_depth_mm   = togunits1_to_mm(port_depth);
bolt_thread_length_mm = togunits1_to_mm(bolt_thread_length);
donut_bevel_mm = togunits1_to_mm(donut_bevel);

inch = 25.4;
chunk = 38.1;

full_block_size_mm = [chunk, chunk, block_height_mm];
half_block_size_mm = [chunk, chunk, block_height_mm/2];

port_thread_style = "3/4-10-UNC";
port_thread_r_offset =  0.2;
bolt_thread_r_offset = -0.1;
tube_diameter = 6.35;
bolt_inner_diameter = tube_diameter + 0.5;

bolt_cap_width = inch;
bolt_cap_thickness = 6.35;

function tubeport2_make_block(size) =
let( size_ca = [[round(size[0]/chunk),"chunk"], [round(size[1]/chunk),"chunk"], [size[2],"mm"]] )
["translate", [0,0,-size[2]/2], tgx11_block(size_ca,
	bottom_segmentation = "chunk",
	bottom_foot_bevel = 0.4,
	top_segmentation = "none"
)];

function make_the_half_block() =
let( connector_hole = tog_holelib2_hole("THL-1005", depth=half_block_size_mm[2]+1, inset=6.35) )
let( top_z = half_block_size_mm[2]/2 )
["difference",
	tubeport2_make_block(half_block_size_mm),
	
	tphl1_make_z_cylinder(zds=[
		[-chunk                                , tube_diameter],
		if( donut_bevel_mm > 0 )
		[top_z - port_depth_mm - donut_bevel_mm, tube_diameter],
		[top_z - port_depth_mm + 1             , tube_diameter + donut_bevel_mm*2 + 2],
		[top_z                 + 1             , tube_diameter + donut_bevel_mm*2 + 2],
	]),
	//togmod1_linear_extrude_z([-chunk,chunk], togmod1_make_circle(d=tube_diameter + 0.2)),
	
	togthreads2_make_threads(
		togthreads2_simple_zparams([[top_z-port_depth_mm, 0], [top_z, 1]], 3, inset=1),
		port_thread_style,
		port_thread_r_offset
	),
	
	for( xm=[-1,1] ) for( ym=[-1,1] ) ["translate", [xm*inch/2, ym*inch/2, top_z], connector_hole],
];

function make_the_full_block() =
let( bot_z = -full_block_size_mm[2]/2 )
let( top_z =  full_block_size_mm[2]/2 )
let( connector_hole = tog_holelib2_hole("THL-1005", depth=full_block_size_mm[2]+1, inset=6.35) )
["difference",
	tubeport2_make_block(full_block_size_mm),
	
	["intersection",
		togthreads2_make_threads(
			togthreads2_simple_zparams([[bot_z, 1], [top_z, 1]], 3, inset=1),
			port_thread_style,
			port_thread_r_offset
		),
		tphl1_make_z_cylinder(zds=[
			[bot_z + port_depth_mm + donut_bevel_mm - 100, tube_diameter + 200],
			[bot_z + port_depth_mm + donut_bevel_mm      , tube_diameter],
			[top_z - port_depth_mm - donut_bevel_mm      , tube_diameter],
			[top_z - port_depth_mm - donut_bevel_mm + 100, tube_diameter + 200],
		]),
	],
	
	for( xm=[-1,1] ) for( ym=[-1,1] ) ["translate", [xm*inch/2, ym*inch/2, top_z], connector_hole],
];


function make_the_bolt() =
let( total_height = bolt_cap_thickness + bolt_thread_length_mm )
["difference",
	["union",
		["translate", [0,0,bolt_cap_thickness/2], tphl1_make_rounded_cuboid([bolt_cap_width, bolt_cap_width, bolt_cap_thickness], r=[inch*3/16, inch*3/16, 1], corner_shape="ovoid1")],
		togthreads2_make_threads(
			togthreads2_simple_zparams([[bolt_cap_thickness-0.5, 0], [total_height, -1]], 3, extend=0, inset=1),
			port_thread_style,
			bolt_thread_r_offset
		)
	],
	
	tphl1_make_z_cylinder(zds=[
		[0                            , tube_diameter + 0.2],
		[total_height - donut_bevel_mm, bolt_inner_diameter],
		[total_height + 1             , bolt_inner_diameter + donut_bevel_mm*2 + 2],
	]),
];

function make_part(name) =
	name == "half-block" ? make_the_half_block() :
	name == "bolt" ? make_the_bolt() :
	name == "full-block" ? make_the_full_block() :
	assert(false, str("Unrecognized part: '", name, "'"));

partlist =
	part == "all" ? ["half-block","bolt","full-block"] :
	[part];

togmod1_domodule(["union",
	for( i=[0:1:len(partlist)-1] )
	["translate", [ 2*inch*(i-len(partlist)/2+0.5),0,0], make_part(partlist[i])],
]);
