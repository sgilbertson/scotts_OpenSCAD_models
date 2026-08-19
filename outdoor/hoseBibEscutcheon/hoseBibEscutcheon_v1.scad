/* Hose bib escutcheon -- dimensions are in millimetres. */

/* [View] */
// Selects which part arrangement is displayed or exported. Export and print Upper and Lower part for a split component, or All in one for a single-piece that can be slid over a pipe.
model_view = "Assembled"; // [Upper part, Lower part, Assembled, All in one, Side by side]
// Sets the separation between parts in the side-by-side view.
part_gap = 8;

/* [Main plate] */
// Sets the nominal outside diameter of the hose bib pipe.
pipe_diameter       = 25.4;
// Adds radial clearance between the pipe and the escutcheon opening.
pipe_clearance      = 1.2;
// Sets the overall diameter of the circular escutcheon plate.
outer_diameter      = 120;
// Sets the thickness of the main plate before decorative relief is added.
body_thickness      = 5;
// Sets the radius of the rounded outer edge of the main plate.
plate_edge_radius   = 3;

/* [Decorative petals] */
// Sets the number of petals; use a multiple of four to center a bottom petal.
petal_count         = 12;
// Sets the chord width of each petal near its outer end.
petal_width         = 12;
// Sets the radial position of the concentric outer ends of the petals.
petal_outer_radius  = 51;
// Sets the raised thickness of the flat outer half of each petal.
petal_outer_thickness = 1.8;
// Sets the fillet radius applied to the petal corners.
petal_corner_radius = 1.5;

/* [Pipe sleeve] */
// Sets how far the central sleeve projects above the plate.
sleeve_height         = 18;
// Sets the radial wall thickness at the top of the sleeve.
sleeve_wall_thickness = 2.4;
// Sets how far the sleeve flares outward where it meets the plate.
sleeve_flare          = 7;
// Sets the number of segments used to approximate the sleeve's S-profile.
sleeve_profile_steps  = 12;

/* [Foam retaining rim] */
// Sets the radial width of the projecting rim on the back of the plate.
back_rim_width      = 3;
// Sets how far the back rim projects behind the plate.
back_rim_depth      = 2;
// Adds radial allowance inside the rim for the neoprene foam insert.
foam_clearance      = 0.4;

/* [Mounting screws] */
// Sets the common radial distance of every screw hole from the model center.
mount_radius         = 38;
// Sets the diameter of the screw shank holes.
screw_shank_diameter = 4;
// Sets the maximum diameter of each screw-head recess.
screw_head_diameter  = 8;
// Sets the depth of each screw-head recess.
screw_head_height    = 2.2;
// Selects a conical flat-head recess or cylindrical round-head recess.
screw_head_style     = "Flat head"; // [Flat head, Round head]

/* [Part connection] */
// Sets the radius of the reinforced pads around the two tab screws.
tab_radius          = 8;
// Sets the thickness of the lower part's overlapping tabs.
tab_thickness       = 2;
// Sets the vertical and radial assembly clearance around the tabs.
fit_clearance       = 0.25;
// Widens each side of the upper pipe slot to prevent residual edge slivers.
slot_side_clearance = 0.25;

/* [Resolution] */
// Sets the circular facet resolution used throughout the model.
$fn                 = 72;

/* [Hidden] */
// Stores the outside radius derived from the selected plate diameter.
outer_radius = outer_diameter / 2;
// Stores the radius of the flat front face inside the rounded plate edge.
front_radius = outer_radius - plate_edge_radius;
// Stores the pipe-opening radius including the selected clearance.
pipe_radius  = pipe_diameter / 2 + pipe_clearance;
// Stores the outside radius at the top of the sleeve.
sleeve_top_radius = pipe_radius + sleeve_wall_thickness;
// Stores the outside radius where the flared sleeve meets the plate.
sleeve_base_radius = sleeve_top_radius + sleeve_flare;
// Stores the maximum height required by clipping and cutting operations.
total_height = body_thickness + max(petal_outer_thickness, sleeve_height);
// Stores the angular spacing between adjacent petal centerlines.
petal_pitch = 360 / petal_count;
// Stores the angular half-width of a petal while preserving a narrow gap.
petal_half_angle = min(petal_pitch / 2 - 0.2,
                       asin(min(0.999, petal_width / (2 * petal_outer_radius))));
// Stores the angle from the slot centerline to a sleeve/slot tangent point.
tangent_half_angle = asin(min(0.999, pipe_radius / sleeve_base_radius));
// Stores the nearest eligible outer petal edge beyond the tangent point.
cut_at_outer_edge = ceil((tangent_half_angle - petal_half_angle) / petal_pitch)
                    * petal_pitch + petal_half_angle;
// Stores the nearest eligible inner petal edge beyond the tangent point.
cut_at_inner_edge = ceil((tangent_half_angle + petal_half_angle) / petal_pitch)
                    * petal_pitch - petal_half_angle;
// Stores the selected petal-edge angle used for the upper/lower cut line.
lower_half_angle = min(cut_at_outer_edge, cut_at_inner_edge);
// Stores the angular locations of the two shared tab screw holes.
tab_angles = [-135, -45];

module sector2d(start_angle, end_angle, radius) {
    steps = ceil((end_angle - start_angle) / 6);
    polygon(concat([[0, 0]], [
        for (i = [0 : steps])
            [radius * cos(start_angle + (end_angle - start_angle) * i / steps),
             radius * sin(start_angle + (end_angle - start_angle) * i / steps)]
    ]));
}

module upper_mask2d(extra = 0) {
    // The radial edges coincide with edges of the bottom-facing petal.
    difference() {
        sector2d(-90 + lower_half_angle, 270 - lower_half_angle,
                 outer_radius + extra);
        pipe_channel2d(extra, slot_side_clearance);
    }
}

module lower_mask2d(extra = 0) {
    union() {
        sector2d(270 - lower_half_angle, 270 + lower_half_angle,
                 outer_radius + extra);
        pipe_channel2d(extra);
    }
}

module pipe_channel2d(extra = 0, side_clearance = 0) {
    // Parallel walls guarantee an opening as wide as the center hole.
    translate([-pipe_radius - side_clearance, -outer_radius - extra])
        square([2 * (pipe_radius + side_clearance), outer_radius + extra]);
}

module tab_shape2d(clearance = 0) {
    for (a = tab_angles)
        hull() {
            rotate(a)
                translate([mount_radius, 0])
                    circle(r = tab_radius + clearance);
            rotate(-90)
                translate([mount_radius - tab_radius / 2, 0])
                    circle(r = tab_radius + clearance);
        }
}

module petal2d() {
    // Radial sides provide exact petal edges for concealing the part seam.
    offset(r = petal_corner_radius)
        offset(delta = -petal_corner_radius)
            difference() {
                sector2d(-petal_half_angle, petal_half_angle,
                         petal_outer_radius);
                circle(r = sleeve_base_radius - 0.05);
            }
}

module petal_height_envelope() {
    ramp_end_radius = (sleeve_base_radius + petal_outer_radius) / 2;
    rotate_extrude(convexity = 2)
        polygon([
            [sleeve_base_radius - 0.1, body_thickness - 0.01],
            [sleeve_base_radius - 0.1, body_thickness],
            [ramp_end_radius, body_thickness + petal_outer_thickness],
            [front_radius - 0.1, body_thickness + petal_outer_thickness],
            [front_radius - 0.1, body_thickness - 0.01]
        ]);
}

module petals() {
    intersection() {
        petal_height_envelope();
        translate([0, 0, body_thickness - 0.01])
            linear_extrude(height = petal_outer_thickness + 0.02)
                intersection() {
                    union()
                        for (a = [0 : 360 / petal_count : 359])
                            rotate(a) petal2d();
                    // Wide petals can never extend beyond the flat front face.
                    circle(r = front_radius - 0.1);
                }
    }
}

function sleeve_outer_profile() =
    [
        for (i = [0 : sleeve_profile_steps])
            let(t = i / sleeve_profile_steps,
                smooth_t = t * t * (3 - 2 * t))
            [sleeve_base_radius
                - (sleeve_base_radius - sleeve_top_radius) * t,
             body_thickness + sleeve_height * smooth_t]
    ];

function plate_edge_profile() =
    [
        for (i = [0 : 8])
            let(a = 90 - 90 * i / 8)
            [outer_radius - plate_edge_radius + plate_edge_radius * cos(a),
             body_thickness - plate_edge_radius + plate_edge_radius * sin(a)]
    ];

module escutcheon_profile2d() {
    sleeve_profile = sleeve_outer_profile();
    rim_inner_radius = outer_radius - back_rim_width - foam_clearance;

    // Trace one closed radial section: pipe wall, sleeve, plate, and back rim.
    polygon(concat(
        [[pipe_radius, 0],
         [pipe_radius, body_thickness + sleeve_height],
         [sleeve_top_radius, body_thickness + sleeve_height]],
        [for (i = [len(sleeve_profile) - 1 : -1 : 0]) sleeve_profile[i]],
        plate_edge_profile(),
        [[outer_radius, -back_rim_depth],
         [rim_inner_radius, -back_rim_depth],
         [rim_inner_radius, 0]]
    ));
}

module unsplit_escutcheon() {
    union() {
        rotate_extrude(convexity = 6) escutcheon_profile2d();

        // Inner halves rise as wedges; outer halves stay broad and flat.
        petals();
    }
}

module screw_hole(angle) {
    rotate([0, 0, angle]) translate([mount_radius, 0, 0]) {
        translate([0, 0, -back_rim_depth - 1])
            cylinder(h = total_height + back_rim_depth + 2,
                     d = screw_shank_diameter);
        if (screw_head_style == "Flat head")
            translate([0, 0, body_thickness - screw_head_height])
                cylinder(h = screw_head_height + petal_outer_thickness + 1,
                         d1 = screw_shank_diameter,
                         d2 = screw_head_diameter);
        else if (screw_head_style == "Round head")
            translate([0, 0, body_thickness - screw_head_height])
                cylinder(h = screw_head_height + petal_outer_thickness + 1,
                         d = screw_head_diameter);
    }
}

module upper_part() {
    difference() {
        intersection() {
            unsplit_escutcheon();
            translate([0, 0, -back_rim_depth - 0.1])
                linear_extrude(height = total_height + back_rim_depth + 0.2)
                    upper_mask2d(1);
        }
        translate([0, 0, -0.01])
            linear_extrude(height = tab_thickness + fit_clearance)
                tab_shape2d(fit_clearance);
        screw_hole(90);
        for (a = tab_angles) screw_hole(a);
    }
}

module lower_part() {
    difference() {
        union() {
            intersection() {
                unsplit_escutcheon();
                translate([0, 0, -back_rim_depth - 0.1])
                    linear_extrude(height = total_height + back_rim_depth + 0.2)
                        lower_mask2d(1);
            }
            // Tabs slide beneath matching grooves in the upper part.
            linear_extrude(height = tab_thickness)
                difference() {
                    tab_shape2d();
                    circle(r = pipe_radius);
                }
        }
        for (a = tab_angles) screw_hole(a);
    }
}

module assembled() {
    upper_part();
    lower_part();
}

module all_in_one() {
    difference() {
        unsplit_escutcheon();
        screw_hole(90);
        for (a = tab_angles) screw_hole(a);
    }
}

if (model_view == "Upper part")
    upper_part();
else if (model_view == "Lower part")
    lower_part();
else if (model_view == "Assembled")
    assembled();
else if (model_view == "All in one")
    all_in_one();
else {
    // Both pieces lie decorative-side-up in their intended print orientation.
    translate([-(outer_radius + part_gap / 2), 0, back_rim_depth]) upper_part();
    translate([ outer_radius + part_gap / 2, 0, back_rim_depth]) lower_part();
}
