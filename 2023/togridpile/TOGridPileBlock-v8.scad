// TOGridPileBlock-v8.0

use <../lib/TOGridPileLib-v2.scad>

block_size_chunks = [2,3];
chunk_column_placement = "grid"; // ["none","corners","grid"]

togridpile2_block_bottom_intersector(block_size_chunks=block_size_chunks, chunk_column_placement=chunk_column_placement);