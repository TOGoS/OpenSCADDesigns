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

triangulate_faces = false;
vertex_consolidation_enabled = true;
face_fixing_enabled = true;

polytest_layer_count = 10;
polytest_vertexes_per_layer = 8;

// Multiple instances to help detect invalid polyhedrons;
// render will sometimes appear to succeed if only one.
instance_count = 2;

use <../lib/TOGArrayLib1.scad>
use <../lib/TOGPolyhedronLib1.scad>

// poly_tm = tphl1_make_polyhedron_from_layers(polytest_layers);
poly_tm = tphl1_make_polyhedron_from_layer_function(polytest_layer_count+1, function(t) [
	for( vi=[0 : 1 : polytest_vertexes_per_layer-1] ) [
		t/polytest_layer_count*(2+sin(t*360/10))*cos(vi * 360 / polytest_vertexes_per_layer),
		t/polytest_layer_count*(2+cos(t*360/10))*sin(vi * 360 / polytest_vertexes_per_layer),
		t
	]
]);

echo(str(
	// len(poly_tm[2]), " faces on resulting polyhedron; ",
	tal1_reduce(0, poly_tm[2], function(c,face) c + (len(face) < 3 ? 1 : 0)), " faces have fewer than 3 vertexes",
	tal1_reduce(0, poly_tm[2], function(c,face) c + (tal1_consecutive_duplicate_count(face) > 0 ? 1 : 0)), " faces contain duplicate points"
));

use <../lib/TOGMod1.scad>

togmod1_domodule(["scale", [10,10,10], ["union", for(i=[0:1:instance_count-1]) ["translate", [i*10, 0, 0], poly_tm]]]);
