// WeMosClip0.1
// 
// Prototype between-the-legs clip for a WeMos D1 mini.
// Idea is that the legs will fit somewhat snugly into
// a case, and this clip will squeeze between the legs
// to hold it more firmly.
// 
// TODO: Some way of centering it in the hypothetical case.
// Maybe a groove, or maybe just size the center section
// more precisely.

// Space for a pin; should probably be half a pin width or slightly under
pin_margin  = "0.25mm";
pin_spacing = "9/10inch";
thickness   = "1/16inch";
height      = "3/16inch";

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGUnits1.scad>

$fn = 24;

function reverse_list(list) =
	[for(i=[len(list)-1 : -1 : 0]) list[i]];

function mirror_rathnodes(nodes) = [
	for(n=nodes) n,
	for(n=reverse_list(nodes)) [n[0], [-n[1][0], n[1][1]], for(i=[2:1:len(n)-1]) n[i]],
];

pin_margin_mm  = togunits1_to_mm(pin_margin);
pin_spacing_mm = togunits1_to_mm(pin_spacing);
thickness_mm   = togunits1_to_mm(thickness);
height_mm      = togunits1_to_mm(height);

the_clip_2d = togpath1_rath_to_polygon(
	let( x0 = -pin_spacing_mm/2 + pin_margin_mm )
	let( y0 = -height_mm                 )
	let( y1 = y0 + thickness_mm          )
	let( y3 =  0                         )
	let( y2 = y3 - thickness_mm          )
	let( fold_positions = [each [x0 + thickness_mm*3.5 : thickness_mm * 4 : -4 ]] )
	let( ocops = [["round", thickness_mm]]         )
	let( icops = [["round", thickness_mm*127/256]] )
	["togpath1-rath", each mirror_rathnodes([
		for( cx0 = reverse_list(fold_positions) ) each [
			["togpath1-rathnode", [cx0+0.5*thickness_mm, y3], each ocops],
			["togpath1-rathnode", [cx0+0.5*thickness_mm, y1], each icops],
			["togpath1-rathnode", [cx0-0.5*thickness_mm, y1], each icops],
			["togpath1-rathnode", [cx0-0.5*thickness_mm, y3], each ocops],
		],
		["togpath1-rathnode", [x0               , y3], each ocops],
		["togpath1-rathnode", [x0               , y0], each icops],
		["togpath1-rathnode", [x0+1*thickness_mm, y0], each icops],
		["togpath1-rathnode", [x0+1*thickness_mm, y2], each icops],
		for( cx0 = fold_positions ) each [
			["togpath1-rathnode", [cx0-1.5*thickness_mm, y2], each icops],
			["togpath1-rathnode", [cx0-1.5*thickness_mm, y0], each ocops],
			["togpath1-rathnode", [cx0+1.5*thickness_mm, y0], each ocops],
			["togpath1-rathnode", [cx0+1.5*thickness_mm, y2], each icops],
		],
	])]
);

togmod1_domodule(togmod1_linear_extrude_z([0, 25.4*8/10], the_clip_2d));
