// TOGridPileLib-v2.4.2
//
// Changes:
// v2.2:
// - togridpile2_block_bottom_intersector et al
// v2.2.2:
// - Actually implement some different chunk body sizes,
//   though some combinations (namely, those where side_segmentation="chunk"
//   and bottom_segmentation is something else)
//   give not-useful results as currently interpreted; I may change them later
// v2.2.3:
// - Improve handling of side_segmentation = "chunk"
// v2.2.4:
// - Support 'v3' feet, which are the same as v6 but one per chunk, not per atom
// - Fix that offset was not being taken into account for some parts of block
// v2.3:
// - Simplify magnet hole shape when drian diameter=0
// v2.4:
// - Add side columns with separately-configurable style and placement
// v2.4.1:
// - Add 'deplane_offset' parameter in attempt to avoid Z-fighting or whatever
//   which leads to leaky surfaces
// v2.4.2:
// - Redefine v6[.0] feet using a constant multiplier (1.707 = sqrt(2)/2 + 1) of column_inset
// - Redefine v7.1 feet using sqrt(2) instead of 2*0.707
// - Redefine v8[.4] feet using sqrt(2)/2 instead of 0.707

// 12.7mm = 1/2"
togridpile2_default_atom_pitch        = 12.7000; // 0.0001
// 9.5245mm = 3/8"
togridpile2_default_column_diameter   =  9.5245; // 0.0001
// 1.5875mm = 1/16"
togridpile2_default_min_corner_radius =  1.5875; // 0.0001

inch = 25.4;

togridpile2_default_rounded_corner_radius = 3/16*inch;
togridpile2_default_beveled_corner_radius = 1/8*inch;
togridpile2_default_chunk_column_placement = "grid";

use <TOGShapeLib-v1.scad>

module togridpile2_atom_column_footprint(
	column_style="v8",
	atom_pitch=togridpile2_default_atom_pitch,
	column_diameter=togridpile2_default_column_diameter,
	min_corner_radius=togridpile2_default_min_corner_radius,
	offset=0
) {
	if( column_style == "none" ) {
	} else if( column_style == "v3" || column_style == "v6" || column_style == "v6.0" ) {
		column_inset = (atom_pitch - column_diameter)/2;
		tog_shapelib_rounded_beveled_square([column_diameter, column_diameter],
			// Previously column_inset*2*0.707 + (0.707-0.414)*min_corner_radius;
			// this is equivalent, when the inset is the same as tha min_corner_radius (each 1/16", usually)
			// to how the bevel was originally miscalcualted.
			column_inset*(sqrt(2)/2+1), // 1.707
			min_corner_radius, offset
		);
	} else if( column_style == "v6.1" ) {
		column_inset = (atom_pitch - column_diameter)/2;
		tog_shapelib_rounded_beveled_square([column_diameter, column_diameter], column_inset*sqrt(2), min_corner_radius, offset);
	} else if( column_style == "v6.2" ) {
		// similar to v6 or v6.1, but with deep-enough bevels to fit another diagonally, as in v8.4
		column_inset = (atom_pitch - column_diameter)/2;
		tog_shapelib_rounded_beveled_square([column_diameter, column_diameter], atom_pitch/2-(atom_pitch-column_diameter), min_corner_radius, offset);
	} else if( column_style == "v8.0" ) {
		circle(d=column_diameter+offset);
	} else if( column_style == "v8" || column_style == "v8.4" ) {
		// rounded but with corners trimmed so another can fit between diagonally
		intersection() {
			circle(d=column_diameter+offset);
			rotate([0,0,45]) square(atom_pitch*sqrt(2)/2+offset, center=true);
		}
	} else {
		assert(false, str("Unrecognized column column_style: '", column_style, "'"));
	}
}

// Segmentation styles:
// - "atom"
// - "chunk"
// - "block" - not segmented

// column placement
// - "none"
// - "grid" - each atom cell gets a column
// - "corners" - corner atom cells get a column

function togridpile2_column_positions(
	block_size_chunks=[1,1],
	chunk_pitch_atoms=3,
	atom_pitch=togridpile2_default_atom_pitch,
	chunk_column_placement="grid"
) =
	chunk_column_placement == "none" ? [] :
	chunk_column_placement == "grid" ? [
		for( xm=[-(block_size_chunks[0]*chunk_pitch_atoms)/2+0.5 : 1 : +(block_size_chunks[0]*chunk_pitch_atoms)/2] )
		for( ym=[-(block_size_chunks[1]*chunk_pitch_atoms)/2+0.5 : 1 : +(block_size_chunks[1]*chunk_pitch_atoms)/2] )
			[atom_pitch * xm, atom_pitch * ym]
	] :
	chunk_column_placement == "corners" ? [
		for( xm=[-block_size_chunks[0]/2+0.5 : 1 : +block_size_chunks[0]/2] )
		for( ym=[-block_size_chunks[1]/2+0.5 : 1 : +block_size_chunks[1]/2] )
		for( cxm=[-1,1] ) for( cym=[-1,1] )
			[
				(xm*chunk_pitch_atoms + cxm*(chunk_pitch_atoms/2-0.5)) * atom_pitch,
				(ym*chunk_pitch_atoms + cym*(chunk_pitch_atoms/2-0.5)) * atom_pitch,
			]
	] : assert(false, str("Unrecognized column placement: ", chunk_column_placement));

// chunk body styles
// - "v0.0" - rounded cube
// - "v0.1" - beveled cube
// - "v1" - rounded beveled cube with vertical edges rounded, used by v3..v6
// - "v2" - rounded beveled cube
// - "v8" - rounded cube with radius=atom_pitch/2

module togridpile2_chunk_body(
	size=[38.1,38.1,38.1],
	style="v1",
	min_corner_radius=togridpile2_default_min_corner_radius,
	rounded_corner_radius=togridpile2_default_rounded_corner_radius,
	beveled_corner_radius=togridpile2_default_beveled_corner_radius,
	atom_radius=togridpile2_default_atom_pitch/2,
	offset=0
) {
	if( style == "v1" ) {
		intersection() {
			tog_shapelib_facerounded_beveled_cube(
				size,
				beveled_corner_radius + offset*0.4, // Approximate; figure out proper offset amount if relying on this for larger offsets!
				min_corner_radius,
				offset
			);
			tog_shapelib_xy_rounded_cube(size, rounded_corner_radius, offset);
		}
	} else if( style == "v2" ) {
		tog_shapelib_facerounded_beveled_cube(
			size,
			beveled_corner_radius + offset*0.4, // Approximate; figure out proper offset amount if relying on this for larger offsets!
			min_corner_radius,
			offset
		);
	} else if( style == "v8" ) {
		tog_shapelib_rounded_cube(size, atom_radius, offset);
	} else {
		assert(false, str("Unrecognized chunk body style: '", style, "'"));
	}
}

function togridpile2__tovec3(v) = is_list(v) ? v : [v,v,v];

function togridpile2__corner_radius_for_body_style(
	body_style,
	rounded_corner_radius,
	beveled_corner_radius,
	atom_radius
) =
	body_style == "v0.0" ? rounded_corner_radius :
	body_style == "v0.1" || body_style == "v1" || body_style == "v2" ? beveled_corner_radius :
	body_style == "v8" ? atom_radius :
	assert(false, str("Unrecognized body style: '", body_style, "'"));

function togridpile2__body_inset_for_segmentation(
	segmentation,
	body_style,
	rounded_corner_radius,
	beveled_corner_radius,
	atom_radius,
	deplane_offset = 0.1, // Almost-zero offset to use to avoid coplanar planes
) =
	segmentation == "block" ? deplane_offset :
	togridpile2__corner_radius_for_body_style(body_style, rounded_corner_radius, beveled_corner_radius, atom_radius);

function togridpile2__unit_index(name) =
	name == "atom"  ? 0 :
	name == "chunk" ? 1 :
	name == "block" ? 2 :
	assert(false, str("Invalid unit name: '", name, "'"));

/* Subtract this to make a magnet hole in the bottom of blocks; origin=block bottom */
module togridpile2_block_magnet_hole(
	magnet_hole_diameter=6,
	magnet_drain_hole_diameter=3,
	floor_thickness=6,
	magnet_hole_depth=2,
) {
	if( magnet_drain_hole_diameter == 0 ) {
		cylinder(d=magnet_hole_diameter, h=magnet_hole_depth*2, center=true);
	} else intersection() {
		cylinder(d=magnet_hole_diameter, h=floor_thickness*2+1, center=true);
		union() {
			//cylinder(d=magnet_hole_diameter, h=magnet_hole_depth*2, center=true);
			cube([magnet_hole_diameter*2, magnet_hole_diameter*2, magnet_hole_depth*2], center=true);
			cube([magnet_hole_diameter*2, magnet_drain_hole_diameter, magnet_hole_depth*2+1], center=true);
			translate([0, 0, floor_thickness/2]) cylinder(d=magnet_drain_hole_diameter, h=floor_thickness*2+1, center=true);
		}
	}
}

module togridpile2_block(
	column_style="v8",
	atom_pitch=togridpile2_default_atom_pitch,
	chunk_pitch_atoms=3,
	block_size_chunks=[1,1,1],
	column_diameter=togridpile2_default_column_diameter,
	min_corner_radius=togridpile2_default_min_corner_radius,
	rounded_corner_radius=togridpile2_default_rounded_corner_radius,
	beveled_corner_radius=togridpile2_default_beveled_corner_radius,
	bottom_segmentation="chunk",
	side_segmentation="block",
	side_column_style="auto",
	chunk_column_placement=togridpile2_default_chunk_column_placement,
	chunk_side_column_placement="auto",
	chunk_body_style="v1",
	offset=0,
	deplane_offset=0.1,
	origin="center"
) translate([0, 0, origin=="center"?0:block_size_chunks[2]*chunk_pitch_atoms*atom_pitch/2] ) {

	// Columns!  The kinda easy part!
	// Well it was before it got all complicated anyway!
	
	columns_are_chunk_based = column_style == "v3";

	// 'column effective' stuff
	ce_chunk_pitch_atoms = columns_are_chunk_based ? 1                                                           : chunk_pitch_atoms;
	ce_column_diameter   = columns_are_chunk_based ? atom_pitch*chunk_pitch_atoms - (atom_pitch-column_diameter) : column_diameter;
	ce_atom_pitch        = columns_are_chunk_based ? atom_pitch*chunk_pitch_atoms                                : atom_pitch;
	ce_chunk_column_placement = columns_are_chunk_based ? "grid" : chunk_column_placement;

	if( column_style != "none" && ce_chunk_column_placement != "none") {
		linear_extrude(block_size_chunks[2]*chunk_pitch_atoms*atom_pitch + offset*2, center=true) {
			for( pos=togridpile2_column_positions(
				block_size_chunks      = block_size_chunks,
				chunk_pitch_atoms      = ce_chunk_pitch_atoms,
				atom_pitch             = ce_atom_pitch,
				chunk_column_placement = ce_chunk_column_placement
			) ) translate(pos) togridpile2_atom_column_footprint(
				column_style    = column_style,
				atom_pitch      = ce_atom_pitch,
				column_diameter = ce_column_diameter
			);
		}
	}
	
	sce_column_style = side_column_style == "auto" ? (column_style == "v3" ? "v6" : column_style) : side_column_style;
	sce_chunk_column_placement = chunk_side_column_placement == "auto" ? chunk_column_placement : chunk_side_column_placement;
	
	assert( sce_column_style != "v3" || sce_chunk_column_placement == "none" );
	// Need to refactor all of this so that this module doesn't need to care about 'v3'
	
	if( side_column_style != "none" && sce_chunk_column_placement != "none" ) {
		// TODO: Maybe dry this out a bit somehow
		rotate([0,90,0]) linear_extrude(block_size_chunks[0]*chunk_pitch_atoms*atom_pitch + offset*2, center=true) { // TODO
			for( pos=togridpile2_column_positions(
				block_size_chunks      = [block_size_chunks[2], block_size_chunks[1]],
				chunk_pitch_atoms      = chunk_pitch_atoms,
				atom_pitch             = atom_pitch,
				chunk_column_placement = sce_chunk_column_placement
			) ) translate(pos) togridpile2_atom_column_footprint(
				column_style    = sce_column_style,
				atom_pitch      = atom_pitch,
				column_diameter = column_diameter
			);
		}
		rotate([90,0,0]) linear_extrude(block_size_chunks[1]*chunk_pitch_atoms*atom_pitch + offset*2, center=true) { // TODO
			for( pos=togridpile2_column_positions(
				block_size_chunks      = [block_size_chunks[0], block_size_chunks[2]],
				chunk_pitch_atoms      = chunk_pitch_atoms,
				atom_pitch             = atom_pitch,
				chunk_column_placement = sce_chunk_column_placement
			) ) translate(pos) togridpile2_atom_column_footprint(
				column_style    = sce_column_style,
				atom_pitch      = atom_pitch,
				column_diameter = column_diameter
			);
		}
	}
	
	// TODO: Side columns, if asked for!
	// Important for cutting out the lips!

	chunk_pitch = chunk_pitch_atoms *  atom_pitch;
	block_size  = block_size_chunks * chunk_pitch;
	unit_sizes = [
		/* atom  */ togridpile2__tovec3(atom_pitch),
		/* chunk */ togridpile2__tovec3(chunk_pitch),
		/* block */ block_size
	];
	pillar_size = [
		unit_sizes[togridpile2__unit_index(bottom_segmentation)][0],
		unit_sizes[togridpile2__unit_index(bottom_segmentation)][1],
		unit_sizes[togridpile2__unit_index(side_segmentation)][2]
	];
	for( x=[-block_size[0]/2+pillar_size[0]/2 : pillar_size[0] : +block_size[0]/2-pillar_size[0]/3] ) // The 3 is on purpose lol
	for( y=[-block_size[1]/2+pillar_size[1]/2 : pillar_size[1] : +block_size[1]/2-pillar_size[1]/3] ) // The 3 is on purpose lol
	for( z=[-block_size[2]/2+pillar_size[2]/2 : pillar_size[2] : +block_size[2]/2-pillar_size[2]/3] ) // The 3 is on purpose lol
	{
		translate([x,y,z]) togridpile2_chunk_body(
			style=chunk_body_style,
			size = pillar_size,
			min_corner_radius=min_corner_radius,
			rounded_corner_radius=rounded_corner_radius,
			beveled_corner_radius=beveled_corner_radius,
			atom_radius = atom_pitch/2,
			offset = offset
		);
	}

	atom_radius = atom_pitch/2;

	block_body_bottom_inset = togridpile2__body_inset_for_segmentation(bottom_segmentation, chunk_body_style, rounded_corner_radius, beveled_corner_radius, atom_radius, deplane_offset=deplane_offset);
	block_body_side_inset   = togridpile2__body_inset_for_segmentation(side_segmentation  , chunk_body_style, rounded_corner_radius, beveled_corner_radius, atom_radius, deplane_offset=deplane_offset);

	// Chunk bodies, if not redundant
	if( side_segmentation == "chunk" && bottom_segmentation != "chunk" ) {
		assert( bottom_segmentation == "atom" || bottom_segmentation == "chunk" );

		for( x=[-block_size[0]/2+chunk_pitch/2 : chunk_pitch : +block_size[0]/2-chunk_pitch/3] ) // The 3 is on purpose lol
		for( y=[-block_size[1]/2+chunk_pitch/2 : chunk_pitch : +block_size[1]/2-chunk_pitch/3] ) // The 3 is on purpose lol
		for( z=[-block_size[2]/2+chunk_pitch/2 : chunk_pitch : +block_size[2]/2-chunk_pitch/3] ) // The 3 is on purpose lol
		{
			// Bottom layer needs to be shrunk so feet can stick out
			if( z == -block_size[2]/2+chunk_pitch/2 ) {
				translate([x,y,z + block_body_bottom_inset/2]) togridpile2_chunk_body(
					style=chunk_body_style,
					size = [chunk_pitch,chunk_pitch,chunk_pitch-block_body_bottom_inset],
					min_corner_radius=min_corner_radius,
					rounded_corner_radius=rounded_corner_radius,
					beveled_corner_radius=beveled_corner_radius,
					atom_radius = atom_pitch/2,
					offset = offset
				);
			} else {
				translate([x,y,z]) togridpile2_chunk_body(
					style=chunk_body_style,
					size = [chunk_pitch,chunk_pitch,chunk_pitch],
					min_corner_radius=min_corner_radius,
					rounded_corner_radius=rounded_corner_radius,
					beveled_corner_radius=beveled_corner_radius,
					atom_radius = atom_pitch/2,
					offset = offset
				);
			}
		}	
	}	

	// Main body
	body_bottom_inset = beveled_corner_radius;
	translate([0,0,(block_body_bottom_inset-block_body_side_inset)/2]) togridpile2_chunk_body(
		style=chunk_body_style,
		size=[
			block_size_chunks[0]*chunk_pitch_atoms*atom_pitch - block_body_side_inset*2,
			block_size_chunks[1]*chunk_pitch_atoms*atom_pitch - block_body_side_inset*2,
			block_size_chunks[2]*chunk_pitch_atoms*atom_pitch - block_body_bottom_inset - block_body_side_inset,
		],
		min_corner_radius=min_corner_radius,
		rounded_corner_radius=rounded_corner_radius,
		beveled_corner_radius=beveled_corner_radius,
		atom_radius = atom_pitch/2,
		offset = offset
	);
}
