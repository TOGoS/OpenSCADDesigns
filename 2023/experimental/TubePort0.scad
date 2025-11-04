// TubePort0.2
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

$fn = 48;

module __tubeport0__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGThreads2.scad>
use <../lib/TOGHoleLib2.scad>

inch = 25.4;
chunk = 38.1;

full_block_size_mm = [chunk, chunk, chunk];
half_block_size_mm = [chunk, chunk, chunk/2];

port_depth = inch*3/8;
port_thread_style = "3/4-10-UNC";
port_thread_r_offset =  0.2;
bolt_thread_r_offset = -0.1;
tube_diameter = 6.35;
bolt_inner_diameter = tube_diameter + 0.5;
donut_bevel = 3.175;

bolt_cap_width = inch;
bolt_cap_thickness = 6.35;
bolt_thread_length = inch/2;

the_half_block =
let( connector_hole = tog_holelib2_hole("THL-1005", depth=half_block_size_mm[2]+1, inset=6.35) )
let( top_z = half_block_size_mm[2]/2 )
["difference",
	tphl1_make_rounded_cuboid(half_block_size_mm, r=[inch*3/16, inch*3/16, 1], corner_shape="ovoid1"),
	
	tphl1_make_z_cylinder(zds=[
		[-chunk                          , tube_diameter],
		[top_z - port_depth - donut_bevel, tube_diameter],
		[top_z - port_depth + 1          , tube_diameter + donut_bevel*2 + 2],
		[top_z              + 1          , tube_diameter + donut_bevel*2 + 2],
	]),
	//togmod1_linear_extrude_z([-chunk,chunk], togmod1_make_circle(d=tube_diameter + 0.2)),
	
	togthreads2_make_threads(
		togthreads2_simple_zparams([[top_z-port_depth, 0], [top_z, 1]], 3),
		port_thread_style,
		port_thread_r_offset
	),
	
	for( xm=[-1,1] ) for( ym=[-1,1] ) ["translate", [xm*inch/2, ym*inch/2, top_z], connector_hole],
];

the_full_block =
let( bot_z = -full_block_size_mm[2]/2 )
let( top_z =  full_block_size_mm[2]/2 )
let( connector_hole = tog_holelib2_hole("THL-1005", depth=full_block_size_mm[2]+1, inset=6.35) )
["difference",
	tphl1_make_rounded_cuboid(full_block_size_mm, r=[inch*3/16, inch*3/16, 1], corner_shape="ovoid1"),
	
	["intersection",
		togthreads2_make_threads(
			togthreads2_simple_zparams([[bot_z, 1], [top_z, 1]], 3),
			port_thread_style,
			port_thread_r_offset
		),
		tphl1_make_z_cylinder(zds=[
			[bot_z + port_depth + donut_bevel - 100, tube_diameter + 200],
			[bot_z + port_depth + donut_bevel      , tube_diameter],
			[top_z - port_depth - donut_bevel      , tube_diameter],
			[top_z - port_depth - donut_bevel + 100, tube_diameter + 200],
		]),
	],
	
	for( xm=[-1,1] ) for( ym=[-1,1] ) ["translate", [xm*inch/2, ym*inch/2, top_z], connector_hole],
];


the_bolt =
let( total_height = bolt_cap_thickness + bolt_thread_length )
["difference",
	["union",
		["translate", [0,0,bolt_cap_thickness/2], tphl1_make_rounded_cuboid([bolt_cap_width, bolt_cap_width, bolt_cap_thickness], r=[inch*3/16, inch*3/16, 1], corner_shape="ovoid1")],
		togthreads2_make_threads(
			togthreads2_simple_zparams([[bolt_cap_thickness-0.5, 0], [total_height, -1]], 3, extend=0),
			port_thread_style,
			bolt_thread_r_offset
		)
	],
	
	tphl1_make_z_cylinder(zds=[
		[0                         , tube_diameter + 0.2],
		[total_height - donut_bevel, bolt_inner_diameter],
		[total_height + 1          , bolt_inner_diameter + donut_bevel*2 + 2],
	]),
];

togmod1_domodule(["union",
	["translate", [-2*inch,0,0], the_half_block],
	["translate", [ 0*inch,0,0], the_bolt],
	["translate", [+2*inch,0,0], the_full_block],
]);
