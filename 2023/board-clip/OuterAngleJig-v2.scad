// OuterAngleJig-v2.4
//
// Versions:
// v2.4:
// - Added thickness_atoms, so you can make fat ones!

// Recommended: 12.7 or 19.05
atom_pitch = 12.7; // 0.01
// Recommended: An odd number
arm_length_atoms = 7;
// 4 is great for #6 screws; #8s are ~4.0mm and might require slightly larger holes
hole_diameter = 4; // 0.1

thickness_atoms = 1;

// Divot around glue joint to avoid gluing the jig to the boards being held; use 0 for no divot.
divot_diameter = 2;
divot_positions = [[9.525,19.05]];

$fn = $preview ? 16 : 64;

module the_device() difference() {
	linear_extrude(atom_pitch * thickness_atoms, center=true) {
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

			if( divot_diameter > 0 ) {
				for( rang=divot_positions ) {
					range = is_list(rang) ? rang : [rang];
					hull() for(x=range) translate([x,0,0]) circle(d=divot_diameter);
				}
			}
		}
	}

	for( ym=[-thickness_atoms/2 + 0.5 : 1 : thickness_atoms/2] ) translate([0, 0, ym*atom_pitch]) {
		for( i=[0.5 : 1 : arm_length_atoms] ) {
			translate([-atom_pitch/2, atom_pitch*i, 0]) rotate([0,90,0]) cylinder(d=hole_diameter, h=atom_pitch*2, center=true);
		}
		for( i=[0 : 2 : arm_length_atoms] ) {
			translate([atom_pitch*i, -atom_pitch/2, 0]) rotate([90,0,0]) linear_extrude(atom_pitch*2, center=true) hull() {
				for( j=[-0.5, 0.5] ) if( i+j > 0 && i+j < arm_length_atoms ) {
					translate([j*atom_pitch, 0, 0]) circle(d=hole_diameter);
				}
			}
		}
	}
}

translate([0,0,atom_pitch]) rotate([90,0,0]) the_device();
