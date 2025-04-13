// InletPanel1.0
//
// Panel on which to mount one of these: https://www.digikey.com/en/products/detail/te-connectivity-corcom-filters/6ESRM-3/142045

size_atoms = [3,9];
panel_edge_thickness = 3.175; // 0.001
panel_center_thickness = 6.35; // 0.001
// Style of holes for attaching panel to rack
edge_hole_style = "THL-1001"; // ["THL-1001", "THL-1004", "THL-1008", "straight-4.5mm", "straight-5mm"]
outer_offset = -0.1;
inner_offset = -0.1;

$fn = 24;

use <../../lib/TOGHoleLib2.scad>
use <../../lib/TOGMod1.scad>
use <../../lib/TOGMod1Constructors.scad>
use <../../lib/TOGPath1.scad>
use <../../lib/TOGPolyhedronLib1.scad>

function u_to_mm(u)     = u * 254/160;
function inch_to_mm(i)  = i * 254/10;
function atoms_to_mm(a) = a * 127/10;

component_cutout_2d = let(hole=togmod1_make_circle(d=4.5)) ["union",
	togmod1_make_rounded_rect([19.5, 27], 2),
	for( ym=[-1,1] ) ["translate", [0,ym*20,0], hole],
];


sx = atoms_to_mm(size_atoms[0]);
sy = atoms_to_mm(size_atoms[1]);
corner_ops = [["bevel", u_to_mm(2)], ["round", u_to_mm(2)], ["offset", -u_to_mm(1)+outer_offset]];
panel_rath = ["togpath1-rath",
	["togpath1-rathnode", [-sx/2,-sy/2], each corner_ops],
	["togpath1-rathnode", [ sx/2,-sy/2], each corner_ops],
	["togpath1-rathnode", [ sx/2, sy/2], each corner_ops],
	["togpath1-rathnode", [-sx/2, sy/2], each corner_ops],
];

//panel_hole = tphl1_make_z_cylinder(d=25.4*5/32, zrange=[-1, panel_thickness+1]);
edge_hole = tog_holelib2_hole(edge_hole_style);

front_thickness  = panel_center_thickness-panel_edge_thickness;

togmod1_domodule(["difference",
	["intersection",
		togmod1_linear_extrude_z([-panel_center_thickness*2, panel_edge_thickness*2], ["difference",
			togpath1_rath_to_polygon(panel_rath),
	   	
			component_cutout_2d,
		]),
		
		togmod1_linear_extrude_x([-sx, sx], ["union",
			["translate", [0, front_thickness/2], togmod1_make_rect([200, front_thickness])],
			["translate", [0, front_thickness-panel_center_thickness/2], togmod1_make_rect([atoms_to_mm(size_atoms[1]-2), panel_center_thickness])],
		]),
	],
	
	for( xm=[-size_atoms[0]/2+0.5 : 1 : size_atoms[0]/2-0.5] )
	for( ym=size_atoms[1] == 1 ? [0] : [-size_atoms[1]/2+0.5, size_atoms[1]/2-0.5] )
	["translate", [atoms_to_mm(xm), atoms_to_mm(ym), front_thickness], edge_hole],	
]);
