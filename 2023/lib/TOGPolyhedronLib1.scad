// TOGPolyhedronLib1.9
// 
// v1.1:
// - tphl1_make_polyhedron_from_layer_function can take a list of inputs ('layer keys')
//   to the layer function as first argument as alternative to 'layer_count'
// v1.1.1:
// - Some assertions
// v1.1.2:
// - tphl1_make_polyhedron_from_layers: assert that all layers are the same length
// v1.2:
// - tphl1_make_rounded_cuboid, which can also make spheres
// v1.2.1:
// - Refactor some assertions to use tal1_assert_for_each
// v1.3:
// - tphl1_make_rounded_cuboid: Special case to avoid extra triangles
//   when radii[2] == 0 (i.e. top and bottom are flat)
// v1.4:
// - Document correct winding order
// - Fix tphl1_make_rounded_cuboid to use correct winding order
// v1.5:
// - Add tphl1_make_z_cylinder
// v1.6:
// - Add tphl1_extrude_polypoints, which is basically a shorthand
//   for tphl1_make_polyhedron_from_layers
// v1.7:
// - tphl1_make_rounded_cuboid corner_shape parameter may be
//   'ellipsoid' (current behavior), or 'ovoid1' or 'ovoid2',
//   which effectively apply a spherical rounding to the top/bottom edges
// v1.8:
// - Fix `tphl1_faces` to mind `cap_top` and `cap_bottom`,
//   so you can make e.g. toruses.
// v1.9:
// - $tphl1_quad_split_direction can be set to "right" or "left"
//   to indicate whether quads should be split from lower-left to
//   upper-right ("right") or lower-right to upper-left ("left").
//   This may be useful when generating right or left-handed screw
//   threads, respectively.  Default is "right".

// Winding order:
// 
// tphl1_make_polyhedron_from_layers expects layers to be specified
// bottom-to-top, with points for each counter-clockwise when viewed
// from the top.  i.e. the first layer appears clockwise from outside,
// and the last layer counter-clockwise from outside.
// 
// OpenSCAD wants polyhedron faces to be defined in clockwise-when-seen-from-outside order,
// which is opposite the order that STL files expect.
// 
// If you make your faces counter-clockwise, your shape might
// be invisible in preview and need to be rendered to become visible.
// Use View > Thrown Together to show wrongly-oriented faces as purple.

function tphl1_cap_faces( layers, layerspan, li, reverse=false ) = [
	[for( vi=reverse ? [0 : 1 : layerspan-1] : [layerspan-1 : -1 : 0] ) (vi%layerspan)+layerspan*li]
];

// $tphl1_quad_split_direction determines whether
// quads are split from lower-left to upper-right ("right")
// or lower-right to upper-left ("left").

function tphl1__get_quad_split_direction() =
	is_undef($tphl1_quad_split_direction) ? "right" : $tphl1_quad_split_direction;

function tphl1_layer_faces( layers, layerspan, i ) =
assert(is_list(layers))
assert(is_num(layerspan))
assert(is_num(i))
let( l0 = i*layerspan )
let( l1 = (i+1)*layerspan )
tphl1__get_quad_split_direction() == "right" ? [
	for( vi=[0 : 1 : len(layers[i])-1] ) each [
		// By making triangles instead of quads,
		// we can avoid some avoidable 'non-planar face' warnings.
		[
			l0 + vi,
			l1 + (vi+1)%layerspan,
			l0 + (vi+1)%layerspan,
		],
		[
			l0 + vi,
			l1 + vi,
			l1 + (vi+1)%layerspan,
		],
	]
] : [
	for( vi=[0 : 1 : len(layers[i])-1] ) each [
		// By making triangles instead of quads,
		// we can avoid some avoidable 'non-planar face' warnings.
		[
			l0 + (vi+1)%layerspan,
			l1 + (vi+1)%layerspan,
			l1 + vi,
		],
		[
			l0 + (vi+1)%layerspan,
			l0 + vi,
			l1 + vi,
		],
	]
];

function tphl1_faces( layers, layerspan, cap_bottom=true, cap_top=true ) = [
	if( cap_bottom ) each tphl1_cap_faces( layers, layerspan, 0, reverse=true ),
	// For now, assume convex end caps
	for( li=[0 : 1 : len(layers)-2] ) each tphl1_layer_faces(layers, layerspan, li),
	if( cap_top ) each tphl1_cap_faces( layers, layerspan, len(layers)-1, reverse=false )
];

function tphl1_points(layers, layerspan) = [
	for( layer=layers ) for( point=layer ) point
];

function tphl1__remap_face_vertexes(faces, index_map) =
	assert(is_list(faces))
	assert(is_list(index_map))
[
	for( face=faces )
		let(face1=[
			// Remap
			for(vi=face)
			assert(is_num(vi))
			assert(vi < len(index_map))
			assert(is_num(index_map[vi]))
			index_map[vi]
		])
		let(face2=tal1_uniq(face1))
		each len(face2) >= 3 ? [face2] : []
];

use <./TOGArrayLib1.scad>

function tphl1_make_polyhedron_from_layers(layers, cap_bottom=true, cap_top=true) =
	assert(is_list(layers))
	assert(len(layers) >= 2)
	assert(is_list(layers[0]))
	let(minmax_layer_count = tal1_reduce([-9999999,9999999], layers, function(prev,layer) [max(prev[0],len(layer)), min(prev[1],len(layer))]))
	assert(minmax_layer_count[0] == minmax_layer_count[1],
		str("Layers differ in point count, from ", minmax_layer_count[0], " to ", minmax_layer_count[1]))
	let(points1 = tphl1_points(layers, len(layers[0])))
	let(faces1  = tphl1_faces(layers, len(layers[0]), cap_bottom=cap_bottom, cap_top=cap_top))
	let(vertex_remap_result = tal1_uniq_remap_v2(points1))
	let(points2 = vertex_remap_result[1])
	let(faces2 = tphl1__remap_face_vertexes(faces1, vertex_remap_result[2]))
	["polyhedron-vf", points2, faces2];

function tphl1_make_polyhedron_from_layer_function(layer_keys, layer_points_function, cap_bottom=true, cap_top=true) =
	let(indexes = is_num(layer_keys) ? [0:1:layer_keys-1] : is_list(layer_keys) ? layer_keys : assert(false, "Layer list must be number or list"))
	let(layers = [for(li=indexes) layer_points_function(li)])
	tphl1_make_polyhedron_from_layers(layers, cap_bottom=cap_bottom, cap_top=cap_top);

function tphl1__tovec3(vec, fromnum=[0,0,1]) =
	let( cev = is_list(vec) ? vec : is_num(vec) ? fromnum * vec : assert(false, str("Can't turn ", vec, " into vec3")) )
	len(cev) >= 3 ? cev :
	len(cev) == 2 ? [cev[0],cev[1],0] :
	len(cev) == 1 ? [cev[0],0,0] :
	[0,0,0];

function tphl1__add_z_or_vec(vec, z) =
	tphl1__tovec3(vec) + tphl1__tovec3(z);

assert([1,2,3] == tphl1__add_z_or_vec([1,2], 3));
assert([1,2,6] == tphl1__add_z_or_vec([1,2,3], 3));
assert([2,4,0] == tphl1__add_z_or_vec([1,2], [1,2]));
assert([2,4,3] == tphl1__add_z_or_vec([1,2], [1,2,3]));
assert([2,4,6] == tphl1__add_z_or_vec([1,2,3], [1,2,3]));

/**
 * Zrange can either be a list of Z values,
 * or [X,Y,Z] positions to offset points by for each layer.
 * Points may be 2D or 3D positions; if 2D, Z=0 is implied.
 */
function tphl1_extrude_polypoints(zrange, points) =
	tphl1_make_polyhedron_from_layers([
		for( z=zrange ) [ for(p=points) tphl1__add_z_or_vec(p, z) ]
	]);


use <./TOGMod1Constructors.scad>

/**
 * Since a single r, or even Vec3 r, cannot describe how all 12 edges should be rounded,
 * corner_shape provides additional information on how r should be interpreted for
 * top/bottom edges.  The default, 'ellipsoid', is the most symmetrical in its
 * treatment of the three axes.  'ovoid1' may be what you often actually
 * want when r[2] is smaller than r[0] and/or r[1].
 *
 * @param corner_shape
 *    "ellipsoid"  --  non-spherical corners are simply scaled spheres
 *    "ovoid1"     --  radius of left/right|front/back top/bottom edges are min(rx|ry, rz), respectively
 *    "ovoid2"     --  radius of top/bottom edges are rz
 */
function tphl1_make_rounded_cuboid(size, r, corner_shape="ellipsoid") =
	assert(tal1_is_vec_of_num(size, 3), "tphl1_make_rounded_cuboid: size should be a Vec3<Num>")
	let(radii = tal1_assert_for_each(
		is_list(r) ? r : is_num(r) ? [r, r, r] : assert(false, "r(adius) should be list<num> or num"),
		function(r,i) [
			is_num(r) && size[i] >= r*2,
			str("size[",i,"] must be >= 2*r[",i,"]; size[0] = ",size[i],", 2*r[",i,"] = ", 2*r)
		]
	))
	// zsubrad = how much to shrink layers at top/bottom
	let(zsubrad =
		corner_shape == "ellipsoid" ? radii :
		corner_shape == "ovoid1" ? [min(radii[0], radii[2]), min(radii[1], radii[2])] :
		corner_shape == "ovoid2" ? [radii[2], radii[2]] :
		assert(false, str("Unrecognized corner shape: '", corner_shape, "'"))
	)
	// Need to be consistent when asking for rounded rect points,
	// lest rounding errors give different results for different layers
	let(quarterfn = max(ceil($fn/4), 1))
	tphl1_make_polyhedron_from_layer_function(
		radii[2] == 0 ? [
			[-size[2]/2, 90],
			[ size[2]/2, 90],
		] : [
			for( zai=[0 : 1 : quarterfn] ) let(ang= 0 + zai*90/quarterfn) [-size[2]/2 + radii[2] - radii[2] * cos(ang), ang],
			for( zai=[0 : 1 : quarterfn] ) let(ang=90 + zai*90/quarterfn) [ size[2]/2 - radii[2] - radii[2] * cos(ang), ang]
		],
		function( z_za )
			let( z=z_za[0] )
			let( zang=z_za[1] )
			let( sinzang=sin(zang) )
			let( ideal_layer_corner_radii = [
				max(0, radii[0] + zsubrad[0]*(sinzang-1)),
				max(0, radii[1] + zsubrad[1]*(sinzang-1)),
			])
			let( layer_size = [
				size[0] + 2*zsubrad[0]*(sinzang-1),
				size[1] + 2*zsubrad[1]*(sinzang-1),
			])
			togmod1_rounded_rect_points(layer_size, r=ideal_layer_corner_radii /*[
				// In case there are rounding errors and adjustments become necessary:
				min(max(0,layer_size[0]/2 - 1/128), ideal_layer_corner_radius[0]),
				min(max(0,layer_size[1]/2 - 1/128), ideal_layer_corner_radius[1]),
			]*/, pos=[0,0,z_za[0]])
	);

function tphl1_make_z_cylinder(d=undef, zrange=undef, zds=undef) =
	let( _zds = !is_undef(zds) ? zds :
		assert(!is_undef(d))
		assert(!is_undef(zrange))
		[ for( z=zrange ) [z, d] ]
	)
	assert(!is_undef(_zds))
	tphl1_make_polyhedron_from_layer_function(_zds, function(zd) togmod1_circle_points(d=zd[1], pos=[0,0,zd[0]]));
