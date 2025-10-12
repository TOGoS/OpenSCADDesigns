// ChunkBeam-v1.7
//
// It's a slotted gridbeam!
// Chunked for TOGridPile compatibility!
// Amazingly amazing!
// 
// v1.7:
// - Fix to make circular holes when chunk_pitch_atoms = 1
// - Atom pitch and hole_diameter may be quantity+unit strings (e.g. "3/4inch")
// - Wasn't previously tracking version.  v1.7 is arbirary.

atom_pitch = "1/2inch";
chunk_pitch_atoms = 3; // [1:1:12]
length_chunks = 3; // [1:1:12]
// 3.5mm has been demonstrated a good size for #6 machine screws
hole_diameter = "3.5mm";
longitudinal_hole_diameter = "0mm";

chunk_size_atoms = [chunk_pitch_atoms, 1, 1];
block_size_chunks = [length_chunks, 1, 1];

module __chunkbeam_v1__end_params() { }

$fn = $preview ? 16 : 64;

use <../lib/TOGShapeLib-v1.scad>
use <../lib/TOGUnits1.scad>

atom_pitch_mm                 = togunits1_to_mm(atom_pitch);
hole_diameter_mm              = togunits1_to_mm(hole_diameter);
longitudinal_hole_diameter_mm = togunits1_to_mm(longitudinal_hole_diameter);

function xx_multiply_each(a, b) = [for(i=[0 : 1 : len(a)-1]) a[i]*b[i]];

module xx_chunky(size_chunks, chunk_size) {
	for( xm=[-size_chunks[0]/2 + 0.5 : 1 : size_chunks[0]/2] )
	for( ym=[-size_chunks[1]/2 + 0.5 : 1 : size_chunks[1]/2] )
	for( zm=[-size_chunks[2]/2 + 0.5 : 1 : size_chunks[2]/2] )
	translate([xm*chunk_size[0],ym*chunk_size[1],zm*chunk_size[2]]) children();
}

module chunky_block_hull(size_chunks, chunk_size, u=1.5875) {
	block_size = xx_multiply_each(size_chunks, chunk_size);
	
	xx_chunky(size_chunks, chunk_size) tog_shapelib_facerounded_beveled_cube(chunk_size, 3.175, u);
	// u*sqrt(2) = v6.1 bevel size
	tog_shapelib_facerounded_beveled_cube([block_size[0]-u*2, block_size[1]-u*2, block_size[2]-u*2], u*sqrt(2), u);
	//cube(size, center=true);
}

chunk_size = [for(i=[0,1,2]) chunk_size_atoms[i]*atom_pitch_mm];
block_size = xx_multiply_each(block_size_chunks, chunk_size);

translate([0,0,block_size[2]/2]) difference() {
	length_atoms = length_chunks*chunk_pitch_atoms;
	
	chunky_block_hull(block_size_chunks, chunk_size);
	
	for( xa=[-length_atoms/2 + 0.5 : 1 : length_atoms/2] ) {
		echo(xa=xa, xa_mm=xa*atom_pitch_mm);
		translate([xa*atom_pitch_mm, 0, 0]) rotate([90,0,0]) cylinder(d=hole_diameter_mm, h=atom_pitch_mm*2, center=true);
	}
	
	if( longitudinal_hole_diameter_mm > 0 ) rotate([0,90,0]) cylinder(d=longitudinal_hole_diameter_mm, h=block_size[0]*2, center=true);
	
	for( xc=[-length_chunks/2 + 0.5 : 1 : length_chunks/2] ) {
		translate([xc*chunk_pitch_atoms*atom_pitch_mm, 0, 0]) linear_extrude(atom_pitch_mm*2, center=true) {
			slot_end_x_positions = chunk_pitch_atoms <= 1 ? [0] :
				[for(em=[-1,1]) em*((chunk_pitch_atoms-1)/2*atom_pitch_mm-hole_diameter_mm*1.5)];
			hull() for(x=slot_end_x_positions) {
				translate([x, 0, 0]) circle(d=hole_diameter_mm);
			}
		}
	}
}
