// FrenchCleat-v1.0
// 
// For v1.0, hardcoded as WSTYPE-4414-H1.5F with configurable length

length_ca = [6, "inch"];
tip_bevel_size = 2;
corner_bevel_size = 1;

use <../lib/TOGridLib3.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>

$fn = $preview ? 12 : 72;

length               = togridlib3_decode(length_ca);
length_gb            = togridlib3_decode(length_ca, unit=[1.5, "inch"]);
hole_diameter        = togridlib3_decode([5/16, "inch"]);
counterbore_diameter = togridlib3_decode([7/ 8, "inch"]);
counterbore_depth    = togridlib3_decode([3/16, "inch"]);

yn  = togridlib3_decode([-3/4    , "inch"]);
ypn = togridlib3_decode([ 3/4-3/8, "inch"]);
ypp = togridlib3_decode([ 3/4+3/8, "inch"]);
zn = togridlib3_decode([-3/8, "inch"]);
zp = togridlib3_decode([+3/8, "inch"]);

// Tip bevel size
tb = tip_bevel_size;
// Corner bevel size
cb = corner_bevel_size;

fc_hull = tphl1_make_polyhedron_from_layer_function([-length/2, length/2], function(x) [
	[x, ypp-tb, zp-tb],
	[x, ypp-tb, zp],
	[x, yn +cb, zp],
	[x, yn    , zp-cb],
	[x, yn    , zn+cb],
	[x, yn +cb, zn],
	[x, ypn   , zn],
]);

counterbored_hole = tphl1_make_polyhedron_from_layer_function([
	[zn-1                ,        hole_diameter],
	[zp-counterbore_depth,        hole_diameter],
	[zp-counterbore_depth, counterbore_diameter],
	[zp+1                , counterbore_diameter]
], function(params) togmod1_circle_points(d=params[1], pos=[0,0,params[0]]));

togmod1_domodule(["difference",
	fc_hull,
	
	for( xm=[-length_gb/2 + 0.5 : 1 : length_gb/2] ) ["x-debug", ["translate", [xm*38.1, 0], counterbored_hole]]
]);
