// CornerRadiusJig-v0.2
//
// Changes:
// v0.2:
// - Compeltely new design!
// - No built-in lips!
// - Holes for heat-set inserts so you can attach your own lips!
// - Labeled corners!

hole_spacing = 38.1;
insert_hole_spacing = 25.4;
insert_hole_diameter = 5;
insert_hole_depth = 15;

preview_fn = 16;
render_fn = 64;

module __end_params_xy120931() {}

inch = 25.4;

body_thickness = 1/2*inch;

size = [6*inch, 6*inch];
arm_width = 1.5*inch;
// 9.525mm = 3/8", 6.35mm = 1/4"
radii = [3/16*inch, 4/16*inch, 5/16*inch, 6/16*inch];
labels = ["3/16", "1/4", "5/16", "3/8"];

$fn = $preview ? preview_fn : render_fn;

use <../lib/TOGHoleLib-v1.scad>

// TODO: Put in TOGShapeLib, use for making regular rounded rectangles, also
function multi_rounded_rect_points(size, radii) =
	let(center_positions = [
		[ size[0]/2 - radii[0],  size[1]/2 - radii[0]],
		[-size[0]/2 + radii[1],  size[1]/2 - radii[1]],
		[-size[0]/2 + radii[2], -size[1]/2 + radii[2]],
		[ size[0]/2 - radii[3], -size[1]/2 + radii[3]],
	])
	[
		for( i=[0,1,2,3] ) for( a=[i*90 : 5 : (i+1)*90] )
			[center_positions[i][0] + cos(a)*radii[i], center_positions[i][1] + sin(a)*radii[i]]
	];

difference() {
	linear_extrude(body_thickness) polygon(multi_rounded_rect_points(size, radii));

	holecount_x = round(size[0] / hole_spacing);
	holecount_y = round(size[1] / hole_spacing);
	
	for( xm = [-holecount_x/2 + 0.5 : 1 : holecount_x] )
	for( ym = [-holecount_y/2 + 0.5 : 1 : holecount_y] )
		translate( [xm * hole_spacing, ym * hole_spacing, 1/8*inch] )
			tog_holelib_hole("THL-1001", overhead_bore_height=body_thickness);
	
	insert_holecount_x = round(size[0] / insert_hole_spacing);
	insert_holecount_y = round(size[1] / insert_hole_spacing);

	for( xm = [-insert_holecount_x/2 + 0.5 : 1 : insert_holecount_x] )
	for( ym = [-1, 1] )
		translate([xm * insert_hole_spacing, ym*size[1]/2, body_thickness/2]) rotate([90, 0, 0]) cylinder(d=insert_hole_diameter, h=insert_hole_depth*2, center=true);
	
	for( ym = [-insert_holecount_y/2 + 0.5 : 1 : insert_holecount_y] )
	for( xm = [-1, 1] )
		translate([xm*size[0]/2, ym * insert_hole_spacing, body_thickness/2]) rotate([0, 90, 0]) cylinder(d=insert_hole_diameter, h=insert_hole_depth*2, center=true);

	lpx = 15;
	lpy = 7;
	
	label_positions = [
		[ size[0]/2 - lpx,  size[1]/2 - lpy],
		[-size[0]/2 + lpx,  size[1]/2 - lpy],
		[-size[0]/2 + lpx, -size[1]/2 + lpy],
		[ size[0]/2 - lpx, -size[1]/2 + lpy],
	];
	for( i=[0,1,2,3] ) {
		translate([label_positions[i][0], label_positions[i][1], body_thickness]) {
			linear_extrude(1, center=true) text(labels[i], size=7, halign="center", valign="center");
		}
	}
}
