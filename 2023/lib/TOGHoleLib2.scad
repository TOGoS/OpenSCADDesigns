// TOGHoleLib2.16
//
// Library of hole shapes!
// Mostly to accommodate counterbored/countersunk screws.
//
// Changes:
// v2.0:
// - Based on v1.5.1, but generate TOGMod1 shapes
// - Drops support for THL-1013 and THL-1021
// v2.1:
// - Add "THL-1003" type, which is counterbored  for #6 hex nuts
// - Allow `inset` to be specified for all hole types,
//   while defaulting to type-specific values (usually 0.01)
// v2.2:
// - Add "THL-1004", which is really just THL-1001 but sloppier.
// v2.3:
// - Fix tog_holelib2_countersunk_hole to properly handle the case
//   when neck_d < bore_d.  I think.  Might need more unit tests.
// v2.4:
// - Add THL-1023 for counterbored M3s
// v2.5:
// - Adjusrt THL-1023 [counter]bore sizes slightly
// v2.6:
// - Add THL-1005, a hexagonal countersunk hole
// v2.7:
// - Remove some debug echoes
// v2.8:
// - Slight refactor to use tphl1_make_z_cylinder instead of duplicating it
// - THL1006, a counterbored hole which can flange at the surface
// v2.9:
// - Fix so that countersinks with negative insets work
// v2.10:
// - Always taper overhead bores
// v2.11:
// - Add THL-1007, counterbored-for-hex-nut with 'hole remedy'
// v2.12:
// - Adjust the hole remedy technique somewhat
// v2.13:
// - Allow bore_d to be overridden for THL-1002 holes
// v2.14:
// - tog_holelib2_slot, which can currently make THL-1006[-3/16in] slots,
//   and will fall back to using tog_holelib2_hole for any single-point slots
// - 'THL-1006-3/16in' hole type
// v2.14.1:
// - Remove some debug echoes from tog_holelib2_slot
// v2.15:
// - Add THL-1008 hole type, which is essentially the union of THL-1001 and THL-1004
// v2.16:
// - Fix tog_holelib2_counterbored_with_remedy_hole so that all cutouts are within
//   the hull of the counterbore (previously corners would 'stick out into the walls'
//   if counterbore was not large enough relative to the shaft).

use <./TOGMod1Constructors.scad>
use <./TOGPolyHedronLib1.scad>
use <./TOGPath1.scad>
use <./TOGVecLib0.scad>

function tog_holelib2__countersunk_hole_2(surface_d, neck_d, head_h, depth, bore_d, overhead_bore_d, overhead_bore_height, inset=0.01) =
	assert(bore_d <= neck_d, str("bore_d (", bore_d, ") > neck_d (", neck_d, ")"))
	let( small_positive_z = max(0, -inset)+0.01 ) // Z just above surface, or top of counterbore edge, whichever is higher
	assert(overhead_bore_height > small_positive_z)
	// TODO: Fix to actually use bore_d!
	tphl1_make_z_cylinder(zds=[
		[-depth       , bore_d],
		[-head_h-inset, bore_d],
		[-head_h-inset, neck_d],
		[       -inset, surface_d],
		[small_positive_z, surface_d],
		if( overhead_bore_d > surface_d ) [ 0.01, overhead_bore_d ],
		// Taper up to overhead_bore_d
		[overhead_bore_height, overhead_bore_d],
		[overhead_bore_height+overhead_bore_d, 0],
	]);

function tog_holelib2_countersunk_hole(surface_d, neck_d, head_h, depth, bore_d=undef, overhead_bore_d=0, overhead_bore_height=undef, inset=0.01) =
	let( adjusted_bore_d = is_undef(bore_d) ? neck_d : bore_d )
	let( adjusted_neck_d = adjusted_bore_d < neck_d ? neck_d : adjusted_bore_d )
	let( adjusted_head_h =
		 adjusted_neck_d == neck_d ? head_h :
		 head_h * (1 - (adjusted_neck_d - neck_d)/(surface_d - neck_d)) )
	let(_inset = tog_holelib2__coalesce(inset, 0.01))
	let(_overhead_bore_height = is_undef(overhead_bore_height) ? max(0, -inset) + 1 : overhead_bore_height)
	tog_holelib2__countersunk_hole_2(
		surface_d = surface_d,
		neck_d    = adjusted_neck_d,
		head_h    = adjusted_head_h,
		depth     = depth,
		bore_d    = adjusted_bore_d,
		overhead_bore_d = max(surface_d, tog_holelib2__coalesce(overhead_bore_d,0)),
		overhead_bore_height = _overhead_bore_height,
		inset     = _inset
	);

// TOTHINKABOUT: This could all be done with a single polyhedron!
// TOTHINKABOUT: Perhaps every counterbored hole should have the option
//   of remedy_depth > 0
function tog_holelib2_counterbored_with_remedy_hole(
	counterbore_d, shaft_d, depth, overhead_bore_height=undef, remedy_depth=0.4, inset=1
) =
	let(_overhead_bore_height = is_undef(overhead_bore_height) ? max(0, -inset) + 1 : overhead_bore_height)
	let(tip_z = _overhead_bore_height+counterbore_d/2)
	["intersection",
		// Hull: Counterbore and overhead bore all the way down
		tphl1_make_z_cylinder(zds=[[-depth, counterbore_d], [_overhead_bore_height, counterbore_d], [tip_z, 0]]),
		["union",
			// From the bottom up:
			// The shaft:
			tphl1_make_z_cylinder(zrange=[-depth-1, tip_z+1], d=shaft_d),
			// Remedy cuts...
			["intersection",
				togmod1_linear_extrude_z([-inset-remedy_depth * 3, -inset+1], togmod1_make_rect([counterbore_d+2, shaft_d])), // Y limit for both
				["union",
					togmod1_linear_extrude_z([-inset-remedy_depth * 2, -inset+3], togmod1_make_rect([shaft_d,   counterbore_d+3])), // Inner
					togmod1_linear_extrude_z([-inset-remedy_depth * 1, -inset+2], togmod1_make_rect([counterbore_d+2, shaft_d+1])), // Outer
				]
			],
			// Counterbore
			tphl1_make_z_cylinder(zrange=[-inset, tip_z+10], d=counterbore_d+1),
		]
	];

function tog_holelib2__coalesce(v, default_v) = is_undef(v) ? default_v : v;

// Suitable for #6 flatheads
function tog_holelib2_hole1001(depth, overhead_bore_height=1, inset=undef) =
	let(_inset = tog_holelib2__coalesce(inset, 0.1))
	tog_holelib2_countersunk_hole(7.5, 3.5, 1.7, depth, 4.5, 0, overhead_bore_height, inset=_inset);

// Suitable for 1/4" flatheads
function tog_holelib2_hole1002(depth, overhead_bore_height=1, overhead_bore_d=undef, inset=undef, bore_d=undef) =
	let(inch = 25.4)
	let(_inset = tog_holelib2__coalesce(inset, 0.1))
	let(_bore_d = is_undef(bore_d) ? 5/16*inch : bore_d)
	tog_holelib2_countersunk_hole(1/2*inch, 1/4*inch, 1/8*inch, depth, _bore_d,
		overhead_bore_d, overhead_bore_height, inset=_inset);

function tog_holelib2_hole1003(depth, overhead_bore_height=1, inset=undef) =
	let(_inset = tog_holelib2__coalesce(inset, 3.175))
	tog_holelib2_countersunk_hole(9.5, 4.5, 0, depth, 4.5, overhead_bore_height=overhead_bore_height, inset=_inset, $fn=6);

function tog_holelib2_hole1005(depth, overhead_bore_height=1, inset=undef) =
	let(_inset = tog_holelib2__coalesce(inset, 3.175))
	tog_holelib2_countersunk_hole(9.5, 4.5, 2.5, depth, 4.5, overhead_bore_height=overhead_bore_height, inset=_inset, $fn=6);

function tog_holelib2_hole1007(depth, overhead_bore_height=1, inset=undef) =
	let(_inset = tog_holelib2__coalesce(inset, 3.175))
	tog_holelib2_counterbored_with_remedy_hole(9.5, 4.5, depth, overhead_bore_height=overhead_bore_height, inset=_inset, $fn=6);

function tog_holelib2__min_delta(list, index=0, current=9999) =
	index >= len(list)-1 ? current :
	tog_holelib2__min_delta(list, index+1, min(current, list[index+1] - list[index])); 

function tog_holelib2___mkhole1006ish(
	bore_diam, counterbore_diam, default_counterbore_depth
) = function(depth, overhead_bore_height=1, inset=undef, flange_radius=undef)
	let(_inset  = max(0, is_undef(inset) ? default_counterbore_depth : inset))
	let(_flange = max(0, min(_inset - 1, is_undef(flange_radius) ? 0 : flange_radius)))
	let(_flangefn = max(1,round(min(_flange,$fn/4)))) // At most one segment per mm
	let(zds=[
		[-depth, bore_diam],
		[-_inset, bore_diam],
		[-_inset, counterbore_diam],
		if( _flange > 0 ) each [
			for( am=[0 : 1 : _flangefn] ) let( a=-90 + 90*am/_flangefn) [(cos(a)-1)*_flange, counterbore_diam + (1 + sin(a))*2*_flange]
		],
		[overhead_bore_height, counterbore_diam + 2*_flange]
	])
	assert(tog_holelib2__min_delta([for(zd=zds) zd[0]]) >= 0)
	tphl1_make_z_cylinder(zds=zds);

tog_holelib2_hole1006 =
	let(inch = 25.4)
	tog_holelib2___mkhole1006ish(5/16*inch, 7/8*inch, default_counterbore_depth=3.175);

tog_holelib2_hole_types = [
	["THL-1001", "Suitable for #6 flathead"],
	["THL-1002", "Suitable for 1/4\" flathead"],
	["THL-1003", "Suitable for #6 hex nuts or pan heads"],
	// THL-1004 is what was called 'coutnersnuk', but without the automatic extra inset;
	// it exists mostly to work around the pre-v2.3 implementation
	// of THL-1001 having a bug where bore_d is ignored.
	// THL-1004 is less precise, but good enough for most cases
	["THL-1004", "Suitable for #6 flathead, but roomier than 1001"],
	["THL-1005", "Countersunk for #6 flathead, but can also accept a hex nut"],
	["THL-1006", "Counterbored for 1/4\" furniture bolt, weld nut, etc"],
	["THL-1007", "Counterbored for #6 hex nut, with 'hole overhang remedy'"],
	["THL-1008", "Suitable for #6 flathead, but roomier than 1001 and larger hole than 1004"],
	// ["THL-1013", "Suitable for CRE24F2HBBNE SPDT rocker switche"],
	// ["THL-1021-(W)x(H)", "Mini-PV sleeve hole"]
	["THL-1023", "Counterbored for M3 pan-head screws"],
	["THL-1024", "Counterbored for M4 pan-head screws"],
	["THL-1025", "Counterbored for M5 pan-head screws"],
];

function tog_holelib2_get_hole_types() = tog_holelib2_hole_types;

function tog_holelib2_is_hole_type(type_name, idx=0) =
	idx > len(tog_holelib2_hole_types) ? false :
	tog_holelib2_hole_types[idx][0] == type_name ? true :
	tog_holelib2_is_hole_type(type_name, idx=idx + 1);

function tog_holelib2_hole(
	type_name,
	// Negative of Z position of bottom of hole
	depth=1000,
	// Z position of top of cutout
	overhead_bore_height=1,
	// How far beneath the surface to sink the top of the counterbore/countersink
	// (for counterbores, this is the depth of the counterbore)
	inset=undef,
	// For certain counterbored shapes that support rounding the top edge
	flange_radius=undef,
	// Overridable for some styles
	bore_d=undef
) =
	let(inch = 25.4)
	type_name == "none" ? ["union"] :
	type_name == "THL-1001" ? tog_holelib2_hole1001(depth, overhead_bore_height, inset=inset) :
	type_name == "THL-1002" ? tog_holelib2_hole1002(depth, overhead_bore_height, inset=inset, bore_d=bore_d) :
	type_name == "THL-1003" ? tog_holelib2_hole1003(depth, overhead_bore_height, inset=inset) :
	type_name == "THL-1004" ? tog_holelib2_countersunk_hole(8, 4, 2, depth, overhead_bore_height=overhead_bore_height, inset=inset) :
	type_name == "THL-1005" ? tog_holelib2_hole1005(depth, overhead_bore_height, inset=inset) :
	type_name == "THL-1006" ? tog_holelib2_hole1006(depth, overhead_bore_height, inset=inset, flange_radius=flange_radius) :
	type_name == "THL-1006-3/16in" ? tog_holelib2_hole1006(depth, overhead_bore_height, inset=3/16*inch, flange_radius=flange_radius) :
	type_name == "THL-1007" ? tog_holelib2_hole1007(depth, overhead_bore_height, inset=inset) :
	type_name == "THL-1008" ? tog_holelib2_countersunk_hole(8, 4.5, 2, depth, overhead_bore_height=overhead_bore_height, inset=inset) :
	type_name == "THL-1023" ? tog_holelib2_countersunk_hole(6.2, 3.8, 0, depth, overhead_bore_height=overhead_bore_height, inset=tog_holelib2__coalesce(inset, 2)) :
	assert(false, str("Unknown hole type: '", type_name, "'"));

// hole_zds = ["tog-holelib2-holezds", [[zbottomfact, zsurfacefactor, ztopfactor, onefactor], diameter], ...]
function tog_holelib2__decode_holezds(type, inset=undef) =
	let(inch = 25.4)
	// TODO: More generically parse the third token as inset, be it 3/16in or 5u
	type == "THL-1006-3/16in" ? tog_holelib2__decode_holezds("THL-1006", inset=3/16*inch) :
	is_list(type) && type[0] == "tog-hgolelib2-holezds" ? type :
	type == "THL-1006" ? let(_inset=is_undef(inset)?3.175:inset) ["tog-holelib2-holezds",
		[[1, 0, 0, -5/32*inch],    0     ],
		[[1, 0, 0,  0        ], 5/16*inch],
		[[0, 1, 0, -_inset   ], 5/16*inch], // 5/16*inch, 7/8*inch, default_counterbore_depth=3.175
		[[0, 1, 0, -_inset   ],  7/8*inch],
		[[0, 0, 1,  0        ],  7/8*inch],
		[[0, 0, 1,  7/16*inch],    0     ],
	] :
	assert(false, str("Unrecognized (to decode_holezds) hole type: ", type));

// zs = [z_bottom_of_hole, z_surface, z_top_of_overhead_bore]
function tog_holelib2_slot(type, zs, points) =
	// Fall back to the classic implementation
	// for single-point holes until everything's ported over
	// to the holezds system:
	is_string(type) && len(points) == 1 ?
		["translate", points[0],
			["translate", [0,0,zs[1]],
				tog_holelib2_hole(type, depth=-zs[0]-zs[1], overhead_bore_height=zs[2]-zs[1])]] :

	let( holezds = tog_holelib2__decode_holezds(type) )
	let( zds = [for(i=[1:1:len(holezds)-1])
		let(hzd=holezds[i])
		[hzd[0][0]*zs[0] + hzd[0][1]*zs[1] + hzd[0][2]*zs[2] + hzd[0][3]*1, hzd[1]]
	] )
	tphl1_make_polyhedron_from_layer_function(
		zds,
		function(zd) let(z=zd[0], r=max(0.01, zd[1]/2)) togvec0_offset_points(
			let(polypoints=togpath1_rath_to_polypoints(togpath1_polyline_to_rath(points, r, "round"))) polypoints,
			z
		)
   );
