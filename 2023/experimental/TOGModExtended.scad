// An interpreter module that can be extended
// to understand more SShapes (arrays representing shapes)
// by delegating to children(), passing the
// mystery SShape using the dynamic variable, $mod.

module mcext0_domodule(mod) {
	assert(is_list(mod));
	assert(len(mod) > 0);
	if( mod[0] == "polygon-vp" ) {
		// ["polygon-vp", vertexes, paths]
		polygon(points=mod[1], paths=mod[2]);
	} else if( mod[0] == "polyhedron-vf" ) {
		polyhedron(mod[1], faces=mod[2]);
	} else if( mod[0] == "scale" ) {
		assert(len(mod) == 3);
		scale(mod[1]) mcext0_domodule(mod[2]) children();
	} else if( mod[0] == "translate" ) {
		assert(len(mod) == 3);
		assert(is_list(mod[1]));
		for(c=mod[1]) assert(is_num(c), "translate component should be numeric");
		translate(mod[1]) mcext0_domodule(mod[2]) children();
	} else if( mod[0] == "rotate" ) {
		assert(len(mod) == 3);
		rotate(mod[1]) mcext0_domodule(mod[2]) children();
	} else if( mod[0] == "intersection" ) {
		intersection_for( i=[1:1:len(mod)-1] ) mcext0_domodule(mod[i]) children();
	} else if( mod[0] == "difference" ) {
		difference() {
			mcext0_domodule(mod[1]) children();
			for( i=[2:1:len(mod)-1] ) mcext0_domodule(mod[i]) children();
		}
	} else if( mod[0] == "union" ) {
		for( i=[1:1:len(mod)-1] ) mcext0_domodule(mod[i]) children();
	} else if( mod[0] == "hull" ) {
		hull() for( i=[1:1:len(mod)-1] ) mcext0_domodule(mod[i]) children();
	} else if( mod[0] == "linear-extrude-zs" ) {
		// ["linear-extrude-zs", [z0,z1], 2d_shape] // centered
		// ["linear-extrude-zs", height, 2d_shape]
		let( zrange = is_list(mod[1]) ? mod[1] : [-mod[1]/2, mod[1]/2] ) {
			translate([0,0,zrange[0]]) linear_extrude(zrange[1]-zrange[0]) mcext0_domodule(mod[2]) children();
		}
	} else if( mod[0] == "render" ) {
		render() mcext0_domodule(mod[1]);
	} else if( mod[0] == "x-debug" ) {
		# mcext0_domodule(mod[1]) children();
	} else if( $children > 0 ) {
		$mod = mod;
		children();
	} else {
		assert(false, str("mcext0_domodule: Unrecognized shape: ", mod[0]));
	}
}

module mcmuffin() {
	sphere(d=10);
}
module mcriddle() {
	cube([10,10,10], center=true);
}

module mcext1_domodule(mod) {
	echo(mcext1_domodule_mod=mod);
	if( mod[0] == "mcmuffin" ) {
		mcmuffin();
	} else if( $children > 0 ) {
		$mod = mod;
		children();
	} else {
		assert(false, str("mcext1_domodule: Unrecognized shape: ", mod[0]));
	}
}

module mcext2_domodule(mod) {
	echo(mcext2_domodule_mod=mod);
	if( mod[0] == "mcriddle" ) {
		mcriddle();
	} else if( $children > 0 ) {
		$mod = mod;
		children();
	} else {
		assert(false, str("mcext2_domodule: Unrecognized shape: ", mod[0]));
	}
}

// Demonstration: mcext0_domodule (which is based on TOGMod1)
// knows about 'union' and 'translate', but not 'mcmuffin'
// or 'mcriddle'; child modules, however, can handle those.
mcext0_domodule(["union",
	["translate", [30,0,0], ["mcmuffin"]],
	["translate", [0,30,0], ["mcriddle"]],
]) mcext1_domodule($mod) mcext2_domodule($mod);

// Order of children doesn't matter, so
// long as they all follow this pattern and don't
// overlap in functionality, and so long as
// arguments to 'operators' are handled no farther up
// the chain than the operators themselves, which can
// be worked around by repetition:
mcext2_domodule(["union",
	["translate", [-30,0,0], ["mcmuffin"]],
	["translate", [0,-30,0], ["mcriddle"]],
]) mcext1_domodule($mod) mcext0_domodule($mod) mcext2_domodule($mod) mcext1_domodule($mod);
