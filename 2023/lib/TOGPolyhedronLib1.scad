// TOGPolyhedronLib1.1.2
// 
// v1.1:
// - tphl1_make_polyhedron_from_layer_function can take a list of inputs ('layer keys')
//   to the layer function as first argument as alternative to 'layer_count'
// v1.1.1:
// - Some assertions
// v1.1.2:
// - tphl1_make_polyhedron_from_layers: assert that all layers are the same length

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
