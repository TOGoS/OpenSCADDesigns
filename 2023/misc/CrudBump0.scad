// CrudBump0.1
// 
// It's a little screw thing.

head_diameter  = "3/4inch";
head_height    = "3/16inch";
thread_length  = "1/4inch";
thread_style   = "1/2-13-UNC";
thread_radius_offset = "-0.2mm";
shaft_diameter = "9/32inch";
shaft_length   = "1/2inch";

$fn = 32;

module __crudbump0__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGThreads2.scad>
use <../lib/TOGUnits1.scad>
use <../lib/TOGVecLib0.scad>

$togunits1_default_unit = "mm"; // Make '0' work.

head_height_mm   = togunits1_to_mm(head_height);
thread_length_mm = togunits1_to_mm(thread_length);
thread_radius_offset_mm = togunits1_to_mm(thread_radius_offset);
head_diam_mm     = togunits1_to_mm(head_diameter);
shaft_length_mm  = togunits1_to_mm(shaft_length);
shaft_diam_mm    = togunits1_to_mm(shaft_diameter);
drive_width_mm   = togunits1_to_mm("1/4inch");
drive_depth_mm   = togunits1_to_mm("3/16inch");

togmod1_domodule(
	["difference",
		["union",
			if( head_height_mm > 0 ) tphl1_make_z_cylinder( zds = let(b=head_height_mm/4) [
				[               0,head_diam_mm-b*2],
				[               b,head_diam_mm    ],
				[head_height_mm-b,head_diam_mm    ],
				[head_height_mm  ,head_diam_mm-b*2],
			]),
			
			if( thread_length_mm > 0 ) togthreads2_make_threads(
				togthreads2_simple_zparams([[head_height_mm/2,0],[head_height_mm+thread_length_mm,-1]], inset=0.5, taper_length=0.5),
				thread_style,
				r_offset = thread_radius_offset_mm
			),
			
			if( shaft_length_mm > 0 ) tphl1_make_z_cylinder( zds = let(z0=head_height_mm+thread_length_mm, z1=z0+shaft_length_mm, bz=3, bxy=1) [
				[z0-1 , shaft_diam_mm      ],
				[z1-bz, shaft_diam_mm      ],
				[z1   , shaft_diam_mm-bxy*2],
			]),
		],
		
		togmod1_make_cuboid([drive_width_mm + 0.2, drive_width_mm + 0.2, drive_depth_mm * 2]),
	]
);
