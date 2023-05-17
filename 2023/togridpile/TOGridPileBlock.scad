// TOGridPileBlock-v4.5
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
// v2.5:
// - Thicker default floor
// v2.6:
// - Add large hole pattern, make both hole types configurable
// v2.7:
// - Give multiblocks 'butt cracks' to hopefully reduce sagging
// v2.8:
// - Magnet wells
// v2.9:
// - Fix hole and sublip platform placement when not square
// - Above-magnet 'well' can be different size than the magnet
// v3.0:
// - Add 'hybrid3' shape
// v4.0:
// - Add 'hybrid4' shape
// v4.1:
// - Rename 'hybrid4-female' to 'hybrid3+4'
// v4.2:
// - magnet_hole_style can be 'normal' for bottom-inserted magnets
// v4.3:
// - Add 'hybrid5' shape
// v4.4:
// - Fixes to hybrid5 shapes
// v4.5:
// - Label lips and fingerslides!
// - Implement 'overhang remedy' for magnet holes

/* [Content] */

size_blocks = [3,2];
// Height, not including lip; 12.7mm = 1/2", 25.4mm = 1", 38.1mm = 1.5", 76.2mm = 3"
height = 12.7;           // 0.001
wall_thickness = 2;      // 0.001
cavity_style = "rounded"; // [ "rounded", "beveled", "hybrid1", "hybrid2", "minimal" ]
// Height of bottom of cavity; 3.175mm (1/8") is fine for single blocks but to avoid gaps, pick a larger value for multi-blocks
floor_thickness = 4.7625; // 0.001

small_hole_style = "THL-1001"; // ["none","THL-1001","THL-1002"]
large_hole_style = "THL-1002"; // ["none","THL-1001","THL-1002"]

magnet_hole_style = "normal"; // ["none","normal","top-loaded"]
magnet_hole_diameter = 6;
magnet_hole_depth = 2;
magnet_hole_floor_thickness = 0.3;
// Diameter of hole above the magnet hole
magnet_well_diameter = 6.5;
// Diameter of hole below the magnet hole
magnet_drain_hole_diameter = 3;

fingerslide_radius = 12.7;
label_width = 12.7;

/* [Grid / Stacking System] */

// 38.1mm = 1+1/2"
togridpile_pitch = 38.1;

beveled_corner_radius = 3.175;
rounded_corner_radius = 4.7625;

// 4.7625mm = 3/16", 3.175 = 1/8"
// "hybrid1" is hybrid2 but with XZ corners rounded off
togridpile_style = "hybrid5-xy"; // [ "rounded", "beveled", "hybrid1", "hybrid2", "hybrid3", "hybrid4-xy", "hybrid5-xy", "minimal" ]
// Style for purposes of lip cutout; "maximal" will accomodate all others; "hybrid1-inner" will accomodate rounded or hybrid1 bottoms
togridpile_lip_style = "hybrid3+5"; // [ "rounded", "beveled", "hybrid1-inner", "hybrid2", "hybrid3", "hybrid3+4", "hybrid4", "hybrid3+5", "hybrid5", "hybrid5-xy", "maximal" ]

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

submod_pitch = togridpile_pitch/3;

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
	difference() {
		intersection() {
			union() {
				togridpile_multiblock_bottom(size_blocks);
				translate([0,0,height+beveled_corner_radius]) togridpile_hull_of_style("hybrid2", [togridpile_pitch*size_blocks[0], togridpile_pitch*size_blocks[1], height*2], corner_radius_offset=0, offset=-margin);
			}
			translate([0,0,(height+lip_height)/2]) cube([size[0], size[1], height+lip_height], center=true);
		}
		// Lip
		if( togridpile_lip_style == "beveled" || togridpile_lip_style == "rounded" || togridpile_lip_style == "hybrid2" || togridpile_lip_style == "hybrid3" ) {
			translate([0,0,height+togridpile_pitch/2]) togridpile_hull_of_style(togridpile_lip_style, [size[0], size[1], togridpile_pitch], corner_radius_offset=0, offset=+margin);
		} else {
			translate([0,0,height+togridpile_pitch/2]) togridpile_hull_of_style("hybrid2", [size[0], size[1], togridpile_pitch], corner_radius_offset=0, offset=+margin);
			for( ym=[-size_blocks[1]/2+0.5 : 1 : size_blocks[1]/2-0.5] ) for( xm=[-size_blocks[0]/2+0.5 : 1 : size_blocks[0]/2-0.5] ) translate([xm*togridpile_pitch, ym*togridpile_pitch, height+togridpile_pitch/2]) {
				togridpile_hull_of_style(togridpile_lip_style, [togridpile_pitch, togridpile_pitch, togridpile_pitch], corner_radius_offset=0, offset=+margin);
			}
		}
	}
}

module block_magnet_hole() {
	if( magnet_hole_style == "none" ) {
	} else if( magnet_hole_style == "top-loaded" ) {
		translate([0, 0, magnet_hole_floor_thickness]) cylinder(d=magnet_hole_diameter, h=floor_thickness+1, center=false);
		translate([0, 0, magnet_hole_floor_thickness+magnet_hole_depth]) cylinder(d=magnet_well_diameter, h=floor_thickness+1, center=false);
		translate([0, 0, 0]) cylinder(d=magnet_drain_hole_diameter, h=floor_thickness*2, center=true);
	} else {
		// normal!
		render() intersection() {
			cylinder(d=magnet_hole_diameter, h=floor_thickness*2+1, center=true);
			union() {
				//cylinder(d=magnet_hole_diameter, h=magnet_hole_depth*2, center=true);
				cube([magnet_hole_diameter*2, magnet_hole_diameter*2, magnet_hole_depth*2], center=true);
				cube([magnet_hole_diameter*2, magnet_drain_hole_diameter, magnet_hole_depth*2+1], center=true);
				translate([0, 0, floor_thickness/2]) cylinder(d=magnet_drain_hole_diameter, h=floor_thickness*2+1, center=true);
			}
		}
	}
}

module togridpile_multiblock_cup__unrounded(size_blocks, height, lip_height) {
	size = [togridpile_pitch*size_blocks[0], togridpile_pitch*size_blocks[1], height];
	cavity_size = [size[0]-wall_thickness*2, size[1]-wall_thickness*2];
	difference() {
		render() togridpile_multiblock_hull(size_blocks, height, lip_height);
		if( floor_thickness < size[2] ) difference() {
			translate([0,0,size[2]+floor_thickness]) render() {
				togridpile_hull_of_style(cavity_style, [cavity_size[0], cavity_size[1], size[2]*2], corner_radius_offset=-wall_thickness, offset=-margin);
			}
			translate([0,0,size[2]+floor_thickness]) {
				// Sublip
				sublip_width = 8;
				sublip_angwid = sublip_width/sin(45);
				sublip_angwid2 = sublip_angwid/sin(45);
				for(xm=[-1,1]) translate([xm*size[0]/2, 0, 0]) rotate([0,45,0])
					cube([sublip_angwid,size[1],sublip_angwid], center=true);
				for(ym=[-1,1]) translate([0, ym*size[1]/2, 0]) rotate([45,0,0])
					cube([size[0],sublip_angwid,sublip_angwid], center=true);
				for(ym=[-1,1]) for(xm=[-1,1]) translate([xm*size[0]/2, ym*size[1]/2, 0]) rotate([0,0,ym*xm*45]) rotate([0,45,0])
					cube([sublip_angwid2,sublip_angwid2,sublip_angwid2], center=true);
				// Label
				if( label_width > 0 ) {
					label_angwid = label_width/sin(45);
					translate([-size[0]/2, 0, 0]) rotate([0,45,0]) cube([label_angwid,size[1],label_angwid], center=true);
				}
			}
			// Finger slide
			if( fingerslide_radius > 0 ) translate([0,0,floor_thickness]) difference() {
				translate([cavity_size[0]/2, 0, 0])
					cube([fingerslide_radius*2, cavity_size[1]*2, fingerslide_radius*2], center=true);
				translate([cavity_size[0]/2-fingerslide_radius, 0, fingerslide_radius])
					rotate([90,0,0]) cylinder(r=fingerslide_radius, h=cavity_size[1]*3, center=true, $fn=max(24,$fn));
			}
		}
		for( ym=[-size_blocks[1]/2+0.5 : 1 : size_blocks[1]/2-0.5] ) for( xm=[-size_blocks[0]/2+0.5 : 1 : size_blocks[0]/2-0.5] ) translate([xm*togridpile_pitch, ym*togridpile_pitch]) {
			translate([0, 0, floor_thickness]) render() tog_holelib_hole(large_hole_style, depth=floor_thickness+1, overhead_bore_height=floor_thickness);
			for( subpos=[[0,1],[1,0],[0,-1],[-1,0]] ) {
				translate([subpos[0]*submod_pitch, subpos[1]*submod_pitch, floor_thickness]) render()
					tog_holelib_hole(small_hole_style, depth=floor_thickness+1, overhead_bore_height=1);
			}
			for( subpos=[[1,1],[1,-1],[-1,-1],[-1,1]] ) {
				translate([subpos[0]*submod_pitch, subpos[1]*submod_pitch])
					block_magnet_hole();
			}
		}
	}
}

module togridpile_multiblock_cup(size_blocks, height, lip_height) {
	size = [togridpile_pitch*size_blocks[0], togridpile_pitch*size_blocks[1], height];
	intersection() {
		translate([0,0,size[2]/2]) linear_extrude(size[2]*2, center=true) togridpile__rounded_square(size, rounded_corner_radius, offset=-margin);
		togridpile_multiblock_cup__unrounded(size_blocks, height, lip_height);
	}
}

togridpile_multiblock_cup(size_blocks, height, lip_height);
