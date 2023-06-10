include <../lib/TOGUnitTable-v1.scad>

$tog_unittable = tog_unittable__demo_unit_table;

cube([
	tog_unittable__divide_ca($tog_unittable, [1.5, "inch"], [1, "mm"]),
	tog_unittable__divide_ca($tog_unittable, [1.5, "inch"], [1, "mm"]),
	tog_unittable__divide_ca($tog_unittable, [3  ,   "mm"], [1, "mm"]),
], center=true);
