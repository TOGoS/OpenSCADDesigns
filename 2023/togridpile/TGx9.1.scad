// TGx9.1.8 - experimental simplified (for OpenSCAD rendering purposes) TOGridPile shape
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
// 9.1.7:
// - Massive refactoring to replace various unit parameters with the
//   $tgx9_unit_table 'special' (i.e. dynamic scoped) variable
//   and use the new TOGUnitTable-v1.scad library.
// - Still no magnet holes in the bottom lol sorry
// - No cup cavity, either!
// 9.1.8:
// - Configure block X/Y and Z sizes separately,
//   since it's inconvenient to specify them in the same units.

// Base unit; 1.5875mm = 1/16"
u = 1.5875; // 0.0001
atom_pitch_u = 8;
chunk_pitch_atoms = 3;
// X/Y block size, in chunks:
block_size_chunks = [2, 1];
// Block height, in 'u'
block_height_u    = 16;
magnet_hole_diameter = 6.2;
lip_height = 2.54;
foot_segmentation = "atom"; // ["atom","chunk"]

margin = 0.05; // 0.01

preview_fn = 12;
render_fn = 36;

$fn = $preview ? preview_fn : render_fn;

module tgx9__end_params() { }

use <../lib/TOGShapeLib-v1.scad>
use <../lib/TOGHoleLib-v1.scad>
use <../lib/TOGUnitTable-v1.scad>

function tgx9_map(arr, fn) = [ for(item=arr) fn(item) ];

$tgx9_mating_offset = -margin;
$tgx9_unit_table = [
	["um",    [    1,               "um"]],
	["mm",    [ 1000,               "um"]],
	["inch",  [25400,               "um"]],
	["u",     [u,                   "mm"]],
	["atom",  [atom_pitch_u,         "u"]],
	["chunk", [chunk_pitch_atoms, "atom"]],
	["m-outer-corner-radius", [4, "u"]],
	["f-outer-corner-radius", [3, "u"]],
];

// [x, y, offset_factor_x, offset_factor_y]
function tgx9_bottom_points(u, height, radius) =
let( height=max(height, 6*u) ) [
	[        0*u, 0*u,     0, -1  ],
	[-radius+1*u, 0*u,    -1, -1  ],
	[-radius+1*u, 1*u,    -1, -0.4],
	[-radius-2*u, 4*u,    -1, -0.4],
	[-radius-2*u, height, -1,  1  ],
	[        0*u, height,  0,  1  ],
];

function tgx9_offset_points(points, offset) = [
	for(p=points) [p[0]+offset*p[2], p[1]+offset*p[3]]
];

module tgx9_atom_foot(height=100, offset=0, radius) {
	rotate_extrude() {
		polygon(tgx9_offset_points(tgx9_bottom_points(u, height, radius), offset));
	}
}

// Here to mess with in case things need to be fattened a little bit
// in order to make CGAL happy.
// So far, so good with exact (rounding errors notwithstanding) matches.
epsilon     = 0; // 1/256; // of a millimiter
rot_epsilon = 0; // 1/ 16; // of a degree

module tgx9_smooth_chunk_foot(
	height       ,
	corner_radius,
	offset
) {
	chunk_pitch     = tog_unittable__divide_ca($tgx9_unit_table, [1, "chunk"], [1, "mm"]);
	u               = tog_unittable__divide_ca($tgx9_unit_table, [1, "u"], [1, "mm"]);
	corner_dist = chunk_pitch/2 - corner_radius;
	tgx9_extrude_along_loop([
		[-corner_dist, -corner_dist],
		[ corner_dist, -corner_dist],
		[ corner_dist,  corner_dist],
		[-corner_dist,  corner_dist],
	], rot_epsilon=rot_epsilon) polygon(tgx9_offset_points(tgx9_bottom_points(u=u, height=height, radius=corner_radius), offset));
	translate([0,0,height/2]) cube([
		chunk_pitch - corner_radius*2 + epsilon*2,
		chunk_pitch - corner_radius*2 + epsilon*2,
		height      +        offset*2 + epsilon*2
	], center=true);
}

module tgx9_atomic_chunk_foot(
	height = 100,
	offset = 0
) {
	u          = tog_unittable__divide_ca($tgx9_unit_table, [1,    "u"], [1, "mm"]);
	atom_pitch = tog_unittable__divide_ca($tgx9_unit_table, [1, "atom"], [1, "mm"]);
	for( xm=[-1,0,1] ) for( ym=[-1,0,1] ) {
		translate([xm*atom_pitch, ym*atom_pitch, 0]) tgx9_atom_foot(height=height, offset=offset, radius=atom_pitch/2);
	}
}

module tgx9_chunk_foot(
	segmentation = "chunk",
	corner_radius,
	height = 100,
	offset = 0
) {
	if( segmentation == "chunk" ) {
		tgx9_smooth_chunk_foot(height=height, corner_radius=corner_radius, offset=offset);
	} else if( segmentation == "atom" ) {
		assert(corner_radius == tog_unittable__divide_ca($tgx9_unit_table, [1/2, "atom"], [1, "mm"]));
		tgx9_atomic_chunk_foot(height=height, offset=offset);
	} else {
		assert(false, str("Unrecognized chunk foot segmentation: '", segmentation, "'"));
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

module tgx9_1_0_block_foot(
	block_size_ca,
	foot_segmentation,
	corner_radius,
	offset=0,
	chunk_ops=[]
) {
	atom_pitch  = atom_pitch_u * u;
	chunk_pitch = chunk_pitch_atoms * atom_pitch;

	block_size_chunks = tgx9_map(block_size_ca, function(ca) tog_unittable__divide_ca($tgx9_unit_table, ca, [1, "chunk"]));
	block_size        = tgx9_map(block_size_ca, function(ca) tog_unittable__divide_ca($tgx9_unit_table, ca, [1,    "mm"]));
	
	for( xm=[-block_size_chunks[0]/2+0.5 : 1 : block_size_chunks[0]/2-0.5] )
	for( ym=[-block_size_chunks[1]/2+0.5 : 1 : block_size_chunks[1]/2-0.5] )
		translate([xm*chunk_pitch, ym*chunk_pitch])
			difference() {
				union() {
					tgx9_chunk_foot(foot_segmentation, height=block_size[2]*2, corner_radius=corner_radius, offset=offset);
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

module tgx9_block_hull(block_size, corner_radius, offset=0) intersection() {
	tog_shapelib_xy_rounded_cube([
		block_size[0],
		block_size[1],
		block_size[2]*2,
	], corner_radius, offset=offset);
}

// An attempt at refactoring for some reason...
// Oh right, because I want this to have the cavity in it; everything but the foot.
module tgx9_1_6_cup_top(
	block_size_ca,
	lip_height,
	wall_thickness,
	floor_thickness,
	lip_subtraction_chunk_ops = [],
	floor_subtraction_chunk_ops = [],
) {
	block_size        = tgx9_map(block_size_ca, function(ca) tog_unittable__divide_ca($tgx9_unit_table, ca, [1,    "mm"]));
	corner_radius     = tog_unittable__divide_ca($tgx9_unit_table, [1, "f-outer-corner-radius"], [1, "mm"]);
	
	difference() {
		tgx9_block_hull(
			block_size = [
				block_size[0],
				block_size[1],
				block_size[2]+lip_height
			],
			corner_radius = corner_radius,
			offset = $tgx9_mating_offset
		);
		
		// Lip	
		translate([0,0,block_size[2]]) tgx9_1_0_block_foot(
			block_size_ca     = block_size_ca,
			foot_segmentation = "chunk",
			corner_radius = corner_radius,
			offset    = -$tgx9_mating_offset,
			chunk_ops = lip_subtraction_chunk_ops
		) children();
		
		// Cavity
		// TODO....
	}

	/*
	My original vision for this module:
	
	  block outer hull
	- lip
	- cavity

	cavity =
		  xy_rounded_cube
		+ floor subtraction?
		- sublip
		- fingerslide
	*/
}

module tgx9_1_6_cup(
	block_size_ca,
	lip_height        = 2.54,
	bottom_chunk_ops          = [],
	lip_subtraction_chunk_ops = []
) intersection() {
	// 'block foot' is *just* the bottom mating surface intersector
	tgx9_1_0_block_foot(
		block_size_ca     = block_size_ca,
		foot_segmentation = foot_segmentation,
		corner_radius     = tog_unittable__divide_ca($tgx9_unit_table, [1, "m-outer-corner-radius"], [1, "mm"]),
		offset            = $tgx9_mating_offset,
		chunk_ops         = bottom_chunk_ops
	) children();
	
	// 'cup top' is *everything else*
	tgx9_1_6_cup_top(
		block_size_ca     = block_size_ca,
		lip_height        = lip_height,
		lip_subtraction_chunk_ops = lip_subtraction_chunk_ops
	) children();
}

block_size_ca = [
	[block_size_chunks[0], "chunk"],
	[block_size_chunks[1], "chunk"],
	[block_height_u      ,     "u"],
];

tgx9_1_6_cup(
	block_size_ca = block_size_ca,
	lip_height    = lip_height,
	bottom_chunk_ops = [],
	lip_subtraction_chunk_ops = [["add",["child"]]]
) union() {
	atom_pitch = tog_unittable__divide_ca($tgx9_unit_table, [1, "atom"], [1, "mm"]);
	
	for( pos=[[-1,-1],[1,-1],[-1,1],[1,1]] ) {
		translate(pos*atom_pitch) cylinder(d=magnet_hole_diameter, h=4, center=true);
	}
	for( pos=[[0,-1],[-1,0],[0,1],[1,0],[0,0]] ) {
		translate(pos*atom_pitch) tog_holelib_hole("THL-1001");
	}
}
