/* [Matrix View Controls] */

// Select the visual layout or the component to export.
model_view = "Single Part"; // [2D Sketch, Single Part, Lid Only, Lettering Only]
// Select which face rests on the print bed.
print_orientation = "Top Down"; // [Top Up, Top Down]

/* [Lid dimensions] */

// Diameter covered by the lid, excluding the outer snap lip (mm).
lid_diameter = 100;
// Thickness of the flat top panel (mm).
top_thickness = 3;
// Radial thickness of the outer snap lip (mm).
lip_thickness = 3;
// Lip height below the underside of the top panel (mm).
lip_height = 5;
// Diameter of the inward-facing retaining bead (0 disables it) (mm).
bead_diameter = 2;
// Chamfer around the upper outside edge (mm).
top_chamfer = 1;

/* [Lettering] */

// One quoted string per line; use ["FIRST LINE", "SECOND LINE"] for newlines.
text_lines = [""];
// Typeface used for the lid text.
text_typeface = "Liberation Sans"; // [Liberation Sans, Liberation Serif, Liberation Mono, DejaVu Sans, DejaVu Serif, DejaVu Sans Mono]
// Typeface style. Unsupported styles fall back to the closest installed style.
text_style = "Bold"; // [Normal, Bold, Italic, Bold Italic]
// Maximum diameter occupied by the text, as a percentage of lid_diameter.
text_fit_percent = 85;
// Engraving/inlay depth below the top surface (mm).
text_depth = 0;
// Height of lettering above the top surface (mm).
text_height = 0.6;
// Extra spacing between lines, as a multiple of the calculated font size.
line_spacing = 1.15;

/* [Output quality] */

// Circle resolution. Lower values render and export faster.
facet_count = 128;

/* [Hidden] */

$fn = $preview ? min(facet_count, 72) : facet_count;
eps = 0.01;

assert(lid_diameter > 0, "lid_diameter must be positive");
assert(top_thickness > 0, "top_thickness must be positive");
assert(lip_thickness > 0 && lip_height > 0,
       "lip_thickness and lip_height must be positive");
assert(bead_diameter >= 0 && bead_diameter <= lip_height,
       "bead_diameter must not exceed lip_height");
assert(bead_diameter <= 2 * lip_thickness,
       "bead_diameter is too large for this lip");
assert(top_chamfer >= 0 && top_chamfer < top_thickness &&
       top_chamfer <= lip_thickness,
       "top_chamfer must fit within both the top and lip");
assert(text_fit_percent > 0 && text_fit_percent <= 100,
       "text_fit_percent must be in the range 0..100");
assert(text_depth >= 0 && text_depth < top_thickness,
       "text_depth must be less than top_thickness");
assert(text_height >= 0, "text_height cannot be negative");
assert(print_orientation == "Top Up" || print_orientation == "Top Down",
       "Unknown print_orientation");
assert(model_view == "2D Sketch" || model_view == "Single Part" ||
       model_view == "Lid Only" || model_view == "Lettering Only",
       "Unknown model_view");

inner_r = lid_diameter / 2;
outer_r = inner_r + lip_thickness;
bead_r = bead_diameter / 2;
line_count = max(1, len(text_lines));
font_style = text_style == "Normal" ? "Regular" : text_style;
text_font = str(text_typeface, ":style=", font_style);

// A conservative font-size estimate keeps even wide glyphs inside the target circle.
function longest_line(i = 0, best = 0) =
    i >= len(text_lines) ? best : longest_line(i + 1, max(best, len(text_lines[i])));
text_zone = lid_diameter * text_fit_percent / 100;
font_size = min(text_zone / max(1, longest_line()) * 1.55,
                text_zone / max(1, line_count * line_spacing));

// Build the complete cross-section as one polygon. Besides being fast, this avoids
// coincident surfaces that can make the F5 preview look hollow or striped.
module lid_solid() {
    round_r = min(lip_thickness / 2, 1);
    lower_chamfer = min(top_chamfer, lip_thickness / 2, lip_height / 2);
    rounded_bottom = print_orientation == "Top Down" && lip_thickness > 0.6;

    outer_bottom = rounded_bottom
        ? [for (a = [0 : -15 : -90])
              [outer_r - round_r + round_r * cos(a),
               -lip_height + round_r + round_r * sin(a)]]
        : [[outer_r, -lip_height + lower_chamfer],
           [outer_r - lower_chamfer, -lip_height]];

    // A bead supplies the entire inner rounding; otherwise use the selected
    // print-orientation treatment on the inner lower corner.
    inner_bottom = bead_diameter > 0
        ? [for (a = [-90 : -15 : -270])
              [inner_r + bead_r * cos(a),
               -lip_height + bead_r + bead_r * sin(a)]]
        : rounded_bottom
            ? [for (a = [-90 : -15 : -180])
                  [inner_r + round_r + round_r * cos(a),
                   -lip_height + round_r + round_r * sin(a)]]
            : [[inner_r + lower_chamfer, -lip_height],
               [inner_r, -lip_height + lower_chamfer]];

    rotate_extrude(convexity = 4)
        polygon(concat(
            [[0, 0], [0, top_thickness],
             [outer_r - top_chamfer, top_thickness],
             [outer_r, top_thickness - top_chamfer],
             [outer_r, 0]],
            outer_bottom,
            inner_bottom,
            [[inner_r, 0]]
        ));
}

module lettering_2d() {
    if (longest_line() > 0)
        for (i = [0 : len(text_lines) - 1])
            translate([0, (line_count - 1) * font_size * line_spacing / 2 -
                             i * font_size * line_spacing])
                text(text_lines[i], size = font_size, font = text_font,
                     halign = "center", valign = "center");
}

module lettering_solid() {
    if (longest_line() > 0 && text_depth + text_height > 0)
        translate([0, 0, top_thickness - text_depth])
            linear_extrude(height = text_depth + text_height)
                lettering_2d();
}

module selected_model() {
    if (model_view == "2D Sketch")
        projection(cut = true)
            if (print_orientation == "Top Up")
                translate([0, lip_height, 0])
                    rotate([-90, 0, 0]) lid_solid();
            else
                translate([0, top_thickness, 0])
                    rotate([90, 0, 0]) lid_solid();
    else if (model_view == "Single Part")
        union() {
            lid_solid();
            lettering_solid();
        }
    else if (model_view == "Lid Only")
        difference() {
            lid_solid();
            lettering_solid();
        }
    else
        lettering_solid();
}

// Put the chosen face on Z=0 while keeping lid and lettering mutually registered.
if (model_view == "2D Sketch")
    selected_model();
else if (print_orientation == "Top Up")
    translate([0, 0, lip_height]) selected_model();
else
    translate([0, 0, top_thickness +
        ((model_view == "Single Part" || model_view == "Lettering Only") &&
         longest_line() > 0 ? text_height : 0)])
        rotate([180, 0, 0]) selected_model();
