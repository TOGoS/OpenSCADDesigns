// FrenchCleatMarkingJig0.1
// 
// To help mark WSTYPE-4114-H4.5Ts
// (and maybe later other profiles)

panel_thickness = 3.175;
router_hole1_diameter = 12;
router_hole2_diameter = 26;

$fn = 24;

module fcmj0__end_params() { }

use <../lib/TOGFDMod.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGVecLib0.scad>

// togmod1_domodule(["union", ["union"], ["union"]]);

inch = 25.4;
atom = 12.7;
chunk = 38.1;

panel_size_atoms = [12,12];
panel_size = panel_size_atoms * 127 / 10;

// Each zsxs = [z, extra_r]
function make_extruded_oval(size, zrs) = tphl1_make_polyhedron_from_layer_function(zrs,
	function(zr) let(z=zr[0], extra_r=zr[1]) togvec0_offset_points(togmod1_rounded_rect_points(
		[size[0]+extra_r*2, size[1]+extra_r*2], r=min(size[0],size[1])/2+extra_r-0.1
	), z));

panel_mounting_hole = make_extruded_oval([0, 3.2], [
	[                  - 1, 4.5/2],
	[panel_thickness/2    , 4.5/2],
	[panel_thickness/2    , 8.0/2],
	[panel_thickness   + 1, 8.0/2],
]);

panel_mounting_hole_positions = [
	for( ym=[-panel_size_atoms[1]/2 + 0.5 : 1 : panel_size_atoms[1]/2 - 0.4] )
	for( xm=[-panel_size_atoms[0]/2 + 0.5,      panel_size_atoms[0]/2 - 0.5] )
	[xm,ym]*atom
];

panel_mounting_holes = [
	for( pos=panel_mounting_hole_positions )
	["translate", pos, panel_mounting_hole],
];

pencil_groove_2d = togmod1_make_polygon(togpath1_rath_to_polypoints(["togpath1-rath",
	["togpath1-rathnode", [-2, 0]],
	["togpath1-rathnode", [ 0,-3], ["round", 0.6]],
	["togpath1-rathnode", [ 2, 0]],
	["togpath1-rathnode", [ 0, 3], ["round", 0.6]],
]));

router_hole1_2d = togmod1_make_circle(d=router_hole1_diameter);
router_hole2_2d = togmod1_make_circle(d=router_hole2_diameter);

router_hole1_troff = make_extruded_oval([2*chunk+router_hole1_diameter, router_hole1_diameter], [
	[panel_thickness/2 + 0.1, 0.1],
	[panel_thickness   + 1  , panel_thickness/2 + 1],
]);

the_panel_2d = ["difference",
	togmod1_make_rounded_rect([6*inch,6*inch], r=6.35),
	
	for( xm=[-panel_size_atoms[0]/2+1.5 : 1 : panel_size_atoms[0]/2-1.5 ] ) ["translate", [xm*atom, -panel_size[1]/2], pencil_groove_2d],
	for( xm=[-panel_size_atoms[0]/2+1   : 1 : panel_size_atoms[0]/2-1   ] ) ["translate", [xm*atom,  panel_size[1]/2], pencil_groove_2d],
	
	for( ym=[-0.5, 1.5] ) for( xm=[-1,0,1] ) ["translate", [xm*chunk,ym*chunk], router_hole1_2d],
	for( ym=[-1.5, 0.5] ) for( xm=[-1,0,1] ) ["translate", [xm*chunk,ym*chunk], router_hole2_2d],
];

thing = ["difference",
	togmod1_linear_extrude_z([0,panel_thickness], the_panel_2d),
	
	each panel_mounting_holes,
	for( ym=[-1 : 1 : 1] ) for( xm=[-1.5 : 1 : 1.5] ) ["translate", [xm*chunk, ym*chunk],
		["rotate", togfdmod(floor(ym),2) == 0 ? [0,0,90] : [0,0,0], panel_mounting_hole]],
	for( ym=[-0.5,  1.5] ) ["translate", [0, ym*chunk], router_hole1_troff],
	for( ym=[-0.5,  1.5] ) for( xm=[-1.5 : 1 : 1.5] ) ["translate", [xm*chunk, ym*chunk],
		["rotate", togfdmod(floor(xm)+floor(ym/2),2) == 0 ? [0,0,90] : [0,0,0], panel_mounting_hole]],
];

togmod1_domodule(thing);
