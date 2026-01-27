// FCSubClip0.1

thickness = "1/12inch";
width = "1inch";
end_bevel = "0.5mm";
$tgx11_offset = -0.15;
$fn = 48;

module __fcsubclip0__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGUnits1.scad>
use <../lib/TOGPolyhedronLib1.scad>

u     = togunits1_to_mm("1u");
2u    = togunits1_to_mm("1/8inch");
atom  = togunits1_to_mm("atom");

thickness_mm = togunits1_to_mm(thickness);
vbev_mm      = min(thickness_mm/3, togunits1_to_mm(end_bevel));
width_mm     = togunits1_to_mm(width);
width_atoms  = togunits1_decode(width, unit="atom", xf="round");

identity = function(x) x;

reverse_list = function(list) [for(i=[len(list)-1 : -1 : 0]) list[i]];

togpath1_make_rathnode_position_transform = function(position_transform)
	function(node) [node[0], position_transform(node[1]), for(i=[2:1:len(node)-1]) node[i]];

mkmap = function(xf) function(list) [for(item=list) xf(item)];

compose = function(a,b) function(x) a(b(x));

outer_rath = ["togpath1-rath",
	for( transform=[
		identity,
		compose(reverse_list, mkmap(togpath1_make_rathnode_position_transform( function(p) [p[0], -p[1]])))
	])
	each transform([
		["togpath1-rathnode", [-3*2u,-4*2u]],
		["togpath1-rathnode", [-3*2u,-6*2u], ["round", 3*u]],
		["togpath1-rathnode", [ 3*2u,-6*2u], ["round", 3*u]],
		["togpath1-rathnode", [ 3*2u,-2*2u], ["round", 3*u]],
		["togpath1-rathnode", [-1*2u,-2*2u], ["round", 3*u]],
	])
];

polyline_rath = togpath1_offset_rath(outer_rath, -thickness_mm/2);
polyline_points = togpath1_rath_to_polypoints(polyline_rath);

polyline_outline_rath = togpath1_polyline_to_rath(polyline_points, thickness_mm/2);
core_rath = togpath1_offset_rath(["togpath1-rath",
	for( transform=[
		identity,
		compose(reverse_list, mkmap(togpath1_make_rathnode_position_transform( function(p) [p[0], -p[1]])))
	])
	each transform([
		["togpath1-rathnode", [-6*u, -3*u]],
		["togpath1-rathnode", [-5*u, -3*u]],
		["togpath1-rathnode", [-4*u, -4*u], ["round", 1.5*u]],
		["togpath1-rathnode", [-1*u, -4*u]],
		["togpath1-rathnode", [-2*u, -3*u]],
	])
], $tgx11_offset);

hole = togmod1_linear_extrude_x([-100,100], togmod1_make_circle(d=4.5, $fn=4));

function le_extrude_rath(zos, rath) =
	tphl1_make_polyhedron_from_layer_function(
		zos,
		function(zo) togpath1_rath_to_polypoints(togpath1_offset_rath(rath, zo[1])),
		layer_points_transform = "key0-to-z"
	);

function z_offset_zos(z_offset, zos) = [for(zo=zos) [zo[0] + z_offset*(zo[0]/abs(zo[0])), zo[1]]];

togmod1_domodule(
	let( extrusion_zos = [
		[-width_mm/2          , -vbev_mm],
		[-width_mm/2 + vbev_mm,        0],
		[ width_mm/2 - vbev_mm,        0],
		[ width_mm/2          , -vbev_mm],
	])
	["difference",
		["union",
			le_extrude_rath(z_offset_zos( 0.00, extrusion_zos), polyline_outline_rath),
			le_extrude_rath(z_offset_zos(-0.01, extrusion_zos), core_rath),
		],
		
		for( zm=[-width_atoms/2 + 0.5 : 1 : width_atoms/2] )
		["translate", [0,0,zm*atom], hole],
	]
);
