// HollowFrenchCleat1.9
// 
// 3D-printable mostly-hollow French cleat section for light use
//
// v1.1:
// - end_offset separately configurable from outer_offset,
//   default is to only offset the ends slightly
// - Attempt to properly calculate y offsets for given slopes.
//   - Currently works approximately for -1, 0, and 1
//   - At least dydz = 0 works, now.
// v1.2:
// - Fix the math for vector offsetting to dx = tan(a/2)
// v1.3:
// - Add option for 'solid' style
// v1.4:
// - Add 'hollow2' style, which has more tightly-spaced x-wise walls
// v1.5:
// - Add 'round-with-base' and 'none' bowtie connector styles
// v1.6:
// - Allow beveling of the pointy corners,
//   which implicitly does a little bit of rounding, also
// v1.7:
// - Configurable hole_style
// - Fix subtraction order so that screw holes
//   cut through outer walls and bowtie borders
// v1.8:
// - raft_thickness option
// v1.9:
// - Specify length and height in arbitrary units
// - Minor fix so that rounding errors don't prevent interior walls from being placed
// - Add floor_thickness parameter, allowing for floors thicker than outer walls.
//   Hollow with floor_thickness > thickness of FC is effectively solid.
// - Add counterbore_depth parameter
// - Fix counterbores to match floor height in non-solid cases
// - Avoid placing screw holes in bowtie cutouts

outer_wall_thickness = 2;
inner_wall_thickness = 0.8;

length        = "5chunk";
height        = "2chunk";
top_dydz      = +1; // [-1, 0, 1]
bottom_dydz   = -1; // [-1, 0, 1]
hole_style    = "THL-1010";
end_offset    = -0.03;
outer_offset  = -0.00;
bowtie_offset = -0.03;
body_style    = "hollow"; // ["hollow","solid","hollow2"]
bowtie_style  = "round"; // ["none","round", "round-with-base"]
bevel_size    =  0.0;

// Extra floor for bottom of hollow; -2 means same as outer_wall thickness
floor_thickness = -2;
// Minimum depth of counterbores; actual depth may be deeper for hollow FCs
min_counterbore_depth = 4.5;

// Set to first layer height to make a solid first layer
raft_thickness = 0; // 0.01

$fn = 32;

use <../lib/RoundBowtie0.scad>
use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGStringLib1.scad>
use <../lib/TOGridLib3.scad>

module assert_equals(expected, actual) {
	assert(abs(expected - actual) < 0.01, str("Expected ", expected, "; got ", actual));
}

// Maybe this should be a library function
function decode_quantity_to_num(quantity_str, unit=[1, "mm"]) =
	let( quantity_q_r = togstr1_parse_quantity(quantity_str) ) // [[[num, den], unit_name], end_offset]
	assert(quantity_q_r[1] > 0, str("Failed to parse quantity from '", quantity_str, "'"))
	togridlib3_decode([quantity_q_r[0][0][0], quantity_q_r[0][1]], unit=unit) / quantity_q_r[0][0][1];

// I forget the combination of trigonometric functions to do it and
// don't want to think about it right now.
// TOGPath1 does this properly for vertex offsets.
// I should make a diagram and put it on nuke24.net or something.

function hfc1_van(dydz) = tan(atan2(1,dydz)/2);

assert_equals(0.414, hfc1_van(+1));
assert_equals(1    , hfc1_van( 0));
assert_equals(2.414, hfc1_van(-1));

function hfc1_shell( size, top_dydz, bottom_dydz, offset=0, front_offset=0, end_offset=0, bevel_size=0 ) =
	let( bf_bev = bottom_dydz < 0 ? bevel_size : 0 )
	let( tf_bev =    top_dydz > 0 ? bevel_size : 0 )
	let( bb_bev = bottom_dydz > 0 ? bevel_size : 0 )
	let( tb_bev =    top_dydz < 0 ? bevel_size : 0 )
	let( ops = [["offset", offset]] )
	let( mops = [["offset", offset], if(bevel_size > 0 ) ["round", bevel_size/2]] )
	togmod1_linear_extrude_x(
		[-size[0]/2 - offset - end_offset, size[0]/2 + offset + end_offset],
		togmod1_make_polygon(togpath1_rath_to_polypoints(["togpath1-rath",
			["togpath1-rathnode", [ size[1]/2 -    top_dydz*size[2]/2 - tb_bev, -size[2]/2               ], each ops],
			
			if( tb_bev > 0 )
			["togpath1-rathnode", [ size[1]/2 -    top_dydz*size[2]/2 - tb_bev, -size[2]/2 + tb_bev      ], each mops],
			
			if( tf_bev > 0 || front_offset > 0 )
			["togpath1-rathnode", [ size[1]/2 +    top_dydz*size[2]/2 - tf_bev,  size[2]/2 - tf_bev      ], each mops],

			["togpath1-rathnode", [ size[1]/2 +    top_dydz*size[2]/2 - tf_bev,  size[2]/2 + front_offset], each mops],
			["togpath1-rathnode", [-size[1]/2 + bottom_dydz*size[2]/2 + bf_bev,  size[2]/2 + front_offset], each mops],
			
			if( bf_bev > 0 || front_offset > 0 )
			["togpath1-rathnode", [-size[1]/2 + bottom_dydz*size[2]/2 + bf_bev,  size[2]/2 - bf_bev      ], each mops],

			if( bb_bev > 0 )
			["togpath1-rathnode", [-size[1]/2 - bottom_dydz*size[2]/2 + bb_bev, -size[2]/2 + bb_bev      ], each mops],
			
			["togpath1-rathnode", [-size[1]/2 - bottom_dydz*size[2]/2 + bb_bev, -size[2]/2               ], each ops],
		])));

inch        = togridlib3_decode([1,"inch"]);
chunk_pitch = 38.1; // togridlib3_decode([1,"chunk"]);
atom_pitch  = togridlib3_decode([1,"atom"]);

size = [decode_quantity_to_num(length), decode_quantity_to_num(height), chunk_pitch/2];

effective_floor_thickness =
	assert(floor_thickness == -2 || floor_thickness > outer_wall_thickness, str(
		"Floor thickness (", floor_thickness, ") < outer_wall_thickness (",
		outer_wall_thickness, ") not currently supported; ",
		"set to -2 to indicate 'same as outer wall thickness'"
	))
	body_style == "solid" ? size[2]/2 :
	max(floor_thickness, outer_wall_thickness);

outer_hull = hfc1_shell(size, top_dydz, bottom_dydz, offset=outer_offset, end_offset=end_offset, bevel_size=bevel_size);

atom_hollow = hfc1_shell([atom_pitch, size[1], size[2]], top_dydz, bottom_dydz, offset=outer_offset-outer_wall_thickness, front_offset=outer_wall_thickness*2, bevel_size=bevel_size);

// Make sure counterbores go as deep as the hollow
atom_hole_cb_z =
	min(size[2]/2 - min_counterbore_depth, -size[2]/2 + effective_floor_thickness + 0.01);

atom_hole = ["render", tog_holelib2_hole(hole_style,
	depth=raft_thickness == 0 ? size[2] : size[2]/2-raft_thickness,
	overhead_bore_height=size[2],
	inset=-atom_hole_cb_z
)];

basic_bowtie_border = togmod1_linear_extrude_z([-size[2], size[2]], roundbowtie0_make_bowtie_2d(atom_pitch/2, offset=outer_wall_thickness-bowtie_offset));
basic_bowtie_cutout = togmod1_linear_extrude_z([-size[2], size[2]], roundbowtie0_make_bowtie_2d(atom_pitch/2, offset=-bowtie_offset));

bowtie_base_cutout_r = 2;

bowtie_border =
	bowtie_style == "none" ? ["union"] :
	bowtie_style == "round" ? basic_bowtie_border :
	let(r=bowtie_base_cutout_r+outer_wall_thickness)
	tphl1_make_rounded_cuboid([1*inch+outer_wall_thickness*2, 0.5*inch+outer_wall_thickness*2, size[2]*2], r=[r,r,0]);
bowtie_cutout =
	bowtie_style == "none" ? ["union"] :
	bowtie_style == "round" ? basic_bowtie_cutout :
	let(r=bowtie_base_cutout_r)
	["union",
		basic_bowtie_cutout,
		["translate", [0,0,size[2]/2], tphl1_make_rounded_cuboid([1*inch-bowtie_offset*2, 0.5*inch-bowtie_offset*2, 0.25*inch], r=[r,r,0])]
	];

bowtie_positions = [
	for( ym=[-size[1]/chunk_pitch/2 + 0.5 : 1 : size[1]/chunk_pitch/2 - 0.4] )
	for( xm=[-1 , +1] )
	[xm * size[0]/2, ym*chunk_pitch, 0]
];

function hfc1_make_hollow(xwall_spacing=chunk_pitch, floor_thickness=0) =
let(ywall = togmod1_make_cuboid([inner_wall_thickness, size[1]*2, size[2]*2]))
let(xwall = togmod1_make_cuboid([size[0]*2, inner_wall_thickness, size[2]*2]))
["difference",
	hfc1_shell(size, top_dydz, bottom_dydz,
	   offset = outer_offset-outer_wall_thickness,
		front_offset = outer_wall_thickness*2,
		end_offset = end_offset,
		bevel_size = bevel_size
	),
	
	if( floor_thickness > 0 )
	["translate", [0,0,-size[2]/2], togmod1_make_cuboid([size[0]*2, size[1]*2, floor_thickness*2])],

	for( xm=[-size[0]/atom_pitch/2 + 1 : 1 : size[0]/atom_pitch/2 - 0.9] )
		["translate", [xm*atom_pitch, 0, 0], ywall],
	for( ym=[-size[1]/xwall_spacing/2 + 1 : 1 : size[1]/xwall_spacing/2 - 0.9] )
		["translate", [0, ym*xwall_spacing, 0], xwall],
];

the_hollow =
	body_style == "hollow"  ? hfc1_make_hollow(xwall_spacing=chunk_pitch, floor_thickness=floor_thickness) :
	body_style == "hollow2" ? hfc1_make_hollow(xwall_spacing= atom_pitch, floor_thickness=floor_thickness) :
	["union"];

function xy_dist_squared(a, b) =
	let(ab = [a[0]-b[0], a[1]-b[1]])
	ab[0]*ab[0] + ab[1]*ab[1];
function xy_dist_from_nearest_squared(pos, points, nearest=999, index=0) =
	index >= len(pos) ? nearest :
	xy_dist_from_nearest_squared(pos, points, min(nearest, xy_dist_squared(pos, points[index])), index+1);

togmod1_domodule(["difference",
	outer_hull,
	
	["difference",
		the_hollow,
		
		for( pos=bowtie_positions ) ["translate", pos, bowtie_border],
	],
	
	for( pos=bowtie_positions ) ["translate", pos, bowtie_cutout],
	
	for( xm=[-size[0]/atom_pitch/2 + 0.5 : 1 : size[0]/atom_pitch/2 - 0.4] )
	for( ym=[-size[1]/atom_pitch/2 + 1.5 : 1 : size[1]/atom_pitch/2 - 1.4] )
		let( pos = [xm*atom_pitch, ym*atom_pitch, 0] )
		if( xy_dist_from_nearest_squared(pos, bowtie_positions) > atom_pitch*atom_pitch*0.5 ) // Close enough
		["translate", pos, atom_hole],
	
	// ["translate", [size[0]/2, 0, 0], togmod1_make_cuboid([size[0], 100, 100])],
]);
