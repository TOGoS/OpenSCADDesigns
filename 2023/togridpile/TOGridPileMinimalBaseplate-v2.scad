// TOGridPileMinimalBasePlate-v2.0
//
// v1.1:
// - Replace 'offset' with 'margin' because apparently the change
//   confused me and I did it backwards and so v1.0 was too tight.
// v1.2:
// - margin can be configured down to 0.01mm
// v1.3:
// - Support v6.0, v6.1, or v6.2, and segmentation configured separately.
// - Outer corners are rounded beveled to ensure fit within 1/8"
//   beveled boxes
// v2.0:
// - Make 'v6.1' the default column style
// - Make 'chunk' the default segmentation
// - More clearly separate parameters relating to interior and exteriod

use <../lib/TOGridPileLib-v2.scad>
use <../lib/TOGShapeLib-v1.scad>

size_chunks = [8,8];
thickness = 1.5875;

chunk_pitch_atoms = 3;
atom_pitch = 12.7;
column_diameter = 9.525;
column_style = "v6.1"; // ["v3", "v6.0", "v6.1", "v6.2", "v8"]
segmentation = "chunk"; // ["atom", "chunk"]

outer_bevel_size = 3.175;
outer_corner_radius = 3.175;

// Radius of column cutouts; anything lower than 1/16"=1.5875 should be 'safe'
inner_corner_radius = 1.5875;

outer_margin = 0.05; // 0.01
inner_margin = 0.10; // 0.01
$fn = $preview ? 16 : 64;

module 123789eyqkwfuybd__end_params() { }

inch = 25.4;

effective_segmentation      = column_style == "v3" ? "chunk" : segmentation;
chonk_pitch_atoms           = effective_segmentation == "atom" ? 1 : chunk_pitch_atoms;
size_chonks                 = size_chunks * (effective_segmentation == "atom" ? chunk_pitch_atoms : 1);
chonk_pitch                 = chonk_pitch_atoms * atom_pitch;
effective_column_diameter   = chonk_pitch - (atom_pitch - column_diameter);
effective_column_style      = column_style == "v3" ? "v6.0" : column_style;

function column_positions(size_atoms, atom_pitch) = [
	for( xm=[-size_atoms[0]/2+0.5 : 1 : size_atoms[0]/2] ) for( ym=[-size_atoms[1]/2+0.5 : 1 : size_atoms[1]/2] )
		[xm*atom_pitch, ym*atom_pitch]
];

linear_extrude(thickness) difference() {
	tog_shapelib_rounded_beveled_square(size_chunks*chunk_pitch_atoms*atom_pitch, outer_bevel_size, outer_corner_radius, offset=-outer_margin);
	// togridpile2_atom_column_footprint(column_style, atom_pitch, 

	for( pos=column_positions(size_chonks, chonk_pitch_atoms*atom_pitch) ) {
		translate(pos) togridpile2_atom_column_footprint(effective_column_style, chonk_pitch, effective_column_diameter, inner_corner_radius, offset=inner_margin);
	}
}
