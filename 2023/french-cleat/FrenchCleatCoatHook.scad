// French Cleat Coat Hook, v1.0

inch = 25.4;

3inch_coat_hook_hole_positions = [
	// In 8ths of an inch
	[ 0,-12],
	[-6, -7.5],
	[ 0, -6],
	[ 0,  0],
	[ 0, +6],
	[+6, +7.5],
	[ 0,+12],
];

module 3inch_coat_hook() {
	scale(inch / 8) {
		difference() {
			linear_extrude(6) {
				polygon([
					[+3,-14],[+3,+6],[+8,+1],[+8.5,+1],[+9,+1.5],[+9,+9],[+3,+15],[-2,+15],
					[-3,+14],[-3,-6],[-8,-1],[-8.5,-1],[-9,-1.5],[-9,-9],[-3,-15],[+2,-15]
				]);
			}
			for( hp = 3inch_coat_hook_hole_positions ) {
				translate(hp) cylinder(d=1.5, h=18, $fn=24, center=true);
				translate(hp) translate([0,0,4]) cylinder(d=3, h=18, $fn=24);
			}
		}
	}
}

translate([0 * inch,0,0]) scale([ 1,1,1]) 3inch_coat_hook();

translate([3 * inch,0,0]) scale([-1,1,1]) 3inch_coat_hook();
