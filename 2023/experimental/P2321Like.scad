// P2321Like
// 
// Low-profile solid bolt with square drive.
// The only reason this isn't just a Threads2 preset
// is that as of this writing, Threads2 doesn't have a way
// to make the 'floor hole' a square.

head_height  = "0.8mm";
head_width   = "1+3/4inch";
total_height = "3/8inch";

// drive_shape = "square"; // implied for now

drive_width = "3/4inch";
drive_xy_offset = "-0.1mm";
drive_depth = "1/4inch";

outer_threads = "1+1/2-6-UNC";
outer_thread_radius_offset = "-0.1mm";

$fn = 144;

module __p2321like__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGThreads2.scad>
use <../lib/TOGUnits1.scad>
use <../lib/TOGPolyhedronLib1.scad>

head_height_mm  = togunits1_to_mm(head_height );
head_width_mm   = togunits1_to_mm(head_width  );
total_height_mm = togunits1_to_mm(total_height);
drive_width_mm  = togunits1_to_mm(drive_width );
drive_depth_mm  = togunits1_to_mm(drive_depth );
drive_xy_offset_mm = togunits1_to_mm(drive_xy_offset);
outer_thread_radius_offset_mm = togunits1_to_mm(outer_thread_radius_offset);

togmod1_domodule(
	["difference",
		["union",
			tphl1_make_z_cylinder(zrange=[0, head_height_mm], d=head_width_mm),
			togthreads2_make_threads(
				togthreads2_simple_zparams([[head_height_mm/2,0],[total_height_mm,-1]], taper_length=1, inset=0.5),
				outer_threads,
				r_offset = outer_thread_radius_offset_mm
			)
		],
		
		togmod1_make_cuboid([drive_width_mm - drive_xy_offset_mm*2, drive_width_mm - drive_xy_offset_mm*2, drive_depth_mm*2]),
	]
);
