// TOGUnitTable-v1.0.0 - Library for handling 'complex amounts' in the form of [multiplier, unit name], e.g. [1.5, "inch"]
// 
// Versions:
// v1.0.0:
// - Created it.
// 
// Naming convention:
// Doing 'OO without classes', here.
// Fully qualified name = class or package name + "__" + member name
// Class or package name may itself be namespaced, and class names may double as package names.
// Here, tog_unittable names both a class and a package.

// Demo unit table uses 'micrometer' as the base unit
// in order to keep multipliers as integers as much as possible.
tog_unittable__demo_unit_table = [
	["um",    [    1   ,   "um"], "micrometer" ],
	["mm",    [ 1000   ,   "um"], "millimeter" ],
	["inch",  [25400   ,   "um"], "inch"       ],
	["u",     [    1/16, "inch"], "model unit" ], // As used by TGx9 et al
	["atom",  [    8   ,    "u"], "model atom" ],
	["chunk", [    3   , "atom"], "model chunk"],
];

function tog_unittable__list__filter(list, predicate) = [
	for( item=list ) if( predicate(item) ) item
];
function tog_unittable__list__first(list, on_error) =
	len(list) > 0 ? list[0] : on_error();

function tog_unittable__unit_value_ca(unit_table, unit_name) =
	tog_unittable__list__first(
		tog_unittable__list__filter(unit_table, function (entry) entry[0] == unit_name),
		function () assert(false, str("Did not find entry for unit '", unit_name, "' in unit table")))[1];

function tog_unittable__ca__is_valid( ca ) =
	is_list(ca) && len(ca) == 2;

// Break down 'amount' until it is in a base unit (one which is defined in terms of itself)
function tog_unittable__simplify_ca(unit_table, amount) =
	assert( tog_unittable__ca__is_valid(amount), str(amount, " is not a valid Complex Amount (should be [numeric_value, \"unit_name\"])") )
	let( unit_value_ca = tog_unittable__unit_value_ca(unit_table, amount[1]) )
	unit_value_ca[1] == amount[1] ? amount :
		tog_unittable__simplify_ca(unit_table, [amount[0] * unit_value_ca[0], unit_value_ca[1]]);

function tog_unittable__divide_ca(unit_table, numerator, denominator) =
	let(
		numerator_base_ca   = tog_unittable__simplify_ca(unit_table, numerator),
		denominator_base_ca = tog_unittable__simplify_ca(unit_table, denominator)
	)
	assert(numerator_base_ca[1] == denominator_base_ca[1], str("Different base units found for ", numerator[1], " and ", denominator[1]))
	numerator_base_ca[0] / denominator_base_ca[0];	

assert(tog_unittable__divide_ca(tog_unittable__demo_unit_table, [1,   "mm"], [  1, "mm"]) ==     1   );
assert(tog_unittable__divide_ca(tog_unittable__demo_unit_table, [1,   "mm"], [  1, "um"]) ==  1000   );
assert(tog_unittable__divide_ca(tog_unittable__demo_unit_table, [1, "inch"], [  1, "um"]) == 25400   );
assert(tog_unittable__divide_ca(tog_unittable__demo_unit_table, [1, "inch"], [  1, "mm"]) ==    25.4 );
assert(tog_unittable__divide_ca(tog_unittable__demo_unit_table, [1, "inch"], [254, "um"]) ==   100   );
assert(tog_unittable__divide_ca(tog_unittable__demo_unit_table, [1,    "u"], [  1, "um"]) ==  1587.5 );
