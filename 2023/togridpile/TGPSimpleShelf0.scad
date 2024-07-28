// TGPSimpleShelf0.1
// 
// Shelf intended to be mounted on DiagBrack0 brackets

floor_thickness = 6.35;
height = 25.4;
floor_segmentation = "chunk"; // ["atom","chatom","chunk","block","none"]
bottom_segmentation = "chatom"; // ["atom","chatom","chunk","block","none"]
wall_thickness = 3.175;
interior_offset = -0.15;
$tgx11_offset = -0.1;

length_chunks = 8;

use <../lib/TGx11.1Lib.scad>
use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGridLib3.scad>
use <../lib/TOGVecLib0.scad>

$fn = 24;
$togridlib3_unit_table = tgx11_get_default_unit_table();

inch  = togridlib3_decode([1, "inch" ]);
u     = togridlib3_decode([1, "u"    ]);
chunk = togridlib3_decode([1, "chunk"]);
atom  = togridlib3_decode([1, "atom"]);

magnet_hole = tphl1_make_z_cylinder(zrange=[-2.2,2.2], d=6.2, $fn=48);
hole1 = tog_holelib2_hole("THL-1001", depth=floor_thickness+1, inset=1, $fn=24);
hole2 = tog_holelib2_hole("THL-1002", depth=floor_thickness+1, inset=1, $fn=24);

togmod1_domodule(["difference",
	["intersection",
		togmod1_linear_extrude_z([0, height], togmod1_make_rounded_rect([length_chunks*chunk, chunk+wall_thickness*2+$tgx11_offset*2], r=1)),
		if( bottom_segmentation != "none" ) ["union",
			tgx11_block_bottom(
				[[length_chunks, "chunk"], [1, "chunk"], [1, "chunk"]],
				segmentation = bottom_segmentation,
				$tgx11_gender = "m"
			),
			// The TGx11 'cones' don't extend far enough out
			// to fully enclose the walls, so add another thing:
			tphl1_make_polyhedron_from_layer_function([
				// Numbers chosesn assuming wall_thickness = 2u, floor_thickness = 4u
				[2  *u     , wall_thickness - 2*u],
				[4  *u     , wall_thickness + 1*u],
				[height+2  , wall_thickness + 1*u],
			], function(z_wt)
				togvec0_offset_points(togmod1_rounded_rect_points([length_chunks*chunk+z_wt[1], chunk+z_wt[1]*2+$tgx11_offset*2+0.001], r=6), z_wt[0])
			),
		],
	],
	
	["intersection",
		togmod1_linear_extrude_z([-2, height+2], togmod1_make_rect([length_chunks*chunk+2, 1.5*inch-interior_offset*2])),
		["union",
			togmod1_linear_extrude_z([floor_thickness + u, height+1], togmod1_make_rect([15*inch, 3*inch])),
			["translate", [0,0,floor_thickness], tgx11_block_bottom(
				[[length_chunks, "chunk"], [1, "chunk"], [1, "chunk"]],
				segmentation = floor_segmentation,
				$tgx11_gender = "f"
			)]
		]
	],
	
	for (cx=[-length_chunks/2+0.5 : 1 : length_chunks/2]) each [
		for( ax=[-1,1] ) for( ay=[-1,1] )
			["translate", [cx*chunk + ax*atom, ay*atom, floor_thickness], magnet_hole],
		for( apos=[[0,1],[-1,0],[1,0],[0,-1]] )
			["translate", [cx*chunk + apos[0]*atom, apos[1]*atom, floor_thickness], hole1],
		for( apos=[[0,0]] )
			["translate", [cx*chunk + apos[0]*atom, apos[1]*atom, floor_thickness], hole2],
	]
]);
