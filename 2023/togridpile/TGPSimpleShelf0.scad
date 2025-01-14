// TGPSimpleShelf0.6
// 
// Shelf intended to be mounted on DiagBrack0 brackets
// 
// v0.2:
// - Add slots
// v0.3:
// - Slots now have fixed width, regardless of wall thickness
// - Make the whole thing more TOGridPilish if
//   if specified dimensions allow for it
// v0.4:
// - Adjust defaults so that preview doesn't crash OpenSCAD
// v0.5:
// - Don't treat 'chatom' bottoms as TGPish
// - Don't put mounting holes in TGPish bottoms,
//   since the grids won't line up
// - Bevel slot corners
// v0.6:
// - Option for WSTYPE-4145 slots
// - Add description parameter
// 
// TODO:
// - Option to make end walls, similar to side walls
// - A simplified rounded-rect-based floor cutouts (floor_segmentation = 'simple-chunk' or somesuch)

description = "";

length_chunks = 2;
floor_thickness = 6.35;
height = 25.4;
floor_segmentation = "chunk"; // ["atom","chatom","chunk","block","none"]
bottom_segmentation = "chatom"; // ["atom","chatom","chunk","block","none"]
slot_style = "WSTYPE-4144"; // ["none", "WSTYPE-4144", "WSTYPE-4145"]
wall_thickness = 3.175;
interior_offset = -0.15;
$tgx11_offset = -0.1;

module tgpsimpleshelf0__end_params() { }

use <../lib/TGx11.1Lib.scad>
use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGridLib3.scad>
use <../lib/TOGVecLib0.scad>

$fn = $preview ? 8 : 24;
magnet_hole_fn = $preview ? 8 : 48;
screw_hole_fn = $preview ? 8 : 24;

$togridlib3_unit_table = tgx11_get_default_unit_table();

inch  = togridlib3_decode([1, "inch" ]);
u     = togridlib3_decode([1, "u"    ]);
chunk = togridlib3_decode([1, "chunk"]);
atom  = togridlib3_decode([1, "atom"]);

length = togridlib3_decode([length_chunks, "chunk"]);
width  = chunk + wall_thickness*2;
slot_spacing = inch;

magnet_hole = tphl1_make_z_cylinder(zrange=[-2.2,2.2], d=6.2, $fn=magnet_hole_fn);
hole1 = tog_holelib2_hole("THL-1001", depth=floor_thickness+1, inset=1, $fn=screw_hole_fn);
hole2 = tog_holelib2_hole("THL-1002", depth=floor_thickness+1, inset=1, $fn=screw_hole_fn);

function make_slot(inner_width) =
	let(y0 = -chunk/2 - wall_thickness - u + $tgx11_offset)
	// Old [WSTYPE-4144] formula: let(y1 = -chunk/2 -                  u - $tgx11_offset)
	let(y1 = -inner_width/2 - $tgx11_offset)
	let(y2 = -y1)
	let(y3 = -y0)
	let(z0 = -u + $tgx11_offset )
	let(z1 =  u - $tgx11_offset )
	let(z2 =  height + 15 )
	let(b  =  u) // Interior corner bevel
	togmod1_linear_extrude_x([-u+$tgx11_offset, u-$tgx11_offset], togmod1_make_polygon([
		[y3  , z0  ],
		[y3  , z2  ],
		[y2  , z2  ],
		[y2  , z1+u],
		[y2-u, z1  ],
		[y1+u, z1  ],
		[y1  , z1+u],
		[y1  , z2  ],
		[y0  , z2  ],
		[y0  , z0  ],
	]));

eff_slot_style = is_undef(slots_enabled) || slots_enabled == false ? slot_style : "none";

slot = eff_slot_style == "none" ? ["union"] :
	make_slot(
		eff_slot_style == "WSTYPE-4144" ? chunk + 2*u :
		eff_slot_style == "WSTYPE-4145" ? chunk + 4*u :
		assert(false, str("Unrecognized slot style: '", eff_slot_style, "'"))
	);

tgp_width_ca =
	bottom_segmentation == "atom" ? [round(width/atom), "atom"] :
	bottom_segmentation == "chunk" || bottom_segmentation == "chatom" ? [round(width/chunk), "chunk"] :
	[width, "mm"];

// Can the TOGridPile block itself serve as the hull?
is_tgpish = abs(togridlib3_decode(tgp_width_ca) - width) < 1;

the_tgp_hull = tgx11_block(
	[[length_chunks, "chunk"], tgp_width_ca, [height, "mm"]],
	bottom_segmentation = bottom_segmentation,
	top_segmentation = "block",
	lip_height = 1.6,
	$tgx11_gender = "m"
);

the_hull =
	is_tgpish ? the_tgp_hull :
	["intersection",
		togmod1_linear_extrude_z([0, height+20], togmod1_make_rounded_rect([length_chunks*chunk, chunk+wall_thickness*2+$tgx11_offset*2], r=1)),
		if( bottom_segmentation != "none" ) ["union",
			the_tgp_hull,
			// The TGx11 'cones' don't extend far enough out
			// to fully enclose the walls, so add another thing:
			tphl1_make_polyhedron_from_layer_function([
				// Numbers chosesn assuming wall_thickness = 2u, floor_thickness = 4u
				[2  *u     , wall_thickness - 2*u],
				[4  *u     , wall_thickness + 1*u],
				[height    , wall_thickness + 1*u],
			], function(z_wt)
				togvec0_offset_points(togmod1_rounded_rect_points([length_chunks*chunk+z_wt[1], chunk+z_wt[1]*2+$tgx11_offset*2+0.001], r=6), z_wt[0])
			),
		],
	];

togmod1_domodule(["difference",
	the_hull,
	
	["intersection",
		togmod1_linear_extrude_z([-2, height+20], togmod1_make_rect([length_chunks*chunk+2, 1.5*inch-interior_offset*2])),
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
		if( !is_tgpish ) for( apos=[[0,1],[-1,0],[1,0],[0,-1]] )
			["translate", [cx*chunk + apos[0]*atom, apos[1]*atom, floor_thickness], hole1],
		if( !is_tgpish ) for( apos=[[0,0]] )
			["translate", [cx*chunk + apos[0]*atom, apos[1]*atom, floor_thickness], hole2],
	],
	
	for( sx=[-round(length/slot_spacing)/2+0.5 : 1 : round(length/slot_spacing)/2-0.4] )
	["translate", [sx*slot_spacing, 0, 0], slot],
]);
