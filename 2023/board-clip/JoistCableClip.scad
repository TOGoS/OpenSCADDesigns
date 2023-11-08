// JoistCableClip-v1.0
// 
// "w" to be bolted or clamped under a joist, parallel to the joist,
// to hold cables perpendicular to the joist.

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>

inch = 25.4;
size = [4.5*inch, 1.5*inch, 1/2*inch];

$fn = $preview ? 12 : 48;

function fluboid_points(size, b=3.175) =
	[
		[-size[0]/2 + b, -size[1]/2    ],
		[ size[0]/2 - b, -size[1]/2    ],
		[ size[0]/2    , -size[1]/2 + b],
		[ size[0]/2    ,  size[1]/2    ],
		[-size[0]/2    ,  size[1]/2    ],
		[-size[0]/2    , -size[1]/2 + b],
	];

function fluboid_x(size, b=3.175) = // togmod1_make_cuboid(size);
	togmod1_linear_extrude_x([-size[0]/2, size[0]/2], togmod1_make_polygon(fluboid_points([size[1], size[2]], b)));

function fluboid_y(size, b=3.175) = // togmod1_make_cuboid(size);
	togmod1_linear_extrude_y([-size[1]/2, size[1]/2], togmod1_make_polygon(fluboid_points([size[0], size[2]], b)));

togmod1_domodule(["difference",
	["translate", [0,0,size[2]/2], fluboid_y(size)],
	
	for( x=[-1.5*inch, 1.5*inch] ) ["translate", [x, 0, size[2]], fluboid_y([1*inch, size[1]*2, 1/2*inch])],
	for( x=[-4/8*inch, 4/8*inch] ) ["translate", [x, 0, size[2]], fluboid_y([3/8*inch, size[1]*2, 1/2*inch])],
	for( y=[-3/8*inch, 3/8*inch] ) ["translate", [0, y, size[2]], fluboid_x([5*inch, 3/8*inch, 1/2*inch])],
	["translate", [0, 0, size[2]], fluboid_y([3/8*inch, 3/4*inch, 1/2*inch])],
	
	togmod1_make_cylinder(d=10, zrange=[-1, size[2]+1])
]);
