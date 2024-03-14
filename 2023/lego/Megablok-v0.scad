// Megablok-v0.1

chunk_h_pitch = 31.75; // 0.0001
chunk_v_pitch = 38.10; // 0.0001
chunk_actual_width = 31.4;
round_stud_diameter = 26.7;
stud_bevel_size = 4;
block_size_chunks = [2,1,1];
stud_height = 20.5;

preview_fn = 12;
render_fn = 48;

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>

$fn = $preview ? preview_fn : render_fn;

function togmegablok__scale_vec(a, b) = [
	for( i=[0 : 1 : len(a)-1] ) a[i] * (is_list(b) ? b[i] : b)
];

function make_megablok_system(
	chunk_size,
	outer_offset,
	stud_height=20.5,
) =
	let(round_stud = tphl1_make_z_cylinder(zds=[
		[                           -1, round_stud_diameter],
		[stud_height - stud_bevel_size, round_stud_diameter],
		[stud_height                  , round_stud_diameter - stud_bevel_size*2],
	]))
	echo(outer_offset=outer_offset)
	function(mode)
		mode == "block" ?
			function(size_chunks)
			let(size = togmegablok__scale_vec(size_chunks, chunk_size))
			let(chunk_cavity = ["difference",
				tphl1_make_rounded_cuboid([round_stud_diameter, round_stud_diameter, size[2]*2 - 4], r=4),
				["difference",
					["union",
						for( r=[0:90:270] ) ["rotate", [0,0,r],
							["translate", [chunk_size[0]/4, 0, 0], togmod1_make_cuboid([1,chunk_size[1],size[2]*2])]
						]
					],
					tphl1_make_z_cylinder(zds=[
						[                           -1, round_stud_diameter],
						[size[2] - 8 - stud_bevel_size, round_stud_diameter],
						[size[2] - 8                  , round_stud_diameter - stud_bevel_size*2],
					])
				]
			])
			echo(size_chunks = size_chunks, chunk_size = chunk_size, size = size)
			["union",
				["difference",
					["translate", [0,0,size[2]/2], tphl1_make_rounded_cuboid([
						size[0] + outer_offset*2,
						size[1] + outer_offset*2,
						size[2]
					], r=1)],
					
					for( xm=[-size_chunks[0]/2+0.5 : 1 : size_chunks[0]/2] )
					for( ym=[-size_chunks[1]/2+0.5 : 1 : size_chunks[1]/2] )
					["translate", [xm*chunk_size[0], ym*chunk_size[1], 0], chunk_cavity]
				],
				
				for( xm=[-size_chunks[0]/2+0.5 : 1 : size_chunks[0]/2] )
				for( ym=[-size_chunks[1]/2+0.5 : 1 : size_chunks[1]/2] )
				["translate", [xm*chunk_size[0], ym*chunk_size[1], size_chunks[2]*chunk_v_pitch], round_stud]
			] :
		assert(false, str("Unknown mode: '", mode, "'"));

blocksys = make_megablok_system(
	chunk_size = [chunk_h_pitch, chunk_h_pitch, chunk_v_pitch],
	outer_offset = (chunk_actual_width - chunk_h_pitch)/2
);

togmod1_domodule(blocksys("block")(block_size_chunks));
