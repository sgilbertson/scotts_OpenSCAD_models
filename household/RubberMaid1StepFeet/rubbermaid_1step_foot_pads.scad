// This model uses two-material printing to create a simple foot pad to replace missing ones
// on a RubberMaid 1-Step step stool. The thin base is printed in PLA and the pad is printed in TPU,
// the idea being that you can crack off the PLA after printing.

/* [Matrix View Controls] */
// Choose which components are visible
part_selection = "both"; // [base: base only, pad: TPU pad only, both: Full Assembly]

/* [Dimensions] */

// Diameter of the foot pad in mm
pad_diameter = 18;

// Height of the foot pad in mm
pad_height = 3.0;

// Tread depth in mm (cuts into the pad height to provide traction)
tread_depth = 1.0;

// Tread width in mm (width of the tread grooves, with flat areas between)
tread_width = 1.5;

// Tread spacing in mm (distance between tread grooves, in each direction))
tread_spacing = 2.0;

// Height of the base plate in mm
base_height = 0.5;

/* [Hidden] */

// Boost resolution
$fn = 100;

// Mathematical offset to eliminate coincident face errors and preview calculation bugs
eps = 0.01; 
overlap_offset = (part_selection == "both") ? eps : 0;

// Module to create a triangular groove (V-shaped)
module triangular_groove(length, depth, width) {
    rotate([90, 0, 0])  // Rotate to make it extend along Y by default
    linear_extrude(height=length, center=true)
    polygon(points=[
        [width/2, 0],      // Right edge at surface
        [-width/2, 0],     // Left edge at surface
        [0, -depth]        // Point goes DOWN into the pad
    ]);
}

// Module to create cross-hatch tread pattern with triangular grooves
module tread_grooves() {
    for (x = [-pad_diameter/2 : tread_spacing : pad_diameter/2]) {
        // Horizontal grooves (extending along Y axis)
        translate([x, 0, pad_height/2])
        triangular_groove(pad_diameter * 1.5, tread_depth, tread_width);
        
        // Vertical grooves (extending along X axis)
        translate([0, x, pad_height/2])
        rotate([0, 0, 90])
        triangular_groove(pad_diameter * 1.5, tread_depth, tread_width);
    }
}

module render_3d_layer_selection() {
    union() {
        // Base layer
        if (part_selection == "base" || part_selection == "both") {
            translate([0, 0, -base_height/2])
            cylinder(r=pad_diameter/2, h=base_height, center=true);
        } 
        
        // TPU pad layer with tread grooves
        if (part_selection == "pad" || part_selection == "both") {
            translate([0, 0, pad_height/2 + (part_selection == "both" ? overlap_offset : 0)])
            difference() {
                cylinder(r=pad_diameter/2, h=pad_height, center=true);
                tread_grooves();
            }
        }
    }
}

render_3d_layer_selection();
