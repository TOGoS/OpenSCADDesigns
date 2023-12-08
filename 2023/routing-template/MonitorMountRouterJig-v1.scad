// MonitorMountRouterJig-v1.4.2
// 
// Versions:
// v1.0:
// - Based on MonitorMountRouterJig-v0.6
// - Make slot and template diameters configurable
// - Make bushing and bit diameters configurable
//   (affects the template, but not the panel itself)
// - Add 'style' parameter so that different configurations
//   can be defined and chosen from
// v1.1:
// - Define MMP-2312, which is long and narrow
// v1.1.1:
// - Use polyhedrons for template alignment holes
//   instead of cutting them outside of the togmod
// v1.2:
// - Define MMP-2313, which is MMP-2312 but shorter
// - template_counterbore_bit_diameter = 8
// v1.3:
// - Define MMP-2314
// v1.4:
// - counterbore_diameter default = 7/8", not 5/8"
// - template_thickness default = 1/8" instead of 1/4"
// - Alignment holes every 3/4" along X except at X=0
// v1.4.1:
// - Refactor to only domoduile on the last line
// v1.4.2:
// - Use TOGPath1 to make ovals

// MMP-2310: original; MMP-2311: more alignment holes
style = "MMP-2310"; // ["MMP-2310", "MMP-2311","MMP-2312","MMP-2313","MMP-2314"]
mode = "front-template"; // ["front-template", "back-template", "panel", "panel-printable", "panel-front", "panel-back", "panel-cuts", "thl-1001"]

/* [Panel] **/

panel_corner_radius = 19.05  ; // 0.01
panel_thickness     = 19.05  ; // 0.01
counterbore_depth   =  4.7625; // 0.01
counterbore_diameter = 22.225;
// 8mm being a close approximation of 5/16"
slot_diameter       = 8;

alignment_hole_countersink_inset = 1; // 0.01

/* [Router Template] */

template_thickness = 3.175;
// Diameter of router bit that will be used to carve counterbores (mm)
template_counterbore_bit_diameter = 8;
// Diameter of router bushing that will be used to trace counterbore pattern (mm)
template_counterbore_bushing_diameter = 12;
// Diameter of router bit that will be used to carve slots (mm)
template_slot_bit_diameter = 8;
// Diameter of router bushing that will be used to trace slot pattern (mm)
template_slot_bushing_diameter = 12;

/* [Detail] */

preview_fn = 9;
render_fn = 72;

module __end_params() { }

inch = 25.4;

height = 9*inch;
top_y = height/2;
top_gb_hole_y = top_y - 3/4*inch;
top_monmount_hole_y = top_y - 9/4*inch;

// Difference in radius between actual and template counterbores due to bushing
template_counterbore_r_offset = (template_counterbore_bushing_diameter - template_counterbore_bit_diameter) / 2;
// Difference in radius between actual and template slots due to bushing
template_slot_r_offset        = (template_slot_bushing_diameter        - template_slot_bit_diameter       ) / 2;

template_counterbore_radius = counterbore_diameter/2 + template_counterbore_r_offset;
template_slot_radius        = slot_diameter/2 + template_slot_r_offset;

function get_alignment_hole_positions(style) =
	style == "MMP-2310" ? [ for( xm=[-1, 1] ) for( ym=[-2, 0, 2] ) [xm*1.5*inch, ym*1.5*inch] ] :
	style == "MMP-2311" ? [ for( xm=[-1 : 1 : 1] ) for( ym=[-2 : 1 : 2] ) [xm*1.5*inch, ym*1.5*inch] ] :
	assert(false, str("Unrecognized style: '", style, "'"));

function make_2312ish(size) =
let(size_chunks = [round(size[0]/(1.5*inch)), round(size[1]/(1.5*inch))])
[size, [
	for( ym=[-size_chunks[1]/2+2 : 2 : size_chunks[1]/2-2] )
		["back-counterbored-slot", [[0, (ym-0.5)*1.5*inch], [0, (ym+0.5)*1.5*inch]]],
	
	for( ym=[-size_chunks[1]/2+0.5 : 1 : size_chunks[1]/2] ) for( xm=[-size_chunks[0]/2+0.5, size_chunks[0]/2-0.5] )
		["front-counterbored-slot", [[xm*1.5*inch, ym*1.5*inch]]],
	for( ym=[-size_chunks[1]/2+0.5, size_chunks[1]/2-0.5] ) for( xm=[-size_chunks[0]/2+1.5, size_chunks[0]/2-1.5] )
		["front-counterbored-slot", [[xm*1.5*inch, ym*1.5*inch]]],
	
	for( xm=[-size_chunks[0]/2+1 : 0.5 : size_chunks[0]/2-1] ) for( ym=[-size_chunks[1]/2+1 : 1 : size_chunks[1]/2-1] )
		if( xm != 0 ) ["alignment-hole", [xm*1.5*inch, ym*1.5*inch]],
]];

// style name -> [size, cuts]
function get_panel_info(style) =
	(style == "MMP-2310" || style == "MMP-2311") ? [[6*inch,9*inch], [
		for( xm=[-1.5 : 1 : 1.5] ) for( ym=[2.5, -2.5] ) ["front-counterbored-slot", [[xm*1.5*inch, ym*1.5*inch]]],
		for( xm=[-1.5, 1.5] ) for( ym=[-1.5, 1.5] ) ["front-counterbored-slot", [[xm*1.5*inch, ym*1.5*inch]]],
		["back-counterbored-slot", [[0, top_monmount_hole_y], [0, top_monmount_hole_y-1.5*inch]]],
		["back-counterbored-slot", [[0, top_monmount_hole_y-3*inch], [0, top_monmount_hole_y-4.5*inch]]],
		for(pos = get_alignment_hole_positions(style)) ["alignment-hole", pos],
		//for( xm=[-1, 1] ) for( ym=[-2, 0, 2] ) ["alignment-hole", [xm*1.5*inch, ym*1.5*inch]],
	]] :
	style == "MMP-2312" ? make_2312ish([4.5*inch, 18*inch]) :
	style == "MMP-2313" ? make_2312ish([4.5*inch, 12*inch]) :
	style == "MMP-2314" ? make_2312ish([6.0*inch, 12*inch]) :
	assert(false, str("Unrecognized style: '", style, "'"));

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGPath1.scad>

$fn = $preview ? preview_fn : render_fn;

function circle_points_with_z(r, pos=[0,0,0]) =
	let(fn = max($fn, 6)) [
		for(i=[0 : 1 : fn-1]) [
			pos[0]+r*cos(i*360/fn),
			pos[1]+r*sin(i*360/fn),
			pos[2]
		]
	];

function make_thl_1001(pos=[0,0,0]) = tphl1_make_polyhedron_from_layers([
	circle_points_with_z(3.5/2, [pos[0], pos[1], pos[2]- 100  ]),
	circle_points_with_z(3.5/2, [pos[0], pos[1], pos[2]-   1.7]),
	circle_points_with_z(7.5/2, [pos[0], pos[1], pos[2]+   0  ]),
	circle_points_with_z(7.5/2, [pos[0], pos[1], pos[2]+  10  ])
]);

// Countersunk on top,
// widened on bottom for heat-set insert
function make_panel_assembly_hole(pos=[0,0,0]) = tphl1_make_polyhedron_from_layers([
	circle_points_with_z(5  /2, [pos[0], pos[1],      0- 100  ]),
	circle_points_with_z(5  /2, [pos[0], pos[1],      0+  15  ]),
	circle_points_with_z(3.5/2, [pos[0], pos[1], pos[2]-   1.7]),
	circle_points_with_z(7.5/2, [pos[0], pos[1], pos[2]+   0  ]),
	circle_points_with_z(7.5/2, [pos[0], pos[1], pos[2]+  10  ])
]);

function make_thl_1002_hole(pos=[0,0,0]) = tphl1_make_polyhedron_from_layers([
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

function make_oval(r, p0, p1) =
let(diff = p1-p0)
let(ang = atan2(diff[1], diff[0]))
togmod1_make_polygon(togpath1_qath_points(["togpath1-qath",
	["togpath1-qathseg", p0, ang-270, ang-90, r],
	["togpath1-qathseg", p1, ang-90, ang+90, r]
]));

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
	cutdesc, panel_thickness, slot_diameter, counterbore_diameter, counterbore_depth, front_gridbeam_hole_style="counterbored"
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
				fat_polyline_to_togmod(r=slot_diameter/2, points=points)]
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
	moddesc[0] == "front-counterbored-slot" ? ["fat-polyline-rp", template_counterbore_radius, moddesc[1]] :
	moddesc[0] == "back-counterbored-slot" ? ["fat-polyline-rp", template_slot_radius, moddesc[1]] :
	moddesc[0] == "normal-slot" ? ["fat-polyline-rp", template_slot_radius, moddesc[1]] :
	assert(false, str("Unsupported front template shape: '", moddesc[0], "'"));

function decode_cut_for_back_template(moddesc) =
	moddesc[0] == "back-counterbored-slot" ? ["fat-polyline-rp", template_counterbore_radius, moddesc[1]] :
	moddesc[0] == "front-counterbored-slot" ? ["fat-polyline-rp", template_slot_radius, moddesc[1]] :
	moddesc[0] == "normal-slot" ? ["fat-polyline-rp", template_slot_radius, moddesc[1]] :
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

function make_the_template_2d(hull_shape_2d, cuts, mode) =
	mode == "front-template" ? decode_template_2d_cuts([ 1,1,1], hull_shape_2d, cuts, function (c) decode_cut_for_front_template(c)) :
	mode == "back-template"  ? decode_template_2d_cuts([-1,1,1], hull_shape_2d, cuts, function (c) decode_cut_for_back_template(c) ) :
	assert(str("Don't know how to make template in mode '", mode, "'"));

function make_the_template(hull_shape_2d, cuts, mode, thickness) = ["difference",
	["linear-extrude-zs", [0, thickness], make_the_template_2d(hull_shape_2d, cuts, mode)],
	
	for(cut=cuts) if(cut[0] == "alignment-hole") make_thl_1001([cut[1][0], cut[1][1], thickness-alignment_hole_countersink_inset]),
];


panel_info = get_panel_info(style);
panel_size = panel_info[0];
cuts = panel_info[1];

hull_2d = togmod1_make_rounded_rect(panel_size, panel_corner_radius);

panel_cuts = [
	for( cut=cuts ) decode_cut_for_panel(cut,
		panel_thickness      = panel_thickness,
		slot_diameter        = slot_diameter,
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

the_shape =
	mode == "front-template" || mode == "back-template" ?
		make_the_template(hull_2d, cuts, mode, template_thickness) :
	mode == "panel" ? panel :
	mode == "panel-printable" ?
		// Upside-down for easier printing
		jj_flip(panel, panel_thickness/2) :
	mode == "panel-cuts" ? ["union", each panel_cuts] :
	mode == "panel-front" ? ["intersection",
		panel_half_intersector,
		["translate", [0,0,-panel_thickness/2], panel]
	] :
	mode == "panel-back" ? ["intersection",
		panel_half_intersector,
		jj_flip(panel, panel_thickness/2)
	] :
	mode == "thl-1001" ? make_thl_1001([20,20,20]) :
	assert(false, str("Unknown mode: '", mode, "'"));

togmod1_domodule(the_shape);
