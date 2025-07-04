// TOGRackPanel1.2
// 
// Library for generating standard TOGRack / TOGRack2 panels
// as described by https://www.nuke24.net/docs/2018/TOGRack.html.
// 
// Changes:
// v1.0
// - Initial version, based on TagPanel1.1
// v1.1
// - Add back_fat, back_fat_2d_mod, 2d_mod, and 3d_mod options
// v1.2
// - Properly handle case where panel is too narrow for any back fat

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGridLib3.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>

function tograckpanel1_panel_rath(nominal_size, bevel_size=undef, outer_offset=0) =
	let(_bevel_size = !is_undef(bevel_size) ? bevel_size : togridlib3_decode([1,"tgp-standard-bevel"]))
	let(sx = nominal_size[0], sy = nominal_size[1])
	let(corner_ops = [["bevel", _bevel_size], ["round", _bevel_size], ["offset", outer_offset]])
	["togpath1-rath",
		["togpath1-rathnode", [-sx/2,-sy/2], each corner_ops],
		["togpath1-rathnode", [ sx/2,-sy/2], each corner_ops],
		["togpath1-rathnode", [ sx/2, sy/2], each corner_ops],
		["togpath1-rathnode", [-sx/2, sy/2], each corner_ops],
	];

function tograckpanel1_mounting_hole_positions(nominal_size, frequency=1) =
	let(atom = togridlib3_decode([1,"atom"]))
	let(size_atoms = [for(d=nominal_size) round(d/atom)])
	[
		for( xm=[-size_atoms[0]/2+0.5 : 1/frequency : size_atoms[0]/2-0.5] )
		for( ym=size_atoms[1] == 1 ? [0] : [-size_atoms[1]/2+0.5, size_atoms[1]/2-0.5] )
		[xm * atom, ym * atom]
	];

function tograckpanel1_panel(
	nominal_size,
	bevel_size=undef,
	outer_offset=0,
	mounting_hole=undef,
	mounting_hole_style=undef,
	mounting_hole_frequency=1,
	back_fat=0,
	back_fat_2d_mod = function(p) p,
	2d_mod = function(p) p,
	3d_mod = function(p) p
) =
	let( thickness = nominal_size[2] )
	let( rail_width = togridlib3_decode([1,"atom"]) ) // Could be made configurable?
	let( _mounting_hole =
		!is_undef(mounting_hole) ? mounting_hole :
		!is_undef(mounting_hole_style) ? tog_holelib2_hole(mounting_hole_style, depth=back_fat+nominal_size[2]+1) :
		["union"]
	)
	let( panel_rath = tograckpanel1_panel_rath(
		nominal_size,
		bevel_size=bevel_size, outer_offset=outer_offset
	))
	let( panel_2d_raw = togpath1_rath_to_polygon(panel_rath) )
	let( panel_2d_modded = 2d_mod(panel_2d_raw) )
	let( panel_3d_block = togmod1_linear_extrude_z([-back_fat, thickness], panel_2d_modded))
	let( back_fat_nominal_size = [nominal_size[0], nominal_size[1] - rail_width*2] )
	let( back_fat_rath =
		back_fat_nominal_size[0] <= 0 || back_fat_nominal_size[1] <= 0 ? undef :
		tograckpanel1_panel_rath(
			[nominal_size[0], nominal_size[1] - rail_width*2 - outer_offset*2],
			bevel_size=bevel_size, outer_offset=outer_offset
		)
	)
	let( back_fat_2d_raw =
		!is_undef(back_fat_rath) ? togpath1_rath_to_polygon(back_fat_rath) :
		["union"]
	)
	let( back_fat_2d = back_fat_2d_mod(back_fat_2d_raw) )
	let( panel_3d_raw = ["intersection",
		panel_3d_block,
		
		["union",
			togmod1_linear_extrude_z([0, thickness+1], togmod1_make_rect(nominal_size*2)),
			togmod1_linear_extrude_z([-back_fat, thickness/2], back_fat_2d),
		]
	])
	3d_mod(["difference",
		panel_3d_raw,
		
		for( pos = tograckpanel1_mounting_hole_positions(nominal_size, frequency=mounting_hole_frequency) )
		["translate", [pos[0], pos[1], thickness], _mounting_hole]
	]);
