// HollowFrenchCleat1.0
// 
// 3D-printable mostly-hollow French cleat section for light use

outer_wall_thickness = 2;
inner_wall_thickness = 0.8;

length_chunks =  5;
height_chunks =  2;
top_dydz      = +1;
bottom_dydz   = -1;
outer_offset  = -0.03;
bowtie_offset = -0.03;

$fn = 32;

use <../lib/RoundBowtie0.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>

function hfc1_shell( size, top_dydz, bottom_dydz, offset=0, front_offset=0 ) =
	let( length=size[0], height=size[1], thickness=size[2] )
	let(
		x0 = -length/2 - offset,
		x1 =  length/2 + offset,
		y0 = -height/2 + bottom_dydz*offset*0.4,
		y1 =  height/2 +    top_dydz*offset*0.4,
		z0 = -thickness/2 - offset,
		z1 =  thickness/2 + offset + front_offset
	)
	tphl1_make_polyhedron_from_layers([
		[
			[x1, y0 + z0*bottom_dydz, z0],
			[x1, y1 + z0*   top_dydz, z0],
			[x0, y1 + z0*   top_dydz, z0],
			[x0, y0 + z0*bottom_dydz, z0],
		],
		[
			[x1, y0 + z1*bottom_dydz, z1],
			[x1, y1 + z1*   top_dydz, z1],
			[x0, y1 + z1*   top_dydz, z1],
			[x0, y0 + z1*bottom_dydz, z1],
		]
	]);

chunk_pitch = 38.1;
atom_pitch = 12.7;
size = [length_chunks*chunk_pitch, height_chunks*chunk_pitch, chunk_pitch/2];

outer_hull = hfc1_shell(size, top_dydz, bottom_dydz, offset=outer_offset);

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
	hfc1_shell(size, top_dydz, bottom_dydz, offset=outer_offset-outer_wall_thickness, front_offset=outer_wall_thickness*2),
	
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
