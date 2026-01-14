/// Demonstrate some matrix math

function translation_matrix(pos) =
	[
		[ 1, 0, pos[0]],
		[ 0, 1, pos[1]],
		[ 0, 0,      1],
	];

function rotation_matrix(angle) =
	// Angle?
	is_num(angle) ? [
		[ cos(angle),-sin(angle), 0],
		[ sin(angle), cos(angle), 0],
		[          0,          0, 1],
	] :
	assert(false, str("rotation_matrix argument should be an angle, in degrees; got: ", angle));

vec = [1,0,1];
matrix = [
	[0,1, 5],
	[1,0,10],
];

//echo( vec=vec, matrix=matrix, vec_times_matrix=vec*matrix, matrix_times_vec=matrix*vec );
// echo( vec=vec, matrix=matrix, matrix_times_vec=matrix*vec );

compound_matrix =
	[
		// Translate([12,24])
		[1,0,12],
		[0,1,24],
		[0,0, 1],
	] * [
		// Rotate(90)
		[ 0, -1, 0],
		[ 1,  0, 0],
		[ 0,  0, 1],
	];

//echo( compound_matrix=compound_matrix );
//echo( compound_matrix_times_vec=compound_matrix*[1,0,1] );

compound_matrix2 = translation_matrix([12,24]) * rotation_matrix(90);

//echo( compound_matrix2=compound_matrix );
//echo( compound_matrix2_times_vec=compound_matrix2*[1,0,1] );

assert( compound_matrix == compound_matrix2 );
assert( compound_matrix2*[1,0,1] == [12,25,1] );

/// Okay with that settled...

cube([1,1,1], center=true);
