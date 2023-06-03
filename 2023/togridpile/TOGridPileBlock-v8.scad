// TOGridPileBlock-v8.0

use <../lib/TOGridPileLib-v2.scad>

column_style = "v8.4"; // ["v6", "v6.1", "v6.2", "v8", "v8.0", "v8.4"]
chunk_body_style = "v1"; // ["v0.0","v0.1","v1","v2","v8"]
block_size_chunks = [2,3,1];
chunk_column_placement = "grid"; // ["none","corners","grid"]
bottom_segmentation = "chunk"; // ["atom","chunk","block"]
side_segmentation = "block"; // ["atom","chunk","block"]
$fn = 24;

togridpile2_block(
	block_size_chunks = block_size_chunks,
	column_style = column_style,
	chunk_column_placement = chunk_column_placement,
	chunk_body_style = chunk_body_style,
	bottom_segmentation = bottom_segmentation,
	side_segmentation = side_segmentation
);
