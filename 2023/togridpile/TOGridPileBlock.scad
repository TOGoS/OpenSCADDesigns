// TOGridPileBlock-v2.4
//
// v1.1:
// - Add bevel option, though I want to change it a little bit...
// v1.2:
// - Improve calculation of lip substraction for nicer shape
// v1.3:
// - hybrid1 and hybrid1-inner styles
// v1.4:
// - Extracted most functions to library
// v2.0:
// - Add 'hybrid2' shape, which is beveled but with rounded faces,
//   and which, when used as lip shape, will accommodate hybrid1 or hybrid2 blocks
// - Allow cavity to be a different shape than the outer hull
// - Cut out corner to show cross-secion in preview
// - Add a hollow cube block, to show off rotatability
// v2.1:
// - Fix offset-to-scale calculation
// - Margin is now simply negative offset, i.e. half the space between perfectly-printed blocks
// - Organize customizable parameters into tabs
// v2.2:
// - Add sublip platform
// v2.3:
// - Multiblock!!  First attempt, with problems.
// v2.4:
// - Fixed corner sublip sections of multiblock
// - Added 0.5" hole pattern at bottom

/* [Content] */

size_blocks = [3,2];
height = 12.7;           // 0.001
wall_thickness = 2;      // 0.001
cavity_style = "rounded"; // [ "rounded", "beveled", "hybrid1", "hybrid2", "minimal" ]
floor_thickness = 3.175; // 0.001

/* [Grid / Stacking System] */

// 38.1mm = 1+1/2"
togridpile_pitch = 38.1;

beveled_corner_radius = 3.175;
rounded_corner_radius = 4.7625;

// 4.7625mm = 3/16", 3.175 = 1/8"
// "hybrid1" is hybrid2 but with XZ corners rounded off
togridpile_style = "hybrid1"; // [ "rounded", "beveled", "hybrid1", "hybrid2", "minimal" ]
// Style for purposes of lip cutout; "maximal" will accomodate all others; "hybrid1-inner" will accomodate rounded or hybrid1 bottoms
togridpile_lip_style = "hybrid2"; // [ "rounded", "beveled", "hybrid1-inner", "hybrid2", "maximal" ]

// Experimental platform under the lip
sublip_platform_enabled = true;

/* [Sizing Tweaks] */

// How much to shrink blocks and expand cutouts for them for better fits
margin = 0.1;            // 0.01
lip_height = 2.54;       // 0.01

/* [Detail] */

preview_fn = 12; // 4
render_fn  = 48; // 4

module __end_params() { }

$fn = $preview ? preview_fn : render_fn;

include <../lib/TOGHoleLib-v1.scad>
include <../lib/TOGridPileLib-v1.scad>

inch = 25.4;

module togridpile_hull(size, beveled_corner_radius=beveled_corner_radius, rounded_corner_radius=rounded_corner_radius, corner_radius_offset=0, offset=0) {
	togridpile_hull_of_style(
		togridpile_style, size,
		beveled_corner_radius=beveled_corner_radius,
		rounded_corner_radius=rounded_corner_radius,
		corner_radius_offset=corner_radius_offset, offset=offset
	);
}

module togridpile_hollow_cup_with_lip(size, lip_height, wall_thickness=2, floor_thickness=2, small_holes=false, large_holes=false) {
	difference() {
		intersection() {
			translate([0,0,size[2]]) togridpile_hull([size[0], size[1], size[2]*2], corner_radius_offset=0, offset=-margin);
			cube([size[0], size[1], (size[2]+lip_height)*2], center=true);
		}
		// Lip
		translate([0,0,size[2]+size[2]/2]) togridpile_hull_of_style(togridpile_lip_style, size, corner_radius_offset=0, offset=+margin);
		// Interior cavity
		intersection() {
			translate([0,0,size[2]+floor_thickness]) togridpile_hull_of_style(cavity_style, [size[0]-wall_thickness*2, size[1]-wall_thickness*2, size[2]*2], corner_radius_offset=-wall_thickness, offset=-margin);
			if( sublip_platform_enabled ) cylinder(d1=1.5*inch + size[2], d2=1.5*inch, h=size[2]+1);
		}
		if(small_holes) for( ym=[-1,0,1] ) for( xm=[-1,0,1] ) {
			translate([ym*12.7, xm*12.7, floor_thickness]) tog_holelib_hole("THL-1001", overhead_bore_height=floor_thickness);
		}
		if(large_holes) {
			translate([0,0,floor_thickness]) tog_holelib_hole("THL-1002", overhead_bore_height=size[2]*2);
		}
		if( $preview ) {
			# translate([-size[0]/2, -size[1]/2, size[2]/2]) cube([size[0]/2, size[1]/2, size[2]*2], center=true);
		}
	}
}

module togridpile_hollow_cube(size, wall_thickness=2) {
	difference() {
		translate([0,0,size[2]/2]) togridpile_hull(size, offset=-margin);
		translate([0,0,size[2]/2]) togridpile_hull_of_style(cavity_style, size, offset=-margin-wall_thickness);
		translate([0,0,size[2]-wall_thickness/2]) togridpile__xy_rounded_cube([size[0]-rounded_corner_radius*1.5, size[1]-rounded_corner_radius*1.5, wall_thickness*2], 2);
		if( $preview ) {
			# translate([-size[0]/2, -size[1]/2, size[2]/2]) cube([size[0]/2, size[1]/2, size[2]*2], center=true);
		}
	}
}

/*module togridpile_multiblock_xy_hull(size_blocks) {
	size = [size_blocks[0]*togridpile_pitch, size_blocks[1]*togridpile_pitch];
	togridpile__rounded_square(size, corner_radius=rounded_corner_radius);
}*/

module togridpile_multiblock_bottom(size_blocks) {
	for( ym=[-size_blocks[1]/2+0.5 : 1 : size_blocks[1]/2-0.5] )
	for( xm=[-size_blocks[0]/2+0.5 : 1 : size_blocks[0]/2-0.5] )
	{
		translate([xm*togridpile_pitch, ym*togridpile_pitch, togridpile_pitch/2]) {
			togridpile_hull([togridpile_pitch, togridpile_pitch, togridpile_pitch], corner_radius_offset=0, offset=-margin);
		}
	}
}

module togridpile_multiblock_hull(size_blocks, height, lip_height) {
	size = [togridpile_pitch*size_blocks[0], togridpile_pitch*size_blocks[1], height+lip_height];
	union() {
		intersection() {
			translate([0,0,beveled_corner_radius/2]) cube([size[0], size[1], beveled_corner_radius], center=true);
			togridpile_multiblock_bottom(size_blocks);
		}
		difference() {
			intersection() {
				translate([0,0,beveled_corner_radius+(height+lip_height-beveled_corner_radius)/2]) cube([togridpile_pitch*size_blocks[0], togridpile_pitch*size_blocks[1], (height+lip_height-beveled_corner_radius)], center=true);
				translate([0,0,height]) togridpile_hull([togridpile_pitch*size_blocks[0], togridpile_pitch*size_blocks[1], height*2], corner_radius_offset=0, offset=-margin);
			}
			// Lip
			translate([0,0,height+togridpile_pitch/2]) togridpile_hull_of_style(togridpile_lip_style, [size[0], size[1], togridpile_pitch], corner_radius_offset=0, offset=+margin);
		}
	}
}

module togridpile_multiblock_cup(size_blocks, height, lip_height) {
	size = [togridpile_pitch*size_blocks[0], togridpile_pitch*size_blocks[1], height];
	difference() {
		render() togridpile_multiblock_hull(size_blocks, height, lip_height);
		translate([0,0,size[2]+floor_thickness]) difference() {
			render() togridpile_hull_of_style(cavity_style, [size[0]-wall_thickness*2, size[1]-wall_thickness*2, size[2]*2], corner_radius_offset=-wall_thickness, offset=-margin);
			// Sublip
			sublip_width = 8;
			sublip_angwid = sublip_width/sin(45);
			sublip_angwid2 = sublip_angwid/sin(45);
			for(xm=[-1,1]) translate([xm*size[0]/2, 0, 0]) rotate([0,45,0]) cube([sublip_angwid,size[1],sublip_angwid], center=true);
			for(ym=[-1,1]) translate([0, ym*size[0]/2, 0]) rotate([45,0,0]) cube([size[0],sublip_angwid,sublip_angwid], center=true);
			for(ym=[-1,1]) for(xm=[-1,1]) {
				translate([xm*size[0]/2, ym*size[1]/2, 0]) rotate([0,0,ym*xm*45]) rotate([0,45,0]) cube([sublip_angwid2,sublip_angwid2,sublip_angwid2], center=true);
			}
		}
		for( ym=[-size_blocks[1]*3+0.5 : 1 : size_blocks[1]*3-0.5] ) for( xm=[-size_blocks[0]*3+0.5 : 1 : size_blocks[0]*3-0.5] ) {
			translate([xm*togridpile_pitch/3, ym*togridpile_pitch/3, floor_thickness]) tog_holelib_hole("THL-1001", depth=floor_thickness+1, overhead_bore_height=floor_thickness);
		}
	}
}

// translate([0*inch, 0, 0]) togridpile_hollow_cup_with_lip([togridpile_pitch, togridpile_pitch, height], lip_height, wall_thickness, floor_thickness,  true, true);
// translate([2*inch, 0, 0]) togridpile_hollow_cube([togridpile_pitch, togridpile_pitch, togridpile_pitch], wall_thickness);

translate([0*inch, 2*inch, 0]) togridpile_multiblock_cup(size_blocks, height, lip_height);
