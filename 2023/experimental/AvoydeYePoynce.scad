// A polyline that jumps up over certain points, or spans of them.
// Intennded to generate insets on a part's hull
// to avoid screw holes on a flange, or something.
// See http://picture-files.nuke24.net/uri-res/raw/urn:bitprint:VLXIWDXHQYJIENN3AEKVF42MHASITPQM.WFSFKRCOJLL7XK2DBA23D3G6RG4FRERH7HQIIFI/20240911-TerrariumOutlineSchems.jpg

function ayp_find_end_of_span( pointxs, min_gap, index=0 ) =
	assert(index < len(pointxs))
	index+1 >= len(pointxs) ? index+1 :
	pointxs[index+1] - pointxs[index] >= min_gap ? index+1 :
	ayp_find_end_of_span( pointxs, min_gap, index+1 );

function skipovre_ye_poince(reg_y, point_y, slope_dx, point_dx, min_dx, pointxs, index=0) =
	let( slope_dx = point_y-reg_y )
	let( skipto = ayp_find_end_of_span(pointxs, point_dx + slope_dx + min_dx + slope_dx  + point_dx, index) )
	[
		[pointxs[skipto-1] + point_dx, point_y],
		[pointxs[skipto-1] + point_dx + slope_dx, reg_y],
		each avoyde_ye_poynce(reg_y, point_y, slope_dx, point_dx, min_dx, pointxs, skipto)
	];

function avoyde_ye_poynce(reg_y, point_y, slope_dx, point_dx, min_dx, pointxs, index=0) =
	index >= len(pointxs) ? [] :
	[
		[pointxs[index] - point_dx - slope_dx, reg_y],
		[pointxs[index] - point_dx, point_y],
		each skipovre_ye_poince(reg_y, point_y, slope_dx, point_dx, min_dx, pointxs, index)
	];

assert( "x" == "x" );


function test_ye_avoydence(expect, pointxs) =
	let( actual = avoyde_ye_poynce(1, 3, 2, 1, 2, pointxs) )
	echo(pointxs=pointxs, result=actual)
	assert( expect == actual )
	true;

module test_ye_avoydence(expect, pointxs) {
	x = test_ye_avoydence(expect, pointxs);
}

test_ye_avoydence([], []);
test_ye_avoydence([[2,1], [4,3], [6,3], [8,1]], [5]);
test_ye_avoydence([[2,1], [4,3], [8,3], [10,1]], [5, 7]); // Obviously not enough room for a dip
test_ye_avoydence([[2,1], [4,3], [6,3], [8,1], [10,1], [12,3], [14,3], [16,1]], [5, 13]);
test_ye_avoydence([[2,1], [4,3], [13,3], [15,1]], [5, 12]); // Not quite enough room for a dip
