// TGPDrawerBox0.5
// 
// v0.2:
// - Atom-segment the sides
// v0.3:
// - Width, depth, height are now customizable
// - Options for tooth_style and tooth_inset
// v0.4:
// - Optional back, with holes and optional 'hatom' segmentation
// - Back lip height can be customized
// v0.5:
// - Slots for shelves every 1/4"
// 
// TODO: Thumb slots

width = "2inch";
depth = "3inch";
height = "2inch";
tooth_inset = "1/8inch";
tooth_style = "triangular-prism"; // ["none","triangular-prism","THL-1008"]
back_thickness = "0inch";
back_segmentation = "none"; // ["none","hatom"]
back_lip_height = "1u";
shelf_slot_depth = "0u";

$tgx11_offset = -0.1;
$fn = 32;

module rgpdrawerbox0__end_params() { }

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGUnits1.scad>
use <../lib/TGx11.1Lib.scad>

$togridlib3_unit_table = tgx11_get_default_unit_table();

u_mm     = togunits1_to_mm("u");
atom_mm  = togunits1_to_mm("atom");
chunk_mm = togunits1_to_mm("chunk");

tooth_inset_mm = togunits1_to_mm(tooth_inset);
nominal_shelf_thickness_mm = togunits1_to_mm("1/2atom");

size_mm = togunits1_vec_to_mms([width, depth, height]);
size_atoms = togunits1_decode_vec([width, depth, height], unit="atom", xf="round");

cavity_size_atoms = [for(d=size_atoms) d-1];
cavity_size_mm    = [for(d=cavity_size_atoms) d*atom_mm];
cavity_width_chunks = round(cavity_size_atoms[0]/3);
back_thickness_mm  = togunits1_to_mm(back_thickness);
back_lip_height_mm = togunits1_to_mm(back_lip_height);
back_lip_width_mm  = togunits1_to_mm("1/2tgp-standard-bevel");
shelf_slot_depth_mm = togunits1_to_mm(shelf_slot_depth);

function drawer_cavity_xz(size, lip_height=2.54) =
	let( height_atoms = round(size[1] / atom_mm) )
	let( mirrar_points = function(points) [
		each points,
		for( i=[len(points)-1 : -1 : 0] ) let( p = points[i] )
		[-p[0], p[1]],
	])
	["offset-ds", -$tgx11_offset,
		togmod1_make_polygon(mirrar_points([
			for( ym=[0 : 1/2 : height_atoms-0.1] ) each [
				[ size[0]/2                      , (ym+0/4)*atom_mm],
				[ size[0]/2                      , (ym+1/4)*atom_mm],
				[ size[0]/2 + shelf_slot_depth_mm, (ym+1/4)*atom_mm],
				[ size[0]/2 + shelf_slot_depth_mm, (ym+2/4)*atom_mm],
			],
			[size[0]/2, size[1]             ],
			[size[0]/2, size[1] + lip_height],
		]))
	];

function hatom_bottom(size) =
	let( ridge_count = size[1]/atom_mm )
	togmod1_linear_extrude_x([-size_mm[0], size_mm[0]],
		["offset-ds", $tgx11_offset,
			togmod1_make_polygon([
				[-size[1]/2-1, size[2]+1],
				[-size[1]/2-1, -1],
				for( y=[ridge_count/2 - 1 : -1 : -ridge_count/2 + 1] ) each [
					[atom_mm*y-2*u_mm, -1*u_mm],
					[atom_mm*y-1*u_mm,  1*u_mm],
					[atom_mm*y+1*u_mm,  1*u_mm],
					[atom_mm*y+2*u_mm, -1*u_mm],
				],
				[ size[1]/2+1, -1],
				[ size[1]/2+1, size[2]+1],
			])
		]
	);

togmod1_domodule(
	let( tooth_positions = [
		for( xm = [-cavity_width_chunks/2 + 0.5 : 1 : cavity_width_chunks - 0.5] )
		let( y = -size_mm[1]/2 + tooth_inset_mm )
		let( z = cavity_size_atoms[2] * atom_mm )
		[xm*chunk_mm, y, z]
	] )
	let( back_hole = tog_holelib2_hole("THL-1005",
		depth=back_thickness_mm+1, overhead_bore_height = 2, inset=1.6) )
	let( drawer_cavity =
		["difference",
			["union",
				togmod1_linear_extrude_y(
					[
						-size_mm[1]/2-1,
						back_thickness_mm > 0 ? size_mm[1]/2 - back_thickness_mm : size_mm[1]/2+1
					],
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
			
			if( back_lip_height_mm > 0 )
			["translate", [0, size_mm[1]/2 - back_thickness_mm, 0],
				togmod1_make_cuboid([
					cavity_size_mm[0]+2,
					back_lip_width_mm*2,
					back_lip_height_mm*2,
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
			// Bottom
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
			// Right
			["translate", [ size_mm[0]/2-1/1024, 0, size_mm[2]/2], ["rotate", [0,-90,0], side]],
			// Left
			["translate", [-size_mm[0]/2+1/1024, 0, size_mm[2]/2], ["rotate", [0, 90,0], side]],
			// Top
			["translate", [ 0, 0, size_mm[2]], ["rotate", [0,180,0],
				hatom_bottom(size_mm, $tgx11_offset=$tgx11_offset-1/2048)]],
			// Back
			each
				back_segmentation == "hatom" ? [
					["translate", [ 0, size_mm[1]/2, size_mm[2]/2], ["rotate", [90,0,0],
						hatom_bottom([size_mm[0],size_mm[2],size_mm[1]],
							$tgx11_offset=$tgx11_offset-1/2048)]]
				] :
				back_segmentation == "none" ? [] :
				assert(false, str("Unrecognized 'back_segmentation': '", back_segmentation, "'")),
		],
		//["translate", [0,0,size_mm[2]/2],
		//	togmod1_make_cuboid([width_atoms*atom_mm, depth_atoms*atom_mm, size_mm[2]]),
		//],
		
		["translate", [0,0,atom_mm/2], drawer_cavity],
		
		if( back_thickness_mm > 0 )
		for( xm=[-size_atoms[0]/2+1.5 : 1 : size_atoms[0]/2-1.5] )
		for( zm=[1.5 : 1 : size_atoms[2]-1.5] )
		["translate", [xm*atom_mm, size_mm[1]/2 - back_thickness_mm, zm*atom_mm],
			["rotate", [90,0,0], back_hole]],
	]
);
