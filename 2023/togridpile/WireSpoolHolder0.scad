// WireSpoolHolder0.1
// 
// TODO: Apply $tgx11_offset to cavity,
// or provide a separate parameter for it,
// so that this can also be a comfy brick holder-like box!
// 
// TODO: Option for TOGridPile 'foot columns';
// whatever axis has those can also get magnet holes.

size_chunks = [2,2,2];
// Nominal wall thickness, before subtractions
wall_thickness = "1/4inch";

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

chunk_size_mm = togunits1_to_mm("chunk");
atom_size_mm  = togunits1_to_mm("atom");

wall_thickness_mm = togunits1_to_mm(wall_thickness);

$togridlib3_unit_table = tgx11_get_default_unit_table();

togmod1_domodule(
	let( size_mm = size_chunks * chunk_size_mm )
	let( chunk = ["render", make_chunk(chunk_size_mm, $fn=24)] )
	let( metachunk = make_metachunk( size_chunks, [chunk_size_mm, chunk_size_mm, chunk_size_mm], chunk, $fn=24 ) )
	let( cavity = ["translate", [0,0,size_mm[2]/2], tphl1_make_rounded_cuboid([size_mm[0]-12.7, size_mm[1]-wall_thickness_mm*2, size_mm[2]*2-wall_thickness_mm*2], r=[1,1,1], $fn=12)] )
	// Counterbored hole along X axis
	let( spool_axis_hole = ["rotate", [0,90,0], tphl1_make_z_cylinder(zds=[
		[-size_mm[0]      , 22],
		[-size_mm[0]/2 + 3, 22],
		[-size_mm[0]/2 + 3,  9],
		[ size_mm[0]/2 - 3,  9],
		[ size_mm[0]/2 - 3, 22],
		[ size_mm[0]      , 22],
	])])
	let( wire_y_hole = ["rotate", [90,0,0], tphl1_make_z_cylinder(zrange=[-size_mm[1], size_mm[1]], d=3)] )
	let( wire_y_hole_positions = [
		for( xc=[-size_chunks[0]/2 + 0.5 : 1 : size_chunks[0]/2 - 0.5] )
		for( zc=[-size_chunks[2]/2 + 0.5 : 1 : size_chunks[2]/2 - 0.5] )
		for( ap=[[-1, 0], [0, 1], [1, 0], [0, -1]] )
		let( p = [xc * chunk_size_mm + ap[0]*atom_size_mm, 0, zc*chunk_size_mm + ap[1]*atom_size_mm] )
		if( abs(p[0]) < size_mm[0]/2 - 7 && p[2] > -size_mm[2]/2 + 7 )
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
	let( magnet_y_pocket = ["rotate", [90,0,0], magnet_z_pocket] )
	let( magnet_y_pocket_positions = [
		for( xc=[-size_chunks[0]/2 + 0.5 : 1 : size_chunks[0]/2 - 0.5] )
		for( zc=[-size_chunks[2]/2 + 0.5 : 1 : size_chunks[2]/2 - 0.5] )
		for( ap=[[-1, -1], [1, -1], [1, 1], [-1, 1]] )
		for( y = [-size_mm[1]/2, size_mm[1]/2] )
	   [xc * chunk_size_mm + ap[0]*atom_size_mm, y, zc*chunk_size_mm + ap[1]*atom_size_mm]
	])
	["difference",
		["render", metachunk],
		
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
	]
);
