// DovetailTrackSection0.1
// 
// Gridbeam / TOGRack-compatible chunk with
// a Matchfit-compatible dovetail slot.

// More negative makes bigger holes
bowtie_offset = -0.2;
length_chunks = 4;

module __dts0__end_params() { }

use <../lib/BowtieLib-v0.scad>
use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMatchfitLib1.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>

function make_slot(
	length,
	taper_length = 9.525,
	pp = tmfl1_get_matchfit_groove_profile_points()
) =
	tphl1_make_polyhedron_from_layer_function([
		[-1/2, -1, 1.2],
		[-1/2,  1, 1  ],
		[ 1/2, -1, 1  ],
		[ 1/2,  1, 1.2],
	], function(params)
		let(x = params[0]*length + params[1]*taper_length)
		let(yzscale = params[2])
		[for(p=pp) [x, p[0]*yzscale, p[1]*yzscale]]
	);

function make_hull(size) = 
	let( hr = 9.525, vr = 1 )
	tphl1_make_rounded_cuboid(size, [hr, hr, vr], corner_shape="ovoid1");

atom_pitch = 12.7;
chunk_pitch_atoms = 3;
chunk_pitch = chunk_pitch_atoms*atom_pitch;
length_atoms = length_chunks * chunk_pitch_atoms;

$fn = $preview ? 12 : 64;
block_size = [length_chunks * chunk_pitch, chunk_pitch, 12.7];
u=25.4/32;
slot_depth = 13*u; // Matching what the library does

small_hole = tog_holelib2_hole("THL-1001", depth=block_size[2]*2, overhead_bore_height=block_size[2], inset=0.1);
big_hole = tog_holelib2_hole("THL-1002", depth=block_size[2]*2, overhead_bore_height=block_size[2], inset=0.1);

holes = [
	for( xm=[-length_chunks/2+0.5, length_chunks/2-0.5] ) ["franslate", [-xm*chunk_pitch, 0, 0, 1], big_hole],
	for( xm=[-length_atoms/2+2.5:1:length_atoms/2-2.5] ) ["franslate", [xm*atom_pitch, 0, 0, 1], small_hole],
	// Assumes width = 3 atoms
	for( xm=[-length_atoms/2+0.5:1:length_atoms/2] ) for( ym=[-1, 1] ) ["franslate", [xm*atom_pitch, ym*atom_pitch, 1, 0], small_hole],
];

bowtie_point_data = get_bowtie_point_data();
function make_bowtie_rath(point_data, vex, vexop) =
let( btu=19.05/6 )
["togpath1-rath",
	for( pd=point_data ) ["togpath1-rathnode", [pd[0]*btu, pd[1]*btu], if(pd[4] == vex) vexop]
];
bowtie_rath = togpath1_offset_rath(
	make_bowtie_rath(bowtie_point_data, "concave", ["round", 3.175]),
	-bowtie_offset
);

floor_z = block_size[2]-slot_depth;

bowtie_points = togpath1_rath_to_polypoints(bowtie_rath);
bowtie_cutout = tphl1_make_polyhedron_from_layer_function([
	[-1, 1],
	[max(3.175 + 0.2, floor_z+0.1), 1],
	[block_size[2], 0]
], function(params) let(z=params[0], xyfact=params[1])
	[for(p=bowtie_points) [p[0]*xyfact, p[1]*xyfact, z]]
);

togmod1_domodule(["difference",
	["translate", [0,0,block_size[2]/2], make_hull(block_size)],
	["translate", [0,0,block_size[2]], make_slot(block_size[0])],
	for( h=holes )
		assert(h[0] == "franslate")
		let( holez = h[1][2]*block_size[2]+h[1][3]*floor_z )
		["translate", [h[1][0], h[1][1], holez], h[2]],
	for( x=[-block_size[0]/2, block_size[0]/2] ) ["translate", [x,0,0], bowtie_cutout],
]);
