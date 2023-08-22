// OuterAngleJig-v1.0

thickness = 3.175;
atom_pitch = 19.05; // 0.01
arm_length_atoms = 9;
arm_width_atoms = 3;
hole_diameter = 4;
large_hole_diameter = 7.75;
chunk_size_atoms = 3;
angle = 90;

$fn = $preview ? 16 : 64;

use <../lib/TOGShapeLib-v1.scad>

module oaj_arm_hull(size) difference() {
	actual_size = [size[0]+size[1], size[1]];
	translate([-size[1], 0]) scale([1,-1]) {
		translate([actual_size[0]/2, actual_size[1]/2]) tog_shapelib_rounded_beveled_square(actual_size, 3.175, 3.175);
		//square(actual_size, center=false);
	}
}

function oaj_arm_hole_positions(size, hole_spacing) = [
	for( y=[hole_spacing/2 : hole_spacing : size[1]-hole_spacing/4] )
	for( x=[
		each for(x=[hole_spacing/2 : hole_spacing : size[1]-hole_spacing*3/8]) -x,
		each for(x=[hole_spacing/2 : hole_spacing : size[0]-hole_spacing*3/8]) x
	] )
	[x, -y]
];

module oaj_one_arm_hull() {
	oaj_arm_hull([arm_length_atoms*atom_pitch, arm_width_atoms*atom_pitch]);
}

function oaj_one_arm_hole_positions(pitch=atom_pitch) =
	oaj_arm_hole_positions([arm_length_atoms*atom_pitch, arm_width_atoms*atom_pitch], pitch);

arm_positions = [
	[[0,0], [0,0,    0], [1, 1]],
	[[0,0], [0,0,angle], [1,-1]],
];

module do_pos(pos) {
	// TODO: Just use a transformation matrix lmao
	translate(pos[0]) rotate(pos[1]) scale(pos[2]) children();
}

linear_extrude(thickness) difference() {
	for( pos=arm_positions ) {
		do_pos(pos) oaj_one_arm_hull();
	}
	
	for( pos=arm_positions ) {
		do_pos(pos) {
			for(hp=oaj_one_arm_hole_positions(                 atom_pitch)) translate(hp) circle(d=hole_diameter);
			for(hp=oaj_one_arm_hole_positions(chunk_size_atoms*atom_pitch)) translate(hp) circle(d=large_hole_diameter);
		}
	}
}
