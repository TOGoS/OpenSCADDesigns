// ChunkBeam-v1.scad
//
// It's a slotted gridbeam!
// Chunked for TOGridPile compatibility!
// Amazingly amazing!

atom_pitch = 12.7;
chunk_pitch_atoms = 3;
length_chunks = 3;
// 3.5mm has been demonstrated a good size for #6 machine screws
hole_diameter = 3.5;

chunk_size_atoms = [chunk_pitch_atoms, 1, 1];
block_size_chunks = [length_chunks, 1, 1];

$fn = $preview ? 16 : 64;

use <../lib/TOGShapeLib-v1.scad>

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

chunk_size = [for(i=[0,1,2]) chunk_size_atoms[i]*atom_pitch];
block_size = xx_multiply_each(block_size_chunks, chunk_size);

translate([0,0,block_size[2]/2]) difference() {
	length_atoms = length_chunks*chunk_pitch_atoms;
	
	chunky_block_hull(block_size_chunks, chunk_size);
	
	for( xa=[-length_atoms/2 + 0.5 : 1 : length_atoms/2] ) {
		echo(xa=xa, xa_mm=xa*atom_pitch);
		translate([xa*atom_pitch, 0, 0]) rotate([90,0,0]) cylinder(d=hole_diameter, h=atom_pitch*2, center=true);
	}
	
	for( xc=[-length_chunks/2 + 0.5 : 1 : length_chunks/2] ) {
		translate([xc*chunk_pitch_atoms*atom_pitch, 0, 0]) linear_extrude(atom_pitch*2, center=true) {
			hull() for(em=[-1,1]) {
				translate([em*((chunk_pitch_atoms-1)/2*atom_pitch-hole_diameter*1.5), 0, 0]) circle(d=hole_diameter);
			}
		}
	}
}
