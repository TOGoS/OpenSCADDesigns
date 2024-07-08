// AlamenSide0.1
// 
// Sides for my home-printed computer case,
// which actually contains a Amazon-bought part,
// WSITEM-201029 or similar.
// 
// v0.1:
// - First attempt.  Very holey.  Prototype?

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGVecLib0.scad>

module __alamenside__end_params() { }

inch = 25.4;
atom_pitch = inch/2;

size = [12*inch, 7.5*inch, 3/8*inch];

the_hull = ["linear-extrude-zs",
	[0, size[2]],
	togmod1_make_rounded_rect(size, r=inch/4, $fn = 32),
];

size_atoms = [round(size[0]/atom_pitch), round(size[1]/atom_pitch)];

slot_positrations =
let(rymin=-size[1]/2/atom_pitch, rymax=size[1]/2/atom_pitch, rxmin=-size[0]/2/atom_pitch, rxmax=size[0]/2/atom_pitch)
let(y1 = 0.5, x1 = 1.5, x2 = 3.5)
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

function xx__round_toon(n, f) = round(n / f) * f;

function xx_magnitude(vec) = sqrt(vec[0]*vec[0] + vec[1]*vec[1]);

function xx__dist(a, b) = xx_magnitude(a - b);

slot_positions = [
	for( pr = slot_positrations ) [pr[0][0], pr[0][1]],
];

function list_contains(haystack, matcher, index=0) =
	len(haystack) > index && (matcher(haystack[index]) || list_contains(haystack, matcher, index+1));

holes = [
	for( xm=[round(-size[0]/atom_pitch)/2+0.5 : 1 : size[0]/atom_pitch/2] )
		for( ym=[round(-size[1]/atom_pitch)/2+0.5 : 1 : size[1]/atom_pitch/2] )
			if( !list_contains(slot_positions, function(sp) xx__dist(sp, atom_pitch*[xm,ym]) < atom_pitch-1) )
				[[xm*atom_pitch, ym*atom_pitch],
				 (floor(xm+ym) + 1024) % 2 == 1 ? "top-hole" : "bottom-hole"],

	for( p=slot_positrations ) [p[0], ["rotate", p[1], "small-slot"]],
];

function extrude_polyline(points, zds) = tphl1_make_polyhedron_from_layer_function(zds, function(zd)
	togvec0_offset_points(togpath1_rath_to_polypoints(togpath1_polyline_to_rath(points, zd[1]/2, end_shape="round")), zd[0]));

function make_counterbored_slot(points) = 
let( hole_d = 4.5 )
let( cb_d = 9.5 )
let( cb_bottom_z = size[2]/2 )
extrude_polyline(
	points,
	[[-1, hole_d], [cb_bottom_z, hole_d], [cb_bottom_z, cb_d], [size[2]+1, cb_d]],
	$fn = 24
);

small_top_hole    = ["render", ["translate", [0,0,size[2]], tog_holelib2_hole("THL-1005", inset=size[2]/3, depth=size[2]+1)]];
small_bottom_hole = ["render", ["rotate", [180,0,0], tog_holelib2_hole("THL-1005", inset=size[2]/3, depth=size[2]+1)]];
small_slot = ["render", make_counterbored_slot([[-inch/16, 0], [+inch/16,0]])];

function decode_hole(thing) =
	thing == "top-hole" ? small_top_hole :
	thing == "bottom-hole" ? small_bottom_hole :
	thing == "small-slot" ? small_slot :
	is_list(thing) && thing[0] == "rotate" ? ["rotate", thing[1], decode_hole(thing[2])] :
	assert(false, str("Unrecognized hole encoding: '", thing, "'"));

thing = ["difference",
	the_hull,
	for( h=holes ) ["translate", h[0], decode_hole(h[1])],
];

togmod1_domodule(thing);
