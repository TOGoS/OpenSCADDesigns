// HollowCornerBracket0.3
// 
// A simple gridbeam corner bracket.
// 
// See also: SmallPlatformBracket1, which is similar but has threaded holes.
// 
// v0.2:
// - hole_style now configurable
// - inner_corner_ops is now configurable
// - counterbore_depth may be blank for cases where not applicable (internally treated as zero)
// - extra_features, which for now can be blank or "p2601-hole"g
// - Fix placement of Y and Z holes when height and depth are different
// - y_hole_z_frequency parameter, for cases where you want more holes per chunk
// - hole_fn parameter, with less rediculous default
// v0.3:
// - Add 'footed-atomic-back' feature

width = "1chunk";
height = "1chunk";
depth = "1chunk";
wall_thickness = "1/4inch";
hole_style = "THL-1006";
y_hole_z_frequency = 1;
counterbore_depth = "1/16inch";
// Space-separated list of feature names, e.g. "p2601-hole footed-atomic-back"
extra_features = "";
// Space-separated list of rath corner ops, e.g. "bevel-3/4inch round-3mm"
inner_corner_ops = "";

// Offset of outer hull and inner walls, in mm
$tgx11_offset = 0.0;
$fn = 24;
hole_fn = "";

module __hollowcornerbracket0__end_params() { }

use <../lib/TGx11.1Lib.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGStringLib1.scad>
use <../lib/TOGUnits1.scad>
use <../lib/TOGHoleLib2.scad>

$togridlib3_unit_table = tgx11_get_default_unit_table();

width_mm  = togunits1_to_mm(width );
height_mm = togunits1_to_mm(height);
depth_mm  = togunits1_to_mm(depth );
width_ca  = togunits1_to_ca(width );
height_ca = togunits1_to_ca(height);
depth_ca  = togunits1_to_ca(depth );

hole_fn_decoded =
	hole_fn == "" ? min(180, $fn*2) :
	togstr1_parse_decimal_nat(hole_fn)[0];

function parse_corner_op(opstr, dbgctxstr=undef) =
	let( parts = togstr1_tokenize(opstr, "-", 2) )
	assert( len(parts) == 2, str("Your opstr should have a dash; got \"", opstr, "\"") )
	let( size = togunits1_to_mm(parts[1], dbgctxstr=dbgctxstr) )
	[parts[0], size];

inner_corner_ops_decoded =
	inner_corner_ops == "" ? [] :
	let( opstrs = togstr1_tokenize(inner_corner_ops, " "))
	[for(i=[0:1:len(opstrs)-1]) parse_corner_op(opstrs[i], dbgctxstr=str("corner op ", i, ": \"",opstrs[i],"\""))];

function xf_points(xf, points) = [for(p=points) xf(p)];

// Emulates PHI-1007 hole as used by p2601
function make_phi_1007like_cutout_2d(eff_slot_width=19.05, outer_margin=0.6) =
	["translate",
		[0, -(1.25*25.4 - outer_margin*2)/2],
		togmod1_make_rounded_rect([eff_slot_width, 50], r=[6, 6, 0])
	];

extra_feature_strs =
	extra_features == "" ? [] :
	togstr1_tokenize(extra_features, " ");

extra_cutouts = [
	for( efs = extra_feature_strs ) each
		efs == "p2601-hole" ? [
			togmod1_linear_extrude_z([-height_mm, height_mm], make_phi_1007like_cutout_2d())
		] : [],
];
extra_intersections = [
	for( efs = extra_feature_strs ) each
		efs == "footed-atomic-back" ? [
			["translate", [0,depth_mm/2,0], ["rotate", [90,0,0], tgx11_block_bottom(
				[width_ca, height_ca, depth_ca],
				bottom_shape = "footed",
				segmentation = "atom",
				v6hc_style = "none"
			)]]
		] : [],
];
//	assert(false, str("Unrecognized extra feature[s]: \"", efs, "\""));

togmod1_domodule(
	let( chunk_mm  = togunits1_to_mm("chunk") )
	let( width_chunks = togunits1_decode(width, unit="chunk") )
	let( height_chunks = togunits1_decode(height, unit="chunk", xf="round") )
	let( depth_chunks = togunits1_decode(depth, unit="chunk", xf="round") )
	let( wall_thickness_mm  = togunits1_to_mm(wall_thickness) )
	let( counterbore_depth_mm = counterbore_depth == "" ? 0 : togunits1_to_mm(counterbore_depth) )
	let( x0 = -width_mm/2, x1 = width_mm/2 )
	let( y0 = -depth_mm/2, y1 = depth_mm/2 )
	let( z0 = -height_mm/2, z1 = height_mm/2 )
	let( oo = $tgx11_offset )
	
	let( vbev = 1 )
	let( scops = [["round", 3.175]] )

	let( the_hull = tphl1_make_polyhedron_from_layer_function(
		[
			[ x0        - oo, oo-vbev],
			[ x0 + vbev - oo, oo     ],
			[ x1 - vbev + oo, oo     ],
			[ x1        + oo, oo-vbev],
		], function(zo) xf_points(
			function(xy) [zo[0], xy[0], xy[1]],
			togpath1_rath_to_polypoints(["togpath1-rath",
				["togpath1-rathnode", [y1,z0], each scops, ["offset", zo[1]]],
				["togpath1-rathnode", [y1,z1], each scops, ["offset", zo[1]]],
				["togpath1-rathnode", [y0,z1], each scops, ["offset", zo[1]]],
			])
		))
	)
	let( hole = ["render", tog_holelib2_hole(hole_style, depth=wall_thickness_mm*2, counterbore_inset=counterbore_depth_mm, overhead_bore_height=oo+1, $fn=hole_fn_decoded)] )
	let( chunk_cutout =
		let( y_hole = ["translate", [0,  depth_mm/2-wall_thickness_mm, 0],
			["rotate-xyz", [ 90,0,0], hole]] )
		let( z_hole = ["translate", [0, 0, height_mm/2-wall_thickness_mm],
			["rotate-xyz", [180,0,0], hole]] )
		["union",
			["translate", [0,-depth_mm/2,-height_mm/2],
				let( w = chunk_mm - wall_thickness_mm*2 - oo*2 )
				togmod1_linear_extrude_x(
					[-w/2, w/2],
					togpath1_rath_to_polygon(
						let( y1 = depth_mm-wall_thickness_mm, z1 = height_mm-wall_thickness_mm )
						["togpath1-rath",
							["togpath1-rathnode", [ y1, -z1]],
							["togpath1-rathnode", [ y1,  z1], each inner_corner_ops_decoded],
							["togpath1-rathnode", [-y1,  z1]],
						]
					)
					// togmod1_make_rect([depth_mm - wall_thickness_mm*2, height_mm-wall_thickness_mm*2])
				)
			],
			
			for( zm=[-height_chunks/2+0.5 : 1/y_hole_z_frequency : height_chunks/2-127/256] )
			["translate", [0,0,zm*chunk_mm], y_hole],
			
			for( ym=[-depth_chunks/2+0.5 : 1 : depth_chunks/2-0.5] )
			["translate", [0,ym*chunk_mm,0], z_hole],			
		]
	)
	["intersection",
		["difference",
			the_hull,
			
			for( xm=[-width_chunks/2 + 0.5 : 1 : width_chunks/2-0.5] )
			["translate", [xm*chunk_mm, 0, 0], chunk_cutout],
			
			for( ec=extra_cutouts ) ec,
		],
		
		for( inter = extra_intersections ) inter,
	]
);
