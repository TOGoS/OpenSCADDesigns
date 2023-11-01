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
// - Layer vertexes are listed counter-clockwise
//   when viewed from the top (e.g. +X, +Y, -X, -Y)

// Use an intermediate ["tlpoly-ls", layers, layerspan] representation?  Should not affect output.
use_eval = false;
triangulate_faces = false;

function polygen_cap_faces( layers, layerspan, li, reverse=false ) = [
	[for( vi=reverse ? [layerspan-1 : -1 : 0] : [0 : 1 : layerspan-1] ) (vi%layerspan)+layerspan*li]
];

function polygen_layer_faces( layers, layerspan, i ) =
let( l0 = i*layerspan )
let( l1 = (i+1)*layerspan )
triangulate_faces ? [
	for( vi=[0 : 1 : len(layers[i])-1] ) each [
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
] : [
	for( vi=[0 : 1 : len(layers[i])-1] ) [
		l0 + vi,
		l0 + (vi+1) % layerspan,
		l1 + (vi+1)%layerspan,
		l1 + vi
	]
];

function polygen_faces( layers, layerspan ) = echo(layerspan=layerspan) [
	each polygen_cap_faces( layers, layerspan, 0, reverse=true),
	// For now, assume convex end caps
	for( li=[0 : 1 : len(layers)-2] ) each polygen_layer_faces(layers, layerspan, li),
	each polygen_cap_faces( layers, layerspan, len(layers)-1, reverse=false )
];

function polygen_points(layers, layerspan) = [
	for( layer=layers ) for( point=layer ) point
];

polytest_layer_count = 10;
polytest_vertexes_per_layer = 8;

// Multiple instances to help detect invalid polyhedrons;
// render will sometimes appear to succeed if only one.
instance_count = 2;

polytest_layers = [
	for( t=[0 : 1 : polytest_layer_count] ) [
		for( vi=[0 : 1 : polytest_vertexes_per_layer-1] ) [
			(2+sin(t*360/10))*cos(vi * 360 / polytest_vertexes_per_layer),
			(2+cos(t*360/10))*sin(vi * 360 / polytest_vertexes_per_layer),
			t
		]
	]
];

function tlpoly_make_from_layers(layers) = [
	"tlpoly-ls", // layers, span
	layers,
	len(layers[0])
];

function tlpoly_eval(mod) = assert(mod[0] == "tlpoly-ls") assert(len(mod) == 3)
	["polyhedron-vf", polygen_points(mod[1], mod[2]), polygen_faces(mod[1], mod[2])];

function tlpoly_make_polyhedron(layers) =
	["polyhedron-vf", polygen_points(layers, len(layers[0])), polygen_faces(layers, len(layers[0]))];

poly_tm =
	use_eval ? tlpoly_eval(tlpoly_make_from_layers(polytest_layers)) :
	tlpoly_make_polyhedron(polytest_layers);

use <../lib/TOGMod1.scad>

togmod1_domodule(["scale", [10,10,10], ["union", for(i=[0:1:instance_count-1]) ["translate", [i*10, 0, 0], poly_tm]]]);
