// TOGRackPanel1.0
// 
// Library for generating standard TOGRack / TOGRack2 panels
// as described by https://www.nuke24.net/docs/2018/TOGRack.html.

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

function tograckpanel1_mounting_hole_positions(nominal_size) =
	let(atom = togridlib3_decode([1,"atom"]))
	let(size_atoms = [for(d=nominal_size) round(d/atom)])
	[
		for( xm=[-size_atoms[0]/2+0.5 : 1 : size_atoms[0]/2-0.5] )
		for( ym=size_atoms[1] == 1 ? [0] : [-size_atoms[1]/2+0.5, size_atoms[1]/2-0.5] )
		[xm * atom, ym * atom]
	];

function tograckpanel1_panel(
	nominal_size,
	bevel_size=undef,
	outer_offset=0,
	mounting_hole=undef,
	mounting_hole_style=undef
) =
	let( thickness = nominal_size[2] )
	let( _mounting_hole =
		!is_undef(mounting_hole) ? mounting_hole :
		!is_undef(mounting_hole_style) ? tog_holelib2_hole(mounting_hole_style, depth=nominal_size[2]+1) :
		["union"]
	)
	let( panel_rath = tograckpanel1_panel_rath(
		nominal_size,
		bevel_size=bevel_size, outer_offset=outer_offset
	))
	["difference",
		tphl1_extrude_polypoints([0, thickness], togpath1_rath_to_polypoints(panel_rath)),
		
		for( pos = tograckpanel1_mounting_hole_positions(nominal_size) )
		["translate", [pos[0], pos[1], thickness], _mounting_hole]
	];
