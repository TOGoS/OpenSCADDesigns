// TOGridPileBlock-v1.1
//
// v1.1:
// - Add bevel option, though I want to change it a little bit...
// v1.2:
// - Improve calculation of lip substraction for nicer shape

// 38.1mm = 1+1/2"
togridpile_pitch = 38.1;
// 4.7625mm = 3/16", 3.175 = 1/8"
togridpile_rounded_corner_radius = 4.7625;
togridpile_beveled_corner_radius = 3.175;
togridpile_style = "rounded"; // [ "rounded", "beveled" ]
// How much space to put between adjacent blocks by shrinking them slightly
margin = 0.25;
lip_height = 2.540;
height = 12.7;
wall_thickness = 2;
floor_thickness = 3.175;

$fn = 12;

module __end_params() { }

include <../lib/TOGHoleLib-v1.scad>

inch = 25.4;

module rounded_cube(size, corner_radius, offset=0) {
	// TODO: Special case for corner_radius=0
	hull() for( zm=[-1,1] ) for( ym=[-1,1] ) for( xm=[-1,1] ) {
		translate([
			xm*(size[0]/2-corner_radius),
			ym*(size[1]/2-corner_radius),
			zm*(size[2]/2-corner_radius),
		]) sphere(r=corner_radius+offset);
	}
}

function zip(a0, a1, func) = [
	for( i=[0:1:len(a0)-1] ) func(a0[i], a1[i])
];

module beveled_cube(size, corner_radius, offset=0) {
	outer_scale = [for(d=size) (d+offset*2)/d];
	inner_scale = [for(d=size) (d-corner_radius*2)/d]; // Purposely not taking offset into account for inner square
	outer_size = zip(size, outer_scale, function(si,sc) si*sc);
	inner_size = zip(size, inner_scale, function(si,sc) si*sc);
	hull() {
		cube([inner_size[0], inner_size[1], outer_size[2]], center=true);
		cube([inner_size[0], outer_size[1], inner_size[2]], center=true);
		cube([outer_size[0], inner_size[1], inner_size[2]], center=true);
	}
}

module togpile_hull(size, corner_radius_offset=0, offset=0) {
	if( togridpile_style == "beveled" ) {
		beveled_cube(size, togridpile_beveled_corner_radius+corner_radius_offset, offset);
	} else if( togridpile_style == "rounded" ) {
		rounded_cube(size, togridpile_rounded_corner_radius+corner_radius_offset, offset);
	} else {
		assert(false, str("Unrecognized style: '"+togridpile_style+"'"));
	}
}

module togridpile_block_with_lip(height, small_holes=false, large_holes=false) {
	difference() {
		intersection() {
			translate([0,0,height]) togpile_hull([togridpile_pitch, togridpile_pitch, height*2], 0, -margin/2);
			cube([togridpile_pitch, togridpile_pitch, (height+lip_height)*2], center=true);
		}
		// Lip
		translate([0,0,height+togridpile_pitch/2]) togpile_hull([togridpile_pitch, togridpile_pitch, togridpile_pitch], 0, +margin/2);
		// Interior cavity
		translate([0,0,height+floor_thickness]) togpile_hull([togridpile_pitch-wall_thickness*2, togridpile_pitch-wall_thickness*2, height*2], -wall_thickness, -margin/2);
		//translate([0,0,height+floor_thickness]) rounded_cube([togridpile_pitch-wall_thickness*2, togridpile_pitch-wall_thickness*2, height*2], -wall_thickness, -margin/2)
		if(small_holes) for( ym=[-1,0,1] ) for( xm=[-1,0,1] ) {
			translate([ym*12.7, xm*12.7, floor_thickness]) tog_holelib_hole("THL-1001", overhead_bore_height=height*2);
		}
		if(large_holes) {
			translate([0,0,floor_thickness]) tog_holelib_hole("THL-1002", overhead_bore_height=height*2);
		}
	}
}

translate([0*inch, 0, 0]) togridpile_block_with_lip(height, true, true);
translate([2*inch, 0, 0]) togridpile_block_with_lip(height, false, true);
