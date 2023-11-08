// TOGArrayLib1.1.1
// 
// Functions for working with arrays.
// 
// v1.1:
// - tal1_reduce assert(is_list(items)) to prevent infinite recursion
//   when given undefined or other non-list values
// v1.1.1:
// - Fix tal1_uniq_remap_v2 to return "list-remap-result" as the
//   first element of the returned list

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
