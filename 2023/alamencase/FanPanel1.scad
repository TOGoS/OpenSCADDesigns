// FanPanel1.2
// 
// Various fan-related parts
// Based on FanPanel0, but replacing the 'cxtor' stuff
// with regular block-segmented TOGridPile stuff.
//
// Versions:
// v1.0:
// - Based on FanPanel0.9
// v1.1:
// - fan-panel only for now; not sure what I want to do with other parts
// - based on a TGx11 block-segmented block
// v1.2:
// - Add 'filter-holder', with height fixed at 1.5".

// TODO
//	- [X] Get rid of the cxtor bits, replace with block-segmented TOGridPile lips
//	- [X] Have single lip_height parameter for all the parts
//	- [/] all 5" parts should allow for both 4.5" and 100mm-spaced holes
// 
// Parts:
// - adapter panel
// - fan holder    (5" square)
// - filter holder (5" square)
// - filter cartridge bottom+sides
// - filter cartridge top
// Note that the filter cartridges will be interchangeable
// with the FanPanel0 ones, so don't really need a different version
// of them except to demonstrate 'TOGridPile instead of special-purpose cxtor'

// Notes:
// - 120mm fans are, supposedly, 120mm in diameter.
//   This is actually the size of their enclosure
//   (120mm x 120mm x 25mm), so the fan is a little smaller.
// - Hole spacing for 120mm fans is a 105mm square

what = "fan-holder"; // ["fan-holder","filter-holder"]
inner_margin = 0.2;
// Also negative rgx11_offset
outer_margin = 0.1;
lip_height   = 1.6; // 0.1

// Additional cutout at bottom of fan holder for 4.5" TOGridPile blocks
fan_holder_filter_seat_depth = 0; // 0.1

module fp1__end_params() { }

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGridLib3.scad>
use <../lib/TOGVecLib0.scad>
use <../lib/TGx11.1Lib.scad>

$togridlib3_unit_table = tgx11_get_default_unit_table();
$tgx11_offset = -outer_margin;
$fn = $preview ? 16 : 24;

function fp1__tovec3(z) = is_list(z) ? z : [0,0,z];

function fp1__ring(rath, xy_zs, pos=0) =
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
				togvec0_add_vec(fp1__tovec3(pos), fp1__tovec3(z_offset))
			)
		),
		cap_top    = false,
		cap_bottom = false
	);

function fp1__wall_hull(rath, height, thickin, thickout) =
	fp1__ring(rath, [
		[-thickin ,      0],
		[ thickout,      0],
		[ thickout, height],
		[-thickin , height],
	]);

function fp1_wr_wall(rath, height, thickin, thickout) =
	["difference",
		fp1__wall_hull(rath, height, thickin, thickout),
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
wall_height     = 1.25*inch;
wall_thickness  = 6.35;
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

thl_1007 = tog_holelib2_hole("THL-1007", depth=50, inset=2);

function slot_polygon_points(points, radius, end_shape="bev") =
	assert(is_list(points))
	assert(is_num(radius))
	assert(radius > 0)
	let( slot_rath_square = togpath1_polyline_to_rath(points, radius, end_shape="square") )
	let( slot_rath =
		end_shape == "bev" ? ["togpath1-rath", for(i=[1:1:len(slot_rath_square)-1]) [each slot_rath_square[i], ["bevel",radius/2], ["round", 1]]] :
		togpath1_polyline_to_rath(points, radius, end_shape=end_shape)
	)
	togpath1_rath_to_polypoints(slot_rath);

function extrude_polyline(points, zds, end_shape="bev") = tphl1_make_polyhedron_from_layer_function(zds, function(zd)
	togvec0_offset_points(slot_polygon_points(points, zd[1]/2, end_shape=end_shape), zd[0]));

// fa_panel_fhole = thl_1007;
fa_panel_mhole = ["render", ["rotate", [180,0,0], thl_1007]];
fa_panel_fslot = extrude_polyline([for(d=[100,105]) [d/2,d/2]], zds=[
	[                  -1, 4.5],
	[fa_panel_thickness/2, 4.5],
	[fa_panel_thickness/2, 9.5],
	[fa_panel_thickness+1, 9.5],
]);
function make_fslot(zrange) = extrude_polyline([for(d=[100,105]) [d/2,d/2]], zds=[
	[zrange[0], 4.5],
	[zrange[1], 4.5],
]);

// Single cord troff extending from -x-y to +x+y;
// intersect with something if you want it to not extend beyond the edges.
function make_cord_troff(zrange) =
let( dep = zrange[1]-zrange[0] )
extrude_polyline([for(d=[-200,200]) [d/2,d/2]], zds=[
	[zrange[0]      , 9      ],
	[zrange[1]-dep/2, 9      ],
	[zrange[1]+dep/2, 9+2*dep],
]);

function rotti2(thing) = ["union", for(a=[0,90]) ["rotate", [0,0,a], thing]];
function rotti4(thing) = ["union", for(a=[0,90,180,270]) ["rotate", [0,0,a], thing]];

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
	// HMM I THIN KTHERE's a reason this wasn't printed right-side-up
	tgx11_block([[5, "inch"], [6.5, "inch"], [fa_panel_thickness, "mm"]], bottom_segmentation="block", top_segmentation="none", lip_height=lip_height),

	togmod1_linear_extrude_z([-1,fa_panel_thickness+1], ["union",
		center_cutout_2d, // Big center hole for air
		for( x=[-38.1,0,38.1] ) ["translate", [x,2*inch], togmod1_make_rounded_rect([6.35, 1.35*inch], r=3)], // Slots for the cable
	]),
	
	for( ang=[0,90,180,270] ) ["rotate", [0,0,ang], fa_panel_fslot],
	// for( pos=120mm_mounting_hole_positions ) ["translate", [pos[0],pos[1],0], ["rotate",[180,0,0],fa_panel_fhole]],
	
	for( pos=rect_edge_mhole_positions(fa_panel_size, 12.7) )
		if( round(abs(pos[1]/12.7) - 4) != 0 )
			["translate", [pos[0],pos[1],0], fa_panel_mhole],
];

the_filter_holder_wall = fp1_wr_wall(
	wall_rath, wall_height,
	wall_thickness/2 - inner_margin,
	wall_thickness/2 - outer_margin
);

the_panel_holes = ["union",
	for( rot=[0,90,180,270] ) ["rotate", [0,0,rot], fp_fhol2]
];

the_filter_holder_bottom_panel = ["difference",
	tgx11_block([[4.5, "inch"], [4.5, "inch"], [panel_thickness, "mm"]], bottom_segmentation="block", top_segmentation="block", lip_height=lip_height),
	
	togmod1_linear_extrude_z([-1, panel_thickness+1], center_cutout_2d),
	// for( pos=120mm_mounting_hole_positions ) ["translate", [pos[0],pos[1],panel_thickness], fp_fhole],
	["translate", [0,0,panel_thickness], the_panel_holes],
];

the_filter_holder =
	let( height = 38.1 )
	//let( hull_rath = togpath1_offset_rath(wall_rath, wall_thickness/2-outer_margin) )
	let( interior_rath = togpath1_offset_rath(wall_rath, -wall_thickness/2+inner_margin) )
	["difference",
	   //togmod1_linear_extrude_z([0,height], togmod1_make_polygon(togpath1_rath_to_polypoints(hull_rath))),
		tgx11_block([[5, "inch"], [5, "inch"], [height, "mm"]], bottom_segmentation="block", top_segmentation="block", lip_height=lip_height),
		
		togmod1_linear_extrude_z([panel_thickness,height+1], togmod1_make_polygon(togpath1_rath_to_polypoints(interior_rath))),
		togmod1_linear_extrude_z([-1, height+1], center_cutout_2d),
		["translate", [0,0,panel_thickness], the_panel_holes],
	];

the_fan_holder =
let( block_size_ca = [[5, "inch"], [5, "inch"], [1.25, "inch"]] )
let( block_size = togridlib3_decode_vector(block_size_ca) )
let( height = block_size[2] )
let( slot_positions = [[-2*inch, -2.5*inch]] )
let( floor_thickness = height-1*inch )
let( fan_size = [120,120,25] )
let( corner_vhole_diameter = 20 )
["difference",
	tgx11_block(
		block_size_ca,
		bottom_segmentation = "block",
		top_segmentation = "block",
		lip_height = lip_height
	),
	
	["intersection",
		// XY hull of central cutout
		tphl1_make_rounded_cuboid([fan_size[0]+inner_margin*2,fan_size[0]+inner_margin*2,height*3], r=[1,1,0]),
		
		["union",
			["translate", [0,0,height], togmod1_make_cuboid([200,200,max(2*inch, (fan_size[2]+outer_margin)*2)])],
			
			// Additional cutouts in floor
			// Wire troffs
			rotti2(make_cord_troff([floor_thickness/2, floor_thickness])),
			// A hole in the corner,
			// in case you want to pass the wire through that way
			["translate", [fan_size[0]/2, fan_size[1]/2], tphl1_make_z_cylinder(d=corner_vhole_diameter, zrange=[-1, height+1])],
		],
	],
	//["translate", [0,0,height], tphl1_make_rounded_cuboid([121.5,121.5,2*inch], r=[1,1,0])],
	togmod1_linear_extrude_z([-1, 100], center_cutout_2d),
	for( pos=slot_positions ) ["translate", [pos[0], pos[1], 0.75*inch],
		//["rotate", [90,0,0],	tphl1_make_z_cylinder(d=10, zrange=[-100,100])]
		togmod1_linear_extrude_y( [-10,10], togmod1_make_rounded_rect([10,10], r=4.5) )
	],
	for( pos=slot_positions ) ["translate", [pos[0], pos[1], 1.25*inch],
		//["rotate", [90,0,0],	tphl1_make_z_cylinder(d=10, zrange=[-100,100])]
		togmod1_linear_extrude_y( [-10,10], togmod1_make_rect([4,20]) )
	],
	// Corner holes
	for( r=[-45,45,135] ) ["rotate", [0,0,r], ["translate", [0,0,0.75*inch], togmod1_linear_extrude_x( [0,100], togmod1_make_rounded_rect([5,10], r=2) )]],
	rotti4(make_fslot([-1, 1.25*inch])),
	
	if( fan_holder_filter_seat_depth > 0 )
	["translate", [0,0,floor_thickness-fan_holder_filter_seat_depth], tgx11_block([[4.5,"inch"],[4.5,"inch"],[1,"inch"]], bottom_segmentation="block", $tgx11_offset=-$tgx11_offset, $tgx11_gender="f")],
];

thing =
	what == "THL-1007" ? thl_1007 :
	what == "fan-adapter-panel" ? the_fan_adapter_panel :
	what == "filter-holder-bottom-panel" ? the_filter_holder_bottom_panel :
	what == "filter-holder-wall" ? the_filter_holder_wall :
	what == "filter-holder" ? the_filter_holder :
	what == "fan-holder" ? the_fan_holder :
	assert(false, str("What is the ", what, "?"));

togmod1_domodule(thing);
