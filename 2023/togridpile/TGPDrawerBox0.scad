// TGPDrawerBox0.3
// 
// v0.2:
// - Atom-segment the sides
// v0.3:
// - Width, depth, height are now customizable
// - Options for tooth_style and tooth_inset
// 
// TODO: Thumb slots
// 
// TODO: Back (with screw holes!)
// 
// TODO: Make that lip in the back optional
// 
// Hmm: adjustable shelves via slots in the sides every 1/4"?

width = "2inch";
depth = "3inch";
height = "2inch";
tooth_inset = "1/8inch";
tooth_style = "triangular-prism"; // ["none","triangular-prism","THL-1008"]

$tgx11_offset = -0.1;
$fn = 32;

module rgpdrawerbox0__end_params() { }

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGUnits1.scad>
use <../lib/TGx11.1Lib.scad>

$togridlib3_unit_table = tgx11_get_default_unit_table();

tooth_inset_mm = togunits1_to_mm(tooth_inset);
nominal_shelf_thickness_mm = togunits1_to_mm("1/2atom");

size_mm = togunits1_vec_to_mms([width, depth, height]);
size_atoms = togunits1_decode_vec([width, depth, height], unit="atom", xf="round");

cavity_size_atoms = [for(d=size_atoms) d-1];
cavity_width_chunks = round(cavity_size_atoms[0]/3);

u_mm     = togunits1_to_mm("u");
atom_mm  = togunits1_to_mm("atom");
chunk_mm = togunits1_to_mm("chunk");

function drawer_cavity_xz(size, lip_height=2.54) =
	["offset-ds", -$tgx11_offset,
		togmod1_make_polygon([
			[ size[0]/2, 0],
			[ size[0]/2, size[1] + lip_height],
			[-size[0]/2, size[1] + lip_height],
			[-size[0]/2, 0],
		])
	];

togmod1_domodule(
	let( tooth_positions = [
		for( xm = [-cavity_width_chunks/2 + 0.5 : 1 : cavity_width_chunks - 0.5] )
		let( y = -size_mm[1]/2 + tooth_inset_mm )
		let( z = cavity_size_atoms[2] * atom_mm )
		[xm*chunk_mm, y, z]
	] )
	let( drawer_cavity =
		["difference",
			["union",
				togmod1_linear_extrude_y([-size_mm[1]-1, size_mm[1]+1],
					drawer_cavity_xz([cavity_size_atoms[0]*atom_mm, cavity_size_atoms[2]*atom_mm])
				),
				
				if( tooth_style == "THL-1008" )
				for( pos = tooth_positions )
				["translate", [pos[0],pos[1],pos[2]+nominal_shelf_thickness_mm],
					tog_holelib2_hole(tooth_style, depth=7, overhead_bore_height=1)
				]
			],
			
			each tooth_style == "triangular-prism" ? [
				for( pos = tooth_positions )
				let( r = u_mm*1.414+$tgx11_offset )
				["translate", [pos[0], pos[1], pos[2]+r],
					["rotate", [45, 0, 0], togmod1_make_cuboid([atom_mm, r*2, r*2])],
				],
			] : [],
			
			["translate", [0, size_mm[1]/2, 0],
				togmod1_make_cuboid([
					cavity_size_atoms[0]*atom_mm+2,
					u_mm*2+$tgx11_offset*2,
					u_mm*2+$tgx11_offset*2
				]),
			],
		]
	)
	["difference",
		let( side = ["render",tgx11_block_bottom(
			[
				[size_atoms[2], "atom"],
				[size_atoms[1], "atom"],
				[size_atoms[0] + 1, "atom"]
			],
			bottom_shape = "beveled"
		)])
		["intersection",
			["render", tgx11_block(
				[
					[size_atoms[0], "atom"],
					[size_atoms[1], "atom"],
					[size_atoms[2], "atom"],
				],
				bottom_shape = "beveled",
				top_segmentation = "block",
				lip_height = -1
			)],
			["translate", [ size_mm[0]/2-1/1024, 0, size_mm[2]/2], ["rotate", [0,-90,0], side]],
			["translate", [-size_mm[0]/2+1/1024, 0, size_mm[2]/2], ["rotate", [0, 90,0], side]],
			togmod1_linear_extrude_x([-size_mm[0], size_mm[0]],
				["offset-ds", $tgx11_offset,
					togmod1_make_polygon([
						[ size_mm[1]/2+1,           -1],
						[ size_mm[1]/2+1, size_mm[2]+1],
						for( y=[size_atoms[1]/2 - 1 : -1 : -size_atoms[1]/2 + 1] ) each [
							[atom_mm*y+3*u_mm, size_mm[2]+2*u_mm],
							[atom_mm*y+1*u_mm, size_mm[2]-1*u_mm],
							[atom_mm*y-1*u_mm, size_mm[2]-1*u_mm],
							[atom_mm*y-3*u_mm, size_mm[2]+2*u_mm],
						],
						[-size_mm[1]/2-1, size_mm[2]+1],
						[-size_mm[1]/2-1,           -1],
					])
				]
			)
		],
		//["translate", [0,0,size_mm[2]/2],
		//	togmod1_make_cuboid([width_atoms*atom_mm, depth_atoms*atom_mm, size_mm[2]]),
		//],
		
		["translate", [0,0,atom_mm/2], drawer_cavity],
	]
);
