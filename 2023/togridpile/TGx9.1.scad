// TGx9.1.1 - experimental simplified (for OpenSCAD rendering purposes) TOGridPile shape
//
// 9.1.0:
// - Initial demo of simple atomic feet
// 9.1.1:
// - Extrude foot shape along path for smooth chunk feet
// - New approach to configurable per-chunk additions/subtractions, using chunk_child_ops.
//   Idea being that applying the modifications per-chunk will allow OpenSCAD
//   to cache the results more easily than going back over the whole block,
//   visiting the chunks twice.
// - Margin/offset is not yet being taken into account!  Probably don't print this.

block_size_chunks = [2,2];
height = 38.1; // 0.001
magnet_hole_diameter = 6.2;
lip_height = 1.5;
foot_segmentation = "atom"; // ["atom","chunk"]

margin = 0.1;

preview_fn = 12;
render_fn = 36;

$fn = $preview ? preview_fn : render_fn;

module tgx9__end_params() { }

inch = 25.4;

use <../lib/TOGShapeLib-v1.scad>

function tgx9_bottom_points(u, height) = [
	[ 0*u, 0*u],
	[-3*u, 0*u],
	[-3*u, 1*u],
	[-6*u, 4*u],
	[-6*u, height],
	[ 0*u, height],
];

module tgx9_atom_foot(height=100, offset=0) {
	u = inch * 1 / 16;
	rotate_extrude() {
		// TODO: Offset the points somehow
		polygon(tgx9_bottom_points(u, height));
	}
}


module tgx9_smooth_chunk_foot(height=100, offset=0) {
	// TODO: Offset the points somehow
	tgx9_extrude_along_loop([
		[-1/2*inch, -1/2*inch],
		[ 1/2*inch, -1/2*inch],
		[ 1/2*inch,  1/2*inch],
		[-1/2*inch,  1/2*inch],
	]) polygon(tgx9_bottom_points(1/16*inch, 100));
	translate([0,0,height/2]) cube([1*inch, 1*inch, height], center=true);
}

module tgx9_atomic_chunk_foot(height=100) {
	for( xm=[-1,0,1] ) for( ym=[-1,0,1] ) {
		translate([xm*inch/2, ym*inch/2, 0]) tgx9_atom_foot(height=height);
	}
}

module tgx9_chunk_foot(segmentation="chunk", height=100, offset=0) {
	if( segmentation == "chunk" ) {
		tgx9_smooth_chunk_foot(height=height, offset=offset);
	} else {
		tgx9_atomic_chunk_foot(height=height, offset=offset);
	}
}

function tgx9_vector_angle(normalized_vector) =
	let( cos = acos(normalized_vector[0]) )
		normalized_vector[1] > 0 ? cos : 360-cos;

function tgx9_angle_difference(angle1, angle0) =
	angle1 < angle0 ? tgx9_angle_difference(angle1+360, angle0) : angle1-angle0;

module tgx9_extrude_along_loop(path) {
	if( len(path) == 1 ) {
		translate(path[0]) rotate_extrude(angle=360) children();
	} else for( i=[0:1:len(path)-1] ) {
		// The straight part
		point_a = path[i];
		point_b = path[(i+1) % len(path)];
		point_c = path[(i+2) % len(path)];
		dx = point_b[0] - point_a[0];
		dy = point_b[1] - point_a[1];
		distance = sqrt(dx*dx + dy*dy);
		normalized_vector = [dx/distance, dy/distance];
		a2b_angle = tgx9_vector_angle(normalized_vector);
		
		translate(point_a) rotate([0, 0, 90 + a2b_angle]) rotate([90,0,0]) linear_extrude(distance) children();

		b2c_dx = point_c[0] - point_b[0];
		b2c_dy = point_c[1] - point_b[1];
		b2c_distance = sqrt(b2c_dx*b2c_dx + b2c_dy*b2c_dy);
		b2c_normalized_vector = [b2c_dx/b2c_distance, b2c_dy/b2c_distance];
		b2c_angle = tgx9_vector_angle(b2c_normalized_vector);
		// TODO: Figure out when and how to do concave corners!
		b2c_turn = tgx9_angle_difference(b2c_angle, a2b_angle);
		
		// Convex corners only for now!!
		//echo(b2c_normalized_vector=b2c_normalized_vector, a2b_angle=a2b_angle, b2c_angle=b2c_angle, b2c_turn=b2c_turn);
		translate(point_b) rotate([0, 0, 90 + a2b_angle]) rotate_extrude(angle=b2c_turn) children();
	}
}

chunk_pitch_atoms = 3;
atom_pitch = 12.5;

module tgx9_1_0_block_foot(block_size_chunks=[1,1], offset=0, chunk_child_ops=[]) {
	chunk_pitch = chunk_pitch_atoms * atom_pitch;
	
	for( xm=[-block_size_chunks[0]/2+0.5 : 1 : block_size_chunks[0]/2-0.5] )
	for( ym=[-block_size_chunks[1]/2+0.5 : 1 : block_size_chunks[1]/2-0.5] )
		translate([xm*chunk_pitch, ym*chunk_pitch])
			difference() {
				union() {
					tgx9_chunk_foot(foot_segmentation, height=height*2, offset=offset);
					for( i=[0 : 1 : len(chunk_child_ops)-1] ) {
						if( chunk_child_ops[i] == "add" ) children(i);
					}
				}
				
				for( i=[0 : 1 : len(chunk_child_ops)-1] ) {
					if( chunk_child_ops[i] == "subtract" ) children(i);
				}
			}
}

module tgx9_1_0_block(block_size_chunks=[1,1], height=100, offset=0, chunk_child_ops=[]) intersection() {
	chunk_pitch = chunk_pitch_atoms * atom_pitch;
	block_size = block_size_chunks*chunk_pitch;

	tgx9_1_0_block_foot(block_size_chunks, offset=offset, chunk_child_ops=chunk_child_ops) children();
	
	tog_shapelib_xy_rounded_cube([
		block_size[0],
		block_size[1],
		height*2
	], 1/4*inch, offset=offset);
}

module tgx9_1_0_cup(block_size_chunks=[1,1], height=100, lip_height=2.54, offset=0, bottom_chunk_child_ops=[], top_subtraction_chunk_child_ops=[]) difference() {
	tgx9_1_0_block(block_size_chunks, height=height+lip_height, offset=offset, chunk_child_ops=bottom_chunk_child_ops) children();
	
	translate([0,0,height]) tgx9_1_0_block_foot(block_size_chunks, offset=-offset, chunk_child_ops=top_subtraction_chunk_child_ops) children();
}

tgx9_1_0_cup(
	block_size_chunks=block_size_chunks,
	height=height,
	lip_height=lip_height,
	offset=-margin,
	bottom_chunk_child_ops = [],
	top_subtraction_chunk_child_ops = ["add"]
) {
	for( pos=[[-1,-1],[1,-1],[-1,1],[1,1]] ) {
		translate(pos*inch/2) cylinder(d=magnet_hole_diameter, h=4, center=true);
	}
}
