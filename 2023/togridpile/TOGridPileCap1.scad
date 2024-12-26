// TOGridPileCap1.0
// 
// Cap for standard 1/8"-beveled TOGridPile cups.

inner_size_atoms = [6,2,1.5];
wall_thickness_u = 1;
floor_thickness_u = 2;
// Interior offset of walls into cavity.  Zero or positive for a tight fit, recommended for rubbery materials.  -0.1 recommended for loosish fit with rigid materials like PLA.
inner_offset = -0.1;
outer_offset =  0.0;
$fn = 64;

module __togridpile1cap__end_params() { }

use <../lib/SimpleCap0.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGridLib3.scad>
use <../lib/TGx11.1Lib.scad>

function togridpilecap1_make_cap(
	inner_size_ca,
	wall_thickness_u,
	floor_thickness_u
) = 
let(inner_size            = togridlib3_decode_vector(inner_size_ca))
let(inner_bevel_size      = togridlib3_decode([1, "tgp-standard-bevel"]))
let(inner_rounding_radius = max(0.1, togridlib3_decode([1, "tgp-min-f-corner-radius"])))
echo(inner_size=inner_size, inner_bevel_size, inner_rounding_radius)
let(wall_thickness        = togridlib3_decode([wall_thickness_u, "u"]) + inner_offset + outer_offset)
let(floor_thickness       = togridlib3_decode([floor_thickness_u, "u"]))
let(inner_rath =
	let(hw = inner_size[0]/2, hh = inner_size[1]/2)
	let(ops = [["bevel", inner_bevel_size], ["round", inner_rounding_radius], ["offset", -inner_offset] ])
	["togpath1-rath",
		["togpath1-rathnode", [ hw, -hh], each ops],
		["togpath1-rathnode", [ hw,  hh], each ops],
		["togpath1-rathnode", [-hw,  hh], each ops],
		["togpath1-rathnode", [-hw, -hh], each ops],
	]
)
simplecap0_make_cap(
	inner_rath,
	inner_size[2]+floor_thickness,
	floor_thickness,
	wall_thickness,
	bevel_size = min(floor_thickness*0.6, wall_thickness - inner_offset + inner_rounding_radius - 0.1)
);

$togridlib3_unit_table = tgx11_get_default_unit_table();

togmod1_domodule(togridpilecap1_make_cap(
	[for(d=inner_size_atoms) [d, "atom"]],
	floor_thickness_u = floor_thickness_u,
	wall_thickness_u = wall_thickness_u
));
