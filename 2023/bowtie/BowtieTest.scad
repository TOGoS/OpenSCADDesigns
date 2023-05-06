panel_size = [38.1, 38.1];
bowtie_length = 19.05;
thickness = 3.175;

$fn = 40;

include <../lib/BowtieLib-v0.scad>;

linear_extrude(thickness) {
	bowtie_test_plate_2d(panel_size, bowtie_length, 0);

	translate([panel_size[0]+bowtie_length, 0, 0]) bowtie_of_style("angular", bowtie_length, 0);
}
