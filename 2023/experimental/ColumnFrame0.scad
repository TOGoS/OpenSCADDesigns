// ColumnFrame0.1
// 
// Minimal framework for a Gridbeam column,
// to which you are expected to add decorations
// with your 3D pen or whatever

height = 38.1;
floor_thickness = 4.5;
$tgx11_offset = -0.1;

module __columnframe0__end_params() { }

inch = 25.4;
$fn = $preview ? 24 : 48;

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TGx11.1Lib.scad>

$togridlib3_unit_table = tgx11_get_default_unit_table();

block_inter = ["difference",
	["union",
		togmod1_make_cuboid([40,40,floor_thickness*2]),
		//togmod1_linear_extrude_z([-10, height+10], togmod1_make_circle(d=inch*7/16)),
		let( dl=10/16*inch, ds=7/16*inch, dd=(dl-ds)/2, sl=1 )
		tphl1_make_z_cylinder(zds=[
			[floor_thickness    -1, dl],
			[floor_thickness+sl   , dl],
			[floor_thickness+sl+dd, ds],
			[height         -sl-dd, ds],
			[height         -sl   , dl],
			[height         +    1, dl],
		]),
	],
	togmod1_linear_extrude_z([-20, height+20], togmod1_make_circle(d=inch*5/16)),
];

togmod1_domodule(["intersection",
	tgx11_block([[1, "chunk"], [1, "chunk"], [height, "mm"]], lip_height=0, bottom_segmentation="atom"),
	block_inter
]);
