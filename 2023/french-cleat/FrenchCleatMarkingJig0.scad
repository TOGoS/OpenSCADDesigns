// FrenchCleatMarkingJig0.4
// 
// To help mark WSTYPE-4114-H4.5Ts
// (and maybe later other profiles)
// 
// Versions:
// v0.2:
// - Added beveled fence thing
// v0.3:
// - Alternate axes of edge mounting holes
// v0.4:
// - Options for straight fences and beveled fences
//   with stickey-outey bits (fence_bevel_trim > 0)
//   and margins (fence_face_offset < 0)

what = "panel"; // ["panel", "straight-fence", "beveled-fence","everything"]

panel_thickness = 3.175;
router_hole1_diameter = 12;
router_hole2_diameter = 26;

fence_bevel_trim = 1.59;
fence_face_offset = -0.1;

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
u = inch/16;

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
	["translate", pos, ["rotate", [0, 0, togfdmod(round(pos[0]/12.7+pos[1]/12.7),2) == 0 ? 0 : 90], panel_mounting_hole]],
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

panel = ["difference",
	togmod1_linear_extrude_z([0,panel_thickness], the_panel_2d),
	
	each panel_mounting_holes,
	for( ym=[-1 : 1 : 1] ) for( xm=[-1.5 : 1 : 1.5] ) ["translate", [xm*chunk, ym*chunk],
		["rotate", togfdmod(floor(ym),2) == 0 ? [0,0,90] : [0,0,0], panel_mounting_hole]],
	for( ym=[-0.5,  1.5] ) ["translate", [0, ym*chunk], router_hole1_troff],
	for( ym=[-0.5,  1.5] ) for( xm=[-1.5 : 1 : 1.5] ) ["translate", [xm*chunk, ym*chunk],
		["rotate", togfdmod(floor(xm)+floor(ym/2),2) == 0 ? [0,0,90] : [0,0,0], panel_mounting_hole]],
];

function beveled_edge_fence_rath(proff, trim=0, face_offset=0) =
let( fo  = face_offset               )
let( fo2 = face_offset * (sqrt(2)-1) )
["togpath1-rath",
	["togpath1-rathnode", [-6*u,  6*u], ["offset", proff], ["round", max(0.5, 1     + proff),  4]],
	["togpath1-rathnode", [-6*u, -6*u], ["offset", proff], ["round", max(0.5, 1     + proff),  4]],
	// TODO: Take face_offset into account
	if( trim == 0 ) each [
		["togpath1-rathnode", [ 0*u + fo + fo2, -6*u], ["offset", proff], ["round", max(0.5, 3.175 + proff),  6]],
	],
	if( trim > 0 ) each [
		["togpath1-rathnode", [       fo, -6*u             ], ["offset", proff]],
		["togpath1-rathnode", [trim + fo, -6*u             ], ["offset", proff]],
		["togpath1-rathnode", [trim + fo, -6*u + trim - fo2], ["offset", proff]],
	],
	["togpath1-rathnode", [12*u + fo + fo2,  6*u], ["offset", proff], ["round", max(0.5, 3.175 + proff), 12]],
];
function straight_edge_fence_rath(proff, face_offset=0) = ["togpath1-rath",
	["togpath1-rathnode", [-6*u,  6*u], ["offset", proff], ["round", max(0.5, 1     + proff),  4]],
	["togpath1-rathnode", [-6*u, -6*u], ["offset", proff], ["round", max(0.5, 1     + proff),  4]],
	// The FCs I'm working with have a 1/16" trim;
	// therefore the right (business) edge is at x = 3/8 - 3/8 + 1/16 = 1/16 = 1u.
	// This wouldn't give much room for centered screw holes, but
	// for this design the holes are on a 1/2" grid starting 1/4" from the left
	// edge, so it works out.
	["togpath1-rathnode", [ 1*u + face_offset, -6*u], ["offset", proff], ["round", max(0.5, 1     + proff),  4]],
	["togpath1-rathnode", [ 1*u + face_offset,  6*u], ["offset", proff], ["round", max(0.5, 1     + proff),  4]],
];



edge_fence_yos = [
	[ panel_size[1]/2  , -1],
	[ panel_size[1]/2-1,  0],
	[-panel_size[1]/2+1,  0],
	[-panel_size[1]/2  , -1],
];

function beveled_edge_fence_hull(trim=0, face_offset=0) =
	tphl1_make_polyhedron_from_layer_function(edge_fence_yos, function(yo)
		let( y=yo[0], off=yo[1] ) [
			for( p=togpath1_rath_to_polypoints(beveled_edge_fence_rath(off, trim=trim, face_offset=face_offset)))
			[p[0], y, p[1]]
		]
	);

function straight_edge_fence_hull(face_offset=0) = tphl1_make_polyhedron_from_layer_function(edge_fence_yos, function(yo)
	let( y=yo[0], off=yo[1] ) [
		for( p=togpath1_rath_to_polypoints(straight_edge_fence_rath(off, face_offset=face_offset)))
		[p[0], y, p[1]]
	]
);

fence_hole1 = tphl1_make_z_cylinder(d=3, zrange=[-20,20] );
fence_hole2 = tphl1_make_z_cylinder(d=5, zrange=[-20,20] );

function beveled_edge_fence(trim=0, face_offset=0) = ["difference",
	beveled_edge_fence_hull(trim=trim, face_offset=face_offset),
	
	for( ym=[-panel_size_atoms[1]/2+0.5 : 1 : panel_size_atoms[1]/2-0.5] )
	["translate", [-3.175, ym*atom, 0], togfdmod(floor(ym), 2) == 0 ? fence_hole1 : fence_hole2]
];

function straight_edge_fence(face_offset=0) = ["difference",
	straight_edge_fence_hull(face_offset=face_offset),
	
	for( ym=[-panel_size_atoms[1]/2+0.5 : 1 : panel_size_atoms[1]/2-0.5] )
	["translate", [-3.175, ym*atom, 0], togfdmod(floor(ym), 2) == 0 ? fence_hole1 : fence_hole2]
];

thing =
	what == "everything" ? ["union",
		["translate", [-panel_size[0], 0, 3*inch/8], straight_edge_fence(face_offset=fence_face_offset)],
		["translate", [             0, 0, 0       ], panel],
		["translate", [ panel_size[0], 0, 3*inch/8], ["rotate", [0,180,0], beveled_edge_fence(trim=0, face_offset=fence_face_offset)]],
		["translate", [ panel_size[0] + chunk, 0, 3*inch/8], ["rotate", [0,180,0], beveled_edge_fence(trim=fence_bevel_trim, face_offset=fence_face_offset)]],
	] :
	what == "panel" ? panel :
	what == "straight-fence" ? straight_edge_fence(face_offset=fence_face_offset) :
	what == "beveled-fence" ? beveled_edge_fence(trim=fence_bevel_trim, face_offset=fence_face_offset) :
	assert(false, str("What is the '", what, "'?"));

togmod1_domodule(thing);
