// TwoByTwoEndJig-v1.0
//
// Jig to be bolted or clamped to the end of a two-by-two
// to which a drill guide can be affixed in order to drill
// straight holes into the end of the beam.

gridbeam_size  = 38.1; // 0.01
length_chunks  =  2;   // 
wall_thickness =  6.3; // 0.1
end_thickness  =  6.3; // 0.1
gridbeam_hole_diameter =  7.9; // 0.1
center_hole_diameter   = 13.0; // 0.1

preview_fn = 12;
render_fn  = 48;

$fn = $preview ? preview_fn : render_fn;

use <../lib/TOGHoleLib-v1.scad>

module gridbeam_hole() {
	cylinder(d=gridbeam_hole_diameter, h=(gridbeam_size+wall_thickness*4), center=true);
}

module the_block(bevel_size=0.1) {
	hgs = gridbeam_size/2;
	wt  = wall_thickness;
	bs  = bevel_size;
	linear_extrude(end_thickness + gridbeam_size * length_chunks) {
		polygon([
			[-hgs   +bs, -hgs      ],
			[ hgs+wt-bs, -hgs      ],
			[ hgs+wt   , -hgs   +bs],
			[ hgs+wt   ,  hgs+wt-bs],
			[ hgs+wt-bs,  hgs+wt   ],
			[-hgs   +bs,  hgs+wt   ],
			[-hgs      ,  hgs+wt-bs],
			[-hgs      , -hgs   +bs],
		]);
	}
}

difference() {
	the_block(bevel_size=3.175);

	translate([0,0,end_thickness]) rotate([0,0,180]) the_block();
	translate([0,0,end_thickness/2]) cylinder(d=center_hole_diameter, h=end_thickness*2, center=true);
	for( ym=[-1,0,1] ) for( xm=[-1,0,1] ) translate([12.7*xm, 12.7*ym, end_thickness]) {
				tog_holelib_hole("THL-1001", depth=end_thickness*2);
	}
	for( zm=[0.5 : 0.5 : length_chunks - 0.1] ) {
		translate([0,0,end_thickness+zm*gridbeam_size]) {
			rotate([90,0,0]) gridbeam_hole();
			rotate([0,90,0]) gridbeam_hole();
		}
	}
}
