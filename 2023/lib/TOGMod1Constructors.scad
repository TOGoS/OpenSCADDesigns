// TOGMod1Constructors-v1.3.1
// 
// Functions to construct objects understood by TOGMod1
// 
// v1.1:
// - Add togmod1_make_rounded_rect
// v1.2:
// - togmod1_make_rounded_rect can make ovals
// v1.3:
// - togmod1_circle_points, to just get the points of a circle
// - if pos parameter to circle function has a third element,
//   returned vertexes will include it as the z component;
// v1.3.1
// - Some assertions

function togmod1_make_cuboid(size) =
	assert(is_list(size))
	assert(len(size) >= 3)
	assert(is_num(size[0]))
	assert(is_num(size[1]))
	assert(is_num(size[2]))
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

function togmod1_make_rounded_rect(size, r) =
	assert(is_list(size))
	assert(len(size) >= 2)
	assert(is_num(r))
	assert(size[0] >= 2*r)
	assert(size[1] >= 2*r)
	let(quarterfn=max($fn/4, 1))
	let(qfnx = size[0] == 2*r ? quarterfn-1 : quarterfn)
	let(qfny = size[1] == 2*r ? quarterfn-1 : quarterfn)
	togmod1_make_polygon([
		for(a=[0 : 1 : qfnx]) let(ang=      a*90/quarterfn) [ size[0]/2-r + r*cos(ang),  size[1]/2-r + r*sin(ang)],
		for(a=[0 : 1 : qfny]) let(ang= 90 + a*90/quarterfn) [-size[0]/2+r + r*cos(ang),  size[1]/2-r + r*sin(ang)],
		for(a=[0 : 1 : qfnx]) let(ang=180 + a*90/quarterfn) [-size[0]/2+r + r*cos(ang), -size[1]/2+r + r*sin(ang)],
		for(a=[0 : 1 : qfny]) let(ang=270 + a*90/quarterfn) [ size[0]/2-r + r*cos(ang), -size[1]/2+r + r*sin(ang)],
	]);

function togmod1_circle_points(r, pos=[0,0], d=undef) =
	assert( !is_undef(r) || !is_undef(d) )
	assert(!is_undef(pos[0]))
	assert(!is_undef(pos[1]))
	let(mkvec = len(pos) >= 3 ? function(p) [p[0], p[1], pos[2]] : function(p) p)
	let(r_ = !is_undef(r) ? r : d/2)
	let(fn = max($fn, 6))
	[for(i=[0 : 1 : fn-1]) mkvec([pos[0]+r_*cos(i*360/fn), pos[1]+r_*sin(i*360/fn)])];

function togmod1_make_circle(r, pos=[0,0], d=undef) =
	togmod1_make_polygon(togmod1_circle_points(r=r, pos=pos, d=d));

function togmod1_make_cylinder(d, zrange=[0,1], r=undef, pos=[0,0]) =
	assert( !is_undef(r) || !is_undef(d) )
	let( r_ = !is_undef(r) ? r : d/2 )
	// TODO: Make polyhedron directly
	["linear-extrude-zs", zrange, togmod1_make_circle(r=r_, pos=pos)];

function togmod1__is_range1d(range) = is_list(range) && len(range) == 2 && is_num(range[0]) && is_num(range[1]);

function togmod1_linear_extrude_z(range, shape) =
	assert(togmod1__is_range1d(range))
	["linear-extrude-zs", range, shape];
function togmod1_linear_extrude_x(range, shape) =
	assert(togmod1__is_range1d(range))
	["rotate", [90, 0, 90], togmod1_linear_extrude_z(range, shape)];
function togmod1_linear_extrude_y(range, shape) =
	assert(togmod1__is_range1d(range))
	["rotate", [90, 0, 180], togmod1_linear_extrude_z(range, shape)];
