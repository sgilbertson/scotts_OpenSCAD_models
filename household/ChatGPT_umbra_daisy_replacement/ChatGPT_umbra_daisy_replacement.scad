//
// Replacement flower for an Umbra Daisy Dress Scarf Hanger
// Two-piece snap-fit design closely matching the original molded connector.
//
// Dimensions are based on measurements supplied by the user.
// Units: mm
//

// --------------------------
// What to render
// --------------------------
// "male", "female", "male_cross_section", "female_cross_section", "both", or "assembly"
part = "both";

// --------------------------
// Measured / visible geometry
// --------------------------
petal_count       = 12;
outer_diameter    = 63.0;   // circle enclosing tips of all petals
inner_diameter    = 40.0;   // clear center opening
petal_length      = 6.0;
flower_thickness  = 2.50;

// Estimated compressed scarf thickness / desired spacing between halves.
// 2.50 + 0.30 + 2.50 = 5.30 mm overall.
fabric_gap        = 0.30;

// Petal shape. A 6 mm radius gives broad, rounded lobes close to the photos.
// Change this independently if the petal shape needs tuning.
petal_radius      = 6.0;

// Visible edge rounding
outer_fillet      = 0.65;
hole_fillet       = 0.60;
fillet_steps      = 16;

// --------------------------
// Original-style snap-fit connector
// --------------------------
// The factory part uses a continuous annular male spigot with two
// triangular circumferential retaining ridges.  The female part has
// a thin tapered annular lip which expands over the ridges.
//
// NOTE ABOUT THE 40 mm "smooth cylinder" measurement:
// The visible center opening is also 40 mm, so a 40 mm *outside*
// diameter would leave zero wall thickness.  I therefore interpret
// that measurement as the inside diameter of the annular male spigot.
// The measured ~0.9 mm radial ridge height and 45 mm ridge OD imply
// a smooth spigot OD of about 43.2 mm.
fabric_hole_diameter = 45.0;

male_inner_diameter  = 40.0;
male_ridge_diameter  = 45.0;
male_ridge_height    = 0.90;
male_body_diameter   = male_ridge_diameter - 2*male_ridge_height; // 43.2
male_projection      = 2.60;

// Each ridge is approximately an isosceles triangle in axial/radial
// cross-section. "spacing" is treated as peak-to-peak spacing.
ridge_width          = 1.50;
ridge_spacing        = 1.50;

// Locate the two ridge peaks within the 2.6 mm projection.
ridge1_peak_z        = -0.55;
ridge2_peak_z        = ridge1_peak_z - ridge_spacing;

// Female socket measurements, taken from the mating/back side.
female_entry_diameter  = 44.0;
female_cavity_diameter = 46.0;
female_lip_thickness   = 0.60;
female_curve_steps     = 24;   // smooth inner curve from snap lip to full flower thickness
female_ramp_width      = 2.00; // radial distance over which the lip blends into the full body

// The male projection is 2.6 mm and the assembled flowers are about
// 0.3 mm apart through the fabric, so a 2.3 mm socket depth is a good
// nominal starting point.
// fabric_gap is defined above from the measured overall thickness.
female_socket_depth   = male_projection - fabric_gap; // 2.30
// Small numerical overlap/extension
eps = 0.02;

$fn = 120;


// ============================================================
// Derived dimensions
// ============================================================
outer_r      = outer_diameter/2;
inner_r      = inner_diameter/2;
petal_root_r = outer_r - petal_length;


// ============================================================
// 2D flower outline
// ============================================================
module flower_outline_2d() {
    union() {
        circle(r = petal_root_r);
        for (a = [0 : 360/petal_count : 359])
            rotate(a)
                translate([petal_root_r, 0])
                    circle(r = petal_radius);
    }
}


// ============================================================
// Rounded flower plate
//
// Back/mating face is z=0.
// Decorative/outward face is z=flower_thickness.
//
// The petal perimeter is rounded only near the outward face, matching
// the appearance in the photos while leaving the mating face flat.
// ============================================================
module rounded_outer_solid() {
    r = min(outer_fillet, flower_thickness/2);

    union() {
        // Straight-sided lower portion.
        linear_extrude(height = flower_thickness - r + eps)
            flower_outline_2d();

        // Quarter-round approximation at the outward edge.
        //
        // IMPORTANT: do not hull() successive complete flower outlines here.
        // hull() convexifies the outline and bridges across the valleys between
        // petals, creating the unwanted rounded-dodecagon flange.  Instead,
        // make many very thin offset slices.  This preserves the actual
        // 12-petal perimeter all the way through the fillet.
        for (i = [0 : fillet_steps-1]) {
            t0 = i / fillet_steps;
            t1 = (i+1) / fillet_steps;
            tm = (t0 + t1) / 2;

            z0 = flower_thickness - r + r*t0;
            z1 = flower_thickness - r + r*t1;

            // Quarter-circle profile.  At the bottom of the fillet the
            // inset is zero; at the outward face it approaches r.
            d = r - sqrt(max(0, r*r - (r*tm)*(r*tm)));

            translate([0,0,z0])
                linear_extrude(height = z1-z0+eps)
                    offset(delta = -d)
                        flower_outline_2d();
        }
    }
}


// ============================================================
// Center opening, including rounding of the outward-facing edge
// ============================================================
module rounded_center_hole() {
    r = min(hole_fillet, flower_thickness/2);

    union() {
        // Main 40 mm bore.
        translate([0,0,-eps])
            cylinder(h = flower_thickness + 2*eps, r = inner_r);

        // Flare the bore only at the decorative/outward face.
        for (i = [0 : fillet_steps-1]) {
            t0 = i / fillet_steps;
            t1 = (i+1) / fillet_steps;

            z0 = flower_thickness - r + r*t0;
            z1 = flower_thickness - r + r*t1;

            d0 = r - sqrt(max(0, r*r - (r*t0)*(r*t0)));
            d1 = r - sqrt(max(0, r*r - (r*t1)*(r*t1)));

            hull() {
                translate([0,0,z0])
                    cylinder(h = eps, r = inner_r + d0);

                translate([0,0,z1])
                    cylinder(h = eps, r = inner_r + d1);
            }
        }
    }
}


module plain_flower_plate() {
    difference() {
        rounded_outer_solid();
        rounded_center_hole();
    }
}


// ============================================================
// Male original-style annular snap spigot
//
// Back/mating face of the flower is z=0. The spigot projects in -Z.
// The two retaining ridges are continuous rings with approximately
// triangular axial cross-sections, like the original molded part.
// ============================================================
module male_snap_ring() {
    ri = male_inner_diameter/2;
    rb = male_body_diameter/2;
    rr = male_ridge_diameter/2;

    rotate_extrude(convexity = 10, $fn = 160)
        polygon(points = [
            [ri, 0],
            [rb, 0],

            // First triangular ridge.
            [rb, ridge1_peak_z + ridge_width/2],
            [rr, ridge1_peak_z],
            [rb, ridge1_peak_z - ridge_width/2],

            // Second triangular ridge.
            [rb, ridge2_peak_z + ridge_width/2],
            [rr, ridge2_peak_z],
            [rb, ridge2_peak_z - ridge_width/2],

            // Insertion end.
            [rb, -male_projection],
            [ri, -male_projection]
        ]);
}


// ============================================================
// Female original-style tapered snap lip
//
// The permanent 40 mm center bore is made by rounded_center_hole().
// This cut adds the larger back-side annular socket around it.
//
// At the mating face, the socket OD is 44 mm. Over the first 0.6 mm
// it opens to 46 mm, making the thin tapered lip that snaps over the
// 45 mm male ridges. Behind the lip the cavity remains 46 mm OD.
// ============================================================
module female_socket_cut() {
    re = female_entry_diameter/2;   // 22 mm: hole radius at the back/fabric face
    rc = female_cavity_diameter/2;  // 23 mm: hole radius just past the thin snap lip
    rr = rc + female_ramp_width;    // radius where the inner ramp reaches full thickness

    // Desired female cross-section (solid is OUTSIDE this cutter):
    //
    //                         decorative/front surface
    //                              ______________________
    //                            /
    //                          /
    //                        /
    //           thin lip ___/
    //   center hole _______|________________________ back/fabric face
    //
    // At z=0 the opening is 44 mm (r=22).
    // For the full female_lip_thickness the opening remains 44 mm (r=22),
    // then steps sharply to 46 mm (r=23), leaving an approximately
    // 1 mm-wide rectangular snap lip.
    //
    // From there the inner wall blends smoothly outward until the
    // normal full-thickness flower body is reached.  This reproduces
    // the curved/ramped section visible on the original part instead
    // of leaving a shelf on the decorative face.
    //
    // The cutter extends to the axis so it robustly overlaps the
    // ordinary center-hole cutter; this avoids coincident Boolean faces.

    ramp_points = [
        for (i = [0 : female_curve_steps])
            let(
                t = i / female_curve_steps,
                // smoothstep: tangent approximately horizontal at both ends
                s = t*t*(3 - 2*t),
                r = rc + (rr - rc)*t,
                z = female_lip_thickness
                    + (flower_thickness - female_lip_thickness)*s
            )
            [r, z]
    ];

    // Cutter polygon: void is everything radially inward/above the
    // desired inner surface.  Starting at the axis makes the subtraction
    // manifold and leaves the lip/ramp as solid material.
    rotate_extrude(convexity = 10, $fn = 160)
        polygon(points = concat(
            [
                [0, -eps],
                [re, -eps],

                // Rectangular snap lip, matching the original part:
                // the 44 mm opening stays cylindrical for the full
                // lip thickness, then steps sharply outward to the
                // 46 mm cavity.  This produces the fairly sharp
                // inside corner seen between the lip and the curved
                // rise toward the decorative face.
                [re, female_lip_thickness],
                [rc, female_lip_thickness]
            ],
            ramp_points,
            [
                // Continue the cutter vertically above the finished part.
                // The previous polygon closed diagonally from the end of
                // the ramp to the axis, and the rounded outer solid extends
                // a tiny epsilon above flower_thickness.  That could leave
                // a paper-thin membrane across the top.  This cap guarantees
                // that everything inward of the ramp is completely removed.
                [rr, flower_thickness + 1],
                [0,  flower_thickness + 1]
            ]
        ));
}

// ============================================================
// Finished halves
// ============================================================
module male_half() {
    union() {
        plain_flower_plate();
        male_snap_ring();
    }
}


module female_half() {
    // The female socket cutter itself defines the entire center opening,
    // including the back lip and the curved rise to the front.  Subtract it
    // directly from the rounded flower body rather than first making the
    // generic 40 mm center hole.  This avoids overlapping/coplanar cutter
    // surfaces and more faithfully matches the original female cross-section.
    difference() {
        rounded_outer_solid();
        female_socket_cut();
    }
}


// ============================================================
// Cross-section helpers
//
// These cut away the Y >= 0 half of the model so the radial/Z profile
// through the center is easy to inspect.  They are intentionally render
// modes only and do not affect exported male/female parts.
// ============================================================
module radial_cross_section() {
    difference() {
        children();
        translate([-100, 0, -20])
            cube([200, 100, 50], center=false);
    }
}


// ============================================================
// Rendering / export
// ============================================================
if (part == "male") {
    male_half();

} else if (part == "female") {
    female_half();

} else if (part == "male_cross_section") {
    radial_cross_section()
        male_half();

} else if (part == "female_cross_section") {
    radial_cross_section()
        female_half();

} else if (part == "both") {
    // Laid out separately for inspection / STL export.
    translate([-36,0,male_projection])
        male_half();

    translate([36,0,0])
        female_half();

} else if (part == "assembly") {
    // Cross-fabric assembled position.
    // Female back face at z=0.
    // Male back face at z=-fabric_gap.
    female_half();

    translate([0,0,-fabric_gap])
        mirror([0,0,1])
            male_half();
}
