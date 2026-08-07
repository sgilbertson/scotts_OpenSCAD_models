//
// Replacement flower for an Umbra Daisy Dress Scarf Hanger
// Two-piece segmented snap-fit design.
//
// Dimensions are based on measurements supplied by the user.
// Units: mm
//

// --------------------------
// What to render
// --------------------------
// "male", "female", "both", or "assembly"
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
fillet_steps      = 7;

// --------------------------
// Snap-fit connector
// --------------------------
// The connector must pass through the 45 mm scarf hole.
fabric_hole_diameter = 45.0;

// Segmented male ring dimensions
snap_segments     = 8;
snap_gap_angle    = 9;       // angular gap between flexible tabs, degrees
snap_inner_r      = inner_diameter/2 + 0.25;
snap_body_outer_r = 21.82;
snap_bead_outer_r = 22.18;   // 44.36 mm OD: still below 45 mm fabric hole

// Female socket dimensions
socket_mouth_outer_r  = 21.95;
socket_cavity_outer_r = 22.34;
socket_depth          = 1.15;

// Male projection is intentionally longer than socket depth;
// the difference establishes the nominal fabric gap.
snap_projection   = socket_depth + fabric_gap;

// Snap bead location measured from the mating/back face.
bead_near         = snap_projection - 0.62;
bead_peak         = snap_projection - 0.34;
bead_tip          = snap_projection;

// Small numerical overlap/extension
eps = 0.02;

$fn = 120;


// ============================================================
// Derived dimensions
// ============================================================
outer_r      = outer_diameter/2;
inner_r      = inner_diameter/2;
petal_root_r = outer_r - petal_length;

// Width of one snap segment.
snap_pitch_angle = 360/snap_segments;
snap_tab_angle   = snap_pitch_angle - snap_gap_angle;


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
// The outer edge is rounded only near the outward face, matching
// the appearance in the photos while leaving the mating face flat.
// ============================================================
module rounded_outer_solid() {
    r = min(outer_fillet, flower_thickness/2);

    union() {
        // Straight-sided lower portion.
        linear_extrude(height = flower_thickness - r + eps)
            flower_outline_2d();

        // Quarter-round approximation at the outward edge.
        for (i = [0 : fillet_steps-1]) {
            t0 = i / fillet_steps;
            t1 = (i+1) / fillet_steps;

            z0 = flower_thickness - r + r*t0;
            z1 = flower_thickness - r + r*t1;

            // Quarter-circle profile:
            // inset is zero where the vertical side starts and
            // reaches r at the outward/top face.
            d0 = r - sqrt(max(0, r*r - (r*t0)*(r*t0)));
            d1 = r - sqrt(max(0, r*r - (r*t1)*(r*t1)));

            hull() {
                translate([0,0,z0])
                    linear_extrude(height = eps)
                        offset(delta = -d0)
                            flower_outline_2d();

                translate([0,0,z1])
                    linear_extrude(height = eps)
                        offset(delta = -d1)
                            flower_outline_2d();
            }
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
// Male segmented snap ring
//
// The tabs project in the -Z direction from the mating face.
// Each tab has a small outward bead near its tip.
// ============================================================
module one_snap_tab() {
    // Radial/Z cross-section.  rotate_extrude revolves this into
    // an annular segment.
    rotate_extrude(angle = snap_tab_angle, convexity = 10, $fn = 80)
        polygon(points = [
            [snap_inner_r,        0],
            [snap_body_outer_r,   0],

            [snap_body_outer_r,  -bead_near],
            [snap_bead_outer_r,  -bead_peak],

            // Taper the bead back inward at the insertion tip.
            [snap_body_outer_r,  -bead_tip],
            [snap_inner_r,       -bead_tip]
        ]);
}


module male_snap_ring() {
    for (i = [0 : snap_segments-1])
        rotate([0,0, i*snap_pitch_angle + snap_gap_angle/2])
            one_snap_tab();
}


// ============================================================
// Female snap socket
//
// A narrow mouth is followed by a slightly wider annular cavity.
// The male bead flexes inward through the mouth, then springs into
// the wider cavity.
// ============================================================
module female_socket_cut() {
    union() {
        // Narrow entry mouth.
        translate([0,0,-eps])
            difference() {
                cylinder(h = 0.48 + eps, r = socket_mouth_outer_r);
                translate([0,0,-eps])
                    cylinder(h = 0.48 + 3*eps, r = inner_r);
            }

        // Wider retaining cavity.
        translate([0,0,0.46])
            difference() {
                cylinder(h = socket_depth - 0.46 + eps,
                         r = socket_cavity_outer_r);
                translate([0,0,-eps])
                    cylinder(h = socket_depth - 0.46 + 3*eps,
                             r = inner_r);
            }
    }
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
    difference() {
        plain_flower_plate();
        female_socket_cut();
    }
}


// ============================================================
// Rendering / export
// ============================================================
if (part == "male") {
    male_half();

} else if (part == "female") {
    female_half();

} else if (part == "both") {
    // Laid out separately for inspection / STL export.
    translate([-36,0,snap_projection])
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
