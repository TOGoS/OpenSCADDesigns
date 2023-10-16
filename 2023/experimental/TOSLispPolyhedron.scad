// Plan:
// 1. [ ] Write in OpenSCAD
// 2. [ ] Iteratively translate to TOSLisp
// 3. [ ] Export to lisp
// 4. [ ] Compile lisp back to TOSLisp
// 5. [ ] Compile lisp directly to OpenSCAD

// The vertices should be in counter-clockwise order when the vertices
// are viewed from outside of the object. (Obviously, viewing from
// inside the object they are then in clockwise order).
// -- https://stackoverflow.com/questions/8715822/triangle-vertex-winding-order-in-stereolithography-stl-files-triangulated-obj
//
// Let's assume layers are defined as follows:
// - Layers are listed bottom-to-top (-Z to +Z)
// - Layer vertexes are lister counter-clockwise
//   when viewed from the top (e.g. +X, +Y, -X, -Y)

function polygen_cap_faces( layers, layerspan, li ) = [
	[for( vi=[0 : 1 : layerspan-1] ) vi+layerspan*li]
]; // TODO

function polygen_layer_faces( layers, layerspan, i ) = [
	for( vi=[0 : 1 : len(layers[i])-1] ) [vi, (vi+1) % layerspan, (vi+1)%layerspan + layerspan, vi+layerspan] // TODO: Triangles
];

function reverse_list( list ) = [for(i=[len(list)-1 : -1 : 0]) list[i]];

function polygen_faces( layers, layerspan ) = [
	each reverse_list(polygen_cap_faces( layers, layerspan, 0 )), // TODO: Reverse this one
	// For now, assume convex end caps
	for( li=[0 : 1 : len(layers)-2] ) each polygen_layer_faces(layers, layerspan, li),
	each polygen_cap_faces( layers, layerspan, len(layers)-1 )
];

function polygen_points(layers, layerspan) = [
	for( layer=layers ) for( point=layer ) point
];

polytest_layers = [
	[[-1, 1,-1], [-1, -1, -1], [ 1,  0, -1]],
	[[-1, 1, 1], [-1, -1,  1], [ 1,  0,  1]],
];
polytest_layerspan = len(polytest_layers[0]);

// TODO: Maybe define a togmod-like structure, like
// ["polygen" (or whatever), layers, vertexes per layer]
// Then we could iteratively transform that

function tlpoly_eval(mod) = assert(mod[0] == "tlpoly-ls") assert(len(mod) == 3)
	["polyhedron-vf", polygen_points(mod[1], mod[2]), polygen_faces(mod[1], mod[2])];

poly_tm = ["polyhedron-vf", polygen_points(polytest_layers, polytest_layerspan), polygen_faces(polytest_layers, polytest_layerspan)];

use <../lib/TOGMod1.scad>

togmod1_domodule(["scale", [10,10,10], poly_tm]);
