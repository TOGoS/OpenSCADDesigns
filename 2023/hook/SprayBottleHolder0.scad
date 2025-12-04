// SprayBottleHolder0.2
// 
// For these spray bottles that I have in the Farmhouse office.
// 
// Measurements of, uh, 'subneck',
// i.e. a part of the main bottle that sticks out a bit
// under where the head screws on:
// - wide part: 49mm wide
// - narrow part under that: 45mm wide, tapering back out to 49mm
//   over...at least 10mm, and beyond
// - bottle :: about 3+1/2"
// 
// v0.2:
// - Option for bottom_membrane_thickness

width     = "3inch";
length    = "4.5inch";
thickness = "1/2inch";
bottom_membrane_thickness = "0";

chin_width = "50mm";

// Width of neck just under chin
neck_width = "46mm";
neck_taperat = -1/5; // dr/dz; 0 = straight up/down, 1 = 45 degrees

$fn = 36;

module __spraybottleholder0__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGUnits1.scad>
use <../lib/TOGVecLib0.scad>

$togunits1_default_unit = "mm";

width_mm  = togunits1_to_mm(width);
length_mm = togunits1_to_mm(length);
thickness_mm = togunits1_to_mm(thickness);
chin_width_mm = togunits1_to_mm(chin_width);
neck_width_mm = togunits1_to_mm(neck_width);
bottom_membrane_thickness_mm = togunits1_to_mm(bottom_membrane_thickness);

center_inset_mm = width_mm/2;
chin_inset_mm = 2;

hole_z0 = bottom_membrane_thickness_mm == 0 ? -thickness_mm : -thickness_mm/2 + bottom_membrane_thickness_mm;

togmod1_domodule(
	let( z1 = thickness_mm/2 )
	let( y0 = -length_mm/2 )
	let( center_x = 0 )
	let( center_y = y0 + center_inset_mm )
	let( atom = togunits1_to_mm("atom"), chunk = togunits1_to_mm("chunk") )
	let( size_chunks = [round(width_mm/chunk), round(length_mm/chunk)] )
	let( size_atoms  = [round(width_mm/atom), round(length_mm/atom)] )
	let( atom_hole   = ["render", tphl1_make_z_cylinder(zrange=[hole_z0, thickness_mm], d=4.5)] )
	let( chunk_hole  = ["render", tphl1_make_z_cylinder(zrange=[hole_z0, thickness_mm], d=9  )] )
	["difference",
		tphl1_make_rounded_cuboid([width_mm, length_mm, thickness_mm], r=[6.35,6.35,2], corner_shape="cone2"),
		
		// Neck slot
		tphl1_make_polyhedron_from_layer_function([
			[-chin_inset_mm - 100, neck_width_mm/2 - neck_taperat*100],
			[-chin_inset_mm      , neck_width_mm/2],
			[-chin_inset_mm + 100, neck_width_mm/2 + neck_taperat*100],
		], function(zo) togvec0_offset_points(
		   togpath1_rath_to_polypoints(
			   togpath1_polyline_to_rath([
				   [center_x, center_y],
					[center_x, center_y - center_inset_mm*2],
				], r=zo[1] )
			),
			z1 + zo[0]
		)),
		
		// Chin rest
		tphl1_make_polyhedron_from_layer_function([
			[-chin_inset_mm - 10 , chin_width_mm/2 - 10],
			[-chin_inset_mm      , chin_width_mm/2],
			[ 1                  , chin_width_mm/2],
		], function(zo) togvec0_offset_points(
		   togpath1_rath_to_polypoints(
			   togpath1_polyline_to_rath([
				   [center_x, center_y],
				], r=zo[1] )
			),
			z1 + zo[0]
		)),
	   
		for( xm=[-size_atoms[0]/2 + 0.5 : 1 : size_atoms[0]/2] )
		for( ym=[-size_atoms[1]/2 + size_atoms[0] - 0.5 : 1 : size_atoms[1]/2] )
		["translate", [xm,ym]*atom, atom_hole],
		
		for( xm=[-size_chunks[0]/2 + 0.5 : 1 : size_chunks[0]/2] )
		for( ym=[-size_chunks[1]/2 + size_chunks[0] + 0.5 : 1 : size_chunks[1]/2] )
		["translate", [xm,ym]*chunk, chunk_hole],
	]
);
