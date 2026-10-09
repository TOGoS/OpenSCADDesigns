// WheelBox0.1
// 
// A small U-shaped bracket to hold a 1-inch wheel

$fn = 32;

system_height = "12/8inch";
// Cut this much off the top of the box so it doesn't scrape on whatever suface the wheel is rolling on
box_trim_z = "1/8inch";
wheel_diameter = "1inch";
wheel_margin_z = "1/8inch";
wheelwell_width = "3/4inch";

$tgx11_offset = -0.1;

module __asdasd__end_params() { }

use <../lib/TGx11.1Lib.scad>
use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGUnits1.scad>

$togridlib3_unit_table = tgx11_get_default_unit_table();

u = togunits1_to_mm("u");
box_trim_z_mm = togunits1_to_mm(box_trim_z);
system_height_mm = togunits1_to_mm(system_height);
height_mm = system_height_mm - box_trim_z_mm;
height_ca = [height_mm, "mm"];
wheel_diameter_mm = togunits1_to_mm(wheel_diameter);
wheel_margin_z_mm = togunits1_to_mm(wheel_margin_z);
wheelwell_width_mm = togunits1_to_mm(wheelwell_width);

wheel_center_z_mm = system_height_mm - wheel_diameter_mm/2;
wheelwell_depth_mm = wheel_diameter_mm/2 + wheel_margin_z_mm + (height_mm - wheel_center_z_mm);
floor_z_mm = wheel_center_z_mm - wheel_diameter_mm/2 - wheel_margin_z_mm;

togmod1_domodule(
	["difference",
		tgx11_block(
			[[1,"chunk"], [1,"chunk"], height_ca],
			bottom_segmentation="chunk",
			top_segmentation="block",
			lip_height=-1
		),
		
		["translate", [0,0,height_mm], ["rotate", [0,90,0], tphl1_make_polyhedron_from_layer_function(
			[
				[-14*u, 4],
				[-10*u, 0],
				[ 10*u, 0],
				[ 14*u, 4],
			],
			function(zo) togpath1_rath_to_polypoints(
				togpath1_offset_rath(
					togpath1_make_rectangle_rath([wheelwell_depth_mm*2, 12*u], corner_ops=[["round", 2*u]]),
					zo[1]
				)
			), layer_points_transform="key0-to-z"
		)]],
		
		["translate", [0,0,wheel_center_z_mm], ["rotate", [90,0,0], tphl1_make_z_cylinder(d=5*u, zrange=[-20,20])]],
		["translate", [0,0,floor_z_mm], tog_holelib2_hole("THL-1002")],
	]
);
