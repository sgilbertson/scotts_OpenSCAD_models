// Parametric press-in foot for furniture, equipment, enclosures, and
// other objects with a round mounting hole.
//
// Designed for flexible filament such as TPU so the stem and retaining
// ribs can compress during insertion and grip the mounting hole.
// Print with the foot on the build plate and the stem pointing upward.

/* [Mounting Hole and Stem] */

// Inside diameter of the round mounting hole.
socket_diameter = 11.0;

// Usable depth of the mounting hole, measured from its opening.
socket_depth    = 27.0;

// Axial gap below the stem; increase it if the hole depth is uncertain or its bottom is obstructed.
stem_length_clearance = 3;

// Diametral clearance between the mounting hole and plain stem; decrease it for a tighter fit (not a per-side value).
stem_diameter_reduction = 0.4;

// Diameter of the axial compliance hole; larger values compress more easily, while 0 makes a solid stem.
stem_hole_diameter = 4.5;

// Axial length of the tapered insertion tip.
lead_in_length             = 2.0;

// Diameter reduction at the tip relative to the plain stem; increase it for an easier-to-start insertion.
lead_in_diameter_reduction = 1.1;


/* [Retaining Ribs] */

// Number of retaining ribs distributed along the stem.
rib_count = 4;

// Radial rib protrusion beyond the plain stem; increase it for more grip or decrease it for easier insertion.
rib_protrusion = 0.25;

// Axial height of each retaining rib.
rib_height = 1.4;

// Axial distance between the centers of adjacent retaining ribs.
rib_spacing = 4;

// Axial distance from the top of the foot to the center of the first rib.
first_rib_height = 5.0;


/* [Foot] */

// Maximum outside diameter of the foot.
foot_diameter = 26;

// Overall foot height, from the contact surface to the base of the stem.
foot_height = 8;

// Height of the straight-sided shoulder at the top of the foot.
shoulder_height = 2.0;

// Shoulder diameter around the mounting hole; keep it larger than socket_diameter to prevent pull-through.
shoulder_diameter = 22;

// Radial inset of the contact face; larger values narrow it and make the 45-degree-or-steeper edge transition taller.
bottom_edge_rounding = 2.1; // [0.1:0.1:50]


/* [Hidden] */

// Dimensions derived from the user-facing fit parameters above.
stem_length      = socket_depth - stem_length_clearance;
stem_diameter    = socket_diameter - stem_diameter_reduction;
lead_in_diameter = stem_diameter - lead_in_diameter_reduction;
rib_diameter     = stem_diameter + 2 * rib_protrusion;

// Number of facets used for curved surfaces.
$fn = 96;


// ---------- Parameter validation ----------

module validate_parameters()
{
    assert(socket_diameter > 0, "socket_diameter must be greater than 0");
    assert(socket_depth > 0, "socket_depth must be greater than 0");
    assert(stem_length_clearance >= 0, "stem_length_clearance must not be negative");
    assert(stem_length > 0, "stem_length_clearance must be less than socket_depth");
    assert(stem_diameter_reduction >= 0, "stem_diameter_reduction must not be negative");
    assert(stem_diameter > 0, "stem_diameter_reduction must be less than socket_diameter");
    assert(lead_in_length > 0 && lead_in_length < stem_length, "lead_in_length must be greater than 0 and less than the derived stem length");
    assert(lead_in_diameter_reduction >= 0, "lead_in_diameter_reduction must not be negative");
    assert(lead_in_diameter > 0, "lead_in_diameter_reduction must be less than the derived stem diameter");
    assert(stem_hole_diameter >= 0, "stem_hole_diameter must not be negative");
    assert(stem_hole_diameter < lead_in_diameter, "stem_hole_diameter must be smaller than the derived lead-in diameter");

    assert(rib_count >= 0 && rib_count == floor(rib_count), "rib_count must be a non-negative integer");
    assert(rib_protrusion >= 0, "rib_protrusion must not be negative");
    assert(rib_count == 0 || rib_height > 0, "rib_height must be greater than 0 when ribs are enabled");
    assert(rib_count <= 1 || rib_spacing > 0, "rib_spacing must be greater than 0 when using multiple ribs");
    assert(rib_count == 0 || first_rib_height >= rib_height/2, "the first rib must not extend below the stem");
    assert(rib_count == 0 || first_rib_height + (rib_count-1)*rib_spacing + rib_height/2 <= stem_length-lead_in_length, "the last rib must end before the tapered lead-in");

    assert(foot_diameter > 0, "foot_diameter must be greater than 0");
    assert(foot_height > 0, "foot_height must be greater than 0");
    assert(shoulder_height >= 0 && shoulder_height < foot_height, "shoulder_height must be non-negative and less than foot_height");
    assert(shoulder_diameter > socket_diameter, "shoulder_diameter must be larger than socket_diameter to prevent pull-through");
    assert(shoulder_diameter <= foot_diameter, "shoulder_diameter must not exceed foot_diameter");
    assert(bottom_edge_rounding > 0, "bottom_edge_rounding must be greater than 0");
    assert(bottom_edge_rounding <= foot_diameter/2, "bottom_edge_rounding must not exceed half of foot_diameter");
    assert(1.25 * bottom_edge_rounding <= foot_height-shoulder_height, "bottom_edge_rounding is too large for the available foot height");
}


// ---------- Model ----------

module rounded_foot()
{
    // A proportional rotational profile approximates a rounded edge without
    // Minkowski(). Each outward segment is at least 45 degrees from the build
    // plate, avoiding the shallow overhang that can weaken the first layers.

    rotate_extrude(convexity=10)
        polygon([
            [0, 0],
            [foot_diameter/2 - bottom_edge_rounding, 0],
            [foot_diameter/2 - bottom_edge_rounding/2,
                bottom_edge_rounding/2],
            [foot_diameter/2 - bottom_edge_rounding/8,
                bottom_edge_rounding],
            [foot_diameter/2, 1.25 * bottom_edge_rounding],
            [foot_diameter/2, foot_height - shoulder_height],
            [shoulder_diameter/2, foot_height - shoulder_height],
            [shoulder_diameter/2, foot_height],
            [0, foot_height]
        ]);
}


module retaining_rib(z)
{
    // Symmetrical shallow bulge.
    // Flexible filament lets the rib compress as it enters the mounting hole.

    translate([0,0,z-rib_height/2])
        cylinder(
            h=rib_height/2,
            d1=stem_diameter,
            d2=rib_diameter
        );

    translate([0,0,z])
        cylinder(
            h=rib_height/2,
            d1=rib_diameter,
            d2=stem_diameter
        );
}


module stem()
{
    difference()
    {
        union()
        {
            // Main stem, stopping before the tapered lead-in
            cylinder(
                h=stem_length-lead_in_length,
                d=stem_diameter
            );

            // Tapered insertion end
            translate([0,0,stem_length-lead_in_length])
                cylinder(
                    h=lead_in_length,
                    d1=stem_diameter,
                    d2=lead_in_diameter
                );

            // Retention ribs
            if (rib_count > 0)
                for (i=[0:rib_count-1])
                    retaining_rib(
                        first_rib_height + i*rib_spacing
                    );
        }

        // Central compliance hole.
        // It stops short of the bottom so the foot remains
        // completely closed against the floor.
        if (stem_hole_diameter > 0)
            translate([0,0,-0.01])
                cylinder(
                    h=stem_length+0.02,
                    d=stem_hole_diameter
                );
    }
}


module press_in_foot()
{
    validate_parameters();

    union()
    {
        rounded_foot();

        translate([0,0,foot_height])
            stem();
    }
}


press_in_foot();
