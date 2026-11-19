// FCMiniRail0.1
// 
// Single-piece, somewhat minimal, FC + panel with MiniRail on the front.
// 
// TODO: Option for full height
// TODO: Option to omit built-in FC

height = "4chunk";
width = "1chunk";
minirail_edge_offset = "-0.1mm";
cc_bolt_hole_style = "straight-4.5mm";
$fn = 24;

module __fcminirail0__end_params() { }

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGUnits1.scad>

inch  = 25.4;
chunk = 38.1;

height_chunks = togunits1_decode(height, unit="chunk", xf="round");
width_chunks = togunits1_decode(width, unit="chunk", xf="round");
mr_y_off_mm = togunits1_to_mm(minirail_edge_offset) * sqrt(2);
width_mm = togunits1_to_mm(width);
panel_thickness_mm = 1/4*inch;
// Top chunk is the FC, which might not fill the whole chunk,
// so actual height might be shorter
height_mm = height_chunks*chunk;

fc_thickness_mm = 1/2*inch;

fc_depth_mm = chunk/2;

fcb_y1 = height_mm/2 - chunk + fc_depth_mm/2;
fcb_y0 = height_mm/2 - chunk - fc_depth_mm/2;
fcb_x1 = 0;
fcb_x0 = 0 - fc_depth_mm;
fct_y0 = fcb_y0 + fc_thickness_mm*sqrt(2);
fct_y1 = fcb_y1 + fc_thickness_mm*sqrt(2);
panel_x0 = 0;
panel_x1 = panel_thickness_mm;
panel_y0 = -height_mm/2;
panel_y1 = fct_y1 + panel_thickness_mm;
mr_depth_mm = inch/4;
mr_width_mm = chunk/2;
mr_x0 = panel_x1;
mr_x1 = mr_x0 + mr_depth_mm;
mr_thickness_mm = inch/6;
// Top sides of MiniRail relative to minirail center Y:
mr_outer_y0 = 0 + mr_width_mm/2 - mr_depth_mm/2 + mr_y_off_mm;
mr_outer_y1 = 0 + mr_width_mm/2 + mr_depth_mm/2 + mr_y_off_mm;
mr_inner_y0 = mr_outer_y0 - mr_thickness_mm*sqrt(2);
mr_inner_y1 = mr_outer_y1 - mr_thickness_mm*sqrt(2);

notch_spacing_mm = chunk/2;

togmod1_domodule(
	let( notch_size_x = 3.5 )
	let( notch_cut = togmod1_linear_extrude_z(
		[-3.2, 3.2],
		["translate", [mr_x0 + mr_depth_mm/4, 0, 0], togmod1_make_rect([notch_size_x, height_mm*2])]
	))
	let( cc_bolt_hole = ["render", ["translate", [mr_x1,0,0], ["rotate", [0,90,0], tog_holelib2_hole(cc_bolt_hole_style, depth=mr_x1+2)]]] )
	["difference",
		togmod1_linear_extrude_z(
			[-width_mm/2, width_mm/2],
			togpath1_rath_to_polygon(["togpath1-rath",
				["togpath1-rathnode", [panel_x1, panel_y0], ["round", panel_thickness_mm*($fn-3)/($fn*2)]],
				for( ym=[-height_chunks/2 + 0.5 : 1 : height_chunks/2-1.5] ) each let(mr_cy = ym*chunk) [
					["togpath1-rathnode", [mr_x0, mr_cy - mr_outer_y0]],
					["togpath1-rathnode", [mr_x1, mr_cy - mr_outer_y1], ["round", 1]],
					["togpath1-rathnode", [mr_x1, mr_cy - mr_inner_y1], ["round", 1]],
					each mr_inner_y0 < 0 ? [
						["togpath1-rathnode", [mr_x0 - mr_inner_y0, mr_cy], ["round", 3]],
					] : [
						["togpath1-rathnode", [mr_x0, mr_cy - mr_inner_y0]],
						["togpath1-rathnode", [mr_x0, mr_cy + mr_inner_y0]],
					],
					["togpath1-rathnode", [mr_x1, mr_cy + mr_inner_y1], ["round", 1]],
					["togpath1-rathnode", [mr_x1, mr_cy + mr_outer_y1], ["round", 1]],
					["togpath1-rathnode", [mr_x0, mr_cy + mr_outer_y0]],
				],
				["togpath1-rathnode", [panel_x1, panel_y1], ["round", panel_thickness_mm]],
				["togpath1-rathnode", [fcb_x0  , fct_y0], ["round", 3  ]],
				["togpath1-rathnode", [fcb_x0  , fcb_y0], ["round", 1.6]],
				["togpath1-rathnode", [fcb_x1  , fcb_y1]],
				["togpath1-rathnode", [panel_x0, panel_y0], ["round", panel_thickness_mm*($fn-3)/($fn*2)]],
			])
		),
		
		let( width_notches = round(width_mm/notch_spacing_mm) )
		for( ym=[-width_notches/2+0.5 : 1 : width_notches/2-0.5] )
		["translate", [0, 0, ym*notch_spacing_mm], notch_cut],

		for( ym=[-height_chunks/2+0.5 : 1 : height_chunks/2-1.5] )
		for( zm=[-width_chunks/2+0.5 : 1 : width_chunks/2-0.5] )
		["translate", [0, ym*chunk, zm*chunk], cc_bolt_hole],
	]
);
