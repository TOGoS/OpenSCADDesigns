// NarrowBeam0.2
// 
// Gridbeam, but narrow in some direction or another,
// which might be useful for making corner connector blocks
// for boxes or something.
// 
// v0.2:
// - Allow Z hole spacing along X to be customized

x0 = "-3/4inch";
x1 = "3/4inch";
y0 = "-3/4inch";
y1 = "3/4inch";
z0 = "-3/4inch";
z1 = "3/4inch";
xy_corner_radius = "3/16inch";
z_corner_radius = "1/16inch";
x_hole_style = "none";
y_hole_style = "none";
z_hole_style = "none";
z_hole_x_spacing = "1chunk";

$fn = 48;

module __narrowbeam0__end_params() { }

use <../lib/TOGUnits1.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGHoleLib2.scad>

x0_mm = togunits1_to_mm(x0);
x1_mm = togunits1_to_mm(x1);
y0_mm = togunits1_to_mm(y0);
y1_mm = togunits1_to_mm(y1);
z0_mm = togunits1_to_mm(z0);
z1_mm = togunits1_to_mm(z1);
xy_corner_radius_mm = togunits1_to_mm(xy_corner_radius);
z_corner_radius_mm  = togunits1_to_mm(z_corner_radius);
z_hole_x_spacing_chunks = togunits1_decode(z_hole_x_spacing, unit="chunk");

size = [x1_mm-x0_mm, y1_mm-y0_mm, z1_mm-z0_mm];
x_hole = ["rotate-xyz", [  0,90, 0], tog_holelib2_hole(x_hole_style, depth=size[0]+10)];
y_hole = ["rotate-xyz", [-90, 0, 0], tog_holelib2_hole(y_hole_style, depth=size[1]+10)];
z_hole = ["rotate-xyz", [  0, 0, 0], tog_holelib2_hole(z_hole_style, depth=size[2]+10)];

togmod1_domodule(
	let(chunk = togunits1_decode("chunk"))
	let(size_chunks = [for(d=[x1_mm-x0_mm, y1_mm-y0_mm, z1_mm-z0_mm]) round(d/chunk)] )
	["difference",
		["translate", [(x0_mm+x1_mm)/2, (y0_mm+y1_mm)/2, (z0_mm+z1_mm)/2],
			tphl1_make_rounded_cuboid(
				[x1_mm-x0_mm, y1_mm-y0_mm, z1_mm-z0_mm],
				r = [xy_corner_radius_mm, xy_corner_radius_mm, z_corner_radius_mm],
				corner_shape = "cone2"
			)
		],
		
		for( ym=[-size_chunks[1]/2 + 0.5 : 1 : size_chunks[1]/2 - 0.5] )
		for( zm=[-size_chunks[2]/2 + 0.5 : 1 : size_chunks[2]/2 - 0.5] )
		["translate", [x1_mm, ym*chunk, zm*chunk], x_hole],
		
		for( xm=[-size_chunks[0]/2 + 0.5 : 1 : size_chunks[0]/2 - 0.5] )
		for( zm=[-size_chunks[2]/2 + 0.5 : 1 : size_chunks[2]/2 - 0.5] )
		["translate", [xm*chunk, y1_mm, zm*chunk], y_hole],
		
		for( xm=[-size_chunks[0]/2 + 0.5 : z_hole_x_spacing_chunks : size_chunks[0]/2 - 0.5] )
		for( ym=[-size_chunks[1]/2 + 0.5 : 1 : size_chunks[1]/2 - 0.5] )
		["translate", [xm*chunk, ym*chunk, z1_mm], z_hole],
	]
);
