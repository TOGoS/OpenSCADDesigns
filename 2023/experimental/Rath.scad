use <../lib/TOGPath1.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>

$fn = 24;

togmod1_domodule(togmod1_make_polygon(togpath1_rath_to_points(["togpath1-rath",
	["togpath1-rathseg", [-10,-10], ["offset", 3], ["bevel", 4], ["round", 2]],
	["togpath1-rathseg", [ 10,-10]],
	["togpath1-rathseg", [ 10, 10], ["round", 2], ["offset", 2]],
	["togpath1-rathseg", [-10, 10], ["round", 4]],
])));
