// USBPSBlock-v1.1
// Block to hold three of these 5-35V-to-USB-PD adapters:
// 
// https://smile.amazon.com/dp/B08P3ZZFWM
// Probably the same as https://www.amazon.com/DWEII-Charge-Step-Down-Module-Adapter/dp/B0C5J847VG
// 49.3mm x 18.2mm x about 1/2" high
//
// Changes:
// v1.1:
// - Remove x-debugs, now that winding order's been fixed
//   and things show up in preview.
// - overhead_bore_height = 2 on screw holes
// - $tgx9_chatomic_foot_column_style = "v6.2" (the default was "v8.4")

/* [Bottom] */

foot_segmentation = "chatom"; // ["chatom", "chunk", "block", "none"]
foot_v6hc_style = "v6.2"; // ["none","v6.2"]
togridpile_margin = 0.2;
bottom_magnet_hole_diameter = 6.4; // 0.1
bottom_magnet_hole_depth    = 2.4; // 0.1

module __1243i12oehji__end_params();

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGHoleLib2.scad>

block_size_ca = [[2, "chunk"], [2, "chunk"], [1/2, "chunk"]];

inch = 25.4;

$fn = $preview ? 12 : 48;

ps_notch = ["union",
	togmod1_make_cuboid([0.75*inch, 3*inch, 1*inch]),
	
	// Grooves for hot glue to grab
	for( ym=[-1.5,-0.5,0.5] ) ["translate", [0,ym*0.5*inch,0], tphl1_make_rounded_cuboid([7/8*inch, 1/4*inch, 1.125*inch], r=[3, 0, 3], $fn=12)],
];
magnet_hole = togmod1_make_cylinder(d=bottom_magnet_hole_diameter, zrange=[-bottom_magnet_hole_depth, bottom_magnet_hole_depth]);

block_thickness = 3/4*inch;

chunk_magnet_holes = ["union",
	for( xam=[-1,1] ) for( yam=[-1,1] ) ["translate", [xam*12.7, yam*12.7], magnet_hole]
];

module block_main() togmod1_domodule(["difference",
	["translate", [0, 0, block_thickness/2], togmod1_make_cuboid([3*inch, 3*inch, block_thickness])],
	
	for( xm=[-1,0,1] ) ["translate", [xm*1*inch, -0.5*inch, block_thickness], ps_notch],

	["translate", [0, 0.75*inch, block_thickness], ["x-debug", tphl1_make_rounded_cuboid([2.75*inch, 1.25*inch, 1*inch], r=[3, 3, 0])]],
	["translate", [0, 1.5*inch, block_thickness], ["x-debug", togmod1_make_cuboid([2*inch, 1.25*inch, 1*inch])]],
	
	for( xcm=[-1/2,1/2] ) for( ycm=[-1/2,1/2] ) ["translate", [xcm*38.1, ycm*38.1], chunk_magnet_holes],
	
	for( xm=[-1,1] ) ["translate", [xm*0.75*inch, 1.25*inch, 1], ["rotate", [180,0,0], tog_holelib2_hole("THL-1001", depth=1*inch)]],
	for( xm=[-1,1] ) ["translate", [xm*0.5*inch, 0.5*inch, 1], ["rotate", [180,0,0], tog_holelib2_hole("THL-1001", depth=1*inch)]],
	for( xm=[-2.5,-0.5,0.5,2.5] ) ["translate", [xm*0.5*inch, 0.75*inch, 0.25*inch-1], tog_holelib2_hole("THL-1001", depth=1*inch)],
	for( xm=[-1.5,1.5] ) ["translate", [xm*0.5*inch, 0.75*inch, 0.25*inch-1], tog_holelib2_hole("THL-1002", depth=1*inch)],
]);

use <../lib/TGx9.4Lib.scad>
use <../lib/TOGridLib3.scad>

intersection() {
	block_main();

	corner_radius = togridlib3_decode([1, "m-outer-corner-radius"]);
	
	tgx9_block_foot(
		block_size_ca     = block_size_ca,
		foot_segmentation = foot_segmentation,
		corner_radius     = corner_radius,
		$tgx9_chatomic_foot_column_style = "v6.2",
		v6hc_style        = foot_v6hc_style,
		offset            = -togridpile_margin
	);

	tgx9_block_hull(
		block_size = togridlib3_decode_vector(block_size_ca),
		corner_radius = corner_radius,
		offset = -togridpile_margin
	);
}
