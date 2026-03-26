// FrenchCleat2.0
// 
// v2.0:
// - Use more raths
// - Grooves

width = "2chunk";
height = "1chunk";
xy_bevel = "1/8inch";
chunk_bevel = "1/8inch";
front_segmentation = "none"; // ["halfchunk","none"]
back_segmentation = "none"; // ["halfchunk","none"]

$fn = 32;

module __frenchcleat2__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGHoleLib2.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGUnits1.scad>

function extrude_rath_z(zos, rath) = tphl1_make_polyhedron_from_layer_function(
	zos,
	function( zo ) togpath1_rath_to_polypoints(
		togpath1_offset_rath(rath, zo[1])
	),
	layer_points_transform = "key0-to-z"
);

width_mm = togunits1_to_mm(width);
width_chunks = togunits1_decode(width, unit="1chunk");
nominal_height_chunks = togunits1_decode(height, unit="1chunk");
nominal_height_mm     = togunits1_decode(height, unit="1mm");
xy_bevel_mm = togunits1_decode(xy_bevel, unit="1mm");
chunk_bevel_mm = togunits1_decode(chunk_bevel, unit="1mm");
hc_mm = 19.05; // 'half chunk' span
inch_mm = togunits1_to_mm("1inch");
chunk_mm = togunits1_to_mm("1chunk");

slot_length_mm = 6.35;

togmod1_domodule(
	let( hole = ["rotate-xyz", [-90,0,0], tog_holelib2_slot(
		"THL-1006", [-hc_mm-20, 0, 20],
		[[0,-slot_length_mm/2],[0,slot_length_mm/2]],
		counterbore_inset = 6.35
		// TODO: A nice counterbore/surface bevel?
	)] )

	let( the_fc =
		let(e=1/16)
		["rotate-xyz", [90,0,90],
			extrude_rath_z([
				[-width_mm/2              , -xy_bevel_mm],
				[-width_mm/2 + xy_bevel_mm,  0          ],
				[ width_mm/2 - xy_bevel_mm,  0          ],
				[ width_mm/2              , -xy_bevel_mm],
			],
			let( cops = [] /*[["bevel", 1/8*inch_mm]]*/ )
			let( pops = [["round", max(xy_bevel_mm+e, 1/8*inch_mm)]] )
			["togpath1-rath",
				["togpath1-rathnode", [-hc_mm/2, -nominal_height_mm/2 + hc_mm/2+e],          ], // Obtuse corner
				["togpath1-rathnode", [ hc_mm/2, -nominal_height_mm/2 - hc_mm/2+e], each pops], // Pointy corner
				["togpath1-rathnode", [ hc_mm/2,  nominal_height_mm/2          -e], each cops],
				["togpath1-rathnode", [-hc_mm/2,  nominal_height_mm/2          -e], each cops],
			])
		]
	)
	let( height_hcs = round(nominal_height_mm / hc_mm) + 2 )
	// Hmm: Maybe do a stack of those hulls for the chunks?
	let( the_chunkiness =
		let(e=1/32)
			extrude_rath_z([
				for( zm=[-height_hcs/2 + 0.5 : 1 : height_hcs/2 - 0.5] ) each [
					[(zm-0.5)*hc_mm               +e, -chunk_bevel_mm-e],
					[(zm-0.5)*hc_mm+chunk_bevel_mm+e,  0             -e],
					[(zm+0.5)*hc_mm-chunk_bevel_mm-e,  0             -e],
					[(zm+0.5)*hc_mm               -e, -chunk_bevel_mm-e],
				]
			],
			let( cops = [["bevel", 1/8*inch_mm]] )
			let( yf = front_segmentation == "halfchunk" ?  hc_mm/2 :  hc_mm )
			let( yb =  back_segmentation == "halfchunk" ? -hc_mm/2 : -hc_mm )
			["togpath1-rath",
				["togpath1-rathnode", [ width_mm/2,yb], each cops],
				["togpath1-rathnode", [ width_mm/2,yf], each cops],
				["togpath1-rathnode", [-width_mm/2,yf], each cops],
				["togpath1-rathnode", [-width_mm/2,yb], each cops],
			]
		)
	)
	["difference",
		["intersection",
			the_chunkiness,
			the_fc,
		],
		
		for( xm=[-width_chunks/2+0.5 : 1 : width_chunks/2-0.5] )
		for( zm=[-nominal_height_chunks/2+0.5 : 1 : nominal_height_chunks/2-0.5] )
		["translate", [xm*chunk_mm, hc_mm/2, zm*chunk_mm], hole],
	]
);
