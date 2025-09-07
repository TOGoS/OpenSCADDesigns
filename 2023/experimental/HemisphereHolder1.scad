// HemisphereHolder1.1
// 
// Holder for spherical things with diameter > 4.5", e.g. p1461
//
// v1.1:
// - Bevel around hole on both sides

$fn = 48;

size = ["6inch","6inch","3inch"];
platform_thickness = "3/4inch";
bottom_segmentation = "chatom";
// Offset of bottom row of holes from bottom
hole_z_offset = "1/2chunk";

$tgx11_offset = -0.1;

module __hemisphereholder1__end_params() { }

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGUnits1.scad>
use <../lib/TGx11.1Lib.scad>
use <../lib/TOGridLib3.scad>

$togridlib3_unit_table = tgx11_get_default_unit_table();

inch = 25.4;
chunk = 38.1;

size_mm = togunits1_decode_vec(size);
size_ca = togunits1_vec_to_cas(size);
size_chunks = togunits1_decode_vec(size, unit=[1,"chunk"]);
platform_thickness_mm = togunits1_decode(platform_thickness);
// Really the length of the bolt holes from back to end of counterbore
back_thickness_mm = 12.7;
hole_diameter_mm = 4.5*inch;
hole_z_offset_chunks = togunits1_decode(hole_z_offset, unit=[1,"chunk"]);

back_hole = ["rotate", [-90,0,0], tog_holelib2_hole("THL-1006", depth=size_mm[1], overhead_bore_height=size_mm[1], inset=0)];

togmod1_domodule(["difference",
	["intersection",
		each platform_thickness == size[2] ? [
			// In this case it's just a cuboid, so let's get nice corners
			tphl1_make_rounded_cuboid(size_mm, r=[6.35, 6.35, 3.175], corner_shape="ovoid1"),
		] : [
			// It'd be nice to round the corners in this case, too, but uh
			togmod1_linear_extrude_x([-1000, 1000], let(cops=[["round", 3.175]]) togpath1_rath_to_polygon(["togpath1-rath",
				["togpath1-rathnode", [-size_mm[1]/2                    , -size_mm[2]/2], each cops],
				["togpath1-rathnode", [ size_mm[1]/2                    , -size_mm[2]/2], each cops],
				["togpath1-rathnode", [ size_mm[1]/2                    , -size_mm[2]/2 + platform_thickness_mm], each cops],
				// ["togpath1-rathnode", [-size_mm[1]/2 + back_thickness_mm,  size_mm[2]/2], each cops],
				["togpath1-rathnode", [-size_mm[1]/2                    ,  size_mm[2]/2], each cops],
			])),
			
			togmod1_linear_extrude_z([-1000, 1000], let(cops=[["round", 6.35]]) togpath1_rath_to_polygon(
			   togpath1_make_rectangle_rath([size_mm[0], size_mm[1]], corner_ops=cops))),
		],
		
		["translate", [0,0,-size_mm[2]/2], tgx11_block_bottom(size_ca, segmentation=bottom_segmentation, foot_bevel=0.4)],
	],
	
	// TODO: Cut out corners or add vertical holes to save material?
	
	let(bevsize=6.35) tphl1_make_z_cylinder(zds=[
		[-size_mm[2]/2           - 100, hole_diameter_mm + 100],
		[-size_mm[2]/2 + bevsize - 100, hole_diameter_mm + 100],
		[-size_mm[2]/2 + bevsize      , hole_diameter_mm      ],
		[ size_mm[2]/2 - bevsize      , hole_diameter_mm      ],
		[ size_mm[2]/2 - bevsize + 100, hole_diameter_mm + 100],
		[ size_mm[2]/2           + 100, hole_diameter_mm + 100],
	]),
	
	for( xm=[-size_chunks[0]/2+0.5 : 1 : size_chunks[0]/2-0.4] )
	for( zm=[-size_chunks[2]/2+hole_z_offset_chunks : 1 : size_chunks[2]/2-0.4] )
	["translate", [xm*chunk, -size_mm[1]/2 + back_thickness_mm, zm*chunk], back_hole],
]);
