panel_size = [38.1, 38.1];
// Long length of bowtie; 3/4" = 19.05
bowtie_length = 19.05;
thickness = 3.175;

// 1/4" = 6.35
// 3/8" = 9.525
// 1/2" = 12.7

$fn = 40;

include <../lib/BowtieLib-v0.scad>;

linear_extrude(thickness) {
	bowtie_test_plate_2d(panel_size, bowtie_length, 0);

	translate([panel_size[0]+bowtie_length, 0, 0]) bowtie_of_style("angular", bowtie_length, 0);
}
