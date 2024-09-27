// TerrariumSegment0.1
// 
// A section of a terrarium that can be bolted together
// with other sections or other 1/2" gridbeam components.
// 
// TODO: For larger shapes, I want more mounting holes
// along each edge.  Need to either hardcode the shapes
// or dynamically adapt to avoid mounting hole positions.
// 
// v0.1: Add inner flanges
// 
// TODO
// - [ ] Wave flanges
//   - can use algorithm from AvoydeYePoynce.scad to generate shape
//     from a list of screw hole points

size_atoms = [9,9,9];

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGVecLib0.scad>

module __terrariumsegment0__end_params() { }

$fn = 16;

function make_terrarium_section(
	size = [114.3, 114.3, 114.3],
	flange_corner_radius = 6.35,
	flange_straight_height = 3.175,
	flange_depth = 25.4,
	inner_flange_depth = 12.7,
	wall_thickness = 2,
	atom = 12.7
) =
	let(corners = [[-1,-1],[1,-1],[1,1],[-1,1]])
	let(flangdat = let(
		sh = flange_straight_height,
		fd = flange_depth
	) [
		[      0      , - 0  ],
		[      0+sh   , - 0  ],
		[      0+sh+fd, -fd  ],
		[size[2]-sh-fd, -fd  ],
		[size[2]-sh   , - 0  ],
		[size[2]      , - 0  ]
	])
	let(flanges = tphl1_make_polyhedron_from_layer_function(flangdat, function(zo) togvec0_offset_points(
		togpath1_rath_to_polypoints(["togpath1-rath",
			for( c=corners )
			["togpath1-rathnode", [c[0]*size[0]/2, c[1]*size[1]/2], ["offset", zo[1]], ["round", flange_corner_radius, $fn/4]],
		]),
		zo[0]
	)))
	let( wall_basic_outer_rathnodes = [
		// TODO: Instead of messing with 'corners',
		// calculate shape for each edge; gaps between
		// them will automatically become bevels
		for( c=corners )
		["togpath1-rathnode", [c[0]*size[0]/2, c[1]*size[1]/2], ["offset", -3.175], ["bevel", atom*1.2]],
	])
	let( outer_wall = tphl1_extrude_polypoints([0,size[2]], togpath1_rath_to_polypoints(["togpath1-rath",
		for( n=wall_basic_outer_rathnodes ) [each n, ["round", 6.35, $fn/4]]
	])))
	let(iflangdat = let(
		sh = flange_straight_height,
		fd = inner_flange_depth
	) [
		[       -1    , -fd ],
		[      0+sh   , -fd ],
		[      0+sh+fd,  0  ],
		[size[2]-sh-fd,  0  ],
		[size[2]-sh   , -fd ],
		[size[2]+1    , -fd ]
	])
	let( cavity_flanged = tphl1_make_polyhedron_from_layer_function(iflangdat, function(zo) togvec0_offset_points(
		togpath1_rath_to_polypoints(["togpath1-rath",
			for( c=corners )
			["togpath1-rathnode", [c[0]*size[0]/2, c[1]*size[1]/2], ["offset", zo[1]], ["round", flange_corner_radius, $fn/4]],
		]),
		zo[0]
	)))
	let( cavity_walled = tphl1_extrude_polypoints([-1,size[2]+1], togpath1_rath_to_polypoints(["togpath1-rath",
		for( n=wall_basic_outer_rathnodes ) [each n, ["offset", -wall_thickness], ["round", 6.35, $fn/4]]
	])))
	let( cavity = ["intersection", cavity_walled, cavity_flanged] )
	let( screw_hole = tog_holelib2_hole("THL-1005", depth=30, overhead_bore_height=10) )
	let( screw_holes = [
		for( zm=[-1, 1] )	for( c=corners )
		["translate", [c[0]*(size[0]/2 - atom/2), c[1]*(size[1]/2 - atom/2), size[2]/2 + zm*size[2]/2+(flange_straight_height+atom/4)], ["scale", [1,1,-zm], screw_hole]]
	])
	["difference",
		["union",
			flanges,
			outer_wall
		],
		["union", each screw_holes],
		cavity
	];

atom = 12.7;

togmod1_domodule(make_terrarium_section(
	atom = atom,
	size = size_atoms*atom
));
