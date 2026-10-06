// PencilHolder2.0

width = "2chunk";
depth = "1chunk";
height = "3chunk";

$fn = 24;
$tgx11_offset = -0.1;

module __pencilholder2__end_params() { }

use <../lib/TGx11.1Lib.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGUnits1.scad>

$togridlib3_unit_table = tgx11_get_default_unit_table();

width_ca = togunits1_to_ca(width);
depth_ca = togunits1_to_ca(depth);
height_ca = togunits1_to_ca(height);

height_chunks = togunits1_decode(height, unit="chunk");

width_mm = togunits1_decode(width);
depth_mm = togunits1_decode(depth);
height_mm = togunits1_decode(height);
chunk_mm = togunits1_decode("chunk");

outer_wall_thickness_mm = 2;
inner_wall_thickness_mm = 2;
floor_thickness_mm = 6.35;

togmod1_domodule(
	let( block_hull =	tgx11_block(
		[width_ca, depth_ca, height_ca],
		bottom_v6hc_style = "none",
		bottom_shape = "footed",
		bottom_segmentation = "atom",
		bottom_foot_bevel = 0.4,
		lip_height = 0
	))
	let( compartments_2d = ["union",
		["translate", [0,0], togmod1_make_rounded_rect([25.4-inner_wall_thickness_mm, 38.1-inner_wall_thickness_mm], r=2)],
		
		for( xm=[-1,1] ) for( ym=[-1,1] )
		["translate", [xm*25.4,ym*19.05/2], togmod1_make_rounded_rect([25.4-inner_wall_thickness_mm, 19.05-inner_wall_thickness_mm], r=2)],
	])
	let( cavities = ["intersection",
		["translate", [0, 0, height_mm], tphl1_make_rounded_cuboid(
			[
				width_mm + ($tgx11_offset - outer_wall_thickness_mm)*2,
				depth_mm + ($tgx11_offset - outer_wall_thickness_mm)*2,
				(height_mm - floor_thickness_mm)*2,
			], r=[2,2,0.4], corner_shape="ovoid2"
		)],
		togmod1_linear_extrude_z([-3,height_mm+3], compartments_2d),
	])
	let( bolt_hole = ["rotate", [90,0,0], tphl1_make_z_cylinder(zds=[
		// For now we hard-code parameters for a 3/8" bolt
		[-depth_mm, 0.4*25.4],
		[ 0       , 0.4*25.4],
		[ 0       , 7/8*25.4],
		[depth_mm , 7/8*25.4],
	])])
	let( bolt_holes = ["union",
		for( zm=[0.5 : 1 : height_chunks-0.5] )
		["translate", [0,0,zm*chunk_mm], bolt_hole],
	])
	["difference",
		block_hull,
		
		cavities,
		bolt_holes,
	]
);
