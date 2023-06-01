// 12.7mm = 1/2"
atom_pitch        = 12.7000; // 0.0001
// 9.5245mm = 3/8"
column_diameter   =  9.5245; // 0.0001
// 1.5875mm = 1/16"
min_corner_radius =  1.5875; // 0.0001

use <TOGShapeLib-v1.scad>

module togridpile2_atom_column_footprint(column_style="v8", atom_pitch=atom_pitch, column_diameter=column_diameter, min_corner_radius=min_corner_radius, offset=0) {
	if( column_style == "v6" ) {
		column_inset = (atom_pitch - column_diameter)/2;
		// (0.707-0.414)*min_corner_radius should be equivalent to the old _adj=... hack
		tog_shapelib_rounded_beveled_square([column_diameter, column_diameter], column_inset*2*0.707 + (0.707-0.414)*min_corner_radius, min_corner_radius, offset);
	} else if( column_style == "v6.1" ) {
		column_inset = (atom_pitch - column_diameter)/2;
		tog_shapelib_rounded_beveled_square([column_diameter, column_diameter], column_inset*2*0.707, min_corner_radius, offset);
	} else if( column_style == "v6.2" ) {
		// similar to v6 or v6.1, but with deep-enough bevels to fit another diagonally, as in v8.4
		column_inset = (atom_pitch - column_diameter)/2;
		tog_shapelib_rounded_beveled_square([column_diameter, column_diameter], atom_pitch/2-(atom_pitch-column_diameter), min_corner_radius, offset);
	} else if( column_style == "v8.0" ) {
		circle(d=column_diameter+offset);
	} else if( column_style == "v8.4" ) {
		// rounded but with corners trimmed so another can fit between diagonally
		intersection() {
			circle(d=column_diameter+offset);
			rotate([0,0,45]) square(atom_pitch*0.707+offset, center=true);
		}
	} else {
		assert(false, str("Unrecognized column column_style: '", column_style, "'"));
	}
}
