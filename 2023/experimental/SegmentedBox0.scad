// SegmentedBox0.1
// 
// Prototype stackable sections.
// See 2026-timelog.txt#2026-01-02-modular-brick-holders for initial thoughts.

section_size_atoms = [6,6,1];
part = "glue"; // ["glue","section"]
connector_surface_offset = "-0.15mm";
outer_surface_offset = "-0.1mm";
$fn = 128;

module __segmentedbox0__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGUnits1.scad>

inch = 254/10;
atom = 127/10;

groove_width_mm = inch/24;
groove_corner_radius_mm = inch/8;

wall_thickness_mm = atom/2;

connector_surface_offset_mm = togunits1_to_mm(connector_surface_offset);
outer_surface_offset_mm     = togunits1_to_mm(outer_surface_offset);

/*
function segmentedbox0_make_rect_rath(size, corner_radius) =
	let( cops = [["round", corner_radius]] )
	["togpath1-rath",
		["togpath1-rathnode", [ size[0]/2,  size[1]/2], each cops],
		["togpath1-rathnode", [-size[0]/2,  size[1]/2], each cops],
		["togpath1-rathnode", [-size[0]/2, -size[1]/2], each cops],
		["togpath1-rathnode", [ size[0]/2, -size[1]/2], each cops],
	];
*/

/*
function segmentedbox0_make_groove(center_rath, xy_thickness, z_thickness, xy_surface_offset, z_surface_offset) =
	let( z0 = -z_thickness/2 - z_surface_offset )
	let( z1 =  z_thickness/2 + z_surface_offset )
	tphl1_make_polyhedron_from_layer_function(
		[
			[z0, 0 + xy_thickness/2 + xy_surface_offset],
			[z1, 0 + xy_thickness/2 + xy_surface_offset],
			[z1, 0 - xy_thickness/2 - xy_surface_offset],
			[z0, 0 - xy_thickness/2 - xy_surface_offset],
			[z0, 0 + xy_thickness/2 + xy_surface_offset],
		],
		function(zo) togpath1_rath_to_polypoints(
			togpath1_offset_rath(center_rath, zo[1])
		),
		layer_points_transform = "key0-to-z",
		cap_bottom = false,
		cap_top = false
	);
*/

function segmentedbox0_make_ring(center_rath, cross_section_rath) =
	let( cs_polypoints = togpath1_rath_to_polypoints(cross_section_rath) )
	tphl1_make_polyhedron_from_layer_function(
		[
			each cs_polypoints,
			cs_polypoints[0],
		],
		function(oz) togpath1_rath_to_polypoints(
			togpath1_offset_rath(center_rath, oz[0])
		),
		layer_points_transform = "key1-to-z",
		cap_bottom = false,
		cap_top = false
	);

function segmentedbox0_make_groove(center_rath, xy_thickness, z_thickness, surface_offset) =
	segmentedbox0_make_ring(center_rath, togpath1_make_rectangle_rath([xy_thickness, z_thickness], corner_ops=[["offset", surface_offset]]));

wall_center_rath = togpath1_make_rectangle_rath(
	[(section_size_atoms[0]-0.5)*atom, (section_size_atoms[1]-0.5)*atom],
	corner_ops = [["round", groove_corner_radius_mm]]
);

togmod1_domodule(
	let( glue = segmentedbox0_make_groove(
		center_rath = wall_center_rath,
		xy_thickness = groove_width_mm,
		z_thickness = 6.35,
		surface_offset = connector_surface_offset_mm
	) )
	let( groove = segmentedbox0_make_groove(
		center_rath = wall_center_rath,
		xy_thickness = groove_width_mm,
		z_thickness = 6.35,
		surface_offset = -connector_surface_offset_mm
	) )
	let( section = ["difference",
		segmentedbox0_make_ring(
			wall_center_rath,
			togpath1_make_rectangle_rath(
				[wall_thickness_mm, section_size_atoms[2]*atom - inch/8],
				corner_ops=[["bevel", inch/16], ["offset", outer_surface_offset_mm]]
			)
		),
		
		for(zm=[-1,+1]) ["translate", [0,0,zm*section_size_atoms[2]*atom/2], groove],
	] )
	
	part == "glue" ? glue :
	part == "section" ? section :
	assert(false, str("Unknown part: '", part, "'"))
);
