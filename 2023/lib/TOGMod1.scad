// TOGMod1
// OpenSCAD library for representing shapes
// 
// See also: Functional OpenSCAD (https://github.com/thehans/FunctionalOpenSCAD)

module togmod1_domodule(mod) {
	assert(is_list(mod));
	assert(len(mod) > 0);
	if( mod[0] == "polygon-vp" ) {
		// ["polygon-vp", vertexes, paths]
		polygon(points=mod[1], paths=mod[2]);
	} else if( mod[0] == "polyhedron-vf" ) {
		polyhedron(mod[1], faces=mod[2]);
	} else if( mod[0] == "scale" ) {
		assert(len(mod) == 3);
		scale(mod[1]) togmod1_domodule(mod[2]);
	} else if( mod[0] == "translate" ) {
		assert(len(mod) == 3);
		translate(mod[1]) togmod1_domodule(mod[2]);
	} else if( mod[0] == "intersection" ) {
		intersection_for( i=[1:1:len(mod)-1] ) togmod1_domodule(mod[i]);
	} else if( mod[0] == "difference" ) {
		difference() {
			togmod1_domodule(mod[1]);
			for( i=[2:1:len(mod)-1] ) togmod1_domodule(mod[i]);
		}
	} else if( mod[0] == "union" ) {
		for( i=[1:1:len(mod)-1] ) togmod1_domodule(mod[i]);
	} else if( mod[0] == "hull" ) {
		hull() for( i=[1:1:len(mod)-1] ) togmod1_domodule(mod[i]);
	} else {
		assert(false, str("Unrecognized shape: ", mod[0]));
	}
}

// togmod1_domodule(["polygon-vp", [[1,1],[1,-1],[-1,-1],[-1,1]], [[0,1,2,3]]]);

function togmod1_make_cuboid(size) =
	["polyhedron-vf", [
		[-size[0]/2, -size[1]/2, -size[2]/2],
		[+size[0]/2, -size[1]/2, -size[2]/2],
		[-size[0]/2, +size[1]/2, -size[2]/2],
		[+size[0]/2, +size[1]/2, -size[2]/2],
		[-size[0]/2, -size[1]/2, +size[2]/2],
		[+size[0]/2, -size[1]/2, +size[2]/2],
		[-size[0]/2, +size[1]/2, +size[2]/2],
		[+size[0]/2, +size[1]/2, +size[2]/2]
	], [
		[0,1,3,2],[0,4,5,1],[4,6,7,5],[3,7,6,2],[1,5,7,3],[6,4,0,2]
	]];

// togmod1_domodule( togmod1_make_cuboid([10,10,10]) );
