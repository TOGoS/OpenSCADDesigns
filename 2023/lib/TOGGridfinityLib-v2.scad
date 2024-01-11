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
togridfinity2_block_bottom_corner_profile_points = [
	[3.20, 0.00], // Right end of bottom bevel
	[2.40, 0.80],
	[2.40, 2.60],
	[0.25, 4.75], // Top of left bevel
];

// Block lip, with min(X) = 0.25
togridfinity2_block_lip_corner_profile_points = [
	[2.85, 0.00], // Right end of bottom bevel
	[2.15, 0.70],
	[2.15, 2.50],
	[0.25, 4.20], // Top tip
];

// Full-cell lip.   Starts at cell edge instead of 0.25 inward for blocks.
// Alternatively one could always use this and just intersect with the block hull,
// (or subtracting the inverse)
// which may be simpler especially if making blocks with a grid on top.
togridfinity2_full_lip_corner_profile_points = [
	[2.85, 0.00], // Right end of bottom bevel
	[2.15, 0.70],
	[2.15, 2.50],
	[0.00, 4.65], // Top tip
];

use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>

function togridfinity2__veclen(v) = sqrt(v[0]*v[0] + v[1]*v[1]);

// Assumes points represent the left side
function togridfinity2__extrapolate_last(points, target_x) =
let( last_point = points[len(points)-1] )
let( pult_point = points[len(points)-2] )
let( last_v = last_point - pult_point )
assert( last_v[0] != 0 )
let( extend_v = last_v * (target_x-pult_point[0])/last_v[0] )
let( fast_point = pult_point + extend_v )
[
	for( i=[0:1:len(points)-1] ) points[i],
	fast_point,
];

function togridfinity2__pad_foot_points(points, size, padding) =
let( extrapolated = togridfinity2__extrapolate_last(points, -padding) )
let( fast_point = extrapolated[len(extrapolated)-1] )
[
	for( p=extrapolated ) p,
	if( fast_point[1] < size[2]+padding ) [fast_point[0], size[2]+padding],
];

function togridfinity2_foot(size=[42,42,42]) =
	tphl1_make_polyhedron_from_layer_function(
		togridfinity2__pad_foot_points( togridfinity2_block_bottom_corner_profile_points, size, 4 ),
		function(p) togmod1_rounded_rect_points([size[0]-p[0]*2, size[1]-p[0]*2], r=4-p[0], pos=[0,0,p[1]])
	);

function togridfinity2_xy_hull(size=[42,42,42]) =
	let( gf_margin = 0.25 )
	tphl1_make_polyhedron_from_layer_function(
		[0,size[2]],
		function(z) togmod1_rounded_rect_points([size[0]-gf_margin*2, size[1]-gf_margin*2], r=4-gf_margin, pos=[0,0,z])
	);
