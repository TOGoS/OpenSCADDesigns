// Flangify0.2
// 
// Attempt at more convenient
// representation of holes
// with counterbores, bevels, flanges, etc.
// 
// Maybe should just be a special mode of tphl1_make_z_cylinder
// 
// pointdat = ["zdopses", ["zdops", [z, d], op, ...], ...], similar to a rath
// op = ["round", radius], same as togpath1-rathnode's
// 
// v0.2:
// - flangify0_extrude_z:
//   - Add support for `togpath1-polyline` shapes
//   - Allow 'zds' as an alternative to 'zrs'
// - Some comments

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGVecLib0.scad>

// r0 = the reference radius (zrs[*][1]) at which no offset should happen
function flangify0_extrude_rath(zrs, rath, r0=0) =
	tphl1_make_polyhedron_from_layer_function(zrs,
		function(zr)
			let( offset_rath = togpath1_offset_rath(rath, zr[1]-r0) )
			togpath1_rath_to_polypoints(offset_rath),
		layer_points_transform = "key0-to-z"
	);

/**
 * Extrude the given shape along zrs.
 * You might want to use flangify0_spec_to_zrs to generate the zrs,
 * since that's what adds the flanges.
 *
 * r0 = the reference zr[1] that should not be offset.
 */
function flangify0_extrude_z(zrs, shape="point", r0=0, zds=undef) =
	assert( is_undef(zrs) ||  is_undef(zds), "Exactly one of zrs or zds should be specified")
	let( _zrs =
		!is_undef(zrs) ? zrs :
		!is_undef(zds) ? [for(zd=zds) [zd[0],zd[1]/2]] :
		assert(false, "Either zrs or zds must be specified")
	)
	shape == "point" ? flangify0_extrude_rath(_zrs, togpath1_make_circle_rath(1), r0+1) :
	is_list(shape) && shape[0] == "togpath1-rath" ? flangify0_extrude_rath(_zrs, shape, r0) :
	is_list(shape) && shape[0] == "togpath1-polyline" ? flangify0_extrude_rath(_zrs, togpath1_polyline_to_rath(shape, r=1, end_shape="round"), r0+1) :
	assert(false, str("Unsupported shape: ", shape));

function flangify0__spec_to_zrs1(zropses, idx=1, rfac=1) =
	let(rath = ["togpath1-rath",
		for(p=[idx:1:len(zropses)-1])
			let(zrops=zropses[p])
				let(zd=zrops[1])
					["togpath1-rathnode", [zd[0], zd[1]*rfac], for(o=[2:1:len(zrops)-1]) zrops[o]]
	])
	togpath1_rath_to_polypoints(rath);

/**
 * Extend a zdopses or zdrses down by extra_depth and up by extra_height
 * 
 * flangify0_extend(ED, EH, [["zdops", [A,B]], ["zdops", [C,D]]])
 * -> ["zdopses", ["zdops", [A-ED,B]], ["zdops", [A,B]], ["zdops", [C,D]], ["zdops", [C+EH,D]]]
 * 
 * Uh, does this work with zropses???
 */
function flangify0_extend(extra_depth, extra_height, spec) =
let(last = len(spec)-1)
let(rfac = spec[0] == "zdopses" ? 0.5 : 1)
let(zd0 = spec[1   ][1])
let(zdN = spec[last][1])
[spec[0],
	if( extra_depth > 0 ) each [
//		["zdops", [zd0[0] - extra_depth - zd0[1]*rfac, 0.1    ]],
		["zdops", [zd0[0] - extra_depth              , zd0[1]]],
	],
	for( i=[1:1:len(spec)-1] ) spec[i],
	if( extra_height > 0 ) each [
		["zdops", [zdN[0] + extra_height              , zdN[1]]],
//		["zdops", [zdN[0] + extra_height + zdN[1]*rfac, 0.1    ]]
	],
];

function flangify0_spec_to_zrs(spec) =
	spec[0] == "zdopses" ? flangify0__spec_to_zrs1(spec, 1, 0.5) :
	spec[0] == "zropses" ? flangify0__spec_to_zrs1(spec, 1, 1) :
	assert(false, str("Unrecognized shape spec: '", spec[0], "'"));

// togmod1_domodule(zrs_to_cylinder([[0,5],[10,5]]));
togmod1_domodule(flangify0_extrude_z(flangify0_spec_to_zrs(flangify0_extend(10, 10, ["zdopses",
	["zdops", [-10,20]],
	["zdops", [- 5,20]],
	["zdops", [- 5,10], ["round", 3]],
	["zdops", [  5,10], ["bevel", 3]],
	["zdops", [  5,20]],
	["zdops", [ 10,20]],
]))), $fn = 24);
