// MonitorMountRouterJig-v0.6
// 
// Versions:
// v0.2:
// - Renamed decode_for_x to decode_cut_for_x, since these
//   functions specifically deal with 'cuts'
// v0.3:
// - Can generate panel...almost.
//   Alignment holes should be countersunk on front, but are not yet.
// v0.4:
// - panel-front, panel-back [almost] work
// v0.5:
// - Counterbored panel assembly holes using polygen
// v0.5.1:
// - alignment_hole_countersink_inset configurable in 0.01mm increments
// v01.6:
// - 'panel-printable' mode with THL-1002 front gridbeam holes,
//   which print facing down.

mode = "front-template"; // ["front-template", "back-template", "panel", "panel-printable", "panel-front", "panel-back", "panel-cuts", "thl-1001"]

panel_corner_radius = 19.05  ; // 0.01
panel_thickness     = 19.05  ; // 0.01
counterbore_depth   =  4.7625; // 0.01

alignment_hole_countersink_inset = 1; // 0.01

/* [Detail] */

preview_fn = 9;
render_fn = 72;

module __end_params() { }

//// Inlined polyhedron generation library

function polygen_cap_faces( layers, layerspan, li, reverse=false ) = [
	[for( vi=reverse ? [layerspan-1 : -1 : 0] : [0 : 1 : layerspan-1] ) (vi%layerspan)+layerspan*li]
];

function polygen_layer_faces( layers, layerspan, i ) =
let( l0 = i*layerspan )
let( l1 = (i+1)*layerspan )
[
	for( vi=[0 : 1 : len(layers[i])-1] ) each [
		// By making triangles instead of quads,
		// we can avoid some avoidable 'non-planar face' warnings.
		[
			l0 + vi,
			l0 + (vi+1) % layerspan,
			l1 + (vi+1)%layerspan,
		],
		[
			l0 + vi,
			l1 + (vi+1)%layerspan,
			l1 + vi
		],
	]
];

function polygen_faces( layers, layerspan ) = [
	each polygen_cap_faces( layers, layerspan, 0, reverse=true ),
	// For now, assume convex end caps
	for( li=[0 : 1 : len(layers)-2] ) each polygen_layer_faces(layers, layerspan, li),
	each polygen_cap_faces( layers, layerspan, len(layers)-1, reverse=false )
];

function polygen_points(layers, layerspan) = [
	for( layer=layers ) for( point=layer ) point
];

function tlpoly_make_polyhedron(layers) =
	["polyhedron-vf", polygen_points(layers, len(layers[0])), polygen_faces(layers, len(layers[0]))];

////

inch = 25.4;

height = 9*inch;
top_y = height/2;
top_gb_hole_y = top_y - 3/4*inch;
top_monmount_hole_y = top_y - 9/4*inch;

panel_size = [6*inch, height, panel_thickness];

counterbore_diameter = 7/8*inch;
counterbore_template_diameter = counterbore_diameter;
hole_diameter = 8; // Slightly over 5/16*inch; need those weld nuts to fit!
// 12mm fits my 7/16" router bushing
hole_template_diameter = 12;

template_thickness = 6.35;

cuts = [
	for( xm=[-1.5 : 1 : 1.5] ) for( ym=[2.5, -2.5] ) ["front-counterbored-slot", [[xm*1.5*inch, ym*1.5*inch]]],
	for( xm=[-1.5, 1.5] ) for( ym=[-1.5, 1.5] ) ["front-counterbored-slot", [[xm*1.5*inch, ym*1.5*inch]]],
	["back-counterbored-slot", [[0, top_monmount_hole_y], [0, top_monmount_hole_y-1.5*inch]]],
	["back-counterbored-slot", [[0, top_monmount_hole_y-3*inch], [0, top_monmount_hole_y-4.5*inch]]],
	for( xm=[-1, 1] ) for( ym=[-2, 0, 2] ) ["alignment-hole", [xm*1.5*inch, ym*1.5*inch]],
];

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGHoleLib-v1.scad>

$fn = $preview ? preview_fn : render_fn;

function circle_points_with_z(r, pos=[0,0,0]) =
	let(fn = max($fn, 6)) [
		for(i=[0 : 1 : fn-1]) [
			pos[0]+r*cos(i*360/fn),
			pos[1]+r*sin(i*360/fn),
			pos[2]
		]
	];

function make_thl_1001(pos=[0,0,0]) = tlpoly_make_polyhedron([
	circle_points_with_z(3.5/2, [pos[0], pos[1], pos[2]- 100  ]),
	circle_points_with_z(3.5/2, [pos[0], pos[1], pos[2]-   1.7]),
	circle_points_with_z(7.5/2, [pos[0], pos[1], pos[2]+   0  ]),
	circle_points_with_z(7.5/2, [pos[0], pos[1], pos[2]+  10  ])
]);

// Countersunk on top,
// widened on bottom for heat-set insert
function make_panel_assembly_hole(pos=[0,0,0]) = tlpoly_make_polyhedron([
	circle_points_with_z(5  /2, [pos[0], pos[1],      0- 100  ]),
	circle_points_with_z(5  /2, [pos[0], pos[1],      0+  15  ]),
	circle_points_with_z(3.5/2, [pos[0], pos[1], pos[2]-   1.7]),
	circle_points_with_z(7.5/2, [pos[0], pos[1], pos[2]+   0  ]),
	circle_points_with_z(7.5/2, [pos[0], pos[1], pos[2]+  10  ])
]);

function make_thl_1002_hole(pos=[0,0,0]) = tlpoly_make_polyhedron([
	circle_points_with_z( 7/2, [pos[0], pos[1],      0- 100  ]),
	circle_points_with_z( 7/2, [pos[0], pos[1], pos[2]- 3.175]),
	circle_points_with_z(13/2, [pos[0], pos[1], pos[2]+   0  ]),
	circle_points_with_z(13/2, [pos[0], pos[1], pos[2]+  10  ])
]);

module fat_polyline(diameter, points) {
	assert(is_list(points))
	assert(len(points) == 0 || is_list(points[1]))
	if( len(points) == 0 ) {
	} else if( len(points) == 1 ) {
		translate(points[0]) circle(d=diameter);
	} else {
		for( i=[0 : 1 : len(points)-2] ) hull() {
			translate(points[i  ]) circle(d=diameter);
			translate(points[i+1]) circle(d=diameter);
		}
	}
}

function make_rounded_rect(size, r) =
	let(quarterfn=max($fn/4, 1))
	togmod1_make_polygon([
		for(a=[0 : 1 : quarterfn]) let(ang=      a*90/quarterfn) [ size[0]/2-r + r*cos(ang),  size[1]/2-r + r*sin(ang)],
		for(a=[0 : 1 : quarterfn]) let(ang= 90 + a*90/quarterfn) [-size[0]/2+r + r*cos(ang),  size[1]/2-r + r*sin(ang)],
		for(a=[0 : 1 : quarterfn]) let(ang=180 + a*90/quarterfn) [-size[0]/2+r + r*cos(ang), -size[1]/2+r + r*sin(ang)],
		for(a=[0 : 1 : quarterfn]) let(ang=270 + a*90/quarterfn) [ size[0]/2-r + r*cos(ang), -size[1]/2+r + r*sin(ang)],
	]);

function make_x_axis_oval(r, x0, x1) =
	x0 == x1 ? togmod1_make_circle(r, [x0, 0]) :
	let(fn = max(6, $fn))
	let(halffn = ceil(fn/2))
	togmod1_make_polygon([
		for(i=[0 : 1 : halffn]) let(ang=-90 + i*180/halffn) [x1+r*cos(ang), r*sin(ang)],
		for(i=[0 : 1 : halffn]) let(ang= 90 + i*180/halffn) [x0+r*cos(ang), r*sin(ang)]
	]);

// TODO: Do it without hull
function make_oval(r, p0, p1) = ["hull", togmod1_make_circle(r, p0), togmod1_make_circle(r, p1)];

// function oval(diameter, p0, p1) = ["hull", ["circle", 

function jj_is_pointlist(points, dims=2, offset=0) =
	is_list(points) && (
		len(points) - offset == 0 || (
			is_list(points[offset]) &&
			len(points[offset]) >= dims &&
			jj_is_pointlist(points, dims, offset+1)
		)
	);

function fat_polyline_to_togmod(r, points) =
	assert(jj_is_pointlist(points, 2), str("Expected point list, but got: ", points))
	len(points) == 0 ? ["union"] :
	len(points) == 1 ? togmod1_make_circle(r, points[0]) :
	["union",
		for( i=[0 : 1 : len(points)-2] ) make_oval(r, points[i], points[i+1])];

// fat_polyline(20, [[0,0], [100,100], [0,200]], $fn = 60);

function decode_cut_for_panel(
	cutdesc, panel_thickness, hole_diameter, counterbore_diameter, counterbore_depth, front_gridbeam_hole_style="counterbored"
) =
	// echo("decode_cut_for_panel", cutdesc=cutdesc)
	let( make_counterbored_slot = function(points, cb_pos)
		// echo("make_counterbored_slot", points=points)
		["union",
			each is_undef(cb_pos) ? [] : [
				["linear-extrude-zs", [cb_pos*panel_thickness - counterbore_depth, cb_pos*panel_thickness + counterbore_depth],
					fat_polyline_to_togmod(r=counterbore_diameter/2, points=points)],
			],
			["linear-extrude-zs", [-2, panel_thickness+2],
				fat_polyline_to_togmod(r=hole_diameter/2, points=points)]
		]
	)
	let( make_alignment_hole = function(pos)
		make_panel_assembly_hole([pos[0],pos[1],panel_thickness-alignment_hole_countersink_inset])
	)
	let( make_thl_1002_slot = function(points)
		assert(is_list(points) && len(points) == 1)
		make_thl_1002_hole([points[0][0], points[0][1], panel_thickness-alignment_hole_countersink_inset])
	)
	cutdesc[0] == "front-counterbored-slot" ? (
		front_gridbeam_hole_style == "counterbored" ?
			make_counterbored_slot(cutdesc[1], 1) :
			make_thl_1002_slot(cutdesc[1])
	) :
	cutdesc[0] == "back-counterbored-slot"  ?	make_counterbored_slot(cutdesc[1], 0) :
	cutdesc[0] == "normal-slot"             ? make_counterbored_slot(cutdesc[1]) :
	cutdesc[0] == "alignment-hole"          ? make_alignment_hole(cutdesc[1]) :
	assert(false, str("Unsupported panel cut: '", cutdesc[0], "'"));
	
function decode_cut_for_front_template(moddesc) =
	moddesc[0] == "front-counterbored-slot" ? ["fat-polyline-rp", counterbore_template_diameter/2, moddesc[1]] :
	moddesc[0] == "back-counterbored-slot" ? ["fat-polyline-rp", hole_template_diameter/2, moddesc[1]] :
	moddesc[0] == "normal-slot" ? ["fat-polyline-rp", hole_template_diameter/2, moddesc[1]] :
	assert(false, str("Unsupported front template shape: '", moddesc[0], "'"));

function decode_cut_for_back_template(moddesc) =
	moddesc[0] == "back-counterbored-slot" ? ["fat-polyline-rp", counterbore_template_diameter/2, moddesc[1]] :
	moddesc[0] == "front-counterbored-slot" ? ["fat-polyline-rp", hole_template_diameter/2, moddesc[1]] :
	moddesc[0] == "normal-slot" ? ["fat-polyline-rp", hole_template_diameter/2, moddesc[1]] :
	assert(false, str("Unsupported front template shape: '", moddesc[0], "'"));

function decode2(moddesc) =
	moddesc[0] == "fat-polyline-rp" ? fat_polyline_to_togmod(moddesc[1], moddesc[2]) :
	moddesc;

// togmod1_domodule(fat_polyline_to_togmod(20, [[-10, -20], [10, 0], [10,20]]));

// echo(cuts);
// echo(decode_cut_for_front_template(cuts[0]));

function decode_template_2d_cuts(scale, block, cuts, cut_decoder) = ["scale", scale, ["difference",
	block,
	for(cut=cuts) each cut[0] == "alignment-hole" ? [] : [decode2(cut_decoder(cut))]
]];

function make_the_template(hull_shape, cuts, mode) =
	mode == "front-template" ? decode_template_2d_cuts([ 1,1,1], hull_2d, cuts, function (c) decode_cut_for_front_template(c)) :
	mode == "back-template"  ? decode_template_2d_cuts([-1,1,1], hull_2d, cuts, function (c) decode_cut_for_back_template(c) ) :
	assert(str("Don't know how to make template in mode '", mode, "'"));

hull_2d = make_rounded_rect([6*inch, 9*inch], panel_corner_radius);

panel_cuts = [
	for( cut=cuts ) decode_cut_for_panel(cut,
		panel_thickness      = panel_thickness,
		hole_diameter        = hole_diameter,
		counterbore_diameter = counterbore_diameter,
		counterbore_depth    = counterbore_depth,
		front_gridbeam_hole_style = mode == "panel-printable" ? "THL-1002" : "counterbored"
	)
];

panel = ["difference",
	["linear-extrude-zs", [0, panel_thickness], hull_2d],
	each panel_cuts
];

panel_half_intersector = ["translate", [0,0, panel_thickness/4], togmod1_make_cuboid([panel_size[0]*2, panel_size[1]*2, panel_thickness/2])];

function jj_flip(mod, around_z) = ["translate", [0,0,around_z], ["scale", [1,1,-1], mod]];

// TODO: togmod1_domodule(final shape)
if( mode == "front-template" || mode == "back-template" ) {
	// TODO: Translate THL-1001 to TOGMod1 so you can do the whole thing in TOGMod1
	difference() {
		togmod1_domodule(["linear-extrude-zs", [0, template_thickness], make_the_template(hull_2d, cuts, mode)]);
		
		for( cut=cuts ) {
			if( cut[0] == "alignment-hole" ) {
				translate([cut[1][0], cut[1][1], template_thickness]) tog_holelib_hole("THL-1001");
			}
		}
	}
} else if( mode == "panel" ) {
	// Upside-down for easier printing
	togmod1_domodule(panel);
} else if( mode == "panel-printable" ) {
	// Upside-down for easier printing
	togmod1_domodule(jj_flip(panel, panel_thickness/2));
} else if( mode == "panel-cuts" ) {
	togmod1_domodule(["union", each panel_cuts]);
} else if( mode == "panel-front" ) {
	togmod1_domodule(["intersection",
		panel_half_intersector,
		["translate", [0,0,-panel_thickness/2], panel]
	]);
} else if( mode == "panel-back" ) {
	togmod1_domodule(["intersection",
		panel_half_intersector,
		jj_flip(panel, panel_thickness/2)
	]);
} else if( mode == "thl-1001" ) {
	togmod1_domodule(make_thl_1001([20,20,20]));
} else {
	assert(false, str("Unknown mode: '", mode, "'"));
}
