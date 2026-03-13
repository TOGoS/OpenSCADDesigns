// HollowBeam0.2
// 
// Hollow square tubing.
// Each side can have differently-sized holes.
//
// Possibly useful as a sort of coupler when you need to attach stuff to the ceiling?
// 
// See also: Schonk3, Schonk4
// 
// v0.2:
// - Add option for Z-wise inner threads

length = "1chunk";
wall_thickness = "3/16inch";
north_hole_style = "straight-5mm";
north_hole_spacing = "1chunk";
north_hole_frequency = 2;
east_hole_style = "straight-9mm";
east_hole_spacing = "1chunk";
east_hole_frequency = 2;
south_hole_style = "straight-10mm";
south_hole_spacing = "1chunk";
south_hole_frequency = 2;
west_hole_style = "straight-9mm";
west_hole_spacing = "1chunk";
west_hole_frequency = 2;
z_inner_thread_style = "none";
z_inner_thread_radius_offset = 0.2;
z_inner_thread_inset = "2mm";

$fn = 32;

use <../lib/TOGMod1.scad>
use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGUnits1.scad>
use <../lib/TOGThreads2.scad>

size_mm = togunits1_vec_to_mms(["chunk","chunk"]);
length_mm = togunits1_to_mm(length);
wall_thickness_mm = togunits1_to_mm(wall_thickness);

north_hole  = tog_holelib2_hole(north_hole_style, depth=wall_thickness_mm+1);
north_hole_spacing_mm = togunits1_to_mm(north_hole_spacing);
south_hole  = tog_holelib2_hole(south_hole_style, depth=wall_thickness_mm+1);
south_hole_spacing_mm = togunits1_to_mm(south_hole_spacing);
east_hole  = tog_holelib2_hole(east_hole_style, depth=wall_thickness_mm+1);
east_hole_spacing_mm = togunits1_to_mm(east_hole_spacing);
west_hole  = tog_holelib2_hole(west_hole_style, depth=wall_thickness_mm+1);
west_hole_spacing_mm = togunits1_to_mm(west_hole_spacing);

togmod1_domodule(
	["difference",
		togmod1_linear_extrude_z([-length_mm/2, length_mm/2], ["difference",
			togmod1_make_rounded_rect(size_mm, r=wall_thickness_mm),
			togmod1_make_rounded_rect([
				size_mm[0]-wall_thickness_mm*2,
				size_mm[1]-wall_thickness_mm*2,
			], r=1),
		]),
		
		togthreads2_make_threads(
			togthreads2_simple_zparams([[-length_mm/2, 1], [length_mm/2, 1]], taper_length=1, inset=togunits1_to_mm(z_inner_thread_inset)),
			z_inner_thread_style
		),
		
		for( zm=[-length_mm/north_hole_spacing_mm/2 + 0.5 : 1/north_hole_frequency : length_mm/north_hole_spacing_mm/2-0.4] )
		["translate", [0,  size_mm[1]/2, zm*north_hole_spacing_mm], ["rotate", [-90,0,0], north_hole]],
		
		for( zm=[-length_mm/south_hole_spacing_mm/2 + 0.5 : 1/south_hole_frequency : length_mm/south_hole_spacing_mm/2-0.4] )
		["translate", [0, -size_mm[1]/2, zm*south_hole_spacing_mm], ["rotate", [ 90,0,0], south_hole]],
		
		for( zm=[-length_mm/east_hole_spacing_mm/2 + 0.5 : 1/east_hole_frequency : length_mm/east_hole_spacing_mm/2-0.4] )
		["translate", [ size_mm[1]/2, 0, zm*east_hole_spacing_mm], ["rotate", [0, 90,0], east_hole]],
		
		for( zm=[-length_mm/west_hole_spacing_mm/2 + 0.5 : 1/west_hole_frequency : length_mm/west_hole_spacing_mm/2-0.4] )
		["translate", [-size_mm[1]/2, 0, zm*west_hole_spacing_mm], ["rotate", [0,-90,0], west_hole]],
	]
);
