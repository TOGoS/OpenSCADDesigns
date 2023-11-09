// TOGPolyhedronLib1.3
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

function tphl1_cap_faces( layers, layerspan, li, reverse=false ) = [
	[for( vi=reverse ? [layerspan-1 : -1 : 0] : [0 : 1 : layerspan-1] ) (vi%layerspan)+layerspan*li]
];

function tphl1_layer_faces( layers, layerspan, i ) =
assert(is_list(layers))
assert(is_num(layerspan))
assert(is_num(i))
let( l0 = i*layerspan )
let( l1 = (i+1)*layerspan )
[
	for( vi=[0 : 1 : len(layers[i])-1] ) each [
		// By making triangles instead of quads,
		// we can avoid some avoidable 'non-planar face' warnings.
		[
			l0 + vi,
			l0 + (vi+1) % layerspan,
			l1 + (vi+1)%layerspan,
		],
		[
			l0 + vi,
			l1 + (vi+1)%layerspan,
			l1 + vi
		],
	]
];

function tphl1_faces( layers, layerspan, cap_bottom=true, cap_top=true ) = [
	each tphl1_cap_faces( layers, layerspan, 0, reverse=true ),
	// For now, assume convex end caps
	for( li=[0 : 1 : len(layers)-2] ) each tphl1_layer_faces(layers, layerspan, li),
	each tphl1_cap_faces( layers, layerspan, len(layers)-1, reverse=false )
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

use <./TOGMod1Constructors.scad>

function tphl1_make_rounded_cuboid(size, r) =
	assert(tal1_is_vec_of_num(size, 3), "tphl1_make_rounded_cuboid: size should be a Vec3<Num>")
	let(radii = tal1_assert_for_each(
		is_list(r) ? r : is_num(r) ? [r, r, r] : assert(false, "r(adius) should be list<num> or num"),
		function(r,i) [
			is_num(r) && size[i] >= r*2,
			str("size[",i,"] must be >= 2*r[",i,"]; size[0] = ",size[i],", 2*r[",i,"] = ", 2*r)
		]
	))
	// Need to be consistent when asking for rounded rect points,
	// lest rounding errors give different results for different layers
	let(is_semicircle_x = size[0] == radii[0]*2)
	let(is_semicircle_y = size[1] == radii[1]*2)
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
			let( lrx=radii[0]*sinzang )
			let( lry=radii[1]*sinzang )
			togmod1_rounded_rect_points([
				// max() to avoid failure due to rounding error
				is_semicircle_x ? 2*lrx : size[0]+radii[0]*2*(sinzang-1),
				is_semicircle_y ? 2*lry : size[1]+radii[1]*2*(sinzang-1),
			], r=[
				lrx,
				lry,
			], pos=[0,0,z_za[0]])
	);
