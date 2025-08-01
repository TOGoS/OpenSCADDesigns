// TOGrat0.1
// 
// Generates gratings made of layers of beams.
// 
// GratingConfig = [beam_size : [num,num], pitch : num, angle : num]

use <./TOGMod1Constructors.scad>

function tograt1_grating_beam_size(grating_config) = grating_config[1];
function tograt1_grating_pitch(    grating_config) = grating_config[2];
function tograt1_grating_angle(    grating_config) = grating_config[3];
function tograt1_grating_z(        grating_config) = grating_config[4];

function tograt1_grating_zrange(grating_config, idx=1, cur=[9999,-9999]) =
	grating_config[0] == "tograt1-simple-grating" ? [
		tograt1_grating_z(grating_config) - tograt1_grating_beam_size(grating_config)[1]/2,
		tograt1_grating_z(grating_config) + tograt1_grating_beam_size(grating_config)[1]/2,
	] :
	grating_config[0] == "union" ?
		idx >= len(grating_config) ? cur :
		let( atidx = tograt1_grating_zrange(grating_config[idx]) )
		tograt1_grating_zrange(grating_config, idx+1, [min(cur[0],atidx[0]), max(cur[1],atidx[1])]) :
	assert(false, str("Don't know how to calculate zrange for grating config: ", grating_config));

function tograt1_make_grating(
	beam_size = [1,1],
	pitch = 10,
	angle = 30,
	z     =  0
) = ["tograt1-simple-grating", beam_size, pitch, angle, z];

function tograt1_make_multi_grating(
	grating_configs,
) = ["union", each grating_configs];

function tograt1__simple_grating_to_togmod(area, grating_config) =
	let( maxlen = sqrt(area[0]*area[0] + area[1]*area[1]) )
	let( beam =
		let( xss = tograt1_grating_beam_size(grating_config) )
		togmod1_make_cuboid([xss[0], ceil(maxlen), xss[1]])
	)
	let( z = tograt1_grating_z(grating_config) )
	let( pitch = tograt1_grating_pitch(grating_config) )
	let( count = ceil(maxlen / pitch) )
	// echo( maxlen=maxlen, beam=beam, pitch=pitch, count=count )
	["rotate", [0,0,tograt1_grating_angle(grating_config)], ["union",
		for( i=[-count/2 : 1 : count/2] ) ["translate", [i*pitch, 0, z], beam]
	]];

function tograt1__multi_grating_to_togmod(area, grating_config) = ["union",
	for( i=[1 : 1 : len(grating_config)-1] ) tograt1_grating_to_togmod(area, grating_config[i])
];

function tograt1_grating_to_togmod(area, grating_config) =
	grating_config[0] == "tograt1-simple-grating" ? tograt1__simple_grating_to_togmod(area, grating_config) :
	grating_config[0] == "union" ? tograt1__multi_grating_to_togmod(area, grating_config) :
	assert(false, str("Bad grating specification: ", grating_config));
