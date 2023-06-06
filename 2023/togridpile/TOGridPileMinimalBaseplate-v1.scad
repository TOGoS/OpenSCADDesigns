// TOGridPileMinimalBasePlate-v1.1
//
// v1.1:
// - Replace 'offset' with 'margin' because apparently the change
//   confused me and I did it backwards and so v1.0 was too tight.

use <../lib/TOGridPileLib-v2.scad>
use <../lib/TOGShapeLib-v1.scad>

size_chunks = [8,8];
thickness = 1.5875;

chunk_pitch_atoms = 3;
atom_pitch = 12.7;
column_diameter = 9.525;
column_style = "v6"; // ["v3", "v6", "v8"]
min_corner_radius = 1.5875;

margin = 0.1;
$fn = 24;

module 123789eyqkwfuybd__end_params() { }

inch = 25.4;

// TODO: Move this logic into togridpilelib
// make a togridpile2_chunk_column_footprint module that
// does whatever is needed for chunk-based feet
effective_atom_pitch        = column_style == "v3" ? atom_pitch*chunk_pitch_atoms : atom_pitch;
effective_chunk_pitch_atoms = column_style == "v3" ? 1 : chunk_pitch_atoms;
effective_column_diameter   = effective_atom_pitch - (atom_pitch - column_diameter);
effective_column_style      = column_style == "v3" ? "v6" : column_style;

function column_positions(size_atoms, atom_pitch) = [
	for( xm=[-size_atoms[0]/2+0.5 : 1 : size_atoms[0]/2] ) for( ym=[-size_atoms[1]/2+0.5 : 1 : size_atoms[1]/2] )
		[xm*atom_pitch, ym*atom_pitch]
];

linear_extrude(thickness) difference() {
	tog_shapelib_rounded_square(size_chunks*effective_chunk_pitch_atoms*effective_atom_pitch, 3/16*inch, offset=-margin);
	// togridpile2_atom_column_footprint(column_style, atom_pitch, 

	for( pos=column_positions(size_chunks*effective_chunk_pitch_atoms, effective_atom_pitch) ) {
		translate(pos) togridpile2_atom_column_footprint(effective_column_style, effective_atom_pitch, effective_column_diameter, min_corner_radius, offset=margin);
	}
}
