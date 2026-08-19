/* Hose bib escutcheon -- dimensions are in millimetres. */

/* [View] */
model_view = "Assembled"; // [Upper part, Lower part, Assembled, Side by side]
part_gap = 8;

/* [Main plate] */
pipe_diameter       = 25.4;
pipe_clearance      = 1.2;
outer_diameter      = 120;
front_diameter      = 110;
body_thickness      = 5;

/* [Decorative petals] */
petal_count         = 12;       // Use a multiple of four to center a bottom petal.
petal_width         = 12;
petal_outer_radius  = 51;
petal_height        = 1.8;

/* [Pipe sleeve] */
sleeve_height         = 18;
sleeve_wall_thickness = 2.4;
sleeve_flare          = 7;
sleeve_profile_steps  = 12;

/* [Foam retaining rim] */
back_rim_width      = 3;
back_rim_depth      = 2;
foam_clearance      = 0.4;

/* [Mounting screws] */
mount_radius         = 38;
screw_shank_diameter = 4;
screw_head_diameter  = 8;
screw_head_height    = 2.2;
screw_head_style     = "Flat head"; // [Flat head, Round head]

/* [Part connection] */
tab_radius          = 8;
tab_thickness       = 2;
fit_clearance       = 0.25;

/* [Resolution] */
$fn                 = 72;

/* [Hidden] */
outer_radius = outer_diameter / 2;
front_radius = front_diameter / 2;
pipe_radius  = pipe_diameter / 2 + pipe_clearance;
sleeve_top_radius = pipe_radius + sleeve_wall_thickness;
sleeve_base_radius = sleeve_top_radius + sleeve_flare;
total_height = body_thickness + max(petal_height, sleeve_height);
petal_pitch = 360 / petal_count;
petal_half_angle = min(petal_pitch / 2 - 0.2,
                       asin(min(0.999, petal_width / (2 * petal_outer_radius))));
tangent_half_angle = asin(min(0.999, pipe_radius / sleeve_base_radius));
// The two candidate expressions are the inner and outer edges of nearby petals.
cut_at_outer_edge = ceil((tangent_half_angle - petal_half_angle) / petal_pitch)
                    * petal_pitch + petal_half_angle;
cut_at_inner_edge = ceil((tangent_half_angle + petal_half_angle) / petal_pitch)
                    * petal_pitch - petal_half_angle;
lower_half_angle = min(cut_at_outer_edge, cut_at_inner_edge);
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
        pipe_channel2d(extra);
    }
}

module lower_mask2d(extra = 0) {
    union() {
        sector2d(270 - lower_half_angle, 270 + lower_half_angle,
                 outer_radius + extra);
        pipe_channel2d(extra);
    }
}

module pipe_channel2d(extra = 0) {
    // Parallel walls guarantee an opening as wide as the center hole.
    translate([-pipe_radius, -outer_radius - extra])
        square([2 * pipe_radius, outer_radius + extra]);
}

module tab_shape2d(clearance = 0) {
    for (a = tab_angles)
        hull() {
            rotate(a)
                translate([mount_radius - tab_radius / 2, 0])
                    circle(r = tab_radius + clearance);
            rotate(-90)
                translate([mount_radius - tab_radius / 2, 0])
                    circle(r = tab_radius + clearance);
        }
}

module petal2d() {
    // Radial sides provide exact petal edges for concealing the part seam.
    difference() {
        sector2d(-petal_half_angle, petal_half_angle, petal_outer_radius);
        circle(r = sleeve_base_radius - 0.05);
    }
}

module sleeve() {
    // Smoothstep makes an S-shaped profile with a horizontal tangent at the plate.
    outer_profile = [
        for (i = [0 : sleeve_profile_steps])
            let(t = i / sleeve_profile_steps,
                smooth_t = t * t * (3 - 2 * t))
            [sleeve_base_radius
                - (sleeve_base_radius - sleeve_top_radius) * t,
             body_thickness + sleeve_height * smooth_t]
    ];
    rotate_extrude(convexity = 4)
        polygon(concat(outer_profile,
                       [[pipe_radius, body_thickness + sleeve_height],
                        [pipe_radius, body_thickness - 0.01]]));
}

module unsplit_escutcheon() {
    difference() {
        union() {
            cylinder(h = body_thickness, r1 = outer_radius,
                     r2 = front_radius);

            sleeve();

            // Raised petals; the visible base between them forms the recesses.
            for (a = [0 : 360 / petal_count : 359])
                rotate([0, 0, a])
                    translate([0, 0, body_thickness - 0.01])
                        linear_extrude(height = petal_height)
                            intersection() {
                                petal2d();
                                // Keep even very wide petals on the flat front face.
                                circle(r = front_radius - 0.1);
                            }

            // The projecting back rim retains a neoprene foam washer.
            translate([0, 0, -back_rim_depth])
                linear_extrude(height = back_rim_depth + 0.01)
                    difference() {
                        circle(r = outer_radius);
                        circle(r = outer_radius - back_rim_width - foam_clearance);
                    }
        }
        translate([0, 0, -back_rim_depth - 1])
            cylinder(h = total_height + back_rim_depth + 2, r = pipe_radius);
    }
}

module screw_hole(angle) {
    rotate([0, 0, angle]) translate([mount_radius, 0, 0]) {
        translate([0, 0, -back_rim_depth - 1])
            cylinder(h = total_height + back_rim_depth + 2,
                     d = screw_shank_diameter);
        if (screw_head_style == "Flat head")
            translate([0, 0, body_thickness - screw_head_height])
                cylinder(h = screw_head_height + petal_height + 1,
                         d1 = screw_shank_diameter,
                         d2 = screw_head_diameter);
        else if (screw_head_style == "Round head")
            translate([0, 0, body_thickness - screw_head_height])
                cylinder(h = screw_head_height + petal_height + 1,
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

if (model_view == "Upper part")
    upper_part();
else if (model_view == "Lower part")
    lower_part();
else if (model_view == "Assembled")
    assembled();
else {
    // Both pieces lie decorative-side-up in their intended print orientation.
    translate([-(outer_radius + part_gap / 2), 0, back_rim_depth]) upper_part();
    translate([ outer_radius + part_gap / 2, 0, back_rim_depth]) lower_part();
}
