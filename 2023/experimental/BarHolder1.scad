// BarHolder1.1

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TGx11.1Lib.scad>
use <../lib/TOGUnits1.scad>

size_chunks = [3,3,1];
bottom_segmentation = "block"; // ["none","block","chunk"]
top_segmentation = "block"; // ["none","block","chunk"]

$fn = 144;

large_diameter = 38.1;
slot_width = 31.75;
$tgx11_offset = -0.1;
$togridlib3_unit_table = tgx11_get_default_unit_table();

inch  = togunits1_decode("inch");
chunk = togunits1_decode("chunk");

togmod1_domodule(
	let( xybev = 5, zbev = 3.175 )
	let( z0 = -chunk/2, z1=chunk/2 )

	let( center_hole_diameter = large_diameter - $tgx11_offset*2 )
	let( mounting_hole =
		let( smallzbev = 1.5 )
		let( tinyzbev  = 1   )
		let( smalld = inch*5/16, larged = inch*7/8 )
		// tog_holelib2_hole("THL-1006", inset=0, depth=chunk, overhead_bore_height=chunk) ) // Could be fancy and make rounded corners...
		tphl1_make_z_cylinder(zds=[
			[z0-smallzbev, smalld+smallzbev*4],
			[z0+smallzbev, smalld            ],
			[ 0-smallzbev, smalld            ],
			[ 0          , smalld+smallzbev*2],
			[ 0          , larged- tinyzbev*2],
			[ 0+ tinyzbev, larged            ],
			[z1-smallzbev, larged            ],
			[z1+smallzbev, larged+smallzbev*4],
		]))

	["difference",
		// tphl1_make_rounded_cuboid([for(d=size_chunks*chunk) d+$tgx11_offset*2], r=[xybev,xybev,zbev], corner_shape="cone2"),
		["translate", [0,0,-size_chunks[2]*chunk/2], tgx11_block(
			[
				[size_chunks[0],"chunk"],
				[size_chunks[1],"chunk"],
				[size_chunks[2],"chunk"],
			],
			bottom_segmentation = bottom_segmentation,
			bottom_v6hc_style = "none",
			bottom_foot_bevel = 0.4,
			top_segmentation = top_segmentation,
			top_v6hc_style = "none",
			top_foot_bevel = 0.4,
			lip_height = -1
		)],
		
		tphl1_make_z_cylinder(zds=[
			[z0-zbev, center_hole_diameter+zbev*4],
			[z0+zbev, center_hole_diameter       ],
			[z1-zbev, center_hole_diameter       ],
			[z1+zbev, center_hole_diameter+zbev*4],
		]),
		
		tphl1_make_polyhedron_from_layer_function([
			[z0-zbev, 0+zbev*2],
			[z0+zbev, 0       ],
			[z1-zbev, 0       ],
			[z1+zbev, 0+zbev*2        ],
		], function(zo) togpath1_rath_to_polypoints(["togpath1-rath",
			["togpath1-rathnode", [ slot_width/2          , 0                             ], ["offset", zo[1]]],
			["togpath1-rathnode", [ slot_width/2          , size_chunks[1]/2*chunk - xybev], ["round", xybev], ["offset", zo[1]]],
			["togpath1-rathnode", [ slot_width/2 + xybev*2, size_chunks[1]/2*chunk + xybev], ["offset", zo[1]]],
			["togpath1-rathnode", [-slot_width/2 - xybev*2, size_chunks[1]/2*chunk + xybev], ["offset", zo[1]]],
			["togpath1-rathnode", [-slot_width/2          , size_chunks[1]/2*chunk - xybev], ["round", xybev], ["offset", zo[1]]],
			["togpath1-rathnode", [-slot_width/2          , 0                             ], ["offset", zo[1]]],
		]), layer_points_transform = "key0-to-z"),
		
		for( ym=[-size_chunks[1]/2+0.5:1:size_chunks[1]/2-0.5] )
		for( xm=[-size_chunks[0]/2+0.5:1:size_chunks[0]/2-0.5] )
		["translate", [xm,ym,0]*chunk, mounting_hole],
	]
);
