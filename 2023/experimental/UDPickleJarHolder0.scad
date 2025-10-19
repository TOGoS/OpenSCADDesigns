// U[pside]D[own]PickleJarHolder0.1
// 
// Holds a pickle jar upside-down so that water
// can drip out through holes in the lid,
// or whatever.

block_size_chunks = [4,4];
block_height = "1chunk";
bottom_segmentation = "chunk"; // ["atom","chunk","chatom","block","none"]
top_segmentation    = "chunk"; // ["atom","chunk","chatom","block","none"]
bolt_hole_style     = "THL-1006";

$tgx11_offset = -0.15;
$fn = 24;

use <../lib/TGx11.1Lib.scad>
use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGUnits1.scad>

chunk = togunits1_to_mm([1,"chunk"]);

block_size_ca = togunits1_vec_to_cas([[block_size_chunks[0],"chunk"], [block_size_chunks[1],"chunk"], block_height]);
block_size_mm = togunits1_vec_to_mms(block_size_ca);
// block_size_chunks = togunits1_decode_vec(block_size_ca, unit=[1,"chunk"], "round");

$togridlib3_unit_table = tgx11_get_default_unit_table();

// Block takes the longest to render, but it should change seldomly
// unless you're changing the height a lot, so render it.
block = ["render", tgx11_block(
	block_size_ca,
	bottom_segmentation = "chatom",
	bottom_v6hc_style   = "none",
	lip_height          = -1.6,
	top_segmentation    = "chatom",
	top_v6hc_style      = "none"
)];

// Rounded-up dimensions of pickle jars:
pj_od  = 95;
pjl_od = 86; // (* 7 12.7) == 88.9
pjl_id = 69;
pjl_thickness = 12.7;

pj_cutout = tphl1_make_z_cylinder(zds=[
	[                 - 1            , pjl_id],
	[block_size_mm[2] - pjl_thickness, pjl_id],
	[block_size_mm[2] - pjl_thickness, pjl_od],
	[block_size_mm[2] + 1            , pjl_od],
]);

bolt_hole = tog_holelib2_hole(bolt_hole_style, depth=block_size_mm[2]*2);

bolt_holes = ["union",
	for( xm = [-block_size_chunks[0]/2 + 0.5 : 1 : block_size_chunks[0]/2 - 0.5] )
	for( ym = [-block_size_chunks[1]/2 + 0.5 : 1 : block_size_chunks[1]/2 - 0.5] )
	["translate", [xm*chunk, ym*chunk, block_size_mm[2]], bolt_hole],
];

togmod1_domodule(["difference", block, pj_cutout, bolt_holes]);
