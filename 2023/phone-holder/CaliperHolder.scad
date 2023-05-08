// Rex Beti Caliper Holder, v1.1
//
// Versions:
// - v1.1: Increase width of bat slot by 1/32 'cuz it was too tight
//   in the print of v1.0, p1002a

$fn = 20;

module __end_parameters() { }

include <../lib/TOGHoleLib-v1.scad>

inch = 25.4;

module ch_panel_outline() {
	hull() {
		translate([-11/8*inch, -23/8*inch]) circle(d=1/4*inch);
		translate([ 11/8*inch, -23/8*inch]) circle(d=1/4*inch);
		translate([-11/8*inch,  11/8*inch]) circle(d=1/4*inch);
		translate([ 11/8*inch,  11/8*inch]) circle(d=1/4*inch);
	}
}

module inner_corner(r, x, y) {
	difference() {
		translate([x*r, y*r]) square([r*2,r*2], center=true);
		circle(r=r);
	}
}

module ch_midblock_outline() {
	hull() {
		translate([- 3/8*inch, 1/8*inch]) circle(d=1/4*inch);
		translate([-11/8*inch, 1/8*inch]) circle(d=1/4*inch);
		translate([-11/8*inch, 3/8*inch]) circle(d=1/4*inch);
	}
	translate([-7/8*inch, -1/8*inch]) inner_corner(1/8*inch, -1, 1);
	hull() {
		translate([- 9/8*inch, -23/8*inch]) circle(d=1/4*inch);
		translate([- 9/8*inch,   1/8*inch]) circle(d=1/4*inch);
		translate([-11/8*inch, -23/8*inch]) circle(d=1/4*inch);
		translate([-11/8*inch,   3/8*inch]) circle(d=1/4*inch);
	}
	translate([-7/8*inch, -19/8*inch]) inner_corner(1/8*inch, -1, -1);
	hull() {
		translate([- 1/8*inch, -23/8*inch]) circle(d=1/4*inch);
		translate([- 1/8*inch, -21/8*inch]) circle(d=1/4*inch);
		translate([-11/8*inch, -23/8*inch]) circle(d=1/4*inch);
		translate([-11/8*inch, -21/8*inch]) circle(d=1/4*inch);		
	}

	hull() {
		translate([  9/8*inch, 3/8*inch]) circle(d=1/4*inch);
		translate([  9/8*inch, 5/8*inch]) circle(d=1/4*inch);
		translate([ 11/8*inch, 3/8*inch]) circle(d=1/4*inch);
		translate([ 11/8*inch, 6/8*inch]) circle(d=1/4*inch);
	}
	hull() {
		translate([  9/8*inch, - 7/8*inch]) circle(d=1/4*inch);
		translate([  9/8*inch, -23/8*inch]) circle(d=1/4*inch);
		translate([ 11/8*inch, -23/8*inch]) circle(d=1/4*inch);
		translate([ 11/8*inch, - 7/8*inch]) circle(d=1/4*inch);
	}
	translate([7/8*inch, -15/8*inch]) inner_corner(1/8*inch, 1, -1);
	hull() {
		translate([  6.25/8*inch, -23/8*inch]) circle(d=1/4*inch);
		translate([  6.25/8*inch, -17/8*inch]) circle(d=1/4*inch);
		translate([ 11.00/8*inch, -23/8*inch]) circle(d=1/4*inch);
		translate([ 11.00/8*inch, -17/8*inch]) circle(d=1/4*inch);		
	}

}

caliper_nose_poinsts = [
	[-13/8*inch,   7  /8*inch],
	[-11/8*inch,   9.2/8*inch],
	[- 2/8*inch,  11  /8*inch],
	[  7/8*inch,  11  /8*inch],
	[ 11/8*inch,  10  /8*inch],
	[ 12/8*inch,   9  /8*inch],
	[ 11/8*inch,   8  /8*inch],
	[  7/8*inch,   7  /8*inch],
	[  7/8*inch,   2  /8*inch],
	[- 2/8*inch,   2.5/8*inch],
	[-11/8*inch,   4.8/8*inch],
];
caliper_bar_poinsts = [
	[  0       ,   0       ],
	[  5/8*inch,   0       ],       
	[  5/8*inch,  -8*inch  ],       
	[  0       ,  -8*inch  ],
];
caliper_body_points = [
	[- 1.0/8*inch,   5.5/8*inch],
	[  6.5/8*inch,   5.5/8*inch],
	[  6.5/8*inch, -13.0/8*inch],
	[- 3.0/8*inch, -11.0/8*inch],
	[- 4.0/8*inch, - 9.0/8*inch],
	[- 1.0/8*inch, - 1.0/8*inch],
];

module caliper_model() {
	color("#909090") linear_extrude(  1/4*inch) translate([0,-1/16*inch]) polygon(caliper_nose_poinsts);
	color("#909090") linear_extrude(  1/8*inch) polygon(caliper_bar_poinsts);
	color("#A0A0A0") linear_extrude(  1/2*inch) minkowski() {
		circle(r=1/8*inch);
		polygon( caliper_body_points );
	}
	color("#B0B0B0") translate([-2/8*inch, -15/8*inch]) cylinder(h=1/4*inch, d=3/8*inch);
}

back_panel_thickness = 3/16*inch;
midblock_thickness   = 5/16*inch;
epsilon = 0;

small_hole_positions = [
	[-1.25*inch, 0.25*inch],
	[ 1.25*inch, 0.50*inch],
	for( ym=[-8.5 : 1 : -0.5] ) [-1.25*inch, ym*0.5*inch],
	for( ym=[-8.5 : 1 : -2.5] ) [ 1.25*inch, ym*0.5*inch],
	for( xm=[-1.5 : 1 :  1.0] ) [ xm*0.5*inch, -2.75*inch],
];

module ch_assembly() {
	difference() {
		union() {
			translate([0,0,              0     ]) color("#283018") linear_extrude(back_panel_thickness, center=false) ch_panel_outline();
			translate([0,0,back_panel_thickness-epsilon]) color("#405030") linear_extrude(midblock_thickness+epsilon, center=false) ch_midblock_outline();
		}
		for(y=[3/4*inch, -3/4*inch, -(2+1/4)*inch] ) for(x=[-3/4*inch, 0, 3/4*inch]) {
			if( x <= 0 || y >= -3/4*inch ) // Skip the bottom right hole
			translate([x, y, back_panel_thickness]) tog_holelib_hole("THL-1002", overhead_bore_height=20);
		}
		for(p=small_hole_positions) {
		//for(ym=[-8.5 : 1 : 2.5] ) for( xm=[-2.5 : 1 : 2.5] ) {
			translate([p[0], p[1], -1]) cylinder(h=midblock_thickness+back_panel_thickness+2, d=5);
		}
	}
}
ch_assembly();
if( $preview ) # translate([0,0,back_panel_thickness]) caliper_model();
