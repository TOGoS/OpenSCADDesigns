use <../lib/TOGPath1.scad>

assert(len(togpath1__round([1,0], [1,1], [0,1], 1, 1)) == 1);
assert(len(togpath1__round([1,0], [1,1], [0,1], 1, 2)) == 2);
assert(len(togpath1__round([1,0], [1,1], [0,1], 1, 3)) == 3);

// echo(togpath1__round([1,0], [1,1], [0,1], 1, 2));
assert(togpath1__round([1,0], [1,1], [0,1], 1, 2) == [[1,0], [0,1]]);

echo(togpath1__round([1,0], [1,1], [0,1], 1, 1));
assert(togpath1__round([1,0], [1,1], [0,1], 1, 1) == [[1,1]]);



use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>

some_rath = ["togpath1-rath",
	["togpath1-rathnode", [ 50,-50]],
	["togpath1-rathnode", [ 50, 50], ["round", 25,  1]],
	["togpath1-rathnode", [-50, 50], ["round", 25,  4]],
	["togpath1-rathnode", [-50,-50], ["round", 45, 12]],
];

some_rath_polypoints = togpath1_rath_to_polypoints(some_rath);
assert( 12+4+1+1 == len(some_rath_polypoints), str("len(rath polypoints) should be = to the sum of the force_fns"));

togmod1_domodule(["linear-extrude-zs", [0, 10], togmod1_make_polygon(some_rath_polypoints)]);
