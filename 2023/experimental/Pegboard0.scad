// Pegboard0.1
// 
// TODO:
// - A variation where top/bottom are French cleats

thickness       = 19.05;
board_thickness = 3.175;
size_inches     = [6, 6];
gridbeam_hole_diameter = 8.0;
pegboard_hole_diameter = 4.8;
pegboard_hole_spacing_u = [16,16];
double_pegboard_holes = true;
peg_cavity_width = 9.5; // Enough for a #6 hex nut
wall_thickness = 3.175;
outer_corner_radius = 6.35;
counterbore_depth = 0;
$fn = 24;

module __pegboard0__end_params() { }

use <../lib/TOGComplexLib1.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>

inch = 25.4;
chunk = 38.1;
pegboard_hole_spacing = pegboard_hole_spacing_u*inch/16;

function gridin(area, cellsize, iter=1) = [
	for( xm=[ -round(area/cellsize)/2 + 0.5 : iter : round(area/cellsize)/2-0.4 ] )
	xm*cellsize
];

function gridin_2d(area, cellsize, iter=[1,1]) = [
	for( ym=[ -round(area[1]/cellsize[1])/2 + 0.5 : iter[0] : round(area[1]/cellsize[1])/2-0.4 ] )
	for( xm=[ -round(area[0]/cellsize[0])/2 + 0.5 : iter[1] : round(area[0]/cellsize[0])/2-0.4 ] )
	[xm*cellsize[0], ym*cellsize[1]]
];

function rcp(xs, ys) = [for(y=ys) for(x=xs) [x,y]];

size = size_inches * inch;

pegboard_hole_column_positions = gridin(size[0], pegboard_hole_spacing[0], double_pegboard_holes ? 0.5 : 1);
pegboard_hole_row_positions    = gridin(size[1], pegboard_hole_spacing[1], double_pegboard_holes ? 0.5 : 1);
pegboard_hole_positions = rcp(pegboard_hole_column_positions, pegboard_hole_row_positions);
gridbeam_hole_positions = gridin_2d(size, [chunk,chunk]);

peg_cavity_column_height = pegboard_hole_row_positions[len(pegboard_hole_row_positions)-1]-pegboard_hole_row_positions[0] + peg_cavity_width;

pegboard_hole_2d = togmod1_make_circle(d=pegboard_hole_diameter);
peg_cavity_2d = togmod1_make_rounded_rect([peg_cavity_width, 19.05], r=pegboard_hole_diameter/2);
peg_cavity_column_2d = togmod1_make_rounded_rect([peg_cavity_width, peg_cavity_column_height], r=peg_cavity_width/2-0.1);
gridbeam_hole_2d = togmod1_make_circle(d=gridbeam_hole_diameter);
gridbeam_column_2d = togmod1_make_rounded_rect([gridbeam_hole_diameter+1.6, gridbeam_hole_diameter+6], r=gridbeam_hole_diameter/2);

gridbeam_counterbore = counterbore_depth <= 0 ? ["union"] :
	togmod1_linear_extrude_z([-counterbore_depth,counterbore_depth], togmod1_make_circle(d=inch*7/8));

panel_2d = ["difference",
	togmod1_make_rounded_rect(size, r=outer_corner_radius),
	
	for( p=pegboard_hole_positions ) ["translate", p, pegboard_hole_2d],
	for( p=gridbeam_hole_positions ) ["translate", p, gridbeam_hole_2d],
];

hollow_back_cutout_2d = ["difference",
	togmod1_make_rounded_rect(size - [wall_thickness,wall_thickness], r=max(0,outer_corner_radius-wall_thickness)),
	
	for( p=gridbeam_hole_positions ) ["translate", p, gridbeam_column_2d],
];

minimal_back_cutout_2d = ["difference",
	["union",
		for( p=pegboard_hole_column_positions ) ["translate", [p,0], peg_cavity_column_2d],
	],
	for( p=gridbeam_hole_positions ) ["translate", p, gridbeam_column_2d],
];

back_cutout_2d = minimal_back_cutout_2d;

panel = ["difference",
	togmod1_linear_extrude_z([  0, thickness                ],       panel_2d),
	togmod1_linear_extrude_z([-10, thickness-board_thickness], back_cutout_2d),
	for( p=gridbeam_hole_positions ) ["translate", [p[0],p[1],thickness], gridbeam_counterbore],	
];

togmod1_domodule(panel);
