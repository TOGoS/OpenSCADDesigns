// TOGLEGO-v0.1
// 
// Experiment to see if I can print LEGO bricks
// precisely enough with a simple SCAD design.
// 
// See https://i.stack.imgur.com/OjziU.png for basic LEGO dimensions

size = [4, 4];
pitch = 8;
outer_margin = 0.1;
nubbin_height = 1.8;
nubbin_diameter = 4.8;
plate_thickness = 1.6;

$fn = $preview ? 24 : 64;

use <../lib/TOGShapeLib-v1.scad>

linear_extrude(plate_thickness) {
	tog_shapelib_rounded_beveled_square(size*pitch, 3.175, 3.175);
}

translate([0,0,plate_thickness-1]) linear_extrude(nubbin_height + 1) {
	for( yc=[-size[1]/2+0.5 : 1 : size[1]/2] )
	for( xc=[-size[0]/2+0.5 : 1 : size[0]/2] )
		translate([xc,yc]*pitch) circle(d=nubbin_diameter);
}
