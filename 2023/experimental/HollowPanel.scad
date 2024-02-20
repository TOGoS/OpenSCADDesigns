// HollowPanel v0.2
// 
// A panel that you're supposed to fill in with your own goop
// 
// Changes:
// v0.2:
// - Add posts, for extra grabbiness
// v0.3:
// - Add y-wise rails
// - Add notion of 'zhps'

chunk_pitch = 38.1;
size_chunks = [3,4];
floor_thickness = 0.3;  // 0.001
panel_thickness = 6.35; // 0.001
wall_thickness = 1;
render_fn = 72;

function __asjd__end_params() = undef;

$fn = $preview ? 12 : render_fn;

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>

// hps = one of the following
function hps_grow(thing, amount) = ["hp-growby", amount, thing];
function hps_union(things) = ["union", for(t=things) t];
function hps_to_togmod(thing, offset=0) =
	thing[0] == "union" ? ["union", for(i=[1:1:len(thing)-1]) hps_to_togmod(thing[i])] :
	thing[0] == "hp-growby" ? hps_to_togmod(thing[2], offset+thing[1]) :
	thing[0] == "togpath1-rath" ? togmod1_make_polygon(togpath1_rath_to_points(togpath1_offset_rath(thing, offset))) :
	thing[0] == "hp-multixform" ? let(xformed=hps_to_togmod(thing[2], offset)) ["union",
		for( xf=thing[1] ) ["translate", [xf[0], xf[1]], ["rotate", xf[2], xformed]]
	] :
	assert(false, str("Unrecognized HollowPanel shape type: ", thing[0]));

// zhps = ["zhps", zhp_zrange, hps]
// zhp_zrange = ["rel", 0..1, 0..1] | ["abs", z0, z1]

function hp__lerp(x, v0, v1) = v0*(1-x) + v1*x;

function zhp_translate_zrange(zhp_range, into) =
	echo("translating ", zhp_range, " into ", into)
	zhp_range[0] == "abs" ? zhp_range :
	zhp_range[0] == "rel" ? [into[0],
		hp__lerp(zhp_range[1], into[1], into[2]),
		hp__lerp(zhp_range[2], into[1], into[2]),
	] :
	assert(false, str("Invalid zhp_zrange: ", zhp_range));

function hp_make_panel(z0, z1, z2, wall_thickness,
	panel_hull_hps,
	panel_cutout_hps = ["union"],
	cavity_subtraction_zhpses = []
) =
let( abs_cavity_subtraction_zhpses = [
	for(zhps=cavity_subtraction_zhpses) ["zhps", zhp_translate_zrange(zhps[1], ["abs",z1,z2]), zhps[2]]
] )
["difference",
	["linear-extrude-zs", [z0,z2], ["difference",
		hps_to_togmod(panel_hull_hps),
		hps_to_togmod(panel_cutout_hps)
	]],
	["difference",
		["linear-extrude-zs", [z1,z2+1], ["difference",
			hps_to_togmod(hps_grow(panel_hull_hps, -wall_thickness)),
			hps_to_togmod(hps_grow(panel_cutout_hps, wall_thickness)),
			for( cszhps=abs_cavity_subtraction_zhpses ) let(zr=cszhps[1]) each [
				if( zr[1] <= z1 && zr[2] >= z2 ) hps_to_togmod(echo(zr2=zr[2], z2=z2) cszhps[2])
			]
		]],
		for( cszhps=abs_cavity_subtraction_zhpses ) let(zr=cszhps[1]) each [
			if( zr[1] > z1 || zr[2] < z2 ) ["linear-extrude-zs", [zr[1],zr[2]], hps_to_togmod(cszhps[2])]
		]
	]
];

w = chunk_pitch*size_chunks[0];
h = chunk_pitch*size_chunks[1];
hole_diameter = 7.9375;

function circle_rath(r) = ["togpath1-rath",
	["togpath1-rathnode", [-r, -r], ["round", r]],
	["togpath1-rathnode", [ r, -r], ["round", r]],
	["togpath1-rathnode", [ r,  r], ["round", r]],
	["togpath1-rathnode", [-r,  r], ["round", r]],
];
hole_rath = circle_rath(hole_diameter/2);

function rect_rath(size, ops) =
let(rx=size[0]/2)
let(ry=size[1]/2)
["togpath1-rath",
	["togpath1-rathnode", [-rx, -ry], each ops],
	["togpath1-rathnode", [ rx, -ry], each ops],
	["togpath1-rathnode", [ rx,  ry], each ops],
	["togpath1-rathnode", [-rx,  ry], each ops],
];

function oval_rath(sr,lr) = rect_rath([lr*2, sr*2], [["round", sr]]);
post_rath = oval_rath(1,4);

hullrop = ["round", 12.7];

the_hull_hps = ["togpath1-rath",
	["togpath1-rathnode", [-w/2, -h/2], hullrop],
	["togpath1-rathnode", [ w/2, -h/2], hullrop],
	["togpath1-rathnode", [ w/2,  h/2], hullrop],
	["togpath1-rathnode", [-w/2,  h/2], hullrop]
];
the_cutout_hps = ["hp-multixform", [
	for( xm=[-size_chunks[0]/2 + 0.5 : 1 : size_chunks[0]/2] )
	for( ym=[-size_chunks[1]/2 + 0.5 : 1 : size_chunks[1]/2] )
	[xm*chunk_pitch,ym*chunk_pitch, 20],
], hole_rath];
the_posts_hps = ["hp-multixform", [
	for( xm=[-size_chunks[0]/2 + 1/4 : 1/2 : size_chunks[0]/2] )
	for( ym=[-size_chunks[1]/2 + 1/4 : 1/2 : size_chunks[1]/2] )
	[xm*chunk_pitch,ym*chunk_pitch, (0.125+xm*0.5+ym*0.5)*360],
], post_rath];

ns_wall = rect_rath([wall_thickness*2, size_chunks[1]*chunk_pitch]);
cavity_subtraction_zhpses = [
	["zhps", ["rel", 0, 0.5], the_posts_hps],
	["zhps", ["rel", 0, 1.1], ["hp-multixform", [
		for( xm=[-size_chunks[0]/2 + 0.5 : 1 : size_chunks[0]/2] ) [xm*chunk_pitch, 0, 0]
	], ns_wall]]
];

panel = hp_make_panel(
	0, floor_thickness, panel_thickness,
	wall_thickness = wall_thickness,
	panel_hull_hps = the_hull_hps,
	panel_cutout_hps = the_cutout_hps,
	cavity_subtraction_zhpses = cavity_subtraction_zhpses,
	$fn = 32);

togmod1_domodule(panel);
