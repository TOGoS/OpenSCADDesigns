// NarrowBeam0.4
// 
// Gridbeam, but narrow in some direction or another,
// which might be useful for making corner connector blocks
// for boxes or something.
// 
// v0.2:
// - Allow Z hole spacing along X to be customized
// v0.3:
// - Allow Y hole spacing along X to be customized
// - Start some code for 'fixing' counterbored holes.
// v0.4:
// - Option for bottom_membrane_thickness; when > 0,
//   z holes will not go through the bottom.

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
y_hole_x_spacing = "1chunk";
z_hole_x_spacing = "1chunk";
bottom_membrane_thickness = "0mm";

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
y_hole_x_spacing_chunks = togunits1_decode(y_hole_x_spacing, unit="chunk");
z_hole_x_spacing_chunks = togunits1_decode(z_hole_x_spacing, unit="chunk");
bottom_membrane_thickness_mm = togunits1_to_mm(bottom_membrane_thickness);

size = [x1_mm-x0_mm, y1_mm-y0_mm, z1_mm-z0_mm];

// Idea I started here is that counterbores would be automatically merged.
// Proper solution is to have an option to round all convex corners lmao,
// which would require rewriting everything as SDFs or something.
y_hole_mode = "normal";
z_hole_mode = "normal";
// y_hole_mode = y_hole_style == "THL-1006" && y_hole_x_spacing_chunks < 1 ? "monopocket" : "normal";
// z_hole_mode = z_hole_style == "THL-1006" && z_hole_x_spacing_chunks < 1 ? "monopocket" : "normal";

eff_x_hole_style = x_hole_style;
eff_y_hole_style = y_hole_mode == "normal" ? y_hole_style : "straight-5/16inch";
eff_z_hole_style = z_hole_mode == "normal" ? z_hole_style : "straight-5/16inch";

x_hole = ["rotate-xyz", [  0,90, 0], tog_holelib2_hole(eff_x_hole_style, depth=size[0]+10)];
y_hole = ["rotate-xyz", [-90, 0, 0], tog_holelib2_hole(eff_y_hole_style, depth=size[1]+10)];
z_hole = ["rotate-xyz", [  0, 0, 0], tog_holelib2_hole(eff_z_hole_style,
	depth=bottom_membrane_thickness_mm > 0 ? size[2]-bottom_membrane_thickness_mm : size[2]+10
)];

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
		
		for( xm=[-size_chunks[0]/2 + 0.5 : y_hole_x_spacing_chunks : size_chunks[0]/2 - 0.5] )
		for( zm=[-size_chunks[2]/2 + 0.5 : 1 : size_chunks[2]/2 - 0.5] )
		["translate", [xm*chunk, y1_mm, zm*chunk], y_hole],
		
		for( xm=[-size_chunks[0]/2 + 0.5 : z_hole_x_spacing_chunks : size_chunks[0]/2 - 0.5] )
		for( ym=[-size_chunks[1]/2 + 0.5 : 1 : size_chunks[1]/2 - 0.5] )
		["translate", [xm*chunk, ym*chunk, z1_mm], z_hole],
	]
);
