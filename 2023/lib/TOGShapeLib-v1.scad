// Private functions/modules

function tog_shapelib__zip(a0, a1, func) = assert(len(a0) == len(a1)) [
	for( i=[0:1:len(a0)-1] ) func(a0[i], a1[i])
];


// Intentionally exported:

module tog_shapelib_rounded_square(size, corner_radius, offset=0) {
	assert(corner_radius + offset > 0);
	assert(corner_radius < size[0]/2);
	assert(corner_radius < size[1]/2);
	// TODO: Special cases when those assertions would fail
	hull() for( ym=[-1,1] ) for( xm=[-1,1] ) {
		translate([
			xm*(size[0]/2-corner_radius),
			ym*(size[1]/2-corner_radius),
		]) circle(r=corner_radius+offset);
	}	
}

module tog_shapelib_rounded_beveled_square(size, bevel_size, rounding_radius, offset=0) {
	// Could special-case these, but in the meantime:
	assert(bevel_size > 0);
	// Make sure things don't go negative:
	assert(size[0]/2 - bevel_size - rounding_radius*0.414 >= 0);
	assert(size[1]/2 - bevel_size - rounding_radius*0.414 >= 0);
	// Maybe not exactly necessary
	assert(rounding_radius <= bevel_size);
	
	hull() for( ym=[-1,1] ) for( xm=[-1,1] ) {
		translate([
			xm*(size[0]/2 - rounding_radius),
			ym*(size[1]/2 - bevel_size - rounding_radius*0.414),
		]) circle(r=rounding_radius+offset);
		translate([
			xm*(size[0]/2 - bevel_size - rounding_radius*0.414),
			ym*(size[1]/2 - rounding_radius),
		]) circle(r=rounding_radius+offset);
	}
}

module tog_shapelib_rounded_cube(size, corner_radius=0, offset=0) {
	if( corner_radius <= 0 ) {
		cube([size[0]-offset*2, size[1]-offset*2, size[2]-offset*2], center=true);
	} else {
		// TODO: Special case for corner_radius=0
		hull() for( zm=[-1,1] ) for( ym=[-1,1] ) for( xm=[-1,1] ) {
			translate([
				xm*(size[0]/2-corner_radius),
				ym*(size[1]/2-corner_radius),
				zm*(size[2]/2-corner_radius),
			]) sphere(r=corner_radius+offset);
		}
	}
}

module tog_shapelib_xy_rounded_cube(size, corner_radius, offset=0) {
	linear_extrude(size[2]+offset*2, center=true) tog_shapelib_rounded_square(size, corner_radius, offset=offset);
}
module tog_shapelib_xz_rounded_cube(size, corner_radius, offset=0) {
	rotate([90,0,0]) tog_shapelib_xy_rounded_cube([size[0], size[2], size[1]], corner_radius, offset=offset);
}
module tog_shapelib_yz_rounded_cube(size, corner_radius, offset=0) {
	rotate([0,90,0]) tog_shapelib_xy_rounded_cube([size[2], size[1], size[0]], corner_radius, offset=offset);
}

module tog_shapelib_facerounded_beveled_cube(size, corner_radius, face_corner_radius, offset=0) {
	outer_scale = [for(d=size) (d+offset*2)/d];
	inner_scale = [for(d=size) (d-corner_radius*2)/d]; // Purposely not taking offset into account for inner square
	outer_size = tog_shapelib__zip(size, outer_scale, function(si,sc) si*sc);
	inner_size = tog_shapelib__zip(size, inner_scale, function(si,sc) si*sc);
	hull() {
		tog_shapelib_xy_rounded_cube([inner_size[0], inner_size[1], outer_size[2]], face_corner_radius+offset);
		tog_shapelib_xz_rounded_cube([inner_size[0], outer_size[1], inner_size[2]], face_corner_radius+offset);
		tog_shapelib_yz_rounded_cube([outer_size[0], inner_size[1], inner_size[2]], face_corner_radius+offset);
	}
}
