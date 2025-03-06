// TOGRack2Case0.4
// 
// v0.3:
// - Adjust rounding point count calculations to work with recent TOGPath1 verions
//   that interpret it as vertex count instead of face count (hmm)
// - Use togx11_block_bottom instead of tgx11_atomic_block_bottom
// v0.4:
// - Make rack_inset configurable

// 'TOGRack2' = WSTYPE-4140, mentioned in https://www.nuke24.net/docs/2018/TOGRack.html
// https://www.nuke24.net/uri-res/raw/urn:bitprint:S7EBAC6OOBUZB3IYHEZ6N2QFXRBT2EVX.4GQUAKTWXJNQJRYTZ2HK43UZC5LE3UUI7JZAKEY/WSTYPE-4140-v2.2.pdf

size_chunks = [1,2,1];
outer_offset = -0.1; // 0.1
inner_offset = -0.2; // 0.1
lip_height = 1.5875; // 0.0001
// 1,2,3 8ths = 3.175, 6.35, 9.525
rack_inset = 6.35; // 0.001
bottom_segmentation = "atom"; // ["atom","chatom","none"]

module __tr2c0__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGridLib3.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGVecLib0.scad>
use <../lib/TGx11.1Lib.scad>

$tgx11_offset = outer_offset;
$tgx11_gender = "m";
$togridlib3_unit_table = tgx11_get_default_unit_table();
$fn = $preview ? 16 : 32;
u = 25.4/16;
chunk_pitch = 38.1;
fn22d = $fn/4;

size_ca = [
	[size_chunks[0], "chunk"],
	[size_chunks[1], "chunk"],
	[size_chunks[2], "chunk"],
];

function recrath(size, corner_ops) = ["togpath1-rath",
	["togpath1-rathnode", [-size[0]/2, -size[1]/2], each corner_ops],
	["togpath1-rathnode", [ size[0]/2, -size[1]/2], each corner_ops],
	["togpath1-rathnode", [ size[0]/2,  size[1]/2], each corner_ops],
	["togpath1-rathnode", [-size[0]/2,  size[1]/2], each corner_ops],
];

function bevrath(size, off) = recrath(size, [["bevel", 2*u], ["round", 2*u, fn22d], ["offset", off]]);
function rourath(size, off) = recrath(size, [["round", 1*u, fn22d*2], ["offset", off]]);

function layer_rath(shap) =
	shap[0] == "b" ? bevrath(shap[1], shap[2]) : rourath(shap[1], shap[2]);

function rack_hull(nsize, rack_inset, lip_height) =
	let(rackz = nsize[2] - rack_inset)
	let(floorz = 6.35)
	let(liptopz = nsize[2]+lip_height)
	let(hsize = [nsize[0] - 4*u, nsize[1] - 14*u])
	let(csize = [nsize[0] - 3*u, nsize[1] -  3*u])
	tphl1_make_polyhedron_from_layer_function([
		[       0, ["b", nsize,   outer_offset]],
		[ liptopz, ["b", nsize,   outer_offset]],
		[ liptopz, ["b", nsize,-u-inner_offset]],
		[   rackz, ["b", nsize,-u-inner_offset]],
		[   rackz     , ["r", hsize,              0]],
		// TODO: Taper cavity out for 1/16"-1/8" walls?
		[   rackz-6.35, ["r", hsize,              0]],
		[   rackz-19.05, ["r", csize,              0]],
		[  floorz+1   , ["r", csize,              0]],
		[  floorz+0   , ["r", csize,             -1]],
	], function(layer)
		let(z = layer[0])
		let(rath = layer_rath(layer[1]))
		togvec0_offset_points(togpath1_rath_to_polypoints(rath), z)
	);

mhole1 = tphl1_make_z_cylinder(5, [-19,1]);
mhole2 = tphl1_make_z_cylinder(3, [-19,1]);
magnet_hole = tphl1_make_z_cylinder(6.2, [-1,2.4]);

function rack(size_ca) =
	let( size = togridlib3_decode_vector(size_ca) )	
	let( conduit_hole = ["rotate", [0,90,0], tphl1_make_z_cylinder(6.35, [-size[0], size[0]])] )
	let( size_atoms = togridlib3_decode_vector(size_ca, unit=[1, "atom"]) )
	let( size_chunks = togridlib3_decode_vector(size_ca, unit=[1, "chunk"]) )
	let( atom_pitch = togridlib3_decode([1,"atom"]) )
	let( chunk_pitch = togridlib3_decode([1,"chunk"]) )
	let( rackz = size[2] - rack_inset )
	["difference",
		["intersection",
			if( bottom_segmentation != "none" ) tgx11_block_bottom([[size_chunks[0], "chunk"], [size_chunks[1], "chunk"], [size_chunks[2]*2, "chunk"]], segmentation=bottom_segmentation),
			rack_hull(size_chunks*chunk_pitch, rack_inset=rack_inset, lip_height=lip_height)
		],
	
		for( xm=[-size_atoms[0]/2+0.5 : 1 : size_atoms[0]/2] )
		for( ym=[-size_atoms[1]/2+0.5 ,     size_atoms[1]/2-0.5] )
		["translate", [xm*atom_pitch, ym*atom_pitch, rackz], round(xm+ym+0.1)%2 == 0 ? mhole1 : mhole2],
		
		for( cxm=[-size_chunks[0]/2+0.5 : 1 : size_chunks[0]/2] )
		for( cym=[-size_chunks[1]/2+0.5 : 1 : size_chunks[1]/2] )
		for( axm=[-1,1] ) for( aym=[-1,1] )
		["translate", [cxm*chunk_pitch + axm*atom_pitch, cym*chunk_pitch + aym*atom_pitch, 0], magnet_hole],
		
		for( ym=[-size_chunks[1]/2+0.5 : 0.5 : size_chunks[1]/2-0.4] )
		["translate", [0,ym*chunk_pitch,size[2]/2], conduit_hole],
	];

togmod1_domodule(rack(size_ca));
