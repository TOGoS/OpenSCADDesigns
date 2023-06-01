margin = 0.1;
atom_pitch = 12.7;

$fn = 48;

module __end_params() { }

use <../lib/TOGridPileLib-v2.scad>

inch  = 25.4;

linear_extrude(3) {
	difference() {
		union() {
			for( xm=[-0.5, 0.5] ) for( ym=[-0.5, 0.5] ) {
				translate([xm*atom_pitch, ym*atom_pitch]) togridpile2_atom_column_footprint("v8.4", atom_pitch=atom_pitch, offset=-margin);
			}
			for( rot=[0,90,180,270] ) {
				rotate([0,0,rot]) translate([atom_pitch/2,0,0]) square([1/8*inch - margin*2, atom_pitch], center=true);
			}
		}
		
		for( xm=[-0.5, 0.5] ) for( ym=[-0.5, 0.5] ) {
			translate([xm*atom_pitch, ym*atom_pitch]) circle(d=3.5);
		}
	}
}
