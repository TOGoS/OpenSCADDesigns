// FanPanel0.6
// 
// Various fan-related parts
// 
// Versions:
// v0.2:
// - Add 'cxtor-demo' mode, which exists so I could take a screenshot
//   of both the matching parts at once.
// v0.3:
// - Extend mounting holes into slots that will align
//   with either 120mm fan holes (105mm pattern)
//   or TOGBeams (101.6mm pattern).
// v0.4:
// - Configurable inner and outer margins
// v0.5:
// - Actually let's make the smaller hole pattern 100mm,
//   in case someone wants to use this with some
//   25mm-based system.
// v0.6:
// - Add 'filter-holder'

// Notes:
// - 120mm fans are, supposedly, 120mm in diameter.
//   This is actually the size of their enclosure
//   (120mm x 120mm x 25mm), so the fan is a little smaller.
// - Hole spacing for 120mm fans is a 105mm square

what = "filter-holder-bottom-panel"; // ["fan-adapter-panel","filter-holder-bottom-panel","filter-holder-wall","filter-holder","cxtor-demo"]
inner_margin = 0.2;
outer_margin = 0.1;

module fp0__end_params() { }

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGVecLib0.scad>

$fn = 24;

function fp0__tovec3(z) = is_list(z) ? z : [0,0,z];

function fp0__ring(rath, xy_zs, pos=0) =
	tphl1_make_polyhedron_from_layer_function(
		[
			each xy_zs,
			xy_zs[0], // Top = bottom
		],
		function(xy_z) (
			let( xy_offset = xy_z[0] )
			let(  z_offset = xy_z[1] )
			togvec0_offset_points(
				togpath1_rath_to_polypoints(togpath1_offset_rath(rath, xy_offset)),
				togvec0_add_vec(fp0__tovec3(pos), fp0__tovec3(z_offset))
			)
		),
		cap_top    = false,
		cap_bottom = false
	);

/**
 * Turn a closed path (represented as a Rath)
 * into a diamond-shaped ridge thing.
 */
function fp0__cxtor(rath, pos=0, r=25.4/16) =
	fp0__ring(rath, [
		[-r,  0],
		[ 0, -r],
		[ r,  0],
		[ 0,  r],
	], pos=pos);

function fp0__wall_hull(rath, height, thickin, thickout) =
	let( cxtor = fp0__cxtor(rath) )
	fp0__ring(rath, [
		[-thickin ,      0],
		[ thickout,      0],
		[ thickout, height],
		[-thickin , height],
	]);

function fp0_wr_wall(rath, height, thickin, thickout) =
	let( cxtor = fp0__cxtor(rath, r=inch/16+0.1) )
	["difference",
		fp0__wall_hull(rath, height, thickin, thickout),
		["translate", [0,0,0     ], cxtor],
		["translate", [0,0,height], cxtor],
	];

// Wall-ridged panel
function fp0_wr_panel(rath, panel_thickness, thickout) =
	let( cxtor = fp0__cxtor(rath, r=inch/16-0.1) )
	let( panel_rath = togpath1_offset_rath(rath, thickout) )
	let( panel_polypoints = togpath1_rath_to_polypoints(panel_rath) )
	["union",
		tphl1_make_polyhedron_from_layer_function(
			[0,panel_thickness],
			function(z) togvec0_offset_points(panel_polypoints, z)
		),
		["translate", [0,0,panel_thickness], cxtor],
	];

function rect_corner_positions(size) =	[
	[-size[0]/2, -size[1]/2],
	[ size[0]/2, -size[1]/2],
	[ size[0]/2,  size[1]/2],
	[-size[0]/2,  size[1]/2],
];

function rect_edge_mhole_positions(size, pitch) =
let( exm = round(size[0]/pitch)/2 - 0.5 )
let( eym = round(size[1]/pitch)/2 - 0.5 )
[
	for( xm=[ -exm : 1 : exm ] ) for( ym=[ -eym, eym ] ) [xm*pitch, ym*pitch],
	for( xm=[ -exm, exm ] ) for( ym=[ -eym+1 : 1 : eym-1 ] ) [xm*pitch, ym*pitch],
];




inch = 25.4;
box_size = [5*inch, 5*inch];
wall_height    = 1.25*inch;
wall_thickness = 6.35;
panel_thickness = 3.175;

120mm_mounting_hole_positions = rect_corner_positions([105,105]);

wall_rath =
let( cx = box_size[0]/2 - wall_thickness/2 )
let( cy = box_size[1]/2 - wall_thickness/2 )
let( corner_ops = [["round", inch*3/16]] )
["togpath1-rath",
	["togpath1-rathnode", [-cx, -cy], each corner_ops],
	["togpath1-rathnode", [ cx, -cy], each corner_ops],
	["togpath1-rathnode", [ cx,  cy], each corner_ops],
	["togpath1-rathnode", [-cx,  cy], each corner_ops],
];

fa_panel_thickness = 6.35;

thl_1005 = tog_holelib2_hole("THL-1005", depth=50, inset=2);

fa_panel_fhole = thl_1005;
fa_panel_mhole = thl_1005;


fp_fhole = tog_holelib2_hole("THL-1001", depth=50, inset=0.1);
fp_fhole_top = tog_holelib2_hole("THL-1001", depth=0, inset=0.1);
fp_fhole_shaft = tphl1_make_z_cylinder(zrange=[-50,50], d=4.5);

fp_fhol2 =
	let( hole_spacings=[100,105] )
	let( parts=[fp_fhole_top, fp_fhole_shaft] )
	["union",
		// Surely there is a more elegant way to do this;
		// actually I think there's a polyline function somewher;
		// just not bothering for now.
		for( part=parts ) ["hull",
			for( spac=hole_spacings ) ["translate", [spac/2, spac/2], part]
		],
	];

center_cutout_2d = ["intersection",
	togmod1_make_circle(d=120, $fn=72),
	togmod1_make_rect([4*inch,4.25*inch])
];

the_fan_adapter_panel =
let( fa_panel_size = [5*inch, 6.5*inch, fa_panel_thickness] )
["difference",
	togmod1_linear_extrude_z([0,fa_panel_thickness], ["difference",
		togmod1_make_rounded_rect([fa_panel_size[0] - outer_margin*2, fa_panel_size[1] - outer_margin*2], r=6.35),
		
		center_cutout_2d, // Big center hole for air
		for( x=[-38.1,0,38.1] ) ["translate", [x,2*inch], togmod1_make_rounded_rect([6.35, 1.35*inch], r=3)], // Slot for the cable
	]),
	
	for( pos=120mm_mounting_hole_positions ) ["translate", [pos[0],pos[1],0], ["rotate",[180,0,0],fa_panel_fhole]],
	
	for( pos=rect_edge_mhole_positions(fa_panel_size, 12.7) )
		if( round(abs(pos[1]/12.7) - 4) != 0 )
			["translate", [pos[0],pos[1],fa_panel_thickness], fa_panel_mhole],
];

the_filter_holder_wall = fp0_wr_wall(
	wall_rath, wall_height,
	wall_thickness/2 - inner_margin,
	wall_thickness/2 - outer_margin
);

the_panel_holes = ["union",
	for( rot=[0,90,180,270] ) ["rotate", [0,0,rot], fp_fhol2]
];

the_filter_holder_bottom_panel = ["difference",
	fp0_wr_panel(wall_rath, panel_thickness, wall_thickness/2 - outer_margin),
	
	togmod1_linear_extrude_z([-1, panel_thickness+1], center_cutout_2d),
	// for( pos=120mm_mounting_hole_positions ) ["translate", [pos[0],pos[1],panel_thickness], fp_fhole],
	["translate", [0,0,panel_thickness], the_panel_holes],
];

the_filter_holder =
	let( cxtor = fp0__cxtor(wall_rath, r=inch/16-0.1) )
	let( height = panel_thickness + wall_height )
	let( hull_rath = togpath1_offset_rath(wall_rath, wall_thickness/2-outer_margin) )
	let( interior_rath = togpath1_offset_rath(wall_rath, -wall_thickness/2+inner_margin) )
	["difference",
	   togmod1_linear_extrude_z([0,height], togmod1_make_polygon(togpath1_rath_to_polypoints(hull_rath))),
		togmod1_linear_extrude_z([panel_thickness,height+1], togmod1_make_polygon(togpath1_rath_to_polypoints(interior_rath))),
		togmod1_linear_extrude_z([-1, height+1], center_cutout_2d),
		["translate", [0,0,panel_thickness], the_panel_holes],
		["translate", [0,0,height], cxtor],
	];

thing =
	what == "fan-adapter-panel" ? the_fan_adapter_panel :
	what == "filter-holder-bottom-panel" ? the_filter_holder_bottom_panel :
	what == "filter-holder-wall" ? the_filter_holder_wall :
	what == "filter-holder" ? the_filter_holder :
	what == "cxtor-demo" ? ["union", the_filter_holder_wall, ["translate", [6*inch, 0, 0], the_filter_holder_bottom_panel]] :
	assert(false, str("What is the ", what, "?"));

togmod1_domodule(thing);
