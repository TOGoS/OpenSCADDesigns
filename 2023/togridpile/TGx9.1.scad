// TGx9.1.13.1 - experimental simplified (for OpenSCAD rendering purposes) TOGridPile shape
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
// 9.1.9:
// - Cavity!
// - Add an ad hoc, informally-specified, bug-ridden, slow implementation of lisp,
//   then comment most of it out.
// - Add more types of shapes that tgx9_do_sshape (formerly tgx9_do_module) can do:
//   - translate, the_cup_cavity, tgx9_usermod_1, and tgx9_usermod_2!
// 9.1.10:
// - Give cavity beveled corners using extrude_along_loop technology
// 9.1.11:
// - Make 'label magnet holes' separate from 'top magnet holes' to avoid
//   extraneous cuts into the lip
// 9.1.12:
// - lip_segmentation = "block"|"chunk".
// 9.1.13:
// - Support foot chunk additions when segmentation="block"
// 9.1.13.1:
// - Fix a tab lmao

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
foot_segmentation = "chunk"; // ["atom","chunk","block"]
lip_segmentation = "block"; // ["chunk","block"]

/* [Connectors] */

bottom_magnet_holes_enabled = true;
label_magnet_holes_enabled = true;
top_magnet_holes_enabled = true;
screw_hole_style = "THL-1001"; // ["none","THL-1001","THL-1002"]

/* [Cavity] */

wall_thickness = 2;
floor_thickness = 6.35; // 0.0001
label_width = 12.5;
fingerslide_radius = 12.5;
cavity_bulkhead_positions = [];
cavity_bulkhead_axis = "x"; // ["x", "y"]

margin = 0.075; // 0.001

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

block_size_ca = [
	[block_size_chunks[0], "chunk"],
	[block_size_chunks[1], "chunk"],
	[block_height_u      ,     "u"],
];
block_size = tgx9_map(block_size_ca, function (ca) tog_unittable__divide_ca($tgx9_unit_table, ca, [1, "mm"]));

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

function tgx9_cavity_side_profile_points(height, radius, bottom_bevel_size=1, top_bevel_size=3) =
let( tb=min(radius-0.2, top_bevel_size), bb=min(radius-0.1, bottom_bevel_size) )
[
	[      0       ,      0    ,     0,   -1   ],
	[-radius+bb    ,      0    ,    -0.4, -1   ],
	[-radius       ,        bb ,    -1  , -0.4 ],
	[-radius       , height-tb ,    -1  ,  0.4 ],
	[-radius+tb    , height    ,    -1  ,  0.4 ],
	[-radius+tb    , height*2  ,    -1  ,  1   ],
	[      0       , height*2  ,     0  ,  1   ],
];

function tgx9_offset_points(points, offset=0) = [
	for(p=points) [p[0]+offset*p[2], p[1]+offset*p[3]]
];

module tgx9_atom_foot(height=100, offset=0, radius) {
	rotate_extrude() {
		polygon(tgx9_offset_points(tgx9_bottom_points(u, height, radius), offset));
	}
}

// Here to mess with in case things need to be fattened a little bit
// in order to make CGAL happy.
// So far, so good with exact (rounding errors notwithstanding) matches,
// though adding some overlap seems to clean up the preview somewhat.
epsilon     = $preview ? 0.001 : 0; // 1/256; // of a millimiter
rot_epsilon = $preview ? 0.001 : 0; // 1/ 16; // of a degree

module tgx9_rounded_profile_extruded_square(size, corner_radius, z_offset) {
	assert( is_list(size) );
	assert( len(size) == 3 );
	assert( is_num(size[0]) );
	assert( is_num(size[1]) );
	assert( is_num(size[2]) );
	assert( is_num(corner_radius) );
	assert( is_num(z_offset) );
	adjusted_size = [
	  size[0] - corner_radius*2,
	  size[1] - corner_radius*2,
	  size[2]
	];
	tgx9_extrude_along_loop([
		[-adjusted_size[0]/2, -adjusted_size[1]/2],
		[ adjusted_size[0]/2, -adjusted_size[1]/2],
		[ adjusted_size[0]/2,  adjusted_size[1]/2],
		[-adjusted_size[0]/2,  adjusted_size[1]/2],
	], rot_epsilon=rot_epsilon) children();
	translate([0,0,adjusted_size[2]/2+z_offset]) cube([
		adjusted_size[0] + epsilon*2,
		adjusted_size[1] + epsilon*2,
		adjusted_size[2]
	], center=true);	
}

module tgx9_smooth_foot(
	size         ,
	corner_radius,
	offset
) {
	u               = tog_unittable__divide_ca($tgx9_unit_table, [1, "u"], [1, "mm"]);
	tgx9_rounded_profile_extruded_square([size[0], size[1], size[2]+offset*2], corner_radius=corner_radius, z_offset=-offset)
		polygon(tgx9_offset_points(tgx9_bottom_points(u=u, height=size[2], radius=corner_radius), offset));
}


module tgx9_smooth_chunk_foot(
	height       ,
	corner_radius,
	offset
) {
	chunk_pitch     = tog_unittable__divide_ca($tgx9_unit_table, [1, "chunk"], [1, "mm"]);
	tgx9_smooth_foot([chunk_pitch, chunk_pitch, height], corner_radius=corner_radius, offset=offset);
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

// SValues: ('S' for 'S-expression', I guess)
// - ["literal", v] - the literal OpenSCAD value, v
// - ["list", ...] - a list of values, each of which is also an SValue
// - ["translate", translation, shape] - a shape defined by translating another shape
// - ["module", name, args...] - a shape defined by a named module and literal arguments to it
// - ["lambda", ...] - whoa let's not get carried away

// Turns out I don't [yet] need to evaluate expressions;
// I just needed a way to represent shapes!
/*
function tgx9_unwrap_svalue(svalue) =
	assert( is_list(svalue) ) 
	assert( len(svalue) > 0 )
	svalue[0] == "literal" ? svalue[1] :
	assert(false, str("Unwrapping of S-Value type ", svalue[0], " not [yet] implemented"));

function tgx9_eval_funcapp(expression) =
	assert( is_list(expression) ) 
	assert( len(expression) > 0 )
	let( func = tgx9_eval_expression(expression[0]) )
	assert( is_string(func) ) // Until I implement 'lambda', roffle
	func == "quote" ? assert(len(expression) == 2) ["literal", expression[1]] :
	func == "list" ? ["list", for(i=[1:1:len(expression)-1]) tgx9_eval_expression(expression[i])] :
	func == "translate" ? ["translate", tgx9_unwrap_svalue(tgx9_eval_expression(expression[1])), tgx9_eval_expression(expression[2])] : 
	assert(false, str("Unrecognized function, '", func, "'"));

function tgx9_eval_expression(expression) =
	is_list(expression) ? tgx9_eval_funcapp(expression) :
	["literal", expression];
*/

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
		tgx9_usermod_1(len(shape) > 1 ? shape[1] : undef);
	} else if( type == "tgx9_usermod_2" ) {
		tgx9_usermod_2(len(shape) > 1 ? shape[1] : undef);
	} else {
		assert(false, str("Unrecognized S-shape type: '", type, "'"));
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
	dh_block_size = [block_size[0], block_size[1], block_size[2]*2];

	if( foot_segmentation == "block" ) {
		tgx9_smooth_foot(dh_block_size, corner_radius=corner_radius, offset=offset);
		// TODO: Support chunk subtractions, here
		
		for( xm=[-block_size_chunks[0]/2+0.5 : 1 : block_size_chunks[0]/2-0.5] )
		for( ym=[-block_size_chunks[1]/2+0.5 : 1 : block_size_chunks[1]/2-0.5] )
		translate([xm*chunk_pitch, ym*chunk_pitch])
		{
			for( i=[0 : 1 : len(chunk_ops)-1] ) {
				op = chunk_ops[i];
				if( op[0] == "add" ) tgx9_do_sshape(op[1]) children();
			}
		}
	} else {
		for( xm=[-block_size_chunks[0]/2+0.5 : 1 : block_size_chunks[0]/2-0.5] )
		for( ym=[-block_size_chunks[1]/2+0.5 : 1 : block_size_chunks[1]/2-0.5] )
		translate([xm*chunk_pitch, ym*chunk_pitch])
		{
			difference() {
				union() {
					tgx9_chunk_foot(foot_segmentation, height=block_size[2]*2, corner_radius=corner_radius, offset=offset);
					for( i=[0 : 1 : len(chunk_ops)-1] ) {
						op = chunk_ops[i];
						if( op[0] == "add" ) tgx9_do_sshape(op[1]) children();
					}
				}
				
				for( i=[0 : 1 : len(chunk_ops)-1] ) {
					op = chunk_ops[i];
					if( op[0] == "subtract" ) tgx9_do_sshape(op[1]) children();				
				}
			}
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

//// Cavity stuff

cavity_size = [
	block_size[0] - wall_thickness*2 + $tgx9_mating_offset*2,
	block_size[1] - wall_thickness*2 + $tgx9_mating_offset*2,
	block_size[2] - floor_thickness
];

cs1 = [cavity_size[0]+0.1, cavity_size[1]+0.1]; // For sticking things in the walls

module the_sublip() {
	sublip_width = 2;
	sublip_angwid = sublip_width/sin(45);
	sublip_angwid2 = sublip_angwid*2*1.414;
	for(xm=[-1,1]) translate([xm*cs1[0]/2, 0, 0]) rotate([0,45,0])
		cube([sublip_angwid,block_size[1],sublip_angwid], center=true);
	for(ym=[-1,1]) translate([0, ym*cs1[1]/2, 0]) rotate([45,0,0])
		cube([block_size[0],sublip_angwid,sublip_angwid], center=true);
	for(ym=[-1,1]) for(xm=[-1,1]) translate([xm*cs1[0]/2, ym*cs1[1]/2, 0]) rotate([0,0,ym*xm*45]) rotate([0,45,0])
		cube([sublip_angwid2,sublip_angwid2,sublip_angwid2], center=true);
}

module the_label_platform() {
	if( label_width > 0 ) {
		label_angwid = label_width*2*sin(45);
		translate([-cs1[0]/2, 0, 0]) rotate([0,45,0]) cube([label_angwid,block_size[1],label_angwid], center=true);
	}
}

module the_fingerslide() {
	if( fingerslide_radius > 0 ) difference() {
		translate([cavity_size[0]/2, 0, 0])
			cube([fingerslide_radius*2, cavity_size[1]*2, fingerslide_radius*2], center=true);
		translate([cavity_size[0]/2-fingerslide_radius, 0, fingerslide_radius])
			rotate([90,0,0]) cylinder(r=fingerslide_radius, h=cavity_size[1]*3, center=true, $fn=max(24,$fn));
	}
}

function kasjhd_swapxy(vec, swap=true) = [
	swap ? vec[1] : vec[0],
	swap ? vec[0] : vec[1],
	for( i=[2:1:len(vec)-1] ) vec[i]
];

module the_cup_cavity() if(cavity_size[2] > 0) difference() {
	outer_corner_radius     = tog_unittable__divide_ca($tgx9_unit_table, [1, "f-outer-corner-radius"], [1, "mm"]);
	cavity_corner_radius    = outer_corner_radius - wall_thickness;
	// Double-height cavity size, to cut through any lip protrusions, etc:
	dh_cavity_size = [cavity_size[0], cavity_size[1], cavity_size[2]*2];
	//tog_shapelib_xy_rounded_cube(dh_cavity_size, corner_radius=cavity_corner_radius);
	translate([0,0,-cavity_size[2]])
		tgx9_rounded_profile_extruded_square(dh_cavity_size, cavity_corner_radius, z_offset=0)
			polygon(tgx9_offset_points(tgx9_cavity_side_profile_points(cavity_size[2], cavity_corner_radius)));
	
	// the_sublip();
	the_label_platform();
	translate([0,0,-cavity_size[2]]) the_fingerslide();
	for( i=cavity_bulkhead_positions ) {
		maybeswapxy = cavity_bulkhead_axis == "x" ? function(v) kasjhd_swapxy(v) : function(v) v;
		bulkhead_length = cavity_bulkhead_axis == "x" ? block_size[0] : block_size[1];
		translate(maybeswapxy([i,0,0])) cube(maybeswapxy([wall_thickness, bulkhead_length, block_size[2]*2]), center=true);
	}
}

function tgx9_invert_op(op) =
	op[0] == "add" ? ["subtract", op[1]] :
	op[0] == "subtract" ? ["add", op[1]] :
	op; // Meh
function tgx9_invert_ops(ops) = tgx9_map(ops, function (op) tgx9_invert_op(op));

// An attempt at refactoring for some reason...
// Oh right, because I want this to have the cavity in it; everything but the foot.
module tgx9_1_6_cup_top(
	block_size_ca,
	lip_height,
	wall_thickness,
	floor_thickness,
	lip_chunk_ops = [],
	block_top_ops = [],
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

module tgx9_1_6_cup(
	block_size_ca,
	wall_thickness,
	floor_thickness,		
	lip_height        = 2.54,
	bottom_chunk_ops          = [],
	lip_chunk_ops = [],
	// floor_chunk_ops = []
	block_top_ops = [],
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
		wall_thickness    = wall_thickness,
		floor_thickness   = floor_thickness,		
		// floor_chunk_ops   = floor_chunk_ops
		block_top_ops     = block_top_ops,
		lip_chunk_ops     = lip_chunk_ops
	) children();
}

//// The Top-Level Program

if( false ) undefined_module(); // Doesn't crash OpenSCAD

// effective_floor_thickness = min(floor_thickness, block_size[2]);

atom_pitch  = tog_unittable__divide_ca($tgx9_unit_table, [1, "atom"], [1, "mm"]);
chunk_pitch = tog_unittable__divide_ca($tgx9_unit_table, [1, "chunk"], [1, "mm"]);

module tgx9_usermod_1(what) {
	if( what == "chunk-magnet-holes" ) {
		for( pos=[[-1,-1],[1,-1],[-1,1],[1,1]] ) {
			translate(pos*atom_pitch) cylinder(d=magnet_hole_diameter, h=4, center=true);
		}
	} else if( what == "chunk-screw-holes" ) {
		for( pos=[[0,-1],[-1,0],[0,1],[1,0],[0,0]] ) {
			translate(pos*atom_pitch) tog_holelib_hole(screw_hole_style);
		}
	} else if( what == "label-magnet-holes" ) {
		for( xm=[-block_size_chunks[0]/2+0.5] )
		for( ym=[-block_size_chunks[1]/2+0.5 : 1 : block_size_chunks[1]/2] ) {
			translate([xm*chunk_pitch, ym*chunk_pitch, 0])
			for( pos=[[-1,-1],[-1,1]] ) {
				translate(pos*atom_pitch) cylinder(d=magnet_hole_diameter, h=4, center=true);
			}
		}
	} else {
		assert(false, str("Unrecognized user module argument: '", what, "'"));
	}
}

tgx9_1_6_cup(
	block_size_ca = block_size_ca,
	lip_height    = lip_height,
	floor_thickness = floor_thickness,
	wall_thickness = wall_thickness,
	block_top_ops = [
		if( floor_thickness < block_size[2]) ["subtract",["the_cup_cavity"]],
		if( label_magnet_holes_enabled ) ["subtract",["tgx9_usermod_1", "label-magnet-holes"]],
	],
	lip_chunk_ops = [
		if( top_magnet_holes_enabled ) ["subtract",["tgx9_usermod_1", "chunk-magnet-holes"]]
	],
	bottom_chunk_ops = [
		["subtract",["translate", [0, 0, floor_thickness], ["tgx9_usermod_1", "chunk-screw-holes"]]],
		if( bottom_magnet_holes_enabled ) ["subtract",["tgx9_usermod_1", "chunk-magnet-holes"]],
	]
);
