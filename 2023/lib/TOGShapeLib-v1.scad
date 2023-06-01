module tog_shapelib_rounded_beveled_square(size, bevel_size, rounding_radius, offset=0) {
	// Could special-case these, but in the meantime:
	assert(bevel_size > 0);
	// Make sure things don't go negative:
	assert(size[0]/2 - bevel_size - rounding_radius*0.414 >= 0);
	assert(size[1]/2 - bevel_size - rounding_radius*0.414 >= 0);

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
