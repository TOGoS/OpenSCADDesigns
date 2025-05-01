// TOGUnits1.1
// 
// For simlifying quantity parsing and unit conversion
// 
// v1.1:
// - Add `togunits1_decode` function

use <./TOGridLib3.scad>
use <./TOGStringLib1.scad>


function togunits1__is_ca(what) =
	is_list(what) && len(what) == 2 && is_num(what[0]) && is_string(what[1]);

function togunits1__parse_to_ca(what) =
	assert( is_string(what) )
	let( parseresult = togstr1_parse_quantity(what) )
	assert( parseresult[1] > 0, str("Failed to parse quantity from  ", what) )
	let( parsed = parseresult[0] )
	let( rat = parsed[0] )
	let( unit = parsed[1] )
	[rat[0]/rat[1], unit];

function togunits1_to_ca(what) =
	is_string(what) ? togunits1__parse_to_ca(what) :
	togunits1__is_ca(what) ? what :
	is_num(what) ? [what, "mm"] :
	assert(false, str("Unrecognized quantity representation: ", what));

function togunits1_decode(what, unit=[1,"mm"]) =
	let( ca = togunits1_to_ca(what) )
	togridlib3_decode(ca, unit=togunits1_to_ca(unit));

function togunits1_to_mm(what) = togunits1_decode(what, [1,"mm"]);
