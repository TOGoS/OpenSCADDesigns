module togridpile__rounded_square(size, corner_radius, offset=0) {
	hull() for( ym=[-1,1] ) for( xm=[-1,1] ) {
		translate([
			xm*(size[0]/2-corner_radius),
			ym*(size[1]/2-corner_radius),
		]) circle(r=corner_radius+offset);
	}	
}

module togridpile__rounded_cube(size, corner_radius, offset=0) {
	// TODO: Special case for corner_radius=0
	hull() for( zm=[-1,1] ) for( ym=[-1,1] ) for( xm=[-1,1] ) {
		translate([
			xm*(size[0]/2-corner_radius),
			ym*(size[1]/2-corner_radius),
			zm*(size[2]/2-corner_radius),
		]) sphere(r=corner_radius+offset);
	}
}

module togridpile__xy_rounded_cube(size, corner_radius) {
	linear_extrude(size[2], center=true) togridpile__rounded_square(size, corner_radius);
}
module togridpile__xz_rounded_cube(size, corner_radius) {
	rotate([90,0,0]) togridpile__xy_rounded_cube([size[0], size[2], size[1]], corner_radius);
}
module togridpile__yz_rounded_cube(size, corner_radius) {
	rotate([0,90,0]) togridpile__xy_rounded_cube([size[2], size[1], size[0]], corner_radius);
}

function togridpile__zip(a0, a1, func) = [
	for( i=[0:1:len(a0)-1] ) func(a0[i], a1[i])
];

module togridpile__beveled_cube(size, corner_radius, offset=0) {
	outer_scale = [for(d=size) (d+offset*2)/d];
	inner_scale = [for(d=size) (d-corner_radius*2)/d]; // Purposely not taking offset into account for inner square
	outer_size = togridpile__zip(size, outer_scale, function(si,sc) si*sc);
	inner_size = togridpile__zip(size, inner_scale, function(si,sc) si*sc);
	hull() {
		cube([inner_size[0], inner_size[1], outer_size[2]], center=true);
		cube([inner_size[0], outer_size[1], inner_size[2]], center=true);
		cube([outer_size[0], inner_size[1], inner_size[2]], center=true);
	}
}

module togridpile__facerounded_beveled_cube(size, corner_radius, face_corner_radius, offset=0) {
	outer_scale = [for(d=size) (d+offset*2)/d];
	inner_scale = [for(d=size) (d-corner_radius*2)/d]; // Purposely not taking offset into account for inner square
	outer_size = togridpile__zip(size, outer_scale, function(si,sc) si*sc);
	inner_size = togridpile__zip(size, inner_scale, function(si,sc) si*sc);
	hull() {
		togridpile__xy_rounded_cube([inner_size[0], inner_size[1], outer_size[2]], face_corner_radius+offset);
		togridpile__xz_rounded_cube([inner_size[0], outer_size[1], inner_size[2]], face_corner_radius+offset);
		togridpile__yz_rounded_cube([outer_size[0], inner_size[1], inner_size[2]], face_corner_radius+offset);
	}
}

module togridpile_hull_of_style(style, size, beveled_corner_radius=3.175, rounded_corner_radius=4.7625, corner_radius_offset=0, offset=0) {
	if( style == "beveled" ) {
		togridpile__beveled_cube(size, beveled_corner_radius+corner_radius_offset, offset);
	} else if( style == "rounded" ) {
		togridpile__rounded_cube(size, rounded_corner_radius+corner_radius_offset, offset);
	} else if( style == "hybrid1" ) {
		intersection() {
			linear_extrude(size[2]*2, center=true) togridpile__rounded_square(size, rounded_corner_radius, offset);
			// beveled_cube(size, beveled_corner_radius+corner_radius_offset, offset);
			togridpile__facerounded_beveled_cube(size, beveled_corner_radius+corner_radius_offset, rounded_corner_radius-beveled_corner_radius, offset);
		}
	} else if( style == "hybrid1-inner" ) {
		union() {
			togridpile_hull_of_style("hybrid1", size, corner_radius_offset, offset);
			togridpile_hull_of_style("rounded", size, corner_radius_offset, offset);
		}
	} else if( style == "maximal" ) {
		union() {
			togridpile_hull_of_style("beveled", size, corner_radius_offset, offset);
			togridpile_hull_of_style("rounded", size, corner_radius_offset, offset);
		}
	} else if( style == "minimal" ) {
		intersection() {
			togridpile_hull_of_style("rounded", size, corner_radius_offset, offset);
			togridpile_hull_of_style("hybrid1", size, corner_radius_offset, offset);
		}
	} else {
		assert(false, str("Unrecognized style: '"+style+"'"));
	}
}
