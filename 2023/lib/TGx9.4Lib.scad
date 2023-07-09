// v1.0
// - Created based on TGx9.3.3

use <../lib/TOGShapeLib-v1.scad>
use <../lib/TOGridPileLib-v3.scad>

function tgx9_map(arr, fn) = [ for(item=arr) fn(item) ];

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

function tgx9_cavity_side_profile_points(height, radius, bottom_bevel_size=1, top_bevel_width=3, top_bevel_height=0) =
let( tb=min(radius-0.2, top_bevel_width), bb=min(radius-0.1, bottom_bevel_size) )
let( tbh=max(tb, top_bevel_height) )
[
	[      0       ,      0    ,     0,   -1   ],
	[-radius+bb    ,      0    ,    -0.4, -1   ],
	[-radius       ,        bb ,    -1  , -0.4 ],
	[-radius       , height-tbh,    -1  ,  0.4 ],
	[-radius+tb    , height    ,    -1  ,  0.4 ],
	[-radius+tb    , height*2  ,    -1  ,  1   ],
	[      0       , height*2  ,     0  ,  1   ],
];

function tgx9_offset_points(points, offset=0) = [
	for(p=points) [p[0]+offset*p[2], p[1]+offset*p[3]]
];

function tgx9_rounded_rectangle_inner_path_points(size, rounding_radius) =
	let( adjusted_size = [
		size[0] - rounding_radius*2,
		size[1] - rounding_radius*2,
	] )
	[
		[-adjusted_size[0]/2, -adjusted_size[1]/2],
		[ adjusted_size[0]/2, -adjusted_size[1]/2],
		[ adjusted_size[0]/2,  adjusted_size[1]/2],
		[-adjusted_size[0]/2,  adjusted_size[1]/2]
	];

function tgx9_rounded_beveled_rectangle_inner_path_points(size, bevel_size, rounding_radius) =
	// 'X' and 'Y' below make sense when you're thinking of the two bottommost points.
	// Arc center Y inset is just the rounding radius
	// such that the circle is tangent to the edge of the rectangle.
	// Arc center X inset is such that the circle is tangent
	// to the bevel, which turns out to be bevel_size + (sqrt(2)-1)*rounding_radius:
	let( acy = rounding_radius, acx = bevel_size + 0.414*rounding_radius )
	[
		[-size[0]/2+acx, -size[1]/2+acy],
		[ size[0]/2-acx, -size[1]/2+acy],
		[ size[0]/2-acy, -size[1]/2+acx],
		[ size[0]/2-acy,  size[1]/2-acx],
		[ size[0]/2-acx,  size[1]/2-acy],
		[-size[0]/2+acx,  size[1]/2-acy],
		[-size[0]/2+acy,  size[1]/2-acx],
		[-size[0]/2+acy, -size[1]/2+acx],
	 ];

function tgx9_minimum_rounding_radius_fitting_inside_bevel(bevel_size) =
	bevel_size / (2 - sqrt(2));
// (/ 0.125 (- 2 1.414)) = 0.21 ~= (/ 13 64.0), which seems about right; between 3/16" and 1/4"

// Returns [rounding_radius assumed by the path, path point list]
// of the 'inner path' for either a rounded rectangle,
// or if that rounded rectangle would not fit entirely within the
// beveled rectangle (with standard bevel size; maybe that should be passed in separately idk),
// for the beveled rectangle with minimum rounding radius such that it
// the offset result fits within both the beveled and rounded (by the requested rounding radius)
// rectangles.
function tgx9_block_hull_extrusion_path_info(
	size,
	bevel_size = togridpile3_decode([1, "tgp-standard-bevel"]),
	rounding_radius
) =
	let( inch = togridpile3_decode([1, "inch"]) )
	let( rb_mult = 2.5 ) // TODO: The trigonometry to calculate this value exactly; but 2.5 is a nice round upper limit
	$tgx9_force_bevel_rounded_corners && rounding_radius < tgx9_minimum_rounding_radius_fitting_inside_bevel(bevel_size) ?
		[5/32*inch, tgx9_rounded_beveled_rectangle_inner_path_points( size, bevel_size, rb_mult * (rounding_radius-bevel_size) )] :
		[rounding_radius, tgx9_rounded_rectangle_inner_path_points( size, rounding_radius )];

module tgx9_atom_foot(height=100, offset=0, radius) {
	rotate_extrude() {
		polygon(tgx9_offset_points(tgx9_bottom_points(u, height, radius), offset));
	}
}

// Extrude children() along the outside of path, and fill the inside with an extruded polygon
module tgx9_filled_extruded_path(inner_path, z0, z1) {
	// Here to mess with in case things need to be fattened a little bit
	// in order to make CGAL happy.
	// So far, so good with exact (rounding errors notwithstanding) matches,
	// though adding some overlap seems to clean up the preview somewhat.
	epsilon     = $preview ? 0.001 : 0; // 1/256; // of a millimiter
	rot_epsilon = $preview ? 0.001 : 0; // 1/ 16; // of a degree
	polygon_fill_epsilon = 0.001;
	
	tgx9_extrude_along_loop(inner_path, rot_epsilon=rot_epsilon) children();
	// TODO: Offset the points instead of scaling
	// Note: When, in TGx9.1.13, this was done using a cube, epsilon=0 seemed to do the job;
	// switching from cube to extruded polygon seems to result in a zero-width wall around betwen
	// the fill and the horizontally-extruded edges.
	translate([0,0,z0]) scale([1+polygon_fill_epsilon, 1+polygon_fill_epsilon, 1])
		linear_extrude(z1-z0, center=false) polygon(inner_path);
}

// Old fashioned, never-bevels-the-corners version.
// Might be worth refactoring to use cubes instead of
// extruded polygons for the center fill, since th....
module tgx9_rounded_profile_extruded_square(size, corner_radius, z_offset) {
	assert( is_list(size) );
	assert( len(size) == 3 );
	assert( is_num(size[0]) );
	assert( is_num(size[1]) );
	assert( is_num(size[2]) );
	assert( is_num(corner_radius) );
	assert( is_num(z_offset) );
	
	inner_path = tgx9_rounded_rectangle_inner_path_points(size, rounding_radius=corner_radius);
	tgx9_filled_extruded_path(inner_path, z_offset, z_offset+size[2]) children();
}

module tgx9_smooth_foot(
	size         ,
	corner_radius,
	offset
) {
	u = togridpile3_decode([1, "u"]);

	if( $tgx9_force_bevel_rounded_corners == false ) {
		// Redundant; tgx9_block_hull_extrusion_path_info would take care of it;
		// this is here to make sure tgx9_rounded_profile_extruded_square still works,
		// in case I want to keep it around for *shrug* reasons.
		tgx9_rounded_profile_extruded_square([size[0], size[1], size[2]+offset*2], corner_radius=corner_radius, z_offset=-offset)
			polygon(tgx9_offset_points(tgx9_bottom_points(u=u, height=size[2], radius=corner_radius), offset));
	} else {
		path_info = tgx9_block_hull_extrusion_path_info(size, rounding_radius=corner_radius);
		tgx9_filled_extruded_path(path_info[1], -offset, size[2]+offset)
			polygon(tgx9_offset_points(tgx9_bottom_points(u=u, height=size[2], radius=path_info[0]), offset));
	}
}

module tgx9_smooth_chunk_foot(
	height       ,
	corner_radius,
	offset
) {
	chunk_pitch     = togridpile3_decode([1, "chunk"]);
	tgx9_smooth_foot([chunk_pitch, chunk_pitch, height], corner_radius=corner_radius, offset=offset);
}

module tgx9_atomic_chunk_foot(
	height = 100,
	offset = 0
) {
	u          = togridpile3_decode([1,    "u"]);
	atom_pitch = togridpile3_decode([1, "atom"]);
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
		assert(corner_radius == togridpile3_decode([1/2, "atom"]));
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

use <../lib/TGX1001.scad>

// Shapes are a subset of S-Values
module tgx9_do_sshape(shape) {
	assert( is_list(shape), str("shape passed to tgx9_do_sshape should be represented as a list, but got ", shape) );
	assert( len(shape) > 0 );
	type = shape[0];
	if( type == "child" ) {
		children(0);
	} else if( type == "translate" ) {
		translate(shape[1]) tgx9_do_sshape(shape[2]);
	} else if( type == "the_cup_cavity" ) {
		the_cup_cavity();
	} else if( type == "tgx9_usermod_1" ) {
		tgx9_usermod_1(len(shape) > 1 ? shape[1] : undef, len(shape) > 2 ? shape[2] : undef);
	} else if( type == "tgx9_usermod_2" ) {
		tgx9_usermod_2(len(shape) > 1 ? shape[1] : undef, len(shape) > 2 ? shape[2] : undef);
	} else if( type == "tgx1001_v6hc_block_subtractor" ) {
		assert(len(shape) >= 2, "tgx1001_v6hc_block_subtractor requires block_size_ca parameter");
		assert(len(shape[1]) >= 2, "tgx1001_v6hc_block_subtractor requires block_size_ca parameter");
		render(10) tgx1001_v6hc_block_subtractor(
			block_size_ca = shape[1],
			unit_table    = $togridpile3_unit_table,
			offset        = margin
		);
	} else {
		assert(false, str("Unrecognized S-shape type: '", type, "'"));
	}
}

function tgx9_chunk_xy_positions(block_size_chunks) =
	let( chunk_pitch = togridpile3_decode([1, "chunk"]) )
[
	for( xm=[-block_size_chunks[0]/2+0.5 : 1 : block_size_chunks[0]/2] )
		for( ym=[-block_size_chunks[1]/2+0.5 : 1 : block_size_chunks[1]/2] )
			[xm*chunk_pitch, ym*chunk_pitch]
];

function tgx9_decode_corner_radius(spec) =
	is_num(spec) ? spec :
	spec == "f" ? togridpile3_decode([1, "f-outer-corner-radius"]) :
	spec == "m" ? togridpile3_decode([1, "m-outer-corner-radius"]) :
	togridpile3_decode(spec);

module tgx9_block_chunk_ops(
	block_size_ca,
	chunk_ops=[]
) {
	block_size_chunks = togridpile3_decode_vector(block_size_ca, unit=[1, "chunk"]);
	// This currently doesn't subtract anything because I don't yet need it to.
	for( pos=tgx9_chunk_xy_positions(block_size_chunks) ) translate(pos) {
		for( i=[0 : 1 : len(chunk_ops)-1] ) {
			op = chunk_ops[i];
			if( op[0] == "add" ) tgx9_do_sshape(op[1]) children();
		}
	}
}

module tgx9_block_foot(
	block_size_ca,
	foot_segmentation,
	corner_radius,
	offset=0,
	chunk_ops=[]
) {
	assert( !is_undef(block_size_ca) );
	assert( !is_undef(foot_segmentation) );
	assert( !is_undef(corner_radius) );

	corner_radius = tgx9_decode_corner_radius(corner_radius);

	atom_pitch  = togridpile3_decode([1, "atom"]);
	chunk_pitch = togridpile3_decode([1, "chunk"]);

	block_size_chunks = togridpile3_decode_vector(block_size_ca, unit=[1, "chunk"]);
	block_size        = tgx9_map(block_size_ca, function(ca) togridpile3_decode(ca));
	dh_block_size = [block_size[0], block_size[1], block_size[2]*2];

	if( foot_segmentation == "none" ) {
		translate([0, 0, block_size[2]]) cube([block_size[0]*2, block_size[1]*2, block_size[2]*2], center=true);
		tgx9_block_chunk_ops(block_size_ca, chunk_ops);
	} else if( foot_segmentation == "block" ) {
		tgx9_smooth_foot(dh_block_size, corner_radius=corner_radius, offset=offset);
		tgx9_block_chunk_ops(block_size_ca, chunk_ops);
	} else {
		// Underside cleavage comes up much higher than necessary
		// in between chunks/atoms; put a cube there to fill it in.
		difference() {
			union() {
				body_inset = togridpile3_decode([2, "u"]);
				underside_filler_thickness = togridpile3_decode([4, "u"]); // shrug
				translate([0,0,body_inset+underside_filler_thickness/2-offset]) cube([
					block_size[0]-atom_pitch,
					block_size[1]-atom_pitch,
					underside_filler_thickness
				], center=true);
				
				for( pos=tgx9_chunk_xy_positions(block_size_chunks) ) translate(pos) {
					tgx9_chunk_foot(foot_segmentation, height=block_size[2]*2, corner_radius=corner_radius, offset=offset);
					for( i=[0 : 1 : len(chunk_ops)-1] ) {
						op = chunk_ops[i];
						if( op[0] == "add" ) tgx9_do_sshape(op[1]) children();
					}
				}
			}
			
			for( pos=tgx9_chunk_xy_positions(block_size_chunks) ) translate(pos) {
				for( i=[0 : 1 : len(chunk_ops)-1] ) {
					op = chunk_ops[i];
					if( op[0] == "subtract" ) tgx9_do_sshape(op[1]) children();
				}
			}
		}
	}
}

module tgx9_block_hull(block_size, corner_radius, offset=0) intersection() {
	linear_extrude(block_size[2]*2 + offset*2, center=true) {
		path_info = tgx9_block_hull_extrusion_path_info(block_size, rounding_radius=corner_radius);
		hull() {
			for( pos=path_info[1] ) translate(pos) circle(r=path_info[0]+offset);
		}
	}
	/*
	tog_shapelib_xy_rounded_cube([
		block_size[0],
		block_size[1],
		block_size[2]*2,
	], corner_radius, offset=offset);
	*/
}

function tgx9_invert_op(op) =
	op[0] == "add" ? ["subtract", op[1]] :
	op[0] == "subtract" ? ["add", op[1]] :
	op; // Meh
function tgx9_invert_ops(ops) = tgx9_map(ops, function (op) tgx9_invert_op(op));

// Outer hull, lip, cavity.
// Everything except the foot.
// Intersect with a foot to make a full block.
module tgx9_cup_top(
	block_size_ca,
	foot_segmentation,
	lip_height,
	wall_thickness,
	floor_thickness,
	lip_chunk_ops = [],
	block_top_ops = [],
) {
	block_size        = tgx9_map(block_size_ca, function(ca) togridpile3_decode(ca));
	corner_radius     = togridpile3_decode([1, "f-outer-corner-radius"]);
	
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
		translate([0,0,block_size[2]]) tgx9_block_foot(
			block_size_ca     = block_size_ca,
			foot_segmentation = lip_segmentation,
			corner_radius = corner_radius,
			offset    = -$tgx9_mating_offset,
			chunk_ops = tgx9_invert_ops(lip_chunk_ops)
		) children();
		
		// Cavity
		// translate([0,0,block_size[2]]) the_cup_cavity();

		translate([0,0,block_size[2]]) {
			for( op=block_top_ops ) if(op[0] == "subtract") tgx9_do_sshape(op[1]);
		}
	}

	translate([0,0,block_size[2]]) {
		for( op=block_top_ops ) if(op[0] == "add") tgx9_do_sshape(op[1]);
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

module tgx9_cup(
	block_size_ca,
	foot_segmentation = "chunk",
	wall_thickness,
	floor_thickness,
	lip_height        = 2.54,
	bottom_chunk_ops          = [],
	lip_chunk_ops = [],
	// floor_chunk_ops = []
	block_top_ops = [],
) intersection() {
	// 'block foot' is *just* the bottom mating surface intersector
	tgx9_block_foot(
		block_size_ca     = block_size_ca,
		foot_segmentation = foot_segmentation,
		corner_radius     = togridpile3_decode([1, "m-outer-corner-radius"]),
		offset            = $tgx9_mating_offset,
		chunk_ops         = bottom_chunk_ops
	) children();
	
	// 'cup top' is *everything else*
	tgx9_cup_top(
		block_size_ca     = block_size_ca,
		foot_segmentation = foot_segmentation,
		lip_height        = lip_height,
		wall_thickness    = wall_thickness,
		floor_thickness   = floor_thickness,
		// floor_chunk_ops   = floor_chunk_ops
		block_top_ops     = block_top_ops,
		lip_chunk_ops     = lip_chunk_ops
	) children();
}
