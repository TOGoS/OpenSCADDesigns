// TOGArrayLib1.4
// 
// Functions for working with arrays.
// 
// v1.1:
// - tal1_reduce assert(is_list(items)) to prevent infinite recursion
//   when given undefined or other non-list values
// v1.1.1:
// - Fix tal1_uniq_remap_v2 to return "list-remap-result" as the
//   first element of the returned list
// v1.2:
// - Add tal1_replace_at function
// v1.3:
// - tal1_is_vec_of, tal1_is_vec_of_num
// v1.4:
// - tal1_assert_for_each, for when you want to assert something
//   about each of a list of items and get nice failure messages

/**
 * Make a list with the contents of list `a`,
 * but starting at offset `off`, replaced by the contents of list `b`.
 * len(result) = max(len(a), off+len(b))
 */
function tal1_replace_at(a, off, b, default_value=undef, default_value_function=undef) =
	assert(is_list(a))
	assert(is_list(b))
	let( _dvf = !is_undef(default_value_function) ? default_value_function : function(i) default_value )
[
	for( i=[0:1:min(off,len(a))-1] ) a[i],
	for( i=[len(a):1:off-1] ) _dvf(i),
	for( i=[off:1:off+len(b)-1] ) b[i-off],
	for( i=[off+len(b):1:len(a)-1] ) a[i],
];

// Simplest case
assert([] == tal1_replace_at([], 0, []));
// Second simplest cases
assert(["foo"] == tal1_replace_at(["foo"], 0, []));
assert(["foo"] == tal1_replace_at([], 0, ["foo"]));
// Replace one item
assert(["foo","quux","baz"] == tal1_replace_at(["foo","bar","baz"], 1, ["quux"]));
// Replace and extend
assert(["foo","quux","tuna","tina"] == tal1_replace_at(["foo","bar","baz"], 1, ["quux", "tuna", "tina"]));
// Add beyond end of `a`
assert(["foo","zzz","quux"] == tal1_replace_at(["foo"], 2, ["quux"], default_value="zzz"));
// Adding 'nothing' should still fill to that point with defaults
assert(["foo","zzz","zzz"] == tal1_replace_at(["foo"], 3, [], default_value="zzz"));


function tal1_reduce(start, items, func, offset=0) =
	assert(is_list(items))
	len(items) == offset ? start :
	tal1_reduce(func(start, items[offset]), items, func, offset+1);

function tal1_consecutive_duplicate_count(items) = tal1_reduce(
	[0, undef],
	items,
	function(z,item) [z[0] + (item == z[1] ? 1 : 0), item]
)[0];

assert(0 == tal1_consecutive_duplicate_count([]));
assert(0 == tal1_consecutive_duplicate_count([50]));
assert(1 == tal1_consecutive_duplicate_count([50,50]));
assert(0 == tal1_consecutive_duplicate_count([50,51,52,53]));
assert(1 == tal1_consecutive_duplicate_count([50,51,52,52]));
assert(3 == tal1_consecutive_duplicate_count([50,50,50,50]));

// Set test_size to arbirarily large values
// to ensure that OpenSCAD can handle heavy recursion
let(test_size=1000) assert(test_size/2 == tal1_consecutive_duplicate_count([for(i=[0:1:test_size-1]) floor(i/2)]));



function tal1_uniq_(items, off0, off1) =
	let(chunklen = off1-off0)
	chunklen == 0 ? [] :
	chunklen == 1 ? [items[off0]] :
	let(half=floor(chunklen/2))
	let(left  = tal1_uniq_(items, off0     , off0+half))
	let(right = tal1_uniq_(items, off0+half, off1     ))
	assert(len(left) > 0)
	assert(len(right) > 0)
	left[len(left)-1] == right[0] ? [each left, for(i=[1:1:len(right)-1]) right[i]] :
	[each left, each right];

/** Given a list of items, returns a new list with identical consecutive items merged */
function tal1_uniq(items) = tal1_uniq_(items, 0, len(items));

assert([] == tal1_uniq([]));
assert([123] == tal1_uniq([123]));
assert([55,0,1,2,3] == tal1_uniq([55,0,1,2,3]));
assert([55,0,1,2] == tal1_uniq([55,0,1,1,2]));
assert([55,0,1] == tal1_uniq([55,55,0,0,0,0,0,0,1,1,1,1]));
assert([55,0] == tal1_uniq([55,0,0,0,0,0,0,0]));



/**
 * Returns [new items, old index -> new index mapping].
 * No-op version.
 */
function tal1_uniq_remap_v1(items) =
	["list-remap-result", items, [for (vi=[0:1:len(items)-1]) vi]];

// [a, a, b, b, c, c]
//
// [a,    ...], []  -> [a],[0]
// [a, a, ...], [0] -> [a],[0,0]

assert([1,2,3] == [1,2,3]);

/**
 * Recursive version that will combine adjacent identical vertexes,
 * but will use the original items.
 */
function tal1_uniq_remap_v2(items, map=[]) =
	let(index = len(map))
	len(items) == index ? ["list-remap-result", items, map] :
	index == 0 ? tal1_uniq_remap_v2(items, [0]) :
	items[index] == items[map[index-1]] ? tal1_uniq_remap_v2(items, [for(vi=map) vi, map[index-1]]) :
	tal1_uniq_remap_v2(items, [for(vi=map) vi, index]);

assert(tal1_uniq_remap_v2([1,1,2,2,3,4]) == ["list-remap-result", [1,1,2,2,3,4], [0,0,2,2,4,5]]);


/**
 * Returns true if `vec` is a list of at least min_len items
 * and component_check(each item, even those beyond min_len) is true.
 */
function tal1_is_vec_of(vec, min_len=0, component_check=function(x) true) =
	assert(is_num(min_len) && min_len >= 0)
	assert(is_function(component_check))
	is_list(vec) && len(vec) >= min_len &&
	tal1_reduce(true, vec, function(prev,item) prev && component_check(item));

function tal1_is_vec_of_num(vec, min_len=0) = tal1_is_vec_of(vec, min_len, function(i) is_num(i));

assert( true == tal1_is_vec_of_num([1,2,3]));
assert( true == tal1_is_vec_of_num([]));
assert( true == tal1_is_vec_of_num([1,2,3], 3));
assert(false == tal1_is_vec_of_num([1,2], 3));
assert(false == tal1_is_vec_of_num([1,2,"spoon"], 3));
// Requirements are ambiguous when
// first min_len items are numbers, but there are non-numeric items afterwards,
// so let's error on the side of saying 'no, it's not a list of numbers';
// i.e. the item check and the min_len are independent.
assert(false == tal1_is_vec_of_num([1,2,3,"artichoke"], 3));


/**
 * Asserts that item_checker(each item in list, index of item)[0] is true.
 * Second element of item_checker return value is assertion message.
 * Returns the original list, in case that's useful to you.
 */
function tal1_assert_for_each(list, item_checker) =
	let( _ignored = [ for(i=[0:1:len(list)-1])
		let(q=item_checker(list[i],i))
		let(passed=is_bool(q) ? q : is_list(q) ? q[0] : assert(false, str(
			"tal1_assert_for_each: item_checker should return Bool|[Bool,String], but returned ",
			q, " for item at index ", i)))
		let(message=is_list(q) ? q[1] : undef)
		assert(passed, message)
		q
	])
	list;

// Callback can return a boolean...
assert([1,2,3] == tal1_assert_for_each([1,2,3], function(v,i) is_num(v)));
// ...or a [boolean, string]
assert([1,2,3] == tal1_assert_for_each([1,2,3], function(v,i) [is_num(v), "element be a num"]));
