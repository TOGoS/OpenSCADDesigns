/* Edge profile point arrays!
 *
 * Should be listed from bottom to top.
 * - X=0 is at the edge of the cell (*not the slightly narrower block*)
 * - Positive X is the offset into the left side
 * - Y=0 is the floor.
 * - Corner profile point lists start with the base
 *   and go upwards to the side.
 */

// Regular block bottom
tog_gridfinity_block_bottom_corner_profile_points = [
	[3.20, 0.00], // Right end of bottom bevel
	[2.40, 0.80],
	[2.40, 2.60],
	[0.25, 4.75], // Top of left bevel
];

// Block lip, with min(X) = 0.25
tog_gridfinity_block_lip_corner_profile_points = [
	[2.85, 0.00], // Right end of bottom bevel
	[2.15, 0.70],
	[2.15, 2.50],
	[0.25, 4.20], // Top tip
];

// Full-cell lip.   Starts at cell edge instead of 0.25 inward for blocks.
// Alternatively one could always use this and just intersect with the block hull,
// (or subtracting the inverse)
// which may be simpler especially if making blocks with a grid on top.
tog_gridfinity_full_lip_corner_profile_points = [
	[2.85, 0.00], // Right end of bottom bevel
	[2.15, 0.70],
	[2.15, 2.50],
	[0.00, 4.65], // Top tip
];

function tog_gridfinity_make_corner_extrudable_points(corner_profile_points, margin, block_height=7, corner_radius=4) = [
	[0, 0],
	for( point=corner_profile_points ) [point[0] - corner_radius, point[1]],
	[margin - corner_radius, block_height],
	[0, block_height],
];

function tog_gridfinity_reverse_list(list) = [
	for( i=[len(list)-1: -1 : 0] ) list[i]
];

/**
 * Reverses the list of points for use as a cutout at the top of a block
 * and also adds some amount of Y
 */
//function tog_gridfinity_adjusted_lip_points(point_list, delta_y=0) = [
//	for( i=[len(list)-1: -1 : 0] ) list[i]
//];

// Extrudable points for an entire block, with lip, filled to the specified height
function tog_gridfinity_make_block_with_lip_extrudable_points( block_height, floor_height=7, corner_radius=4, wall_thickness=2 ) = [
	[0, 0],
	for( point=tog_gridfinity_block_bottom_corner_profile_points ) [point[0] - corner_radius, point[1]],
	for( point=tog_gridfinity_reverse_list(tog_gridfinity_block_lip_corner_profile_points) ) [point[0] - corner_radius, point[1] + block_height],
	each (floor_height == block_height ? [] : [
		// TODO: Really want to filter this list of down-the-inside-of-the-lip points
		// based on being >= floor height.
		[tog_gridfinity_block_lip_corner_profile_points[0][0] - corner_radius, max(floor_height, block_height-2)], // 2 is probably fine; really want a max. 45deg from wall thickness to innermost point in lip
		[wall_thickness+0.25 - corner_radius, max(floor_height, block_height-4)], // difference y=-2 is probably fine; really want a max. 45deg from wall thickness to innermost point in lip
		[wall_thickness+0.25 - corner_radius, floor_height],
	]),
	[0, floor_height],,
	//[tog_gridfinity_block_lip_corner_profile_points[0][0] - corner_radius, floor_height],
];

// Create full extrudable polygon where x=0 refers to the pivot point
function tog_gridfinity_make_block_bottom_corner_extrudable_points(block_height=7, corner_radius=4) = tog_gridfinity_make_corner_extrudable_points(
	tog_gridfinity_block_bottom_corner_profile_points,
	0.25,
	block_height=block_height,
	corner_radius=corner_radius
);

module tog_gridfinity_block_from_profile_points(profile_points, block_width=42, corner_radius=4, overlap=0) {
	bottom_z = profile_points[0][1];
	top_z    = profile_points[len(profile_points)-1][1];
	for( r=[0:90:270] ) rotate([0,0,r]) {
		translate([-block_width/2+corner_radius, -block_width/2+corner_radius, 0]) {
			rotate_extrude(angle=90) {
				polygon(profile_points);
			}
		}
		translate([-block_width/2+corner_radius, 0, 0]) {
			rotate([90,0,0]) linear_extrude(block_width-2*corner_radius+overlap*2, center=true) {
				polygon(profile_points);
			}
		}
	}
	translate([0,0,(bottom_z+top_z)/2]) cube([block_width-corner_radius*2+overlap*2, block_width-corner_radius*2+overlap*2, top_z-bottom_z], center=true);
}


/**
 * Hull to be intersected with block bottoms for gridfinity compatibility.
 * Overlap=0 seems to work, but it can be set to a small value, like 1/64,
 * if OpenSCAD gets confused about exactly interfacing surfaces.
 */
module tog_gridfinity_block_bottom(height=14, gridfinity_pitch=42, corner_radius=4, overlap=0) {
	tog_gridfinity_block_from_profile_points(tog_gridfinity_make_block_bottom_corner_extrudable_points(height, corner_radius), gridfinity_pitch, corner_radius, overlap);
}

module tog_gridfinity_block_with_lip(
	height=14, floor_height=7,
	gridfinity_pitch=42, corner_radius=4, overlap=0,
	magnet_hole_diameter=6.5,
	magnet_hole_depth=2.4,
) {
	difference() {
		tog_gridfinity_block_from_profile_points(tog_gridfinity_make_block_with_lip_extrudable_points(height, floor_height, corner_radius), gridfinity_pitch, corner_radius, overlap);
		if( magnet_hole_diameter > 0 && magnet_hole_depth > 0 ) for( ym=[-1,1] ) for( xm=[-1,1] ) {
			translate([13*xm, 13*ym, 0]) cylinder(d=magnet_hole_diameter, h=magnet_hole_depth*2, center=true);
		}
	}
}
