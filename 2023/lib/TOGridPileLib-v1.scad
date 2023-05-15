// TOGridPileLib-v3.0
//
// Changes:
// v3.0:
// - Add 'hybrid3' shape
//
// Notes:
// - 0.707 = cos(pi/4), or 1/sqrt(2)

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

module togridpile__xy_rounded_beveled_square(size, bevel_size, rounding_radius, offset=0) {
	hull() for( ym=[-1,1] ) for( xm=[-1,1] ) {
		translate([
			xm*(size[0]/2-rounding_radius),
			ym*(size[1]/2-bevel_size-rounding_radius*0.707),
		]) circle(r=rounding_radius+offset);
		translate([
			xm*(size[0]/2-bevel_size-rounding_radius*0.707),
			ym*(size[1]/2-rounding_radius),
		]) circle(r=rounding_radius+offset);
	}
}

function togridpile__zip(a0, a1, func) = [
	for( i=[0:1:len(a0)-1] ) func(a0[i], a1[i])
];

// Figure out the scale to apply to an object of a given size such that the resulting size is for(v=vec) v+offset*2
function togridpile__offset_scale(vec, offset) = [
	for( v=vec ) (v+offset*2) / v
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
	} else if( style == "maximal" ) {
		union() {
			togridpile_hull_of_style("beveled", size, beveled_corner_radius, rounded_corner_radius, corner_radius_offset, offset);
			togridpile_hull_of_style("rounded", size, beveled_corner_radius, rounded_corner_radius, corner_radius_offset, offset);
		}
	} else if( style == "minimal" ) {
		intersection() {
			togridpile_hull_of_style("rounded", size, beveled_corner_radius, rounded_corner_radius, corner_radius_offset, offset);
			togridpile_hull_of_style("hybrid1", size, beveled_corner_radius, rounded_corner_radius, corner_radius_offset, offset);
		}
	} else if( style == "hybrid1" ) {
		intersection() {
			linear_extrude(size[2]*2, center=true) togridpile__rounded_square(size, rounded_corner_radius, offset);
			// beveled_cube(size, beveled_corner_radius+corner_radius_offset, offset);
			togridpile__facerounded_beveled_cube(size, beveled_corner_radius+corner_radius_offset, rounded_corner_radius-beveled_corner_radius, offset);
		}
	} else if( style == "hybrid1-inner" ) {
		union() {
			togridpile_hull_of_style("hybrid1", size, beveled_corner_radius, rounded_corner_radius, corner_radius_offset, offset);
			togridpile_hull_of_style("rounded", size, beveled_corner_radius, rounded_corner_radius, corner_radius_offset, offset);
		}
	} else if( style == "hybrid2" ) {
		// In this case I'm just scaling the whole thing instead of passing offset down;
		// I think generally, for convex shapes, scaling is what we want.
		rescale = togridpile__offset_scale(size, offset);
		scale(rescale) intersection() {
			togridpile__facerounded_beveled_cube(size, beveled_corner_radius+corner_radius_offset, rounded_corner_radius+corner_radius_offset-beveled_corner_radius);
			//togridpile__rounded_cube(size, rounded_corner_radius+corner_radius_offset);
		}
	} else if( style == "hybrid3-scaled" ) {
		// Alternate mode of applying the offset; shouldn't matter much, but does seem a little crappier idk
		rescale = togridpile__offset_scale(size, offset);
		scale(rescale) union() {
			togridpile__facerounded_beveled_cube(size, beveled_corner_radius+corner_radius_offset, rounded_corner_radius+corner_radius_offset-beveled_corner_radius);
			linear_extrude(size[2], center=true) {
				togridpile__xy_rounded_beveled_square([size[0]-beveled_corner_radius, size[1]-beveled_corner_radius], beveled_corner_radius*0.707+corner_radius_offset, beveled_corner_radius/2);
			}
		}
	} else if( style == "hybrid3" ) {
		togridpile__facerounded_beveled_cube(size, beveled_corner_radius+corner_radius_offset, rounded_corner_radius+corner_radius_offset-beveled_corner_radius, offset);
		linear_extrude(size[2]+offset*2, center=true) {
			togridpile__xy_rounded_beveled_square([size[0]-beveled_corner_radius, size[1]-beveled_corner_radius], beveled_corner_radius*0.707+corner_radius_offset, beveled_corner_radius/2, offset);
		}
	} else if( style == "hybrid3-rounded" ) {
		intersection() {
			linear_extrude(size[2]*2, center=true) togridpile__rounded_square(size, rounded_corner_radius, offset);
			togridpile_hull_of_style("hybrid3", size, beveled_corner_radius, rounded_corner_radius, corner_radius_offset, offset);
		}
	} else {
		assert(false, str("Unrecognized style: '", style, "'"));
	}
}
