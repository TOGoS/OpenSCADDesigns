// TOGridLatticeLib0.1
// 
// Library for making TOGridPile-compatible lattices
// like those used in WSTYPE201630Plate1 and FHTVPSPlate1.
// 
// Dynamic variables:
// - $tgx11_offset :: offset of generated polygons
//   - As with tgx11 functions, this does NOT assume that you're using it
//     to generate subtractions, so if you want larger holes, pass a positive offset!
// - $togridlib3_unit_table

use <../lib/TOGUnits1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGMod1Constructors.scad>

function togridlatticelib0_make_cake_2d() =
	let( chunk = togunits1_to_mm([1,"chunk"]) )
	let( ci = togunits1_to_mm([1,"tgp-column-inset"]) )
	let( sect = togmod1_make_polygon(togpath1_rath_to_polypoints(
		let( cops=[["round", 3.175], ["offset", -25.4/15]] )
		["togpath1-rath",
			["togpath1-rathnode", [0.5*chunk, -0.5*chunk], each cops],
			["togpath1-rathnode", [0.5*chunk, +0.5*chunk], each cops],
			["togpath1-rathnode", [0        ,  0        ], each cops],
		])))
	["union", for( r=[0:90:270] ) ["rotate", [0,0,r], sect]];

function togridlatticelib0_make_bake_2d(offset=$tgx11_offset) =
	let( chunk = togunits1_to_mm([1,"chunk"]) )
	let( ci = togunits1_to_mm([1,"tgp-column-inset"]) )
	togmod1_make_rounded_rect([chunk-ci*2+offset*2, chunk-ci*2+offset*2], r=25.4/16);

function togridlatticelib0_make_lake_2d(rect_size, offset=$tgx11_offset) =
	let( chunk = togunits1_to_mm([1,"chunk"]) )
	let( size_chunks = [ceil(rect_size[0]/chunk), ceil(rect_size[1]/chunk)] )
	let( size_remaining = [for(i=[0:1:len(rect_size)-1]) size_chunks[i]*chunk - rect_size[i] ] )
	let( corner_chop = min(rect_size[0]*96/255, rect_size[1]*96/255, chunk - size_remaining[0]/2, chunk - size_remaining[1]/2) )
	let( corner_rad = min(12.7, 1 * (min(rect_size[0],rect_size[1])-corner_chop*2)) )
	togpath1_make_rounded_beveled_rect(rect_size, corner_chop, corner_rad, offset=offset);

function togridlatticelib0_make_lower_2d(rect_size) =
	let( offset = $tgx11_offset )
	let( chunk = togunits1_to_mm([1,"chunk"]) )
	let( size_chunks = [ceil(rect_size[0]/chunk), ceil(rect_size[1]/chunk)] )
   let( cake = togridlatticelib0_make_cake_2d() )
	["intersection",
		togridlatticelib0_make_lake_2d(rect_size, offset=$tgx11_offset - 1.5),
		
		["union",
			for( ym=[-size_chunks[1]/2 + 0.5 : 1 : size_chunks[1]/2] )
			for( xm=[-size_chunks[0]/2 + 0.5 : 1 : size_chunks[0]/2] )
			["translate", [xm,ym]*chunk, cake],
		]
	];

function togridlatticelib0_make_upper_2d(rect_size) =
	let( chunk = togunits1_to_mm([1,"chunk"]) )
	let( size_chunks = [ceil(rect_size[0]/chunk), ceil(rect_size[1]/chunk)] )
   let( bake = togridlatticelib0_make_bake_2d() )
	["intersection",
		togridlatticelib0_make_lake_2d(rect_size),
		
		["union",
			for( ym=[-size_chunks[1]/2 + 0.5 : 1 : size_chunks[1]/2] )
			for( xm=[-size_chunks[0]/2 + 0.5 : 1 : size_chunks[0]/2] )
			["translate", [xm,ym]*chunk, bake],
		]
	];
