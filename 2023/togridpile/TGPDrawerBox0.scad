// TGPDrawerBox0.1

$tgx11_offset = -0.1;
$fn = 32;

module rgpdrawerbox0__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGUnits1.scad>
use <../lib/TGx11.1Lib.scad>

width_atoms = 4;
cavity_width_atoms = width_atoms - 1;
depth_atoms = 6;
cavity_height_atoms = 3;
height_atoms = cavity_height_atoms + 1;

atom_mm = 12.7;

size_mm = [width_atoms*atom_mm, depth_atoms*atom_mm, height_atoms*atom_mm];

$togridlib3_unit_table = tgx11_get_default_unit_table();

u_mm = togunits1_to_mm("u");

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
	let( drawer_cavity =
		["difference",
			togmod1_linear_extrude_y([-size_mm[1]-1, size_mm[1]+1],
				drawer_cavity_xz([cavity_width_atoms*atom_mm, cavity_height_atoms*atom_mm])
			),
			
			["translate", [0, 3.175-size_mm[1]/2, cavity_height_atoms*atom_mm + 3.175],
				let(d = u_mm*1.414*2+$tgx11_offset*2)
				["rotate", [45, 0, 0], togmod1_make_cuboid([atom_mm, d, d])],
			],
			["translate", [0, size_mm[1]/2, 0],
				togmod1_make_cuboid([cavity_width_atoms*atom_mm+2, u_mm*2+$tgx11_offset*2, u_mm*2+$tgx11_offset*2]),
			],
		]
	)
	["difference",
		tgx11_block(
			[
				[width_atoms, "atom"],
				[depth_atoms, "atom"],
				[height_atoms, "atom"],
			],
			bottom_shape = "beveled",
			top_segmentation = "block",
			lip_height = -1
		),
		//["translate", [0,0,height_atoms*atom_mm/2],
		//	togmod1_make_cuboid([width_atoms*atom_mm, depth_atoms*atom_mm, height_atoms*atom_mm]),
		//],
		
		["translate", [0,0,atom_mm/2], drawer_cavity],
	]
);
