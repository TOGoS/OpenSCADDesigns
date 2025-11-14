// TerrariumSegment0.12
// 
// A section of a terrarium that can be bolted together
// with other sections or other 1/2" gridbeam components.
// 
// TODO: For larger shapes, I want more mounting holes
// along each edge.  Need to either hardcode the shapes
// or dynamically adapt to avoid mounting hole positions.
// 
// v0.1:
// - Add inner flanges
// v0.2:
// - It is now an AvoydeYePoynce0 demo
// v0.3:
// - Mostly working using the avoyde stuff,
//   hole positioning is a little off
// v0.4:
// - Fix the hole placement algorithm.
// v0.5:
// - Fix the inner wall rath
// v0.6:
// - Render $fn = 48
// - Change wall generation to start from center and offset outwards
// v0.7:
// - Change hole placement to center of every non-corner chunk
//   when edge length is a multiple of 3 atoms
// v0.7.1:
// - Refactoring towards formalizing the APIs a bit
//   - make_terrarium_section can accept complex amounts for the size
//   - squavoiden[0] == "squavoiden", to make it clear what's up
// v0.8:
// - Expose parameters for floor_thickness, wall_inset, wall_thickness,
//   and inner_flange_depth
//   - This allows generating water tanks
// v0.8.1:
// - Factor out terrariumsegment0_make_squavoiden
// - squavoiden_to_hole_positions assumes 1/2 atom for hole inset if undefined
// v0.9
// - Fixes to flange generation for short-in-the-Z cases
// - Refactor to allow for pre-assembly transformations, e.g. to add ports
// - Even with fixes, CGAL trips up with the p2167 preset.
//   Try OpenSCAD 2024 with 'manifold' enabled.  It's faster, anyway.
// v0.10:
// - Options for outer_flange_slope, inner_flange_slope
// v0.11:
// - P2167Like ports are 3" apart instead of 4.5",
//   and add their own screw holes + columns
// v0.12:
// - Round corners with r=1/2inch

size_atoms = [9,9,9];
floor_thickness = 0;
wall_inset = 3.2;
wall_thickness = 2;
// dy/dx of outer flange
outer_flange_slope = 1; // 0.001
// dy/dx of inner flange
inner_flange_slope = 1; // 0.001
// 12.7 is a good minimum; 22.2 to allow something rest on top
inner_flange_depth = 12.7;
// May add more flexible configuration option later!
port_config = "none"; // ["none","P2167Like"]

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGVecLib0.scad>
use <../lib/AvoydeYePoynce0.scad>
use <../lib/TOGridLib3.scad>
use <../lib/TOGArrayLib1.scad>

module __terrariumsegment0__end_params() { }

$fn = $preview ? 16 : 48;

function is_divisible(num, den) =
	num / den == round(num/den);

/**
 * Find the greatest integer factor less than max_factor,
 * or, if there isn't one, the largest number <= max_factor
 * that evenly divides `number`.
 */
function find_factor(number, min_factor=3, max_factor=9999) =
	assert(min_factor <= number)
	min_factor > max_factor ? number / ceil(number / max_factor) :
	is_divisible(number, min_factor) ? min_factor :
	find_factor(number, min_factor+1, max_factor);

function generate_edge_hole_positions( length_atoms, min_distance_atoms=3, max_distance_atoms=7 ) =
	// Usual case: length_atoms is multiple of 3,
	// and we put one hole on each end and om the center of every other chunk:
	floor(length_atoms / 3) == length_atoms/3 ?
		[-length_atoms/2 + 0.5, for(x=[-length_atoms/2 + 4.5 : 3 : length_atoms/2 - 4.5]) x, length_atoms/2-0.5] :
	let(hole_spacing_atoms = find_factor(length_atoms - 1, round(min_distance_atoms), max_distance_atoms))
	// TODO: If divisor is too large, use fractional and round position for every hole
	[
		for(i=[0.5 : hole_spacing_atoms : length_atoms-0.5])
		(round(i-0.5)+0.5) - length_atoms/2
	];


function round_polypoints(polypoints, rad) = togpath1_rath_to_polypoints(["togpath1-rath",
	for(p=polypoints) ["togpath1-rathnode", p, ["round", rad]]
]);



// Sidepoints = [[x,y],rot,points]

// Transform a list of sidepointses to one big list of points.
// Useful for generating hole positions.
function sidepointses_to_point_positions(sidepointses) = [
	for( side=sidepointses ) each
		let( off = side[0] )
		let( ang = side[1] )
		let( points = side[2] )
		assert( is_num(off[0]) )
		assert( is_num(off[1]) )
		assert( is_num(ang) )
		let( sinang = sin(ang) )
		let( cosang = cos(ang) )
		[
			for( p=points )
			assert(is_num(p[0]))
			assert(is_num(p[1]))
			[
				off[0] + cosang*p[0] - sinang*p[1],
				off[1] + sinang*p[0] + cosang*p[1],
			]
		]
];

function cdr(list) = [for(i=[1:1:len(list)-1]) list[i]];

function skip_ends(arr, skip_begin=0, skip_end=0) =
	[for(i=[skip_begin:1:len(arr)-skip_end-1]) arr[i]];


// Sqavoiden = [
//   "squavoiden",
//   [width, height],
//   left_hole_positions,
//   top_hole_positions,
//   right_hole_positions,
//   bottom_hole_positions
// ]
// where hole positions are a list of numbers indicating position from the center of the side, counter-clockwise

function squavoiden_is_valid(squavoiden) =
	squavoiden[0] == "squavoiden" &&
	tal1_is_vec_of_num(squavoiden[1], 2) &&
	tal1_is_vec_of_num(squavoiden[2]) &&
	tal1_is_vec_of_num(squavoiden[3]) &&
	tal1_is_vec_of_num(squavoiden[4]);

function squavoiden_to_hole_positions(squavoiden, inset=undef) =
	let(_inset = is_undef(inset) ? togridlib3_decode([1/2, "atom"]) : inset)
	assert(squavoiden_is_valid(squavoiden))
	assert(is_num(_inset))
	let( halfw=squavoiden[1][0]/2, halfh=squavoiden[1][1]/2 )
	sidepointses_to_point_positions([
		[[ halfw,     0],  90, [for(x=squavoiden[2]) [x,_inset]]],
		[[     0, halfh], 180, [for(x=squavoiden[3]) [x,_inset]]],
		[[-halfw,     0], 270, [for(x=squavoiden[4]) [x,_inset]]],
		[[     0,-halfh],   0, [for(x=squavoiden[5]) [x,_inset]]],
	]);

function squavoiden_to_foil_polypoints(squavoiden, reg_y, point_y, slope_dx, point_dx, min_dx) =
	assert(squavoiden_is_valid(squavoiden))
	let(size = squavoiden[1])
	let(sidepointspointses = [
		for( i=[0:1:3] )
			let( side_hole_x_positions = squavoiden[2+i] )
			//let( middle_side_hole_x_positions = [for(i=[1:1:len(side_hole_x_positions)-2]) side_hole_x_positions[i]] )
			let( points = [
				//[side_hole_x_positions[0]+10, reg_y], // TODO: calculate right
				// TODO: Parameterize inset etc
				// May need to add in first and last points somehow
				each ayp0_avoyde_ye_poynce(reg_y, point_y, slope_dx, point_dx, min_dx, side_hole_x_positions),
				//[side_hole_x_positions[len(side_hole_x_positions)-1]-10, reg_y], // TODO: calculate right
			])
			skip_ends(points, 3, 3)
	])
	sidepointses_to_point_positions([
		[[ size[0]/2,       0  ],  90, sidepointspointses[0]],
		[[       0  , size[1]/2], 180, sidepointspointses[1]],
		[[-size[0]/2,       0  ], 270, sidepointspointses[2]],
		[[       0  ,-size[1]/2], 360, sidepointspointses[3]],
	]);

// Demo render with sharp corners
function render_squavoiden(squavoiden) =
let(size = squavoiden[1])
let(hole = tphl1_make_z_cylinder(zrange=[-10,10], d=5))
["difference",
	["union",
		togmod1_make_cuboid([size[0], size[1], atom/2]),
		togmod1_linear_extrude_z([0, 32], togmod1_make_polygon(
			squavoiden_to_foil_polypoints(squavoiden, atom/4, atom*3/4, 1, atom/4, atom/4)
		)),
	],
	for( hp = squavoiden_to_hole_positions(squavoiden) ) ["translate", hp, hole],
];

function terrariumsegment0_make_squavoiden(size_ca) = 
	let(size = togridlib3_decode_vector(size_ca))
	let(atom = togridlib3_decode([1, "atom"]))
	// TODO: Improve hole placement to prefer some 'standard' positions
	let(x_hole_positions = generate_edge_hole_positions(round(size[0]/atom))*atom)
	let(y_hole_positions = generate_edge_hole_positions(round(size[1]/atom))*atom)
	["squavoiden", size, y_hole_positions, x_hole_positions, y_hole_positions, x_hole_positions];

function make_terrarium_section(
	size_ca = [[9, "atom"], [9, "atom"], [9, "atom"]],
	flange_corner_radius = 6.35,
	flange_straight_height = 3.175,
	flange_depth = 25.4, // Pick a big number; it will be clamped as needed
	inner_flange_depth = 12.7,
	floor_thickness = 0,
	wall_inset = 3.175,
	wall_thickness = 2,
	flange_extend = 0, // Extend flanges outside the bounding box by this much (because you're going to intersect with something later)
	assembler = function(flanges, outer_wall, screw_holes, cavity, screw_hole_xy_positions) ["difference",
		["union",
			flanges,
			outer_wall,
		],
		["union", each screw_holes],
		cavity
	]
) =
	let(size = togridlib3_decode_vector(size_ca))
	let(atom = togridlib3_decode([1, "atom"]))
	let(squavoiden = terrariumsegment0_make_squavoiden(size_ca) )
	let(screw_hole_positions = squavoiden_to_hole_positions(squavoiden))
	let(corners = [[-1,-1],[1,-1],[1,1],[-1,1]])
	
	let(flangdat = let(
		sh = flange_straight_height,
		fd = flange_depth,
		fh = flange_depth * outer_flange_slope,
		fe = flange_extend,
		efh = min(fh, (size[2]-sh*2) / 2 + 1),
		efd = fd * efh/fh
	) [
		[-size[2]/2-fe    , + fe  ],
		[-size[2]/2+sh    , -  0  ],
		[-size[2]/2+sh+efh, -efd  ],
		[ size[2]/2-sh-efh, -efd  ],
		[ size[2]/2-sh    , -  0  ],
		[ size[2]/2+fe    , + fe  ]
	])
	// TODO: Assert that iflangdat's z positions are monotonic
	let(flanges = tphl1_make_polyhedron_from_layer_function(flangdat, function(zo) togvec0_offset_points(
		togpath1_rath_to_polypoints(["togpath1-rath",
			for( c=corners )
			["togpath1-rathnode", [c[0]*size[0]/2, c[1]*size[1]/2], ["offset", zo[1]], ["round", flange_corner_radius, $fn/4]],
		]),
		zo[0]
	)))
	let(iflangdat = let(
		sh = flange_straight_height,
		fd = inner_flange_depth,
		fh = inner_flange_depth * inner_flange_slope,
		floor_z = floor_thickness <= 0 ? -size[2] : -size[2]/2+floor_thickness,
		// Bottom base
		bb_z    = -size[2]/2 + max(sh, floor_thickness),
		// Top base
		tb_z    = size[2]/2 - sh,
		// Effective flange depth, accounting for how much space we have
		efh = min(fh, (tb_z - bb_z)/2 - 1),
		efd = fd * efh/fh
	) [
		if( floor_z < bb_z ) [floor_z, -fd],
		[ bb_z           , -fd ],
		[ bb_z + efh     , -fd + efd],
		[ tb_z - efh     , -fd + efd],
		[ tb_z           , -fd ],
		[ size[2]        , -fd ]
	])
	// TODO: Assert that iflangdat's z positions are monotonic
	let( cavity_flanged = tphl1_make_polyhedron_from_layer_function(iflangdat, function(zo) togvec0_offset_points(
		togpath1_rath_to_polypoints(["togpath1-rath",
			for( c=corners )
			["togpath1-rathnode", [c[0]*size[0]/2, c[1]*size[1]/2], ["offset", zo[1]], ["round", flange_corner_radius, $fn/4]],
		]),
		zo[0]
	)))

	let( wall_center_polypoints = squavoiden_to_foil_polypoints(
		squavoiden,
		// Inset by at least 0.01 to avoid CGAL errors `_`
		max(0.01, togridlib3_decode(wall_inset)) + wall_thickness/2,
		atom*7/8 + wall_thickness/2 - 0.1,
		1, atom/4, atom/4
	) )
	let( wall_center_rounded_rath = ["togpath1-rath", for( p=wall_center_polypoints ) ["togpath1-rathnode", p, ["round", 4, $fn/4]]] )
	let( outer_wall_polypoints = togpath1_rath_to_polypoints(togpath1_offset_rath(wall_center_rounded_rath, +wall_thickness/2)) )
	let( inner_wall_polypoints = togpath1_rath_to_polypoints(togpath1_offset_rath(wall_center_rounded_rath, -wall_thickness/2)) )
	let( outer_wall = tphl1_extrude_polypoints([-size[2]/2,size[2]/2], outer_wall_polypoints) )
	let( cavity_walled = tphl1_extrude_polypoints([-size[2],size[2]], inner_wall_polypoints) )
	let( cavity = ["intersection", cavity_walled, cavity_flanged] )
	
	let( screw_hole = tog_holelib2_hole("THL-1005", depth=30, overhead_bore_height=10) )
	let( screw_hole_xy_positions = skip_ends(screw_hole_positions,1) )
	let( screw_holes = [
		for( zm=[-1, 1] )
		// for( c=corners )
		// ["translate", [c[0]*(size[0]/2 - atom/2), c[1]*(size[1]/2 - atom/2), size[2]/2 + zm*size[2]/2+(flange_straight_height+atom/4)], ["scale", [1,1,-zm], screw_hole]]
		for( hp=screw_hole_xy_positions )
		["scale", [1,1,zm], ["translate", [hp[0], hp[1], -size[2]/2 + flange_straight_height+atom/4], screw_hole]]
	])
	assembler(flanges=flanges, outer_wall=outer_wall, screw_holes=screw_holes, cavity=cavity, screw_hole_xy_positions=screw_hole_xy_positions);

atom = 12.7;

squavoiden_1 = ["squavoiden", [100,50], [-20,+20], generate_edge_hole_positions(10,3)*10, [-20,+20], [-45,0,+45]];

function make_assembler(outer_additions=[], inner_additions=[], final_subtractions=[], final_intersections=[]) =
	function(flanges, outer_wall, screw_holes, cavity, screw_hole_xy_positions) ["intersection",
		["difference",
			["union",
				["difference",
					["union",
						flanges,
						outer_wall,
					],
					["union", each screw_holes],
				],
				each outer_additions,
			],
			["difference",
				cavity,
				each inner_additions
			],
			each final_subtractions
		],
		each final_intersections
	];

flange_extend = 2;

final_intersection_box =
	let( atom = togridlib3_decode([1, "atom"]) )
	let( size_mm = size_atoms*atom )
	togmod1_linear_extrude_z([-size_mm[2]/2, size_mm[2]/2], togmod1_make_rounded_rect([size_mm[0], size_mm[1]], r=atom/2));

/* // As it was previously defined
vanilla_assembler = function(flanges, outer_wall, screw_holes, cavity, screw_hole_xy_positions) ["difference",
	["union",
		flanges,
		outer_wall,
	],
	["union", each screw_holes],
	cavity
];
*/

vanilla_assembler = make_assembler(
	final_intersections = [final_intersection_box]
);

p2167_assembler =
	let( atom = togridlib3_decode([1, "atom"]) )
	let( port_y_positions = [-3*atom, 3*atom] )
	let( size_mm = size_atoms*atom )
	let( extra_hole = tphl1_make_z_cylinder(zrange=[-size_mm[2], size_mm[2]], d=5) )
	let( extra_hole_column = tphl1_make_z_cylinder(zrange=[-size_mm[2], size_mm[2]], d=9) )
	let( extra_hole_positions = [for(y=port_y_positions) for(ym=[-1.5,1.5])
		[(-size_atoms[0]/2+0.5) * atom, y + ym * atom] // If you move the ports, you'll need to adjust this!
	] )
	let( outer_additions=[for(y=port_y_positions)
		["translate", [0,y,0],
			["rotate", [0,90,0], tphl1_make_z_cylinder(zds=[
				[-size_mm[0]/2- 5, 38.1-10],
				[-size_mm[0]/2+20, 38.1+40],
				[ size_mm[0]/2-20, 38.1+40],
				[ size_mm[0]/2+ 5, 38.1-10],
			])]
		],
		for( pos=extra_hole_positions ) ["translate", pos, extra_hole_column],
	])
	let( inner_additions=[for(y=port_y_positions) for(x=[-size_mm[0]/2,size_mm[0]/2])
	   ["translate", [x,y,0],
			["rotate", [0,90,0], tphl1_make_z_cylinder(zds=[
				[-inner_flange_depth, 38.1                       ],
				[                  0, 38.1 + inner_flange_depth*2],
				[ inner_flange_depth, 38.1                       ],
			])]
		],
		for( pos=extra_hole_positions ) ["translate", pos, extra_hole_column],
	])
	let( final_subtractions = [for(y=port_y_positions)
		["translate", [0,y,0],
			["rotate", [0,90,0], tphl1_make_z_cylinder(d=32.5, zrange=[-size_mm[0], size_mm[0]])],
		],
		for( pos=extra_hole_positions ) ["translate", pos, extra_hole],
	])
	make_assembler(
		outer_additions = outer_additions,
		inner_additions = inner_additions,
		final_subtractions = final_subtractions,
		final_intersections = [final_intersection_box]
	);

thing_1 = make_terrarium_section(
	size_ca = [for(dim=size_atoms) [dim, "atom"]],
	floor_thickness = floor_thickness,
	wall_inset = wall_inset,
	wall_thickness = wall_thickness,
	inner_flange_depth = inner_flange_depth,
	flange_extend = flange_extend,
	assembler =
		port_config == "none" ? vanilla_assembler :
		port_config == "P2167Like" ? p2167_assembler :
		assert(false, str("Unrecognized port configuration: '", port_config, "'"))
);

thing_3 = render_squavoiden(squavoiden_1);

thing = thing_1;

togmod1_domodule(thing);
