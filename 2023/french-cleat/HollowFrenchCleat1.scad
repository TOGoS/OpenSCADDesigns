// HollowFrenchCleat1.1
// 
// 3D-printable mostly-hollow French cleat section for light use
//
// v1.1:
// - end_offset separately configurable from outer_offset,
//   default is to only offset the ends slightly
// - Attempt to properly calculate y offsets for given slopes.
//   - Currently works approximately for -1, 0, and 1
//   - At least dydz = 0 works, now.

outer_wall_thickness = 2;
inner_wall_thickness = 0.8;

length_chunks =  5;
height_chunks =  2;
top_dydz      = +1; // [-1, 0, 1]
bottom_dydz   = -1; // [-1, 0, 1]
end_offset    = -0.03;
outer_offset  = -0.00;
bowtie_offset = -0.03;

$fn = 32;

use <../lib/RoundBowtie0.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>

module assert_equals(expected, actual) {
	assert(abs(expected - actual) < 0.01, str("Expected ", expected, "; got ", actual));
}

// I forget the combination of trigonometric functions to do it and
// don't want to think about it right now.
// TOGPath1 does this properly for vertex offsets.
// I should make a diagram and put it on nuke24.net or something.

function hfc1_van(dydz) =
	// TODO: atan2 something something
	// something to do with 'miter limit'?
	dydz > 0  ? 0.404 :
	dydz == 0 ? 1 :
	dydz < 0  ? 2.4 :
	assert(false);

assert_equals(1, hfc1_van(0));
assert_equals(0.404, hfc1_van(1));
assert_equals(2.4, hfc1_van(-1)); // TODO what should it actually be lmao

function hfc1_shell( size, top_dydz, bottom_dydz, offset=0, front_offset=0, end_offset=0 ) =
	echo( offset=offset, shell_y1_van = hfc1_van(top_dydz) )
	let( length=size[0], height=size[1], thickness=size[2] )
	let(
		x0 = -length/2 - offset - end_offset,
		x1 =  length/2 + offset + end_offset,
		// y0, y1 refer to at the bottom
		y0 = -height/2 - bottom_dydz*thickness/2 - offset * hfc1_van(-bottom_dydz),
		y1 =  height/2 -    top_dydz*thickness/2 + offset * hfc1_van(    top_dydz),
		z0 = -thickness/2 - offset,
		z1 =  thickness/2 + offset + front_offset
	)
	tphl1_make_polyhedron_from_layers([
		[
			[x1, y0, z0],
			[x1, y1, z0],
			[x0, y1, z0],
			[x0, y0, z0],
		],
		[
			[x1, y0 + (z1-z0)*bottom_dydz, z1],
			[x1, y1 + (z1-z0)*   top_dydz, z1],
			[x0, y1 + (z1-z0)*   top_dydz, z1],
			[x0, y0 + (z1-z0)*bottom_dydz, z1],
		]
	]);

chunk_pitch = 38.1;
atom_pitch = 12.7;
size = [length_chunks*chunk_pitch, height_chunks*chunk_pitch, chunk_pitch/2];

outer_hull = hfc1_shell(size, top_dydz, bottom_dydz, offset=outer_offset, end_offset=end_offset);

atom_hollow = hfc1_shell([atom_pitch, size[1], size[2]], top_dydz, bottom_dydz, offset=outer_offset-outer_wall_thickness, front_offset=outer_wall_thickness*2);
atom_hole = tphl1_make_z_cylinder(zrange=[-size[2], +size[2]], d=4.5);

bowtie_border = togmod1_linear_extrude_z([-size[2], size[2]], roundbowtie0_make_bowtie_2d(atom_pitch/2, offset=outer_wall_thickness-bowtie_offset));
bowtie_cutout = togmod1_linear_extrude_z([-size[2], size[2]], roundbowtie0_make_bowtie_2d(atom_pitch/2, offset=-bowtie_offset));

bowtie_positions = [
	for( ym=[-size[1]/chunk_pitch/2 + 0.5 : 1 : size[1]/chunk_pitch/2 - 0.4] )
	for( xm=[-1 , +1] )
	[xm * size[0]/2, ym*chunk_pitch, 0]
];

hollow =
let(ywall = togmod1_make_cuboid([inner_wall_thickness, size[1]*2, size[2]*2]))
let(xwall = togmod1_make_cuboid([size[0]*2, inner_wall_thickness, size[2]*2]))
["difference",
	hfc1_shell(size, top_dydz, bottom_dydz, offset=outer_offset-outer_wall_thickness, front_offset=outer_wall_thickness*2, end_offset=end_offset),
	
	for( xm=[-size[0]/atom_pitch/2 + 1 : 1 : size[0]/atom_pitch/2 - 1] )
		["translate", [xm*atom_pitch, 0, 0], ywall],
	for( ym=[-size[1]/chunk_pitch/2 + 1 : 1 : size[1]/chunk_pitch/2 - 1] )
		["translate", [0, ym*chunk_pitch, 0], xwall],
];

togmod1_domodule(["difference",
	outer_hull,
	
	["difference",
		["union",
			hollow,
			//for( xm=[-size[0]/atom_pitch/2 + 0.5 : 1 : size[0]/atom_pitch/2] )
			//	["translate", [xm*atom_pitch, 0, 0], atom_hollow],
			
			for( xm=[-size[0]/atom_pitch/2 + 0.5 : 1 : size[0]/atom_pitch/2 - 0.4] )
			for( ym=[-size[1]/atom_pitch/2 + 1.5 : 1 : size[1]/atom_pitch/2 - 1.4] )
				["translate", [xm*atom_pitch, ym*atom_pitch, 0], atom_hole],
		],
		
		for( pos=bowtie_positions ) ["translate", pos, bowtie_border],
	],
	for( pos=bowtie_positions ) ["translate", pos, bowtie_cutout],
]);
