// ChunkBeam2Lib, v2.1
// 
// TODO:
// - [ ] Librarify 'nice hole'-making functions from ChunkBeam2.scad

use <../lib/TOGridLib3.scad>
use <../experimental/AutoOffsetPolyhedron0.scad>

function chunkbeam2__make_chunky_profile(chunk_count, ep=0.0001) =
let( chunk_pitch = togridlib3_decode([1,"chunk"]) )
let( bevel_size = togridlib3_decode([1, "tgp-standard-bevel"]) )
[
	for( c=[0:1:chunk_count-1] ) each let(cy0=chunk_pitch*c) [
		[-bevel_size,  cy0                            + ep],
		[          0,  cy0               + bevel_size     ],
		[          0,  cy0 + chunk_pitch - bevel_size     ],
		[-bevel_size,  cy0 + chunk_pitch             - ep],
	]
];

// Note: Subtracting offset from rounding radius
// (which actually increases the radius) is necessary to prevent
// <0 radius invalid corners.
// This maybe shows a limitation of the
// "just offset each layer" approach.
chunkbeam2_tgp_rath =
let( chunk_pitch = togridlib3_decode([1,"chunk"]) )
let( bevel_size = togridlib3_decode([1, "tgp-standard-bevel"]) )
let( x1 = chunk_pitch/2, y1=chunk_pitch/2 )
let( cops = [["bevel", bevel_size], ["round", 3.175-$tgx11_offset]] )
["togpath1-rath",
	["togpath1-rathnode", [ x1, -y1], each cops],
	["togpath1-rathnode", [ x1,  y1], each cops],
	["togpath1-rathnode", [-x1,  y1], each cops],
	["togpath1-rathnode", [-x1, -y1], each cops],
];

function chunkbeam2_make_chunkbeam_hull(height_chunks) =
	aop0_make_polyhedron_from_profile_rath( chunkbeam2__make_chunky_profile(height_chunks), chunkbeam2_tgp_rath );
