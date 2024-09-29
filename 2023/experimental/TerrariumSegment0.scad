// TerrariumSegment0.4
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
use <../lib/AvoydeYePoynce0.scad>

module __terrariumsegment0__end_params() { }

$fn = 16;

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

/**
 * Generate hole X positions along an edge X = -length/2 to length/2,
 * where each hole is centered on an atom-sized cell.
 * Try to place holes at least min_distance apart,
 * but never more than max_distance apart.
 */
function generate_edge_hole_positions(length, atom, min_distance, max_distance=9999) =
	assert(is_num(length))
	assert(is_num(atom))
	assert(is_num(min_distance))
	let(length_atoms = round(length/atom))
	let(hole_spacing_atoms = find_factor(length_atoms - 1, round(min_distance/atom), max_distance/atom))
	// TODO: If divisor is too large, use fractional and round position for every hole
	[
		for(i=[0.5 : hole_spacing_atoms : length_atoms-0.5])
		(round(i-0.5)+0.5) * atom - length/2
	];

module assert_equals(expected, actual) {
	assert(expected == actual, str("Expected ", expected, " but got ", actual));
}

assert_equals([-30, 0, 30], generate_edge_hole_positions(70, 10, 30));
assert_equals([-45, -15, 15, 45], generate_edge_hole_positions(100, 10, 30));
assert_equals([-40, 0, 40], generate_edge_hole_positions( 90, 10, 30));
assert_equals([-40, -10, 10, 40], generate_edge_hole_positions( 90, 10, 30, 30));
assert_equals([-55, -15, 15, 55], generate_edge_hole_positions( 120, 10, 30, 45));




function round_polypoints(polypoints, rad) = togpath1_rath_to_polypoints(["togpath1-rath",
	for(p=polypoints) ["togpath1-rathnode", p, ["round", rad]]
]);



// sidepoints :: [[x,y],rot,points]
function transform_sidepointses(sidepointses) = [
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

function skip_ends(arr, skip_begin=0, skip_end=0) =
	[for(i=[skip_begin:1:len(arr)-skip_end-1]) arr[i]];

function squavoiden_to_foil_polypoints(squavoiden, reg_y, point_y, slope_dx, point_dx, min_dx) =
	let(size = squavoiden[0])
	let(sidepointspointses = [
		for( i=[0:1:3] )
			let( side_hole_x_positions = squavoiden[i+1] )
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
	transform_sidepointses([
		[[ size[0]/2,       0  ],  90, sidepointspointses[0]],
		[[       0  , size[1]/2], 180, sidepointspointses[1]],
		[[-size[0]/2,       0  ], 270, sidepointspointses[2]],
		[[       0  ,-size[1]/2], 360, sidepointspointses[3]],
	]);

// Demo render with sharp corners
function render_squavoiden(squavoiden) =
let(size = squavoiden[0])
let(hole = tphl1_make_z_cylinder(zrange=[-10,10], d=5))
["difference",
	["union",
		togmod1_make_cuboid([size[0], size[1], atom/2]),
		togmod1_linear_extrude_z([0, 32], togmod1_make_polygon(
			squavoiden_to_foil_polypoints(squavoiden, atom/4, atom*3/4, 1, atom/4, atom/4)
		)),
	],
	for( hp = squavoiden_to_hole_positions(squavoiden, 5) ) ["translate", hp, hole],
];




// Sqavoiden = [[width, height], left_hole_positions, top_hole_positions, right_hole_positions, bottom_hole_positions]
// where hole positions are a list of numbers indicating position from the center of the side, counter-clockwise

function squavoiden_to_hole_positions(squavoiden, inset) =
	assert(is_num(inset))
	let( halfw=squavoiden[0][0]/2, halfh=squavoiden[0][1]/2 )
	transform_sidepointses([
		[[ halfw,     0],  90, [for(x=squavoiden[1]) [x,inset]]],
		[[     0, halfh], 180, [for(x=squavoiden[2]) [x,inset]]],
		[[-halfw,     0], 270, [for(x=squavoiden[3]) [x,inset]]],
		[[     0,-halfh],   0, [for(x=squavoiden[4]) [x,inset]]],
	]);



function make_terrarium_section(
	size = [114.3, 114.3, 114.3],
	flange_corner_radius = 6.35,
	flange_straight_height = 3.175,
	flange_depth = 25.4,
	inner_flange_depth = 12.7,
	wall_thickness = 2,
	atom = 12.7,
) =
	let(x_hole_positions = generate_edge_hole_positions(size[0], atom, 3*atom, 7*atom))
	let(y_hole_positions = generate_edge_hole_positions(size[1], atom, 3*atom, 7*atom))
	let(squavoiden = [size, y_hole_positions, x_hole_positions, y_hole_positions, x_hole_positions])
	let(screw_hole_positions = squavoiden_to_hole_positions(squavoiden, atom/2))
	let(corners = [[-1,-1],[1,-1],[1,1],[-1,1]])
	let(flangdat = let(
		sh = flange_straight_height,
		fd = flange_depth
	) [
		[-size[2]/2      , - 0  ],
		[-size[2]/2+sh   , - 0  ],
		[-size[2]/2+sh+fd, -fd  ],
		[ size[2]/2-sh-fd, -fd  ],
		[ size[2]/2-sh   , - 0  ],
		[ size[2]/2      , - 0  ]
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
		//for( c=corners )
		//["togpath1-rathnode", [c[0]*size[0]/2, c[1]*size[1]/2], ["offset", -3.175], ["bevel", atom*1.2]],
		for( p = squavoiden_to_foil_polypoints(squavoiden, atom/4, atom*7/8-0.1, 1, atom/4, atom/4) )
			["togpath1-rathnode", p]
	])
	let( outer_wall = tphl1_extrude_polypoints([-size[2]/2,size[2]/2], togpath1_rath_to_polypoints(["togpath1-rath",
		for( n=wall_basic_outer_rathnodes ) [each n, ["round", 6.35, $fn/4]]
	])))
	let(iflangdat = let(
		sh = flange_straight_height,
		fd = inner_flange_depth
	) [
		[-size[2]        , -fd ],
		[-size[2]/2+sh   , -fd ],
		[-size[2]/2+sh+fd,  0  ],
		[ size[2]/2-sh-fd,  0  ],
		[ size[2]/2-sh   , -fd ],
		[ size[2]        , -fd ]
	])
	let( cavity_flanged = tphl1_make_polyhedron_from_layer_function(iflangdat, function(zo) togvec0_offset_points(
		togpath1_rath_to_polypoints(["togpath1-rath",
			for( c=corners )
			["togpath1-rathnode", [c[0]*size[0]/2, c[1]*size[1]/2], ["offset", zo[1]], ["round", flange_corner_radius, $fn/4]],
		]),
		zo[0]
	)))
	let( cavity_walled = tphl1_extrude_polypoints([-size[2],size[2]], togpath1_rath_to_polypoints(["togpath1-rath",
		for( n=wall_basic_outer_rathnodes ) [each n, ["offset", -wall_thickness], ["round", 6.35, $fn/4]]
	])))
	let( cavity = ["intersection", cavity_walled, cavity_flanged] )
	let( screw_hole = tog_holelib2_hole("THL-1005", depth=30, overhead_bore_height=10) )
	let( screw_holes = [
		for( zm=[-1, 1] )
		// for( c=corners )
		// ["translate", [c[0]*(size[0]/2 - atom/2), c[1]*(size[1]/2 - atom/2), size[2]/2 + zm*size[2]/2+(flange_straight_height+atom/4)], ["scale", [1,1,-zm], screw_hole]]
		for( hp=skip_ends(screw_hole_positions,1) )
		["scale", [1,1,zm], ["translate", [hp[0], hp[1], -size[2]/2 + flange_straight_height+atom/4], screw_hole]]
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

squavoiden_1 = [[100,50], [-20,+20], generate_edge_hole_positions(100,10,30), [-20,+20], [-45,0,+45]];

thing_1 = make_terrarium_section(size_atoms * atom);

thing_3 = render_squavoiden(squavoiden_1);

thing = thing_1;

togmod1_domodule(thing);
