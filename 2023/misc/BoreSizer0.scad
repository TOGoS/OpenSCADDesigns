// BoreSizer0.1

base_diameter = "1inch";
section_height = "3/8inch";
section_count = 8;
diameter_decrement = "1/16inch";

$fn = 72;

module __boresizer0__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGUnits1.scad>

base_diameter_mm = togunits1_to_mm(base_diameter);
section_height_mm = togunits1_to_mm(section_height);
diameter_decrement_mm = togunits1_to_mm(diameter_decrement);

togmod1_domodule(tphl1_make_z_cylinder(zds=[
	for( s=[0:1:section_count-1] ) each let(diam = base_diameter_mm - s*diameter_decrement_mm) diam <= 0 ? [] : [
		[(s  )*section_height_mm, diam],
		[(s+1)*section_height_mm, diam],
	],
]));
