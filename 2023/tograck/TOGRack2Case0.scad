// TOGRack2Case0.1

size_chunks = [1,2,1];
outer_offset = -0.1;
inner_offset = -0.2;
u = 25.4/16;

use <../lib/TOGMod1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGVecLib0.scad>

function recrath(size, corner_ops) = ["togpath1-rath",
	["togpath1-rathnode", [-size[0]/2, -size[1]/2], each corner_ops],
	["togpath1-rathnode", [ size[0]/2, -size[1]/2], each corner_ops],
	["togpath1-rathnode", [ size[0]/2,  size[1]/2], each corner_ops],
	["togpath1-rathnode", [-size[0]/2,  size[1]/2], each corner_ops],
];

fn22d = 6;

function bevrath(size, off) = recrath(size, [["bevel", 2*u], ["round", 2*u, fn22d], ["offset", off]]);
function rourath(size, off) = recrath(size, [["round", 1*u, fn22d*2+2], ["offset", off]]);

function layer_rath(shap) =
	shap[0] == "b" ? bevrath(shap[1], shap[2]) : rourath(shap[1], shap[2]);

function rack(nsize) =
	let(rackz = nsize[2] - 6.35)
	let(floorz = 6.35)
	let(hsize = [nsize[0] - 4*u, nsize[1] - 14*u])
	let(csize = [nsize[0] - 3*u, nsize[1] -  3*u])
	tphl1_make_polyhedron_from_layer_function([
		[      -1, ["b", nsize,   outer_offset]],
		[nsize[2], ["b", nsize,   outer_offset]],
		[nsize[2], ["b", nsize,-u-inner_offset]],
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

togmod1_domodule(rack(size_chunks*38.1));
// TODO: Holes
// TODO: TOGridPile foot
