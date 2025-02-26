// DrillBitBushingJigBread3.0
// 
// 'Bread' for making a sandwich with a DrillBitBushingJig3 in the middle.
// 
// v3.0:
// - Copied code from PepsiPanelCorner1.0, adjusted to new shape

length_chunks = 3;
$fn = 32;

module drillbitbushingjigbread3__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGVecLib0.scad>
use <../lib/TOGPolyhedronLib1.scad>

togmod1_domodule(
	let( inch = 25.4 )
	let( chunk = 38.1 )
	let( cornbev = 1 )
	let( height = inch*3/8 )
	let( panel_hull_rath =
		let( cops = [["round", inch*1/4]] )
		["togpath1-rath",
			["togpath1-rathnode", [+length_chunks*chunk/2, -1.75*inch], each cops],
			["togpath1-rathnode", [+length_chunks*chunk/2, +1.75*inch], each cops],
			["togpath1-rathnode", [-length_chunks*chunk/2, +1.75*inch], each cops],
			["togpath1-rathnode", [-length_chunks*chunk/2, -1.75*inch], each cops],
		]
	)
	let( panel_hole = tphl1_make_z_cylinder(zds=[
		[      -1        , 3/8*inch],
		[height-1/8*inch , 3/8*inch],
		[height-1/8*inch , 7/8*inch],
		[height-cornbev  , 7/8*inch],
		[height+cornbev*2, 7/8*inch + cornbev*4]
	]))
	let( panel_hole_positions = [
		for(xm=[-length_chunks/2 + 0.5 : 1 : length_chunks/2])
		for(ym=[-1, +1])
		[xm * chunk, ym * inch]
	])
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
	]
);
