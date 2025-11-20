// MiniRail2.2
// 
// MiniRail with back thingy
// 
// v2.0
// - Initial [re]design
// v2.1
// - Alternatieve bowtie Y placements
// v2.2
// - THL-1004s instead of THL-1001s
// - Inset alll the bolt hole a little bit
// 
// TODO: Option for magnet holes?
// Maybe put the membrane between the magnet and screw holes
// to avoid having to remediate.

/* [Overall Size] */

length = "6inch";
panel_width = "1chunk";
panel_thickness = "1/4inch";

/* [Features] */

bottom_segmentation = "chatom"; // ["atom","chatom","chunk","block","none"]
bowtie_style = "none"; // ["none", "round"]
bowtie_y_placement = "center"; // ["none","center","chunk","atom"]

/* [Detail] */

// Set to >0 to put a membrane at the bottom of holes, which may help with FDM printing
bottom_membrane_thickness = "0.3mm";
$fn = 32;
minirail_edge_x_offset = "-0.2mm";
bowtie_offset = "-0.03mm";
$tgx11_offset = -0.15; // 0.025

module __minirail2__end_params() { }

use <../lib/RoundBowtie0.scad>
use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGUnits1.scad>
use <../lib/TGx11.1Lib.scad>

function mirror_rathnodes(nodes) =
	[for(i=[len(nodes)-1 : -1 : 0])
		let(n=nodes[i])
		[n[0], [-n[1][0], n[1][1]], for(o=[2:1:len(n)-1]) n[o]]
	];

$togridlib3_unit_table = [
	["tgp-m-outer-corner-radius", [3, "u"]],
	each tgx11_get_default_unit_table()
];

panel_width_mm     = togunits1_to_mm(panel_width);
panel_thickness_mm = togunits1_to_mm(panel_thickness);
rail_width_mm      = togunits1_to_mm("3/4inch");
rail_thickness_mm  = togunits1_to_mm("1/4inch");
bottom_membrane_thickness_mm = togunits1_to_mm(bottom_membrane_thickness);
bowtie_offset_mm   = togunits1_to_mm(bowtie_offset);
mr_offset_mm       = togunits1_to_mm(minirail_edge_x_offset);

bowtie_y_positions =
	bowtie_y_placement == "none" ? [] :
	bowtie_y_placement == "center" ? [0] :
	bowtie_y_placement == "atom" || bowtie_y_placement == "chunk" ?
		let(pwa = round(togunits1_decode(panel_width, unit=bowtie_y_placement)))
		[for(xm = [-pwa/2+0.5 : 1 : pwa/2-0.5]) togunits1_decode([xm,bowtie_y_placement])] :
	assert(false, str("Unrecognized bowtie Y placement: '", bowtie_y_placement, "'"));

function minirail2_make_rath(xoffset=0) =
	let( rcops = [["round", 1.6]] )
	let( pcops = [["bevel", 1.6]] )
	let( px1 = panel_width_mm/2, py1 = panel_thickness_mm )
	let( mrx0 = rail_width_mm/2 - rail_thickness_mm/2 + mr_offset_mm )
	let( mrx1 = rail_width_mm/2 + rail_thickness_mm/2 + mr_offset_mm )
	let( mry1 = py1 + rail_thickness_mm )
	let( rn0 = [
		["togpath1-rathnode", [px1  + xoffset,  0  ], each pcops],
		["togpath1-rathnode", [px1  + xoffset,  py1], each pcops],
		["togpath1-rathnode", [mrx0 + xoffset,  py1]],
		["togpath1-rathnode", [mrx1 + xoffset, mry1], each rcops],
	])
	["togpath1-rath",
		each rn0,
		each mirror_rathnodes(rn0)
	];

togmod1_domodule(
	let( length_mm          = togunits1_to_mm(length) )
	let( z0 = 0, z1 = panel_thickness_mm + rail_thickness_mm )
	let( pz1 = panel_thickness_mm )
	let( x0 = length_mm/2 )
	let( atom = togunits1_to_mm("atom") )
	let( mhole0_x_offset_mholes = 0.5  )
	let(    ph0_x_offset_mholes = 0.75 )
	let( ahole0_x_offset_mholes = 1    )
	let( ph_dx = atom/2 + 0.4, ph_dz = rail_thickness_mm/2 )
	let( bev = 2 )
	// Basic shape
	let( body = tphl1_make_polyhedron_from_layer_function([
		[-x0      , -bev],
		[-x0 + bev,  0  ],
		[ x0 - bev,  0  ],
		[ x0      , -bev],
	], function(xo)
		let( rath = minirail2_make_rath(xo[1]) )
		let( points = togpath1_rath_to_polypoints(rath) )
		[for(p=points) [xo[0], p[0], p[1]]]
	))
	// TOGridPile bottom
	let( tgp_bottom = ["render", tgx11_block(
	   togunits1_vec_to_cas([length, panel_width, [z1+10,"mm"]]),
		bottom_segmentation = bottom_segmentation,
		bottom_v6hc_style = "none",
		bottom_foot_bevel = 0.4
	)] )
	// Hole stuff
	let( hole_z0 = bottom_membrane_thickness_mm > 0 ? bottom_membrane_thickness_mm : -1 )
	let( mhole = ["render", tog_holelib2_hole("THL-1002", inset=2, depth=z1-hole_z0)] )
	let( ahole = ["render", tog_holelib2_hole("THL-1004", inset=2, depth=z1-hole_z0)] )
	let( phole = ["render", tog_holelib2_hole("THL-1004", inset=1, depth=panel_thickness_mm-hole_z0)] )
	let( mhole_pitch = togunits1_to_mm("chunk"), mhole0_x_offset_mholes=0.5 )
	let( length_mholes = round(length_mm*2/mhole_pitch)/2 )
	let( length_atoms = round(length_mm/atom) )
	// Pinhole stuff
	let( pin_hole = togmod1_linear_extrude_y([-panel_width_mm, panel_width_mm], togmod1_make_polygon([
		[ ph_dx/2, pz1 - 0.1  ],
		[ ph_dx/2, pz1 + ph_dz],
		[-ph_dx/2, pz1 + ph_dz],
		[-ph_dx/2, pz1 - 0.1  ],
	])))
	// Bowtie stuff
	let( bowtie_cutout =
		bowtie_style == "none" ? ["union"] :
		bowtie_style == "round" ? ["linear-extrude-zs", [z0-1, z1+1], roundbowtie0_make_bowtie_2d(6.35, lobe_count=2, offset=-bowtie_offset_mm)] :
		assert(false, str("Unrecognized bowtie style: '", bowtie_style, "'"))
	)
	// Assemble!
	["difference",
		["intersection",
			body,
			if( !is_undef(tgp_bottom) ) tgp_bottom,
		],
		
		// Pin holes
		for( xm=[-length_mholes/2+ph0_x_offset_mholes : 0.5 : length_mholes/2-ph0_x_offset_mholes+0.1] ) let( x = xm*mhole_pitch )
		["translate", [x, 0, 0], pin_hole],
		
		for( xm=[-length_mholes/2+mhole0_x_offset_mholes : 1 : length_mholes/2-mhole0_x_offset_mholes+0.1] ) ["translate", [xm*mhole_pitch, 0, z1], mhole],
	   
		for( xm=[-length_mholes/2+ahole0_x_offset_mholes : 1 : length_mholes/2-ahole0_x_offset_mholes+0.1] ) let( x = xm*mhole_pitch )
		// for( xm=[-length_atoms/2 + 0.5 : 1 : length_atoms/2 - 0.5] ) let( x = xm*atom )
		for( ym=[0] )
		["translate", [x, ym*atom, z1], ahole],
		
		for( xm=[-length_atoms/2 + 0.5 : 1 : length_atoms/2 - 0.5] )
		for( ym=[-1, 1] )
		["translate", [xm*atom, ym*atom, panel_thickness_mm], phole],
				
		for( x=[-x0, x0] ) for(y=bowtie_y_positions) ["translate", [x,y,0], bowtie_cutout],
	]
);
