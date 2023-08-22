// OuterAngleJig-v2.2

atom_pitch = 12.7;
arm_length_atoms = 6;
// 4 is great for #6 screws; #8s are ~4.0mm and might require slightly larger holes
hole_diameter = 4; // 0.1

$fn = $preview ? 16 : 64;

module the_device() difference() {
	linear_extrude(atom_pitch, center=true) {
		a = arm_length_atoms * atom_pitch;
		b = -atom_pitch;
		difference() {
			polygon([
				[0,0],
				[a,0],
				[a,b],
				[b,b],
				[b,a],
				[0,a],
			]);
			
			for( i=[0.5 : 1 : arm_length_atoms] ) {
				translate([ -atom_pitch/2, i*atom_pitch  ]) circle(d=hole_diameter);
				translate([i*atom_pitch  ,  -atom_pitch/2]) circle(d=hole_diameter);
				translate([ -atom_pitch/2,  -atom_pitch/2]) circle(d=hole_diameter);
			}
		}
	}
	
	for( i=[0.5 : 1 : arm_length_atoms] ) {
		translate([-atom_pitch/2, atom_pitch*i, 0]) rotate([0,90,0]) cylinder(d=hole_diameter, h=atom_pitch*2, center=true);
	}
	for( i=[1 : 2 : arm_length_atoms] ) {
		translate([atom_pitch*i, -atom_pitch/2, 0]) rotate([90,0,0]) linear_extrude(atom_pitch*2, center=true) hull() {
			for( j=[-0.5, 0.5] ) if( i+j < arm_length_atoms ) {
				translate([j*atom_pitch, 0, 0]) circle(d=hole_diameter);
			}
		}
	}
}

translate([0,0,atom_pitch]) rotate([90,0,0]) the_device();
