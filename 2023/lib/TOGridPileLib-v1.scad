// TOGridPileLib-v1.6.2
//
// Changes:
// v1.3.0:
// - Add 'hybrid3' shape
// v1.4.0:
// - Add 'hybrid4' shape
// v1.4.1:
// - Rename 'hybrid4-female' to 'hybrid3+4'
// v1.4.2:
// - Fix hybrid5 to fit into hybrid3 footprint
// v1.4.3:
// - Remove '-rounded' postfix; just intersect the block with something round if you want
// v1.4.6:
// - Add 'offset' parameter to togridpile__xy_rounded_cube, et al
// v1.5.0:
// - Add 'togridpile_chunky_multiblock'
// - Add 'hybrid5-rounded' style, as that actually is a little different than just rounding the result
// v1.5.1:
// - Add 'extend_pylons' option so that hybrid5 multiblocks can be made without gaps
// v1.6.0:
// - Add 'hybrid6' shape
// v1.6.1:
// - Fix rounded beveled squares; this will increase their size slightly compared to the old, buggy calculation!
// - Old block shapes pass in _adj=0.707 to retain the old behavior
// v1.6.2:
// - Fix misspelled "[o]ffset" that prevented some hybrid6 shapes from working
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

module togridpile__xy_rounded_cube(size, corner_radius, offset=0) {
	linear_extrude(size[2]+offset*2, center=true) togridpile__rounded_square(size, corner_radius, offset=offset);
}
module togridpile__xz_rounded_cube(size, corner_radius, offset=0) {
	rotate([90,0,0]) togridpile__xy_rounded_cube([size[0], size[2], size[1]], corner_radius, offset=offset);
}
module togridpile__yz_rounded_cube(size, corner_radius, offset=0) {
	rotate([0,90,0]) togridpile__xy_rounded_cube([size[2], size[1], size[0]], corner_radius, offset=offset);
}

/**
 * Previously, _adj, the factor of rounding_radius by which to scoot the circles inward,
 * was 0.707 (i.e. sqrt(2)/2), but this was *wrong*!
 * That value should be 0.414 (i.e. sqrt(2)-1).
 *
 * (adjustment is sqrt(2)*r - r = r * (aqrt(2)-1) = r * 1.414-1 = r * 0.414
 */
module togridpile__rounded_beveled_square(size, bevel_size, rounding_radius, offset=0, _adj=0.414) {
	// Could special-case these, but in the meantime:
	assert(bevel_size > 0);
	// Make sure things don't go negative:
	assert(size[0]/2 - bevel_size - rounding_radius*_adj >= 0);
	assert(size[1]/2 - bevel_size - rounding_radius*_adj >= 0);

	hull() for( ym=[-1,1] ) for( xm=[-1,1] ) {
		translate([
			xm*(size[0]/2 - rounding_radius),
			ym*(size[1]/2 - bevel_size - rounding_radius*_adj),
		]) circle(r=rounding_radius+offset);
		translate([
			xm*(size[0]/2 - bevel_size - rounding_radius*_adj),
			ym*(size[1]/2 - rounding_radius),
		]) circle(r=rounding_radius+offset);
	}
}

/** Legacy (wrong) version */
module togridpile__xy_rounded_beveled_square(size, bevel_size, rounding_radius, offset=0, _adj=0.707) {
	togridpile__rounded_beveled_square(size, bevel_size, rounding_radius, offset=offset, _adj=_adj);
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

module togridpile_h5x_2d(togridpile_pitch=38.1, inset=1.5875, corner_radius=1.5875, _adj=0.707, offset=0) {
	fwoobwidth = togridpile_pitch/3-inset*2;
	for( scalex=[-1,1] ) scale([scalex,1]) hull() for( i=[-1,1] ) {
		translate([i*togridpile_pitch/3,i*togridpile_pitch/3]) // togridpile__rounded_square([fwoobwidth, fwoobwidth], corner_radius, _adj=_adj, offset=offset);
			togridpile__xy_rounded_beveled_square([fwoobwidth, fwoobwidth], inset*2*0.707, corner_radius, _adj=_adj, offset);
	}
}

module togridpile_h6x_2d(togridpile_pitch=38.1, inset=1.5875, corner_radius=1.5875, _adj=0.707, offset=0) {
	fwoobwidth = togridpile_pitch/3-inset*2;
	for( xm=[-1,0,1] ) for( ym=[-1,0,1] ) {
		translate([xm*togridpile_pitch/3, ym*togridpile_pitch/3])
			togridpile__xy_rounded_beveled_square([fwoobwidth, fwoobwidth], inset*2*0.707, corner_radius, _adj=_adj, offset=offset);
	}
}

module togridpile_h5x_xy(togridpile_pitch=38.1, offset=0, length_offset="auto") {
	length_offset = length_offset == "auto" ? offset : length_offset;
	linear_extrude(togridpile_pitch+length_offset*2, center=true) togridpile_h5x_2d(togridpile_pitch, offset=offset);
}
module togridpile_h6x_xy(togridpile_pitch=38.1, offset=0, length_offset="auto") {
	length_offset = length_offset == "auto" ? offset : length_offset;
	linear_extrude(togridpile_pitch+length_offset*2, center=true) togridpile_h6x_2d(togridpile_pitch, offset=offset);
}

module each_axis() {
	for( rot=[[0,0,0],[0,90,0],[90,0,0]] ) rotate(rot) children();
}

module togridpile_h5x(togridpile_pitch=38.1, offset=0, length_offset="auto") {
	each_axis() togridpile_h5x_xy(togridpile_pitch, offset=offset, length_offset=length_offset);
}

module togridpile_h6x(togridpile_pitch=38.1, offset=0, length_offset="auto") {
	each_axis() togridpile_h6x_xy(togridpile_pitch, offset=offset, length_offset=length_offset);
}

module togridpile_hull_of_style(style, size, beveled_corner_radius=3.175, rounded_corner_radius=4.7625, corner_radius_offset=0, offset=0, extend_pylons=false) {
	h5x_length_offset = extend_pylons ? 0 : offset;

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
			// I think 'hybrid1' here is redundant; unioning 'hybrid1' with 'rounded'
			// should be the same as unioning 'hybrid2' with 'rounded'.
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
	} else if( style == "hybrid4" ) {
		togridpile__facerounded_beveled_cube(size, beveled_corner_radius+corner_radius_offset, rounded_corner_radius+corner_radius_offset-beveled_corner_radius, offset);
		togridpile__xy_rounded_cube([size[0]-beveled_corner_radius+offset, size[1]/3+offset, size[2]+offset*2], beveled_corner_radius/2+offset);
		togridpile__xy_rounded_cube([size[0]/3+offset, size[1]-beveled_corner_radius+offset, size[2]+offset*2], beveled_corner_radius/2+offset);
		togridpile__yz_rounded_cube([size[0]+offset*2, size[1]-beveled_corner_radius+offset, size[2]/3+offset], beveled_corner_radius/2+offset);
		togridpile__yz_rounded_cube([size[0]+offset*2, size[1]/3+offset, size[2]-beveled_corner_radius+offset], beveled_corner_radius/2+offset);		
		togridpile__xz_rounded_cube([size[0]-beveled_corner_radius+offset, size[1]+offset*2, size[2]/3+offset], beveled_corner_radius/2+offset);
		togridpile__xz_rounded_cube([size[0]/3+offset, size[1]+offset*2, size[2]-beveled_corner_radius+offset], beveled_corner_radius/2+offset);
	} else if( style == "hybrid3+4" ) {
		// Hybrid4 but with the full xy column from hybrid3
		togridpile__facerounded_beveled_cube(size, beveled_corner_radius+corner_radius_offset, rounded_corner_radius+corner_radius_offset-beveled_corner_radius, offset);
		linear_extrude(size[2]+offset*2, center=true)
			togridpile__xy_rounded_beveled_square([size[0]-beveled_corner_radius, size[1]-beveled_corner_radius], beveled_corner_radius*0.707+corner_radius_offset, beveled_corner_radius/2, offset);
		togridpile__yz_rounded_cube([size[0]+offset*2, size[1]-beveled_corner_radius+offset, size[2]/3+offset], beveled_corner_radius/2+offset);
		togridpile__yz_rounded_cube([size[0]+offset*2, size[1]/3+offset, size[2]-beveled_corner_radius+offset], beveled_corner_radius/2+offset);		
		togridpile__xz_rounded_cube([size[0]-beveled_corner_radius+offset, size[1]+offset*2, size[2]/3+offset], beveled_corner_radius/2+offset);
		togridpile__xz_rounded_cube([size[0]/3+offset, size[1]+offset*2, size[2]-beveled_corner_radius+offset], beveled_corner_radius/2+offset);
	} else if( style == "hybrid4-xy" ) {
		togridpile__facerounded_beveled_cube(size, beveled_corner_radius+corner_radius_offset, rounded_corner_radius+corner_radius_offset-beveled_corner_radius, offset);
		togridpile__xy_rounded_cube([size[0]-beveled_corner_radius+offset, size[1]/3+offset, size[2]+offset*2], beveled_corner_radius/2+offset);
		togridpile__xy_rounded_cube([size[0]/3+offset, size[1]-beveled_corner_radius+offset, size[2]+offset*2], beveled_corner_radius/2+offset);
	} else if( style == "hybrid5-rounded" ) {
		intersection() {
			togridpile__facerounded_beveled_cube(size, beveled_corner_radius+corner_radius_offset, rounded_corner_radius+corner_radius_offset-beveled_corner_radius, offset);
			linear_extrude(size[2]*2, center=true) togridpile__rounded_square(size, rounded_corner_radius, offset);			
		}
		togridpile_h5x(offset=offset, length_offset=h5x_length_offset);
	} else if( style == "hybrid5" ) {
		togridpile__facerounded_beveled_cube(size, beveled_corner_radius+corner_radius_offset, rounded_corner_radius+corner_radius_offset-beveled_corner_radius, offset);
		togridpile_h5x(offset=offset, length_offset=h5x_length_offset);
	} else if( style == "hybrid6" ) {
		togridpile__facerounded_beveled_cube(size, beveled_corner_radius+corner_radius_offset, rounded_corner_radius+corner_radius_offset-beveled_corner_radius, offset);
		togridpile_h6x(offset=offset, length_offset=h5x_length_offset);
	} else if( style == "hybrid3+5" ) {
		togridpile__facerounded_beveled_cube(size, beveled_corner_radius+corner_radius_offset, rounded_corner_radius+corner_radius_offset-beveled_corner_radius, offset);
		linear_extrude(size[2]+offset*2, center=true) {
			togridpile__xy_rounded_beveled_square([size[0]-beveled_corner_radius, size[1]-beveled_corner_radius], beveled_corner_radius*0.707+corner_radius_offset, beveled_corner_radius/2, offset);
		}
		togridpile_h5x(offset=offset, length_offset=h5x_length_offset);
	} else if( style == "hybrid3+6" ) {
		togridpile__facerounded_beveled_cube(size, beveled_corner_radius+corner_radius_offset, rounded_corner_radius+corner_radius_offset-beveled_corner_radius, offset);
		linear_extrude(size[2]+offset*2, center=true) {
			togridpile__xy_rounded_beveled_square([size[0]-beveled_corner_radius, size[1]-beveled_corner_radius], beveled_corner_radius*0.707+corner_radius_offset, beveled_corner_radius/2, offset);
		}
		togridpile_h6x(offset=offset, length_offset=h5x_length_offset);
	} else if( style == "hybrid5-xy" ) {
		togridpile__facerounded_beveled_cube(size, beveled_corner_radius+corner_radius_offset, rounded_corner_radius+corner_radius_offset-beveled_corner_radius, offset);
		togridpile_h5x_xy(offset=offset, length_offset=h5x_length_offset);
	} else if( style == "hybrid6-xy" ) {
		togridpile__facerounded_beveled_cube(size, beveled_corner_radius+corner_radius_offset, rounded_corner_radius+corner_radius_offset-beveled_corner_radius, offset);
		togridpile_h6x_xy(offset=offset, length_offset=h5x_length_offset);
	} else {
		assert(false, str("Unrecognized style: '", style, "'"));
	}
}

module togridpile_chunky_multiblock(size_blocks, style="hybrid5", pitch=38.1, beveled_corner_radius=3.175, rounded_corner_radius=4.7625, offset=0, round_vertical_edges=true) {
	size = [size_blocks[0]*pitch, size_blocks[1]*pitch, size_blocks[2]*pitch];
	block_size = [pitch,pitch,pitch];
	core_size = [size[0]-beveled_corner_radius*2, size[1]-beveled_corner_radius*2, size[2]-beveled_corner_radius*2];
	togridpile__facerounded_beveled_cube(core_size, beveled_corner_radius, rounded_corner_radius, offset);

	intersection() {
		for( xb=[-size_blocks[0]/2+0.5 : 1 : size_blocks[0]/2-0.5] )
		for( yb=[-size_blocks[1]/2+0.5 : 1 : size_blocks[1]/2-0.5] )
		for( zb=[-size_blocks[2]/2+0.5 : 1 : size_blocks[2]/2-0.5] )
		{
			translate([xb*pitch, yb*pitch, zb*pitch]) togridpile_hull_of_style(
				style, size=block_size,
				beveled_corner_radius=beveled_corner_radius, rounded_corner_radius=rounded_corner_radius,
				offset=offset, extend_pylons=true
			);
		}

		cube([size[0]+offset*2, size[1]+offset*2, size[2]+offset*2], center=true);
	}
}
