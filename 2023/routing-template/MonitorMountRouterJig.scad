// MonitorMountRouterJig-v0.2
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

mode = "front-template"; // ["front-template", "back-template", "panel", "panel-front", "panel-back"]

panel_thickness = 19.05;    // 0.01
counterbore_depth = 4.7625; // 0.01

module __end_params() { }

inch = 25.4;

height = 9*inch;
top_y = height/2;
top_gb_hole_y = top_y - 3/4*inch;
top_monmount_hole_y = top_y - 9/4*inch;

panel_size = [6*inch, height, panel_thickness];

counterbore_diameter = 7/8*inch;
counterbore_template_diameter = counterbore_diameter;
hole_diameter = 5/16*inch;
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

$fn = $preview ? 24 : 72;

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
	cutdesc, panel_thickness, hole_diameter, counterbore_diameter, counterbore_depth
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
		// TODO: Countersink!
		// Here's where THL-1001 needs to be a TOGMod shape!
		// For now, cylinder:
		["translate", pos, togmod1_make_cylinder(d=5, zrange=[-1, panel_thickness+1])]
	)
	cutdesc[0] == "front-counterbored-slot" ?	make_counterbored_slot(cutdesc[1], 1) :
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

hull_2d = make_rounded_rect([6*inch, 9*inch], 3/4*inch);

panel = ["difference",
	["linear-extrude-zs", [0, panel_thickness], hull_2d],
	for( cut=cuts ) decode_cut_for_panel(cut,
		panel_thickness      = panel_thickness,
		hole_diameter        = hole_diameter,
		counterbore_diameter = counterbore_diameter,
		counterbore_depth    = counterbore_depth
	)
];

panel_half_intersector = ["translate", [0,0, panel_thickness/4], togmod1_make_cuboid([panel_size[0]*2, panel_size[1]*2, panel_thickness/2])];

function jj_flip(mod, around_z) = ["translate", [0,0,around_z], ["scale", [1,1,-1], mod]];

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
	togmod1_domodule(panel);
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
} else {
	assert(false, str("Unknown mode: '", mode, "'"));
}
