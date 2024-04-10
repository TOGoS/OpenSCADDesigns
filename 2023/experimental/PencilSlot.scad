// PencilSlot0.1

$fn = $preview ? 24 : 64;

use <../lib/TOGMod1.scad>
use <../lib/TOGPolyhedronLib1.scad>

slab_thickness = 3.175;

slab = tphl1_make_rounded_cuboid([19.05, 19.05, slab_thickness], r=[6.35, 6.35, slab_thickness/2-0.3], corner_shape="ovoid1");

pencil_hole = tphl1_make_z_cylinder(zds = [
	[-1, 2],
	[ 2, 2],
	[ 4, 4],
]);

togmod1_domodule(["difference",
	["translate", [0,0,slab_thickness/2], slab],
	pencil_hole
]);
