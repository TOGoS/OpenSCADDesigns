include <TOGShapeLib-v1.scad>
include <TOGUnitTable-v1.scad>

$fn = 16;

tog_bbl1_default_unit_table = [
	each tog_unittable__demo_unit_table,
	["bb-pin-width", [1/32, "inch"], "width of my widest header pin"],
	["bb-cell", [1/10, "inch"], "breadboard grid pitch"],
	["bb-bevel-size", [1/32, "inch"], "size of corner bevel"]
];

function tog_bbl1_get_unit_table() =
	is_undef($tog_bbl1_unit_table) ? tog_bbl1_default_unit_table : is_undef($tog_bbl1_unit_table);

function tog_bbl1_map(arr, fn) = [ for(item=arr) fn(item) ];
function tog_bbl1_decode(dim, unit_table=tog_bbl1_get_unit_table(), unit=[1, "mm"]) =
	is_num(dim) ? dim : tog_unittable__divide_ca(unit_table, dim, unit);
function tog_bbl1_decode_vector(size, unit_table=tog_bbl1_get_unit_table(), unit=[1, "mm"]) =
	tog_bbl1_map(size, function(dim) is_num(dim) ? dim : tog_unittable__divide_ca(unit_table, dim, unit));

module tog_bbl1_smooth_block(size, hole_style="none", offset=0) {
	size_cells = tog_bbl1_decode_vector(size, unit=[1, "bb-cell"]);
	size = tog_bbl1_decode_vector(size);
	cell_pitch = tog_bbl1_decode([1, "bb-cell"]);
	pin_width  = tog_bbl1_decode([1, "bb-pin-width"]);
	bevel_size = tog_bbl1_decode([1, "bb-bevel-size"]);
	linear_extrude(size[2], center=true) difference() {
		tog_shapelib_rounded_beveled_square(size, bevel_size, bevel_size/2, offset=offset);
		
		if( hole_style != "none" ) for( posc=[
			for(xc=[-size_cells[0]/2 + 0.5 : 1 : size_cells[0]/2])
			for(yc=[-size_cells[1]/2 + 0.5 : 1 : size_cells[1]/2])
				[xc, yc]
		]) translate(posc*cell_pitch) {
			square([pin_width, pin_width], center=true);
		}
	}
}
