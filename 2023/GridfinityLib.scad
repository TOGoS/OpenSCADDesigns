// X,Y points from bottom, left corner of 42mm cell, assuming 4mm radius
// (spec actually indicates in terms of the 41.5mm block)
tog_gridfinity_block_bottom_corner_profile_points = [
	[0.25, 4.75], // Top of left bevel
	[2.40, 2.60],
	[2.40, 0.80],
	[3.20, 0.00], // Right end of bottom bevel
];

// Create full extrudable polygon where x=0 refers to the pivot point
function tog_gridfinity_make_block_bottom_corner_extrudable_points(block_height=7, corner_radius=4) = [
	[0.25 - corner_radius, block_height],
	for( point=tog_gridfinity_block_bottom_corner_profile_points ) [point[0] - corner_radius, point[1]],
	[0, 0],
	[0, block_height],
];

/**
 * Hull to be intersected with block bottoms for gridfinity compatibility.
 * Overlap=0 seems to work, but it can be set to a small value, like 1/64,
 * if OpenSCAD gets confused about exactly interfacing surfaces.
 */
module tog_gridfinity_block_bottom(height=14, gridfinity_pitch=42, corner_radius=4, overlap=0) {
	for( r=[0:90:270] ) rotate([0,0,r]) {
		translate([-gridfinity_pitch/2+corner_radius, -gridfinity_pitch/2+corner_radius, 0]) {
			rotate_extrude(angle=90) {
				polygon(tog_gridfinity_make_block_bottom_corner_extrudable_points(height, corner_radius));
			}
		}
		translate([-gridfinity_pitch/2+corner_radius, 0, 0]) {
			rotate([90,0,0]) linear_extrude(gridfinity_pitch-2*corner_radius+overlap*2, center=true) {
				polygon(tog_gridfinity_make_block_bottom_corner_extrudable_points(height));
			}
		}
	}
	translate([0,0,height/2]) cube([gridfinity_pitch-corner_radius*2+overlap*2, gridfinity_pitch-corner_radius*2+overlap*2, height], center=true);
}
