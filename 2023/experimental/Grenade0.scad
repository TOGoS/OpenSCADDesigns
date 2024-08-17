// A very bumpy cube
// 
// OpenSCAD 2021 chokes when rendering,
// but OpenSCAD 2024 seems to be able to handle it.

$tgx11_offset = -0.1;
$fn = 32;

use <../lib/TGX11.1Lib.scad>
use <../lib/TOGridLib3.scad>
use <../lib/TOGMod1.scad>

$togridlib3_unit_table = tgx11_get_default_unit_table();

function make_foot(size_atoms, bottom_shape="beveled") = tgx11_block_bottom(
	[[size_atoms[0],"atom"],[size_atoms[1],"atom"],[1000,"mm"]],
	bottom_shape = bottom_shape,
	segmentation="block" // We're doing our own segmentation
);

onebyone_beveled_foot = ["render", make_foot([1,1])];

function foot(size_atoms) = size_atoms == [1,1] ? onebyone_beveled_foot : make_foot(size_atoms);

atom = togridlib3_decode([1,"atom"]);
chunk = togridlib3_decode([1,"chunk"]);

function sorf(pattern, bottom_shape="beveled") =
	["union",
		for(item=pattern)
			["translate", [(item[0][0]+item[1][0]/2) * atom, (item[0][1]+item[1][1]/2)*atom, 0], foot(item[1])],
	];

pattern = [
	[[0,0], [1,1]],
	[[1,0], [2,1]],
	
	[[0,1], [3,1]],
	
	[[0,2], [2,1]],
	[[2,2], [1,1]],
];

section = ["render", ["translate", [-chunk/2,-chunk/2,0], sorf(pattern)]];

face = ["render", ["union",
	for( ym=[-1 : 1 : 1] )
	for( xm=[-1 : 1 : 1] )
	["translate", [xm*chunk, ym*chunk], ["rotate", [0,0,(xm+ym)*90], section]]
]];

togmod1_domodule(["intersection",
	for( rotation=[
		[  0,   0, 0],
		[  0, 180, 0],
		[ 90,   0, 0],
		[-90,   0, 0],
		[  0,  90, 0],
		[  0, -90, 0],
	] )
	["rotate", rotation, ["translate", [0,0,-1.5*chunk], face]]
]);
