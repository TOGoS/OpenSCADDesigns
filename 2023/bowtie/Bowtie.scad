panel_size = [38.1, 38.1];
// Long length of bowtie; 3/4" = 19.05
bowtie_length = 19.05;
bowtie_style = "angular"; // ["angular","minimal","quarter-bit-cutout","maximal","semi-maximal"]
thickness = 3.175;

// 1/4" = 6.35
// 3/8" = 9.525
// 1/2" = 12.7

$fn = 40;

include <../lib/BowtieLib-v0.scad>;

linear_extrude(thickness) {
	bowtie_of_style(bowtie_style, bowtie_length, 0);
}
