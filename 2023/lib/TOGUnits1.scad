// TOGUnits1.4
// 
// For simlifying quantity parsing and unit conversion
// 
// v1.1:
// - Add `togunits1_decode` function
// v1.2:
// - Add togunits1_decode_vec
// v1.3:
// - Add togunits1_vec_to_cas
// v1.4:
// - Add togunits1_vec_to_mms

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

function togunits1_vec_to_cas(whats, unit=[1,"mm"]) =
	[for(w=whats) togunits1_to_ca(w)];

function togunits1__get_transform(name) =
	is_function(name) ? name :
	is_undef(name) ? function(n) n :
	name == "round" ? function(n) round(n) :
	name == "ceil" ? function(n) ceil(n) :
	assert(false, str("Unrecognized transform: '", name, "'"));

function togunits1_decode(what, unit=[1,"mm"]) =
	let( ca = togunits1_to_ca(what) )
	togridlib3_decode(ca, unit=togunits1_to_ca(unit));

function togunits1_decode_vec(whats, unit=[1,"mm"], xf=undef) =
	let( unit_ca = togunits1_to_ca(unit) )
	let( xf1 = togunits1__get_transform(xf) )
	[for(w=whats) xf1(togunits1_decode(w, unit_ca))];

function togunits1_to_mm(what) = togunits1_decode(what, [1,"mm"]);
function togunits1_vec_to_mms(what) = togunits1_decode_vec(what, [1,"mm"]);
