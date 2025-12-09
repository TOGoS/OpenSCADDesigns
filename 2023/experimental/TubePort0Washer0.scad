// TubePort0washer0.1
// 
// A washer to sit inside a TubePort0-style port
// in front of any old 3/4-10 'bolt'.

hole_diameter = "1/4inch";

$fn = 144;

module __tubeport0washer0__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGUnits1.scad>

$togunits1_default_unit = "mm";

hole_diameter_mm = togunits1_to_mm(hole_diameter);

inch = 25.4;

tbev = inch * 1/48;

d4 = inch * 10/16;
d3 = inch *  8/16 + tbev*2;
d2 = inch *  8/16 - tbev*2;
d1 = inch *  6/16;
d0 = 0;

z0 = 0;
z1 = inch * 1/16;
z2 = inch * 2/16 - tbev;

togmod1_domodule(
	let( lcbev = z1/3 )
	tphl1_make_z_cylinder(zds=[
		if( hole_diameter_mm > 0 )
		let( hd1 = hole_diameter_mm, hbev = z1/4, hd2 = hd1+hbev*2 )
		each [
			[z1, d1],
			[z1     , hd2],
			[z1-hbev, hd1],
			[z0+hbev, hd1],
			[z0     , hd2],
		],
		
		[z0      , d4-lcbev*2],
		[z0+lcbev, d4        ],
		[z1      , d4        ],
		[z2      , d3        ],
		[z2      , d2        ],
		[z1      , d1        ],
	], cap_top=hole_diameter_mm <= 0, cap_bottom = hole_diameter_mm <= 0)
);
