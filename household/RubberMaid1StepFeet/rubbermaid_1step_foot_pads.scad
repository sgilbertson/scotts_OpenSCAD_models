// This model uses two-material printing to create a simple foot pad that can be glued or attached
// using double-sided tape. The motivation for this design to replace missing feet on a RubberMaid
// S1-Step step stool, so the default settings are for that use-case.
// You can optionally create it with two materials, typically a hard material like PLA or PETG for
// the base and a soft material like TPU for the pad, if for example the glue you're using works better
// with the harder material.
// Alternatively you can configure Bambu Studio to print a PLA raft and a TPU part, whereupon the raft
// can be easily removed and the TPU pad can be glued to the bottom of the step stool.

// For fastest and cleanest printing, use concentric treads and a low tread count.
// For maximum traction, use crosshatch treads and a higher tread count.
// With concentric treads, you can configure the slicer for 100% concentric infill.
// With crosshatch treads, you can configure the slicer for 100% rectilinear infill.

/* [Matrix View Controls] */
// Choose which components are visible
part_selection = "pad"; // [base: base only, pad: TPU pad only, both: Full Assembly]

// Choose the tread pattern type
tread_pattern = "concentric"; // [crosshatch: Cross-hatch pattern, concentric: Concentric circles]

/* [Dimensions] */

// Diameter of the foot pad in mm
pad_diameter = 20;

// Height of the foot pad in mm
pad_height = 2.0;

// Tread depth in mm (cuts into the pad height to provide traction)
tread_depth = 1.0;

// Tread width in mm (width of the tread grooves, with flat areas between)
tread_width = 1.5;

// Tread count
tread_count = 5;

// Height of the base plate in mm
base_height = 0.5;

/* [Hidden] */

// Boost resolution
$fn = 100;

// Mathematical offset to eliminate coincident face errors and preview calculation bugs
eps = 0.01; 
overlap_offset = (part_selection == "both") ? eps : 0;

// Module to create a triangular groove (V-shaped)
// Arguments:
//  length: how long the groove extends (along the extrusion direction)
//  depth: how deep the groove cuts into the pad
//  width: how wide the groove is at the surface of the pad
module straight_triangular_groove(length, depth, width) {
    rotate([90, 0, 0])  // Rotate to make it extend along Y by default
    linear_extrude(height=length, center=true)
    polygon(points=[
        [width/2, 0],      // Right edge at surface
        [-width/2, 0],     // Left edge at surface
        [0, -depth]        // Point goes DOWN into the pad
    ]);
}

// Module to create cross-hatch tread pattern with triangular grooves
module crosshatch_tread_grooves() {
    // We want tread_count grooves in each direction, so we calculate the spacing based on the pad diameter.
    // The outermost groove's center (lowest point) will be at the edge of the pad, so we need to space them evenly across the pad diameter.
    tread_spacing = pad_diameter / (tread_count - 1);
    
    // Validate parameters for crosshatch pattern
    assert(tread_count >= 2, "tread_count must be at least 2 for crosshatch pattern");
    assert(tread_spacing >= tread_width, str("Grooves overlap! tread_spacing (", tread_spacing, "mm) must be >= tread_width (", tread_width, "mm). Reduce tread_count or tread_width."));
    assert(tread_width > 0, "tread_width must be positive");
    assert(tread_depth > 0 && tread_depth <= pad_height, str("tread_depth (", tread_depth, "mm) must be between 0 and pad_height (", pad_height, "mm)"));
    for (x = [-pad_diameter/2 : tread_spacing : pad_diameter/2]) {
        // Horizontal grooves (extending along Y axis)
        translate([x, 0, pad_height/2])
        straight_triangular_groove(pad_diameter * 1.5, tread_depth, tread_width);
        
        // Vertical grooves (extending along X axis)
        translate([0, x, pad_height/2])
        rotate([0, 0, 90])
        straight_triangular_groove(pad_diameter * 1.5, tread_depth, tread_width);
    }
}

// Crate a triangular groove that is concentric around the center of the pad, with the point of the triangle facing down into the pad.
// Arguments:
//  radius: distance from the center of the pad to the center of the groove (the lowest point of the triangle)
//  depth: how deep the groove cuts into the pad
//  width: how wide the groove is at the surface of the pad
module concentric_triangular_groove(radius, depth, width) {
    rotate_extrude(angle=360)
    translate([radius, 0, 0])
    polygon(points=[
        [width/2, 0],      // Right edge at surface
        [-width/2, 0],     // Left edge at surface
        [0, -depth]        // Point goes DOWN into the pad
    ]);
}

// Create the requested number of concentric tread grooves, evenly spaced from the center to the edge of the pad.
module concentric_tread_grooves() {
    // We want tread_count grooves, so we calculate the spacing based on the pad diameter.
    // The outermost groove's center (lowest point) will be at the edge of the pad.
    tread_spacing = (pad_diameter / 2) / (tread_count - 1);
    
    // Validate parameters for concentric pattern
    assert(tread_count >= 2, "tread_count must be at least 2 for concentric pattern");
    assert(tread_spacing >= tread_width, str("Grooves overlap! tread_spacing (", tread_spacing, "mm) must be >= tread_width (", tread_width, "mm). Reduce tread_count or tread_width."));
    assert(tread_width > 0, "tread_width must be positive");
    assert(tread_depth > 0 && tread_depth <= pad_height, str("tread_depth (", tread_depth, "mm) must be between 0 and pad_height (", pad_height, "mm)"));
    for (r = [0 : tread_spacing : pad_diameter/2]) {
        translate([0, 0, pad_height/2])
        concentric_triangular_groove(r, tread_depth, tread_width);
    }
}

// Render the 3D model based on the selected part(s) and tread pattern
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
                if (tread_pattern == "crosshatch") {
                    crosshatch_tread_grooves();
                } else {
                    // tread_pattern == "concentric"
                    concentric_tread_grooves();
                }
            }
        }
    }
}

render_3d_layer_selection();
