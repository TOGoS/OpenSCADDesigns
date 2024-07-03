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
		assert(is_list(mod[1]));
		for(c=mod[1]) assert(is_num(c), "translate component should be numeric");
		translate(mod[1]) togmod1_domodule(mod[2]);
	} else if( mod[0] == "rotate" ) {
		assert(len(mod) == 3);
		rotate(mod[1]) togmod1_domodule(mod[2]);
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
	} else if( mod[0] == "offset-rs" ) {
		assert(len(mod) == 3);
		assert(is_num(mod[1]));
		assert(is_list(mod[2]));
		offset(mod[1]) togmod1_domodule(mod[2]);
	} else if( mod[0] == "linear-extrude-zs" ) {
		// ["linear-extrude-zs", [z0,z1], 2d_shape] // centered
		// ["linear-extrude-zs", height, 2d_shape]
		let( zrange = is_list(mod[1]) ? mod[1] : [-mod[1]/2, mod[1]/2] ) {
			translate([0,0,zrange[0]]) linear_extrude(zrange[1]-zrange[0]) togmod1_domodule(mod[2]);
		}
	} else if( mod[0] == "render" ) {
		render() togmod1_domodule(mod[1]);
	} else if( mod[0] == "minkowski" ) {
		minkowski() {
			togmod1_domodule(mod[1]);
			togmod1_domodule(mod[2]);
		}
	} else if( mod[0] == "x-debug" ) {
		# togmod1_domodule(mod[1]);
	} else {
		assert(false, str("Unrecognized shape: ", mod[0]));
	}
}
