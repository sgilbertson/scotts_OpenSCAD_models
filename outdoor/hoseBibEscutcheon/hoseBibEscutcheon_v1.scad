/* Hose bib escutcheon -- dimensions are in millimetres. */

pipe_diameter       = 25.4;
pipe_clearance      = 1.2;
outer_diameter      = 120;
front_diameter      = 110;
body_thickness      = 5;

petal_count         = 12;       // A multiple of six keeps seams on petal edges.
petal_width         = 12;
petal_inner_radius  = 18;
petal_outer_radius  = 51;
petal_height        = 1.8;

back_rim_width      = 3;
back_rim_depth      = 2;
foam_clearance      = 0.4;

mount_radius         = 38;
screw_shank_diameter = 4;
screw_head_diameter  = 8;
screw_head_height    = 2.2;
screw_head_style     = "flat";  // "flat" or "round"

tab_radius          = 8;
tab_thickness       = 2;
fit_clearance       = 0.25;

part_gap            = 8;
layout              = "print"; // "print", "assembled", "upper", or "lower"
$fn                 = 72;

outer_radius = outer_diameter / 2;
front_radius = front_diameter / 2;
pipe_radius  = pipe_diameter / 2 + pipe_clearance;
total_height = body_thickness + petal_height;
lower_half_angle = 30;
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
    sector2d(-90 + lower_half_angle, 270 - lower_half_angle,
             outer_radius + extra);
}

module lower_mask2d(extra = 0) {
    sector2d(270 - lower_half_angle, 270 + lower_half_angle,
             outer_radius + extra);
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
    hull() {
        translate([petal_inner_radius, 0])
            scale([1, 0.72]) circle(d = petal_width);
        translate([petal_outer_radius, 0])
            scale([0.62, 1]) circle(d = petal_width);
    }
}

module unsplit_escutcheon() {
    difference() {
        union() {
            cylinder(h = body_thickness, r1 = outer_radius,
                     r2 = front_radius);

            // Raised petals; the visible base between them forms the recesses.
            for (a = [0 : 360 / petal_count : 359])
                rotate([0, 0, a])
                    translate([0, 0, body_thickness - 0.01])
                        linear_extrude(height = petal_height,
                                       scale = front_radius / outer_radius)
                            intersection() {
                                petal2d();
                                circle(r = outer_radius - 1);
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
        if (screw_head_style == "flat")
            translate([0, 0, body_thickness - screw_head_height])
                cylinder(h = screw_head_height + petal_height + 1,
                         d1 = screw_shank_diameter,
                         d2 = screw_head_diameter);
        else if (screw_head_style == "round")
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
        screw_hole(-90);
        for (a = tab_angles) screw_hole(a);
    }
}

module assembled() {
    upper_part();
    lower_part();
}

if (layout == "upper")
    upper_part();
else if (layout == "lower")
    lower_part();
else if (layout == "assembled")
    assembled();
else {
    // Both pieces lie decorative-side-up in their intended print orientation.
    translate([-(outer_radius + part_gap / 2), 0, back_rim_depth]) upper_part();
    translate([ outer_radius + part_gap / 2, 0, back_rim_depth]) lower_part();
}
