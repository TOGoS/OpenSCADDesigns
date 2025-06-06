// TOGMod1Constructors-v1.9
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
// v1.4:
// - Refactor togmod1_rounded_rect_points and togmod1_circle_points
//   to use togmod1__make_nd_vector_adder for adapting to whatever
//   `pos` parameter is.
// v1.5:
// - togmod_rounded_rect_points will not simplify completely rounded sides
//   (where length of side is exactly twice the rounding radius)
//   unless simplify_rounded_sides=true
//   - This makes it more useful for polyhedron generation,
//     where radius varies, but number of points must remain constant.
// v1.6:
// - togmod1_make_rect makes a simple rectangle
// - togmod1_make_rounded_rect will defer to togmod1_make_rect when r=0
// v1.7:
// - togmod1_make_circle will return empty shape (["union"]) when d=0
// v1.8:
// - Add togmod1_text
// v1.9:
// - togmod1_circle_points uses 3 as minimum circle point count instead of 6

use <./TOGArrayLib1.scad>

function togmod1__make_nd_vector_adder(origin=[0,0]) =
	let(origin_is_zero = tal1_reduce(true, origin, function(prev,item) prev && item == 0))
	origin_is_zero ? (function(vec) len(vec) >= len(origin) ? vec : tal1_replace_at(origin, 0, vec)) :
	function(vec) [
		for(i=[0:1:max(len(origin),len(vec))-1]) (len(vec) > i ? vec[i] : 0) + (len(origin) > i ? origin[i] : 0),
	];

assert([1,2,3] == togmod1__make_nd_vector_adder()([1,2,3]));
echo(togmod1__make_nd_vector_adder([0,0,3])([1,2]));
assert([1,2,3] == togmod1__make_nd_vector_adder([0,0,3])([1,2]));


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

function togmod1_rounded_rect_points(size, r, pos=[0,0], simplify_rounded_sides=false) =
	assert(is_list(size))
	assert(len(size) >= 2)
	let(radii = is_list(r) ? r : is_num(r) ? [r,r] : assert(false, "rounded_rect r(adius) should be list<num> or num"))
	let(rx = radii[0])
	let(ry = radii[1])
	assert(is_num(rx))
	assert(is_num(ry))
	assert(size[0] >= 2*rx, str("size[0] must be >= 2*r[0]; size[0] = ",size[0],", 2*r[0] = ",2*rx))
	assert(size[1] >= 2*ry, str("size[1] must be >= 2*r[1]; size[1] = ",size[1],", 2*r[1] = ",2*ry))
	let(quarterfn=max($fn/4, 1))
	let(qfnx = simplify_rounded_sides && size[0] == 2*rx ? quarterfn-1 : quarterfn)
	let(qfny = simplify_rounded_sides && size[1] == 2*ry ? quarterfn-1 : quarterfn)
	let(finalizepos = togmod1__make_nd_vector_adder(pos))
[
	for(a=[0 : 1 : qfnx]) let(ang=      a*90/quarterfn) finalizepos([ size[0]/2-rx + rx*cos(ang),  size[1]/2-ry + ry*sin(ang)]),
	for(a=[0 : 1 : qfny]) let(ang= 90 + a*90/quarterfn) finalizepos([-size[0]/2+rx + rx*cos(ang),  size[1]/2-ry + ry*sin(ang)]),
	for(a=[0 : 1 : qfnx]) let(ang=180 + a*90/quarterfn) finalizepos([-size[0]/2+rx + rx*cos(ang), -size[1]/2+ry + ry*sin(ang)]),
	for(a=[0 : 1 : qfny]) let(ang=270 + a*90/quarterfn) finalizepos([ size[0]/2-rx + rx*cos(ang), -size[1]/2+ry + ry*sin(ang)]),
];

function togmod1_make_rect(size) =
	togmod1_make_polygon([
		[-size[0]/2, -size[1]/2],
		[+size[0]/2, -size[1]/2],
		[+size[0]/2, +size[1]/2],
		[-size[0]/2, +size[1]/2],
	]);

function togmod1_make_rounded_rect(size, r) =
	r == 0 ? togmod1_make_rect(size) :
	togmod1_make_polygon(togmod1_rounded_rect_points(size,r,simplify_rounded_sides=true));

/**
 * Returns points for an approximation of a circle where points are at distance r from pos.
 * Can be used to make other regular polygons, but the faces will be less than that
 * distance from pos (do some trig if you want face distance, e.g. for a hex nut).
 */
function togmod1_circle_points(r, pos=[0,0], d=undef) =
	assert( !is_undef(r) || !is_undef(d) )
	assert(!is_undef(pos[0]))
	assert(!is_undef(pos[1]))
	let(finalizepos = togmod1__make_nd_vector_adder(pos))
	let(r_ = !is_undef(r) ? r : d/2)
	let(fn = max($fn, 3))
	[for(i=[0 : 1 : fn-1]) finalizepos([r_*cos(i*360/fn), r_*sin(i*360/fn)])];

function togmod1_make_circle(r, pos=[0,0], d=undef) =
	r == 0 || d == 0 ? ["union"] :
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

function togmod1_text(text, size, font, halign, valign, spacing, direction, language, script) =
	["text-tsfhvsdls", text, size, font, halign, valign, spacing, direction, language, script];
