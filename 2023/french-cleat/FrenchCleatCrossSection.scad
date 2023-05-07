// French cleat cross-sections, v1.0

thickness_inches = 0.75;
nominal_height_inches = 4.5;
length_inches = 0.75;
top_edge_slant = 1; // [-1, 0, 1]
top_edge_trim_inches = 0.125;
bottom_edge_slant = 1; // [-1, 0, 1]
bottom_edge_trim_inches = 0.125;
hole_spacing_inches = 0.75;
// Diameter of holes, in mm
hole_diameter = 5;

// Detail level; only affects holes
$fn = 20;

module __no_more_parameters() { }

inch = 25.4;

thickness = thickness_inches * inch;
height = nominal_height_inches * inch;
length = length_inches * inch;
top_edge_trim    =    top_edge_trim_inches * inch;
bottom_edge_trim = bottom_edge_trim_inches * inch;
hole_spacing     = hole_spacing_inches * inch;

function edge_points(height, thickness, slant) =
	[
		[-thickness/2, height/2 + slant*thickness/2],
		[ thickness/2, height/2 - slant*thickness/2],
	];

function scale_points_2d(points, by) = [
	for( p=points ) [p[0]*by[0], p[1]*by[1]]
];

function fc_corner_points_2d(height, thickness, top_slant, bottom_slant) = [
	each edge_points(height, thickness, top_slant),
	each scale_points_2d(edge_points(height, thickness, bottom_slant), [-1,-1]),
];

linear_extrude(length) {
	difference() {
		intersection() {
			polygon(fc_corner_points_2d(height, thickness, top_edge_slant, bottom_edge_slant));
			trim_top_y    =  height/2 + abs(top_edge_slant * thickness/2) - top_edge_trim;
			trim_bottom_y = -height/2 - abs(bottom_edge_slant * thickness/2) + bottom_edge_trim;
			polygon([
				[-thickness, trim_top_y   ],
				[+thickness, trim_top_y   ],
				[+thickness, trim_bottom_y],
				[-thickness, trim_bottom_y],
			]);
		}
		for( y=[-round(height/2/hole_spacing)+0.5 : 1 : round(height/2/hole_spacing)-0.5] ) {
			translate([0, y*hole_spacing, 0]) circle(d=hole_diameter);
		}
	}
}
