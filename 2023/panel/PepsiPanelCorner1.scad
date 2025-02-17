// PepsiPanelCorner1.0

$fn = 32;

module pepsipanelcorner1__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGVecLib0.scad>
use <../lib/TOGPolyhedronLib1.scad>

togmod1_domodule(
	let( inch = 25.4 )
	let( cornbev = 1 )
	let( height = inch*3/8 )
	let( panel_hull_rath =
		let( cops = [["round", inch*1/4]] )
		["togpath1-rath",
			["togpath1-rathnode", [1.5*inch, 0  *inch], each cops],
			["togpath1-rathnode", [5  *inch, 0  *inch], each cops],
			["togpath1-rathnode", [5  *inch, 5  *inch], each cops],
			["togpath1-rathnode", [0  *inch, 5  *inch], each cops],
			["togpath1-rathnode", [0  *inch, 1.5*inch], each cops],
		]
	)
	let( slot       = togmod1_linear_extrude_z([-1, height+1], togmod1_make_rounded_rect([3/8*inch + 3/4*inch, 3/8*inch], r=3/16*inch)) )
	let( panel_hole = tphl1_make_z_cylinder(zds=[
		[      -1        , 3/8*inch],
		[height-1/8*inch , 3/8*inch],
		[height-1/8*inch , 7/8*inch],
		[height-cornbev  , 7/8*inch],
		[height+cornbev*2, 7/8*inch + cornbev*4]
	]))
	let( holinset = 3/4*inch )
	let( panel_hole_positions = [
		[5  *inch - holinset, 5  *inch - holinset],
		[5  *inch - holinset,            holinset],
		[1.5*inch + holinset,            holinset],
		[           holinset, 1.5*inch + holinset],
		[           holinset, 5  *inch - holinset],
	])
	// TODO: Maybe also make those slots?
	let( panel_holes = ["union",
		for( p=panel_hole_positions ) ["translate", p, panel_hole]
	] )
	let( panel_hull = tphl1_make_polyhedron_from_layer_function([
		[0             ,  0],
		[height-cornbev,  0],
		[height        , -1],
	], function(zo) togvec0_offset_points(
		togpath1_rath_to_polypoints(togpath1_offset_rath(panel_hull_rath, zo[1])),
		zo[0]
	)))
	["difference",
		panel_hull,
		
		panel_holes,
		for(tr = [[[(4)*inch, 2.25*inch], 0], [[2.25*inch, (4)*inch], 90]]) ["translate", tr[0], ["rotate", tr[1], slot]]
	]
);
