// TGx9.1.6 - experimental simplified (for OpenSCAD rendering purposes) TOGridPile shape
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
// 9.1.2:
// - Offset points to be extruded
// 9.1.3:
// - Add THL-1001 holes
// - Note that the `child_ops` thing doesn't actually work; bummersauce!
//   Need to either transpile my own language to OpenSCAD or hack in a way
//   to pass modules by name (["module_name", arg1, arg2, ...] kind of thing)
// - Fix that `atomic_chunk_foot` didn't take or use `offset`
// 9.1.4:
// - Different corner radius for bottom (1/4") and top (3/16", for [near?] compatibility with other designs)
// 9.1.5:
// - Fix to avoid CGAL error for short blocks
// 9.1.6:
// - Refactor child_ops stuff to a more general S-expression system, where 'child' is one possible named module

block_size_chunks = [2,2];
height = 38.1; // 0.001
magnet_hole_diameter = 6.2;
lip_height = 1.5;
foot_segmentation = "atom"; // ["atom","chunk"]

margin = 0.05; // 0.01

preview_fn = 12;
render_fn = 36;

$fn = $preview ? preview_fn : render_fn;

module tgx9__end_params() { }

inch = 25.4;

use <../lib/TOGShapeLib-v1.scad>
use <../lib/TOGHoleLib-v1.scad>

default_u = 5; // Make it wrong for starters

u = 1/16*inch;
chunk_pitch_atoms = 3;
atom_pitch_u = 8;
atom_pitch = atom_pitch_u*u;

// [x, y, offset_factor_x, offset_factor_y]
function tgx9_bottom_points(u, height, radius_u=4) =
let( height=max(height, 6*u) ) [
	[            0*u, 0*u,     0, -1  ],
	[-(radius_u-1)*u, 0*u,    -1, -1  ],
	[-(radius_u-1)*u, 1*u,    -1, -0.4],
	[-(radius_u+2)*u, 4*u,    -1, -0.4],
	[-(radius_u+2)*u, height, -1,  1  ],
	[            0*u, height,  0,  1  ],
];

function tgx9_offset_points(points, offset) = [
	for(p=points) [p[0]+offset*p[2], p[1]+offset*p[3]]
];

module tgx9_atom_foot(height=100, offset=0, u=u, radius_u=4) {
	rotate_extrude() {
		polygon(tgx9_offset_points(tgx9_bottom_points(u, height, radius_u), offset));
	}
}

// Here to mess with in case things need to be fattened a little bit
// in order to make CGAL happy.  So far, so good with theoretically exact matches.
epsilon     = 0; // 1/256; // of a millimiter
rot_epsilon = 0; // 1/ 16; // of a degree

module tgx9_smooth_chunk_foot(height=100, u=default_u, chunk_pitch_u=24, corner_radius_u=4, offset=0) {
	corner_dist_u = (chunk_pitch_u/2)-corner_radius_u;
	corner_dist = u*corner_dist_u;
	tgx9_extrude_along_loop([
		[-corner_dist, -corner_dist],
		[ corner_dist, -corner_dist],
		[ corner_dist,  corner_dist],
		[-corner_dist,  corner_dist],
	], rot_epsilon=rot_epsilon) polygon(tgx9_offset_points(tgx9_bottom_points(u=u, height=height, radius_u=corner_radius_u), offset));
	translate([0,0,height/2]) cube([
		(chunk_pitch_u-corner_radius_u*2)*u + epsilon*2,
		(chunk_pitch_u-corner_radius_u*2)*u + epsilon*2,
		height                    +offset*2 + epsilon*2
	], center=true);
}

module tgx9_atomic_chunk_foot(u=default_u, height=100, offset=0) {
	for( xm=[-1,0,1] ) for( ym=[-1,0,1] ) {
		translate([xm*atom_pitch, ym*atom_pitch, 0]) tgx9_atom_foot(u=u, height=height, offset=offset);
	}
}

module tgx9_chunk_foot(segmentation="chunk", u=default_u, height=100, corner_radius_u=4, offset=0) {
	if( segmentation == "chunk" ) {
		tgx9_smooth_chunk_foot(u=u, height=height, corner_radius_u=corner_radius_u, offset=offset);
	} else {
		assert(corner_radius_u == 4);
		tgx9_atomic_chunk_foot(u=u, height=height, offset=offset);
	}
}

function tgx9_vector_angle(normalized_vector) =
	let( cos = acos(normalized_vector[0]) )
		normalized_vector[1] > 0 ? cos : 360-cos;

function tgx9_angle_difference(angle1, angle0) =
	angle1 < angle0 ? tgx9_angle_difference(angle1+360, angle0) : angle1-angle0;

module tgx9_extrude_along_loop(path, rot_epsilon=0) {
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
		translate(point_b) rotate([0, 0, 90 + a2b_angle - rot_epsilon]) rotate_extrude(angle=b2c_turn+rot_epsilon*2) children();
	}
}

module tgx9_do_module(expression) {
	assert( len(expression) > 0 );
	function_name = expression[0];
	if( function_name == "child" ) {
		children(0);
	} else {
		assert(false, str("Unrecognized expression type: '", function_name, "'"));
	}
}

module tgx9_1_0_block_foot(block_size_chunks=[1,1], offset=0, corner_radius_u=4, chunk_ops=[]) {
	chunk_pitch = chunk_pitch_atoms * atom_pitch;
	
	for( xm=[-block_size_chunks[0]/2+0.5 : 1 : block_size_chunks[0]/2-0.5] )
	for( ym=[-block_size_chunks[1]/2+0.5 : 1 : block_size_chunks[1]/2-0.5] )
		translate([xm*chunk_pitch, ym*chunk_pitch])
			difference() {
				union() {
					tgx9_chunk_foot(foot_segmentation, u=u, height=height*2, corner_radius_u=corner_radius_u, offset=offset);
					for( i=[0 : 1 : len(chunk_ops)-1] ) {
						op = chunk_ops[i];
						if( op[0] == "add" ) tgx9_do_module(op[1]) children();
					}
				}
				
				for( i=[0 : 1 : len(chunk_ops)-1] ) {
					op = chunk_ops[i];
					if( op[0] == "subtract" ) tgx9_do_module(op[1]) children();				
				}
			}
}

basic_corner_rad_u = 4;
female_corner_rad_u = 3;

module tgx9_1_0_block(block_size_chunks=[1,1], height=100, offset=0, chunk_ops=[]) intersection() {
	chunk_pitch = chunk_pitch_atoms * atom_pitch;
	block_size = block_size_chunks * chunk_pitch;

	tgx9_1_0_block_foot(block_size_chunks, offset=offset, corner_radius_u=basic_corner_rad_u, chunk_ops=chunk_ops) children();
	
	tog_shapelib_xy_rounded_cube([
		block_size[0],
		block_size[1],
		height*2
	], u*female_corner_rad_u, offset=offset);
}

module tgx9_1_0_cup(block_size_chunks=[1,1], height=100, lip_height=2.54, offset=0, bottom_chunk_ops=[], top_subtraction_chunk_ops=[]) difference() {
	tgx9_1_0_block(block_size_chunks, height=height+lip_height, offset=offset, chunk_ops=bottom_chunk_ops) children();
	
	translate([0,0,height]) tgx9_1_0_block_foot(block_size_chunks, corner_radius_u=female_corner_rad_u, offset=-offset, chunk_ops=top_subtraction_chunk_ops) children();
}

tgx9_1_0_cup(
	block_size_chunks=block_size_chunks,
	height=height,
	lip_height=lip_height,
	offset=-margin,
	bottom_chunk_ops = [],
	top_subtraction_chunk_ops = [["add",["child"]]]
) union() {
	for( pos=[[-1,-1],[1,-1],[-1,1],[1,1]] ) {
		translate(pos*atom_pitch) cylinder(d=magnet_hole_diameter, h=4, center=true);
	}
	for( pos=[[0,-1],[-1,0],[0,1],[1,0],[0,0]] ) {
		translate(pos*atom_pitch) tog_holelib_hole("THL-1001");
	}
}
