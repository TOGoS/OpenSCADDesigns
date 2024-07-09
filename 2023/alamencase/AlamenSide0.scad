// AlamenSide0.4
// 
// Sides for my home-printed computer case,
// which actually contains a Amazon-bought part,
// WSITEM-201029 or similar.
// 
// v0.1:
// - First attempt.  Very holey.  Prototype?
// v0.2:
// - Make thickness adjustable
// - Adjust counterbore and countersink depth based on thickness
// v0.3:
// - Fix hole positions
// v0.4:
// - When thickness is <= 3.5mm, make straight holes instead of counterboring
// - Options for two large holes in the panel

thickness = 9.53; // 0.01
regular_hole_grid_enabled = true;
big_hole_style = "empty"; // ["empty", "pocket", "mesh", "none"]

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGVecLib0.scad>

module __alamenside__end_params() { }


function xx__round_toon(n, f) = round(n / f) * f;

function xx__magnitude(vec) = sqrt(vec[0]*vec[0] + vec[1]*vec[1]);

function xx__dist(a, b) = xx__magnitude(a - b);

function list_contains(haystack, matcher, index=0) =
	len(haystack) > index && (matcher(haystack[index]) || list_contains(haystack, matcher, index+1));

// A candidate for TOGAABBLib or something:
function area_contains(area, position, element_index=1) =
	area[0] == "union" ? (
		element_index >= len(area) ? false :
		area_contains(area[element_index], position) || area_contains(area, position, element_index+1)
	) :
	area[0] == "rect-bounds" ? (
		position[0] >= area[1][0] && position[0] <= area[2][0] &&
		position[1] >= area[1][1] && position[1] <= area[2][1]
	) :
	assert(false, str("Unrecognized area spec: '", area, "'"));



slot_fn = 24;

inch = 25.4;
small_hole_d = 4.5; // Used by slots and 2D holes
atom_pitch = inch/2;

counterbore_holes = thickness > 3.5;

size = [12*inch, 7.5*inch, thickness];

size_atoms = [round(size[0]/atom_pitch), round(size[1]/atom_pitch)];

slot_positrations =
let(rymin=-size[1]/2/atom_pitch, rymax=size[1]/2/atom_pitch, rxmin=-size[0]/2/atom_pitch, rxmax=size[0]/2/atom_pitch)
let(y1 = 0.5, x1 = 1.5, x2 = 5.5)
[
	for( xo=[0,2] ) for( yo=[0,1] ) for( xm=[-1, 1] ) for( ym=[-1, 1] ) each [
		[atom_pitch * [xm * (rxmin + x1 + xo), ym * (rymin + y1 + yo)],  0],
		[atom_pitch * [xm * (rxmin + x2 + xo), ym * (rymin + y1 + yo)],  0],
		[atom_pitch * [xm * (rxmin + y1 + xo), ym * (rymin + x1 + yo)], 90],
		[atom_pitch * [xm * (rxmin + y1 + xo), ym * (rymin + x2 + yo)], 90],
	],
	for( xm=[-1, 1] ) for( ym=[-1, 1] ) each [
		[atom_pitch * [xm * (rxmin + 11), ym * (rymin + 0.75)], 0],
	]
];

slot_positions = [
	for( pr = slot_positrations ) [pr[0][0], pr[0][1]],
];
big_hole_size = [atom_pitch*7,atom_pitch * 9];
big_hole_positions = [ for( xm=[-1,1] ) [xm*atom_pitch*5.5,0] ];

hole_exclusion_zone = big_hole_style == "mesh" || big_hole_style == "empty" ?
	["union", for(bhp=big_hole_positions) ["rect-bounds", bhp - big_hole_size/2, bhp + big_hole_size/2]] : ["union"];

holes = [
	if( regular_hole_grid_enabled )
	for( xm=[round(-size[0]/atom_pitch)/2+0.5 : 1 : size[0]/atom_pitch/2] )
	for( ym=[round(-size[1]/atom_pitch)/2+0.5 : 1 : size[1]/atom_pitch/2] )
	let( hole_pos = atom_pitch*[xm,ym] ) each [
		if( !area_contains(hole_exclusion_zone, hole_pos) && !list_contains(slot_positions, function(sp) xx__dist(sp, hole_pos) < atom_pitch-1) )
			[hole_pos, (floor(xm+ym) + 1024) % 2 == 1 ? "top-hole" : "bottom-hole"],
	],

	for( p=slot_positrations ) [p[0], ["rotate", p[1], "small-slot"]],
];

slot_polyline_points = [[-inch/16, 0], [+inch/16,0]];

function slot_polygon_points(points, radius) =
	assert(is_list(points))
	assert(is_num(radius))
	assert(radius > 0)
	togpath1_rath_to_polypoints(togpath1_polyline_to_rath(points, radius, end_shape="round"));

function extrude_polyline(points, zds) = tphl1_make_polyhedron_from_layer_function(zds, function(zd)
	togvec0_offset_points(slot_polygon_points(points, zd[1]/2), zd[0]));

counterbore_inset = min(size[2]/2, 3/16*inch);
countersink_inset = min(size[2]/3, 1/8 *inch);

function make_counterbored_slot(points) =
let( hole_d = small_hole_d )
let( cb_d = 9.5 )
let( cb_bottom_z = size[2] - counterbore_inset )
extrude_polyline(
	points,
	[[-1, hole_d], [cb_bottom_z, hole_d], [cb_bottom_z, cb_d], [size[2]+1, cb_d]],
	$fn = slot_fn
);

small_hole_2d = togmod1_make_circle(d=4.5, $fn = slot_fn);
small_slot_2d = togmod1_make_polygon(slot_polygon_points(slot_polyline_points, small_hole_d/2, $fn = slot_fn));

small_top_hole    = ["render", ["translate", [0,0,size[2]], tog_holelib2_hole("THL-1005", inset=countersink_inset, depth=size[2]+1)]];
small_bottom_hole = ["render", ["rotate", [180,0,0], tog_holelib2_hole("THL-1005", inset=countersink_inset, depth=size[2]+1)]];
small_slot = ["render", make_counterbored_slot(slot_polyline_points)];

function decode_hole_2d(thing) =
	thing == "top-hole" ? small_hole_2d :
	thing == "bottom-hole" ? small_hole_2d :
	thing == "small-slot" ? small_slot_2d :
	is_list(thing) && thing[0] == "rotate" ? ["rotate", thing[1], decode_hole_2d(thing[2])] :
	assert(false, str("Unrecognized hole encoding: '", thing, "'"));

function decode_hole_3d(thing) =
	thing == "top-hole" ? small_top_hole :
	thing == "bottom-hole" ? small_bottom_hole :
	thing == "small-slot" ? small_slot :
	is_list(thing) && thing[0] == "rotate" ? ["rotate", thing[1], decode_hole_3d(thing[2])] :
	assert(false, str("Unrecognized hole encoding: '", thing, "'"));

the_panel_hull_2d = togmod1_make_rounded_rect(size, r=inch/4, $fn = 32);

big_holes_2d = ["union", for( xm=[-1,1] ) ["translate", [xm*atom_pitch*5.5,0,0], togmod1_make_rounded_rect(big_hole_size, r=12.7, $fn=24)]];

the_panel_hull = ["difference",
	["linear-extrude-zs",
		[0, size[2]],
		["difference",
			the_panel_hull_2d,
			if( big_hole_style == "empty" ) big_holes_2d,
			if( !counterbore_holes ) for( h=holes ) ["translate", h[0], decode_hole_2d(h[1])],
		]
	],
	if( big_hole_style == "pocket" ) ["linear-extrude-zs",
		[min(size[2]/2, inch/16), size[2]+1],
		big_holes_2d
	],
	if( big_hole_style == "mesh" ) ["difference",
		["linear-extrude-zs",
			[-1, size[2]+1],
			big_holes_2d
		],
		["linear-extrude-zs",
			[-2, inch/16],
			["union",
				for( ym=[-20:1:20] ) ["translate", [0, ym*inch/4], ["rotate", [0,0, 30], togmod1_make_rect([400, 1])]],
				for( xm=[-30:1:30] ) ["translate", [xm*inch/4, 0], ["rotate", [0,0,120], togmod1_make_rect([400, 1])]],
			]
		],
	],
];

thing = ["difference",
	the_panel_hull,
	if( counterbore_holes ) for( h=holes ) ["translate", h[0], decode_hole_3d(h[1])],
];

togmod1_domodule(thing);
