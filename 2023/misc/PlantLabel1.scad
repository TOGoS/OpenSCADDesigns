// PlantLabel1.1
// 
// A thing you can write on and stick in the dirt.
// 
// Changes:
// v1.1:
// - Allow label and post to be the same width
// - Adjust rounding radii to allow for arbitrarily narrow labels/posts

thickness = "1/8inch";
label_width = "3inch";
label_height = "3inch";
post_width = "3/4inch";
post_height = "3inch";
$fn = 24;

module __plantlabel1__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGUnits1.scad>

atom = togunits1_to_mm("1atom");

labw = togunits1_to_mm(label_width);
labh = togunits1_to_mm(label_height);
posw = togunits1_to_mm(post_width);
posh = togunits1_to_mm(post_height);
thickness_mm = togunits1_to_mm(thickness);

hole_2d = togmod1_make_circle(d = 4.5);

// TODO: Rounding will need adjustment for very small sizes
labr    = min(atom/2, labw*127/256, labh*127/256);
postipr = min(atom/2, posw*31/256);
hipr    = min(labr, abs(labw - posw)*63/256);

togmod1_domodule(["intersection",
	togmod1_linear_extrude_z([-1, thickness_mm+1], ["difference",
		togpath1_rath_to_polygon(["togpath1-rath",
			["togpath1-rathnode", [-labw/2, labh       ], ["round", labr]],
			each labw != posw ? [
				["togpath1-rathnode", [-labw/2,    0       ], ["round", hipr]],
				["togpath1-rathnode", [-posw/2,    0       ], ["round", hipr]],
			] : [],
			["togpath1-rathnode", [-posw/2,-posh+posw/2], ["round", labr]],
			["togpath1-rathnode", [-posw/4,-posh       ], ["round", postipr]],
			["togpath1-rathnode", [ posw/4,-posh       ], ["round", postipr]],
			["togpath1-rathnode", [ posw/2,-posh+posw/2], ["round", labr]],
			each labw != posw ? [
				["togpath1-rathnode", [ posw/2,    0       ], ["round", hipr]],
				["togpath1-rathnode", [ labw/2,    0       ], ["round", hipr]],
			] : [],
			["togpath1-rathnode", [ labw/2, labh       ], ["round", labr]],
		]),
		
		for( xm = [round(-labw/atom+1/4)/2 + 0.5 : 1 : round(labw/atom-1/4)/2 - 0.4] )
		for( y = labh-atom/2 ) ["translate", [xm*atom,y], hole_2d]
	]),
	
	togmod1_linear_extrude_x([-labw, +labw], togmod1_make_polygon([
		[- posh - posw * 0.5, 0],
		[ labh*2, 0],
		[ labh*2, thickness_mm],
		[-posh + posw, thickness_mm],
	])),
]);
