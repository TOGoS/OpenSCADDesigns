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

function togmod1_make_polygon(verts) =
	["polygon-vp", verts, [[for( i=[0:1:len(verts)-1] ) i%len(verts)]]];

function togmod1_make_circle(r, pos=[0,0]) =
	assert(!is_undef(r))
	assert(!is_undef(pos[0]))
	assert(!is_undef(pos[1]))
	let(fn = max($fn, 6))
	togmod1_make_polygon([ for(i=[0 : 1 : fn-1]) [pos[0]+r*cos(i*360/fn), pos[1]+r*sin(i*360/fn)]]);

function togmod1_make_cylinder(d, zrange=[0,1], r=undef) =
	assert( !is_undef(r) || !is_undef(d) )
	let( r_ = !is_undef(r) ? r : d/2 )
	// TODO: Make polyhedron directly
	["linear-extrude-zs", zrange, togmod1_make_circle(r=r_)];
