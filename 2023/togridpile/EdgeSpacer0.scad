size = ["3inch", "1/2inch", "1/8inch"];

edge_bevel = "1mm";
corner_bevel = "1/8inch";

bowtie_cutout_style = "none"; // ["none","round"]
bowtie_offset = -0.10; // 0.025

$tgx11_offset = -0.1;
$fn = 36;

module edgespacer0__end_params() { }

use <../lib/RoundBowtie0.scad>
use <../lib/TGx11.1Lib.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGUnits1.scad>
use <../lib/TOGVecLib0.scad>

$togridlib3_unit_table = tgx11_get_default_unit_table();

bowtie_cutout_2d =
	bowtie_cutout_style == "none" ? ["union"] :
	roundbowtie0_make_bowtie_2d(6.35, offset=-bowtie_offset);

size_mm = togunits1_decode_vec(size);
vbev = togunits1_decode(edge_bevel);
hbev = min(size_mm[0]*96/128, size_mm[1]*96/128, togunits1_decode(corner_bevel));
hround = hbev;

block_hull = tphl1_make_polyhedron_from_layer_function([
	[           0   -$tgx11_offset, -vbev],
	[           vbev-$tgx11_offset,  0],
   [size_mm[2]-vbev+$tgx11_offset,  0],
	[size_mm[2]     +$tgx11_offset, -vbev],
], function(zo) togvec0_offset_points(
	togpath1_rath_to_polypoints(
		togpath1_make_rectangle_rath(
			[size_mm[0], size_mm[1]],
			[["bevel", hbev], ["round", hround], ["offset", zo[1] + $tgx11_offset]]
		)
	),
	zo[0]
));

btatom = 12.7;
approximate_size_btatoms = [for(s=size_mm) round(s/btatom)];

togmod1_domodule(["difference",
   block_hull,
	
	togmod1_linear_extrude_z([-1, size_mm[2]+1], ["union",
		for( xm=[-approximate_size_btatoms[0]/2 + 0.5 : 1 : approximate_size_btatoms[0]/2] )
		["translate", [xm*btatom, -size_mm[1]/2], ["rotate", [0,0,90], bowtie_cutout_2d]]
	]),
]);
