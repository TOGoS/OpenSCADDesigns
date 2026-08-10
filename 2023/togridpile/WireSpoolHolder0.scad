// WireSpoolHolder0.3
// 
// v0.2:
// - Fix that `wall_thickness` was not taken into account in all directions
// - By `cavity_surface_offset` (defaults to $tgx11_offset) to cavity surfaces
// - Option for `top_lip_z_offset`, which, when negative,
//   cuts a female TOGridPile foot into the top
// v0.3:
// - Option for foot_style = 'circle'
// - Option for magnet pockets in bottom
// - Bevel edges around X axis hole counterbores

size_chunks = [2,2,2];
// Nominal wall thickness, before subtractions
wall_thickness = "1/4inch";

// Set to a negative value to cut a positive TOGridPile lip that far below the nominal top of the block.
top_lip_z_offset = "0inch";
top_lip_segmentation = "chunk";
top_lip_height = "1.6mm";

foot_style = "none"; // ["none","circle"]
bottom_atom_hole_style = "none"; // ["none","magnet-pocket"]

// Set to a small negative value to slightly enlarge cavity; if blank, will be the same as $tgx11_offset
cavity_surface_offset = "";

$tgx11_offset = -0.1;
$fn = 48;

module __wirespoolholder0__end_params() { }

use <../lib/TGx11.1Lib.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGUnits1.scad>
use <../lib/TOGHoleLib2.scad>

//// Chunk construction functions

// Might want to stick in a library at some point because this isn't
// the first time I've written something like this.

function make_chunk(width) =
	let( bevel_size = togunits1_to_mm("tgp-standard-bevel") )
	let( actual_width = width + $tgx11_offset*2 )
	let( zrange = [-actual_width/2, actual_width/2] )
	let( face =
		let(ew = width - 2*bevel_size + $tgx11_offset*(sqrt(2)-1)*2)
		togmod1_make_rounded_rect([ew, ew], r=bevel_size/2) )
	["hull",
		togmod1_linear_extrude_x(zrange, face),
		togmod1_linear_extrude_y(zrange, face),
		togmod1_linear_extrude_z(zrange, face),
	];

function make_metachunk( size_chunks, chunk_size, chunk ) =
	let( bevel_size = togunits1_to_mm("tgp-standard-bevel") )
	let( rr = bevel_size/2 )
	["union",
		for( zm=[-size_chunks[2]/2+0.5 : 1 : size_chunks[2]/2-0.5] )
		for( ym=[-size_chunks[1]/2+0.5 : 1 : size_chunks[1]/2-0.5] )
		for( xm=[-size_chunks[0]/2+0.5 : 1 : size_chunks[0]/2-0.5] )
		["translate", [xm*chunk_size[0], ym*chunk_size[1], zm*chunk_size[2]], chunk],
		
		tphl1_make_rounded_cuboid([
			size_chunks[0]*chunk_size[0] - bevel_size*2 + $tgx11_offset*2 + 1/32,
			size_chunks[1]*chunk_size[1] - bevel_size*2 + $tgx11_offset*2 + 1/32,
			size_chunks[2]*chunk_size[2] - bevel_size*2 + $tgx11_offset*2 + 1/32,
		], r=[rr,rr,rr])
	];

//// End chunk construction functions

function is_blank(v) = is_undef(v) || v == "";

$togunits1_default_unit = "mm";

chunk_size_mm = togunits1_to_mm("chunk");
atom_size_mm  = togunits1_to_mm("atom");

top_lip_z_offset_mm = togunits1_to_mm(top_lip_z_offset);
top_lip_height_mm   = togunits1_to_mm(top_lip_height);
wall_thickness_mm   = togunits1_to_mm(wall_thickness);
cavity_surface_offset_mm = is_blank(cavity_surface_offset) ? $tgx11_offset : togunits1_to_mm(cavity_surface_offset);

$togridlib3_unit_table = tgx11_get_default_unit_table();

assert( top_lip_height_mm >= 0, "Negative top lip height not currently supported" );
// There's no reason it couldn't be, though I might want to
// use some sentinal string instead of magical -1 to mean
// 'make the top male'.

togmod1_domodule(
	let( size_mm = size_chunks * chunk_size_mm )
	let( size_atoms = size_chunks * 3 )
	let( chunk = ["render", make_chunk(chunk_size_mm, $fn=24)] )
	let( metachunk = make_metachunk( size_chunks, [chunk_size_mm, chunk_size_mm, chunk_size_mm], chunk, $fn=24 ) )
	let( foot_d = atom_size_mm*sqrt(2)/2 )
	let( foot = tphl1_make_z_cylinder(zds=[
		[0   - $tgx11_offset + 1/256, foot_d-0.8],
		[0.4 - $tgx11_offset + 1/256, foot_d    ],
		[atom_size_mm               , foot_d    ]
	]))
	let( block_hull = ["union",
		metachunk,
		
		if( foot_style != "none" )
		for( ym=[-size_atoms[1]/2 + 0.5 : 1 : size_atoms[1]/2 - 0.5] )
		for( xm=[-size_atoms[0]/2 + 0.5 : 1 : size_atoms[0]/2 - 0.5] )
		["translate", [xm*atom_size_mm, ym*atom_size_mm, -size_mm[2]/2],
			foot
		]
	])
	let( cavity = ["translate", [0,0,size_mm[2]/2],
		tphl1_make_rounded_cuboid(
			[
				size_mm[0] - wall_thickness_mm*2 - cavity_surface_offset_mm*2,
				size_mm[1] - wall_thickness_mm*2 - cavity_surface_offset_mm*2,
				size_mm[2]*2-wall_thickness_mm*2 - cavity_surface_offset_mm*2
			], r=[1,1,1], $fn=12)
	] )
	let( eff_top_z = size_mm[2]/2 + top_lip_z_offset_mm )
	// Counterbored hole along X axis
	let( spool_axis_hole = ["rotate", [0,90,0], tphl1_make_z_cylinder(zds=[
		[-size_mm[0]/2 - 2, 30],
		[-size_mm[0]/2 + 2, 22],
		[-size_mm[0]/2 + 3, 22],
		[-size_mm[0]/2 + 3,  9],
		[ size_mm[0]/2 - 3,  9],
		[ size_mm[0]/2 - 3, 22],
		[ size_mm[0]/2 - 2, 22],
		[ size_mm[0]/2 + 2, 30],
	])])
	let( wire_y_hole = ["rotate", [90,0,0], tphl1_make_z_cylinder(zrange=[-size_mm[1], size_mm[1]], d=3)] )
	let( wire_y_hole_positions = [
		for( xc=[-size_chunks[0]/2 + 0.5 : 1 : size_chunks[0]/2 - 0.5] )
		for( zc=[-size_chunks[2]/2 + 0.5 : 1 : size_chunks[2]/2 - 0.5] )
		for( ap=[[-1, 0], [0, 1], [1, 0], [0, -1]] )
		let( p = [xc * chunk_size_mm + ap[0]*atom_size_mm, 0, zc*chunk_size_mm + ap[1]*atom_size_mm] )
		if( abs(p[0]) < size_mm[0]/2 - 7 && p[2] > -size_mm[2]/2 + 7 && p[2] + 3 < eff_top_z )
		p
	])
	let( floor_hole = tog_holelib2_hole("THL-1006", depth=wall_thickness_mm+5, inset=2) )
	let( floor_hole_positions =
		let( floor_z = -size_mm[2]/2 + wall_thickness_mm )
		[
			for( xc=[-size_chunks[0]/2 + 0.5 : 1 : size_chunks[0]/2 - 0.5] )
			for( yc=[-size_chunks[1]/2 + 0.5 : 1 : size_chunks[1]/2 - 0.5] )
			[xc*chunk_size_mm, yc*chunk_size_mm, floor_z],
			
			for( xc=[-size_chunks[0]/2 + 1 : 1 : size_chunks[0]/2 - 1] )
			for( yc=[-size_chunks[1]/2 + 1 : 1 : size_chunks[1]/2 - 1] )
			[xc*chunk_size_mm, yc*chunk_size_mm, floor_z],
		])
	// Hmm: Might want to countersink the connector holes on the inside
	// for use with #6 flatheads.
	let( connector_y_hole = ["rotate", [90,0,0], tphl1_make_z_cylinder(zrange=[-size_mm[1], size_mm[1]], d=5)] )
	let( connector_x_hole = ["rotate", [0,90,0], tphl1_make_z_cylinder(zrange=[-size_mm[0], size_mm[0]], d=5)] )
	let( magnet_z_pocket = tphl1_make_z_cylinder(d=6.2, zrange=[-2.4,2.4]) )
	let( bottom_edge_atom_positions = [
		for( xc=[-size_chunks[0]/2 + 0.5 : 1 : size_chunks[0]/2 - 0.5] )
		for( yc=[-size_chunks[1]/2 + 0.5 : 1 : size_chunks[1]/2 - 0.5] )
		for( ap=[[-1, -1], [0,-1], [1, -1], [1,0], [1, 1], [0,1], [-1, 1], [-1,0]] )
		[xc * chunk_size_mm + ap[0]*atom_size_mm, yc*chunk_size_mm + ap[1]*atom_size_mm, -size_mm[2]/2]
	])
	let( magnet_y_pocket = ["rotate", [90,0,0], magnet_z_pocket] )
	let( magnet_y_pocket_positions = [
		for( xc=[-size_chunks[0]/2 + 0.5 : 1 : size_chunks[0]/2 - 0.5] )
		for( zc=[-size_chunks[2]/2 + 0.5 : 1 : size_chunks[2]/2 - 0.5] )
		for( ap=[[-1, -1], [1, -1], [1, 1], [-1, 1]] )
		for( y = [-size_mm[1]/2, size_mm[1]/2] )
		[xc * chunk_size_mm + ap[0]*atom_size_mm, y, zc*chunk_size_mm + ap[1]*atom_size_mm]
	])
	["difference",
		["render", block_hull],
		
		cavity,
		
		spool_axis_hole,
		
		for( pos=wire_y_hole_positions ) ["translate", pos, wire_y_hole],
		
		for( pos=floor_hole_positions ) ["translate", pos, floor_hole],
		
		for( zc=[-size_chunks[2]/2 + 0.5 : 1 : size_chunks[2]/2 - 0.5] )
		for( xc=[-size_chunks[0]/2 + 0.5 : 1 : size_chunks[0]/2 - 0.5] )
		["translate", [xc, 0, zc]*chunk_size_mm, connector_y_hole],
		
		for( zc=[-size_chunks[2]/2 + 0.5 : 1 : size_chunks[2]/2 - 0.5] )
		for( yc=[-size_chunks[1]/2 + 0.5 : 1 : size_chunks[1]/2 - 0.5] )
		["translate", [0, yc, zc]*chunk_size_mm, connector_x_hole],
		
		// TODO: Magnet pockets on X and Z surfaces, too
		// But for now, none of them, because they cut into the edges of the beveled cubes.
		// Add 'foot columns' and it may work.
		// for( pos = magnet_y_pocket_positions ) ["translate", pos, magnet_y_pocket],
		if( bottom_atom_hole_style == "magnet-pocket" )
		for( pos = bottom_edge_atom_positions ) ["translate", pos, magnet_z_pocket],
		
		if( top_lip_z_offset_mm < 0 )
		["translate", [0, 0, size_mm[2]/2+top_lip_z_offset_mm],
			["union",
				if( top_lip_height_mm > 0 ) tgx11_block_bottom(
					[for(d=size_chunks) [d,"chunk"]],
					bottom_shape = "footed",
					segmentation = top_lip_segmentation,
					$tgx11_gender = "female",
					$tgx11_offset = -$tgx11_offset
				),
				
				["translate", [0,0,top_lip_height_mm+size_mm[2]/2], togmod1_make_cuboid([size_mm[0]+20, size_mm[1]+20, size_mm[2]])],
			]
		]
	]
);
