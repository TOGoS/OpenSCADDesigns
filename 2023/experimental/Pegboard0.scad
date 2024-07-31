// Pegboard0.3
// 
// Changes:
// v0.2:
// - Options for gridbeam hole styles: straight, countersunk, counterbored
// v0.3:
// - Options for togbeam holes
// 
// TODO:
// - A variation where top/bottom are French cleats
// - Countersink gridbeam holes?

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
gridbeam_hole_style = "straight"; // ["none","straight","THL-1002","THL-1006"]
togbeam_hole_style  = "none";     // ["none","THL-1001"]
$fn = 24;

module __pegboard0__end_params() { }

use <../lib/TOGComplexLib1.scad>
use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>

inch = 25.4;
atom = 12.7;
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

gridbeam_hole_spacing = [chunk,chunk];
togbeam_hole_spacing = [ atom,atom];

pegboard_hole_column_positions = gridin(size[0], pegboard_hole_spacing[0], double_pegboard_holes ? 0.5 : 1);
pegboard_hole_row_positions    = gridin(size[1], pegboard_hole_spacing[1], double_pegboard_holes ? 0.5 : 1);
pegboard_hole_positions = rcp(pegboard_hole_column_positions, pegboard_hole_row_positions);
gridbeam_hole_positions = gridin_2d(size, gridbeam_hole_spacing);
togbeam_hole_positions = gridin_2d(size, togbeam_hole_spacing);

peg_cavity_column_height = pegboard_hole_row_positions[len(pegboard_hole_row_positions)-1]-pegboard_hole_row_positions[0] + peg_cavity_width;

pegboard_hole_2d = togmod1_make_circle(d=pegboard_hole_diameter);
peg_cavity_2d = togmod1_make_rounded_rect([peg_cavity_width, 19.05], r=pegboard_hole_diameter/2);
// there are two different 'column's around here:
// - The long Y-wise slot behind the peg holes
// - The walls of the gridbeam/togbeam holes
// Maybe I should rename one of them.
peg_cavity_column_2d = togmod1_make_rounded_rect([peg_cavity_width, peg_cavity_column_height], r=peg_cavity_width/2-0.1);
gridbeam_hole_2d = togmod1_make_circle(d=gridbeam_hole_diameter);
gridbeam_column_2d = togmod1_make_rounded_rect([gridbeam_hole_diameter+1.6, gridbeam_hole_diameter+6], r=gridbeam_hole_diameter/2);
togbeam_column_2d  = togmod1_make_circle(d=6.35);

togbeam_hole_inset =
	togbeam_hole_style == "THL-1001" ? 0.5 :
	0.1;
gridbeam_hole_inset =
	gridbeam_hole_style == "THL-1002" ? 0.8 :
	gridbeam_hole_style == "THL-1006" ? 2.5 :
	0.1;

togbeam_hole  =
	togbeam_hole_style  == "straight" ? ["union"] :
	["render", tog_holelib2_hole( togbeam_hole_style, depth=thickness*2, inset=togbeam_hole_inset)];
gridbeam_hole =
	gridbeam_hole_style == "straight" ? ["union"] :
	["render", tog_holelib2_hole(gridbeam_hole_style, depth=thickness*2, inset=gridbeam_hole_inset)];

panel_2d = ["difference",
	togmod1_make_rounded_rect(size, r=outer_corner_radius),
	
	for( p=pegboard_hole_positions ) ["translate", p, pegboard_hole_2d],
	if(gridbeam_hole_style == "straight") for( p=gridbeam_hole_positions ) ["translate", p, gridbeam_hole_2d],
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
	for( p= togbeam_hole_positions ) ["translate", p,  togbeam_column_2d],
];

back_cutout_2d = minimal_back_cutout_2d;

panel = ["difference",
	togmod1_linear_extrude_z([  0, thickness                ],       panel_2d),
	togmod1_linear_extrude_z([-10, thickness-board_thickness], back_cutout_2d),
	for( p=gridbeam_hole_positions ) ["translate", [p[0],p[1],thickness], gridbeam_hole],
	for( p= togbeam_hole_positions ) ["translate", [p[0],p[1],thickness],  togbeam_hole],
];

togmod1_domodule(panel);
