// RSAKeyHolder0.1

angle = 30;
groove_depth =  "9.5mm";
groove_width = "20.1mm";
$fn = 32;

module __rsakeyholder0__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGUnits1.scad>

groove_depth_mm = togunits1_decode(groove_depth);
groove_width_mm = togunits1_decode(groove_width);

block_size_y = 38.1;
by0 = -block_size_y/2;
by1 =  block_size_y/2;

top_length = block_size_y/cos(angle);

foot_thickness_mm = 6.35;

function translation_matrix_2d(offset) = [
	[1, 0, offset[0]],
	[0, 1, offset[1]],
	[0, 0,         1],
];

function rotation_matrix_2d(angle) = [
	[cos(angle), -sin(angle), 0],
	[sin(angle),  cos(angle), 0],
	[         0,           0, 1],
];

topmtrx = translation_matrix_2d([by0,foot_thickness_mm]) * rotation_matrix_2d(angle) * translation_matrix_2d([top_length/2,0]);

function mmult2d(matrix, vec) =
	let(vec_extended = [vec[0], vec[1], 1])
	let(prod = matrix * vec_extended)
	[prod[0], prod[1]];

togmod1_domodule(
	togmod1_linear_extrude_x([-12.7, 12.7], togpath1_rath_to_polygon(["togpath1-rath",
		["togpath1-rathnode", [by0, foot_thickness_mm], ["round", 3]],
		["togpath1-rathnode", [by0, 0], ["bevel", 3.175], ["round", 3]],
		["togpath1-rathnode", [by1, 0], ["bevel", 3.175], ["round", 3]],
		["togpath1-rathnode", [by1, foot_thickness_mm + sin(angle)/cos(angle)*block_size_y], ["round", 3]],
		["togpath1-rathnode", mmult2d(topmtrx, [ groove_width_mm/2, 0]), ["round", 3]],
		["togpath1-rathnode", mmult2d(topmtrx, [ groove_width_mm/2, -groove_depth_mm])],
		["togpath1-rathnode", mmult2d(topmtrx, [-groove_width_mm/2, -groove_depth_mm])],
		["togpath1-rathnode", mmult2d(topmtrx, [-groove_width_mm/2, 0]), ["round", 3]],
	]))
);
