// Pegboard0.7
// 
// Changes:
// v0.2:
// - Options for gridbeam hole styles: straight, countersunk, counterbored
// v0.3:
// - Options for togbeam holes
// v0.4:
// - Option for THL-1002-9/32 gridbeam holes, which are just
//   slightly narrower than the regular 5/16
// - Increase height of cavity behind peg holes
// v0.5:
// - Fix inset of countersunk holes
// v0.6:
// - Rename 'cavity column' to 'unicavity'
// - Add connector holes, which are placed on a 1/2"
//   grid offset halfway betweem the TOGBeam holes,
//   i.e. same grid as the pegboard holes.
// - Don't add columns for nonexistent holes
// - Remove `gridbeam_hole_diameter` option,
//   hardcode at 9/32" (this applies only to 'straight' holes)
// v0.7:
// - Option of double-ended TOGBeam holes!  (THL-1001-double-ended)
// 
// TODO:
// - A variation where top/bottom are French cleats
// - Allow offsetting pegboard and connector holes by 1/4"

thickness       = 19.05;
board_thickness = 3.175;
size_inches     = [6, 6];
pegboard_hole_diameter = 4.8;
pegboard_hole_spacing_u = [16,16];
double_pegboard_holes = true;
peg_cavity_width = 9.5; // Enough for a #6 hex nut
wall_thickness = 3.175;
outer_corner_radius = 6.35;
gridbeam_hole_style = "straight"; // ["none","straight","THL-1002","THL-1002-9/32","THL-1006"]
togbeam_hole_style  = "none";     // ["none","THL-1001","THL-1001-double-ended"]
connector_hole_style = "none";    // ["none","straight-4.5mm"]
$fn = 24;

module __pegboard0__end_params() { }

use <../lib/TOGComplexLib1.scad>
use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>

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

inch = 25.4;
atom = 12.7;
chunk = 38.1;

gridbeam_hole_diameter = 7.15; // About 9/32"

size = size_inches * inch;

pegboard_hole_spacing = pegboard_hole_spacing_u*inch/16;
gridbeam_hole_spacing  = [chunk,chunk];
togbeam_hole_spacing   = [ atom, atom];
connector_hole_spacing = [2*atom,2*atom];

pegboard_hole_x_positions = gridin(size[0], pegboard_hole_spacing[0], double_pegboard_holes ? 0.5 : 1);
pegboard_hole_y_positions    = gridin(size[1], pegboard_hole_spacing[1], double_pegboard_holes ? 0.5 : 1);
pegboard_hole_positions = rcp(pegboard_hole_x_positions, pegboard_hole_y_positions);
gridbeam_hole_positions = gridin_2d(size, gridbeam_hole_spacing);
togbeam_hole_positions = gridin_2d(size, togbeam_hole_spacing);
connector_hole_x_positions = gridin(size[0], connector_hole_spacing[0], 0.5);
connector_hole_y_positions = gridin(size[0], connector_hole_spacing[1], 0.5);

peg_unicavity_height =
	// pegboard_hole_y_positions[len(pegboard_hole_y_positions)-1]-pegboard_hole_y_positions[0] + peg_cavity_width);
	size[1] - wall_thickness*2;

pegboard_hole_2d = togmod1_make_circle(d=pegboard_hole_diameter);
peg_cavity_2d = togmod1_make_rounded_rect([peg_cavity_width, 19.05], r=pegboard_hole_diameter/2);
peg_unicavity_2d = togmod1_make_rounded_rect([peg_cavity_width, peg_unicavity_height], r=peg_cavity_width/2-0.1);
gridbeam_hole_2d = togmod1_make_circle(d=gridbeam_hole_diameter);
gridbeam_column_2d = togmod1_make_rounded_rect([9.6, gridbeam_hole_diameter+6], r=gridbeam_hole_diameter/2);
togbeam_column_2d  = togmod1_make_circle(d=6.35);

function pegboard0_hole( style, depth, inset ) =
	style == "THL-1002-9/32" ? tog_holelib2_hole("THL-1002", depth, inset=inset, bore_d=9/32*inch) :
	tog_holelib2_hole(style, depth, inset=inset);

togbeam_hole_inset =
	togbeam_hole_style == "THL-1001" ? 0.5 :
	togbeam_hole_style == "THL-1001-double-ended" ? 0.5 :
	0.1;
gridbeam_hole_inset =
	gridbeam_hole_style == "THL-1002" || gridbeam_hole_style == "THL-1002-9/32" ? 0.8 :
	gridbeam_hole_style == "THL-1006" ? 2.5 :
	0.1;

function reversey(doit, list) =
	doit ? [for(i=[len(list)-1 : -1 : 0]) list[i]] : list;

thl_1001_sym =
let( hh = 1.7 )
let( dd_dz = 2.35 )
let( inset = togbeam_hole_inset )
tphl1_make_z_cylinder(zds=[
	for( od=[[-thickness,1],[0,-1]] ) each reversey(od[1] == -1, [
	// rad/z slope = (/ (- 7.5 3.5) (* 2 1.7)) = 1.1764705882352942
	// dz/dd = 0.425
	// head height is 1.7
		[od[0] - od[1]*1                                     , 7.5],
		[od[0] + od[1]*(inset                               ), 7.5],
		[od[0] + od[1]*(inset + hh * (7.5 - 4.0)/(7.5 - 3.5)), 4.0],
	])
]);

togbeam_hole  =
	togbeam_hole_style  == "straight" ? ["union"] :
	togbeam_hole_style  == "THL-1001-double-ended" ? thl_1001_sym :
	["render", pegboard0_hole( togbeam_hole_style, depth=thickness*2, inset= togbeam_hole_inset)];
gridbeam_hole =
	gridbeam_hole_style == "straight" ? ["union"] :
	["render", pegboard0_hole(gridbeam_hole_style, depth=thickness*2, inset=gridbeam_hole_inset)];

connector_hole_z =
	connector_hole_style == "none" ? ["union"] :
	togmod1_linear_extrude_z([-12,12], togmod1_make_circle(d=4.5));
connector_hole_x = ["rotate", [0,90,0], connector_hole_z];
connector_hole_y = ["rotate", [90,0,0], connector_hole_z];

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
		for( p=pegboard_hole_x_positions ) ["translate", [p,0], peg_unicavity_2d],
	],
	if( gridbeam_hole_style != "none" ) for( p=gridbeam_hole_positions ) ["translate", p, gridbeam_column_2d],
	if(  togbeam_hole_style != "none" ) for( p= togbeam_hole_positions ) ["translate", p,  togbeam_column_2d],
];

back_cutout_2d = minimal_back_cutout_2d;

panel = ["difference",
	togmod1_linear_extrude_z([  0, thickness                ],       panel_2d),
	togmod1_linear_extrude_z([-10, thickness-board_thickness], back_cutout_2d),
	if(  gridbeam_hole_style != "none" ) for( p=gridbeam_hole_positions )
		["translate", [p[0],p[1],thickness], gridbeam_hole],
	if(   togbeam_hole_style != "none" ) for( p= togbeam_hole_positions )
		["translate", [p[0],p[1],thickness],  togbeam_hole],
	if( connector_hole_style != "none" ) for( x=connector_hole_x_positions ) for(y=[-size[1]/2, size[1]/2] )
		["translate", [x, y, thickness/2], connector_hole_y],
	if( connector_hole_style != "none" ) for( y=connector_hole_y_positions ) for(x=[-size[0]/2, size[0]/2] )
		["translate", [x, y, thickness/2], connector_hole_x],
];

togmod1_domodule(panel);
