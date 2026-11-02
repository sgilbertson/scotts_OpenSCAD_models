// Length of the horizontal rectangular grid
l = 180; // Länge des Quaders jetzt 180 mm

// Width of the horizontal rectangular grid
w = 75; // Breite des Quaders jetzt 75 mm

// Thickness of the horizontal grid (mm)
t = 3;

// Height of the side walls above the grid (mm; 0 = no raised walls)
side_wall_height = 0;

// Thickness of the raised side wall grids (mm), independent of the bottom grid
side_wall_thickness = 2;

// Vertical distance from the grid bottom to the underside of the hook crossbar (mm)
hook_depth = 52;

// Inside width of the cleaning tub at the rim, across the tray width (mm)
tub_inside_width = 90;

// Outside width of the cleaner where the hook legs hang (mm)
cleaner_outside_width = 105;

// Clearance per side: braces inside the tub and hook legs outside the cleaner (mm)
hook_fit_clearance = 0.5;

// Clear vertical drop from the crossbar underside to the bottom of the outer leg (mm)
hook_inside_height = 6;

// Thickness of the hook bars, including their width along the tray length (mm)
hook_bar_thickness = 3;

$fn = 50;

// Resolve coplanar Boolean faces before previewing, so F5 matches F6.
// This adds a geometry evaluation step when the preview is rebuilt.
render(convexity = 10) tray();

module tray() {
    // Assume the tub, cleaner and tray are centered on the same width axis.
    // Uprights are centered on the grid edges, so their outside span is w + b.
    upright_outside_span = w + hook_bar_thickness;
    gap_to_tub = (tub_inside_width - upright_outside_span)/2;
    rim_span = (cleaner_outside_width - tub_inside_width)/2;
    hook_inside_length = gap_to_tub + rim_span + hook_fit_clearance;
    brace_run = gap_to_tub - hook_fit_clearance;
    assert(brace_run >= 0,
           "Tub must fit the upright outside span plus clearance on both sides.");
    assert(brace_run <= hook_depth,
           "Tub is too wide for a 45 degree brace at this hook depth; increase hook_depth.");
    assert(cleaner_outside_width >= tub_inside_width,
           "Cleaner outside width must be at least the tub inside width.");
    assert(hook_fit_clearance >= 0, "Hook fit clearance cannot be negative.");
    // Modul: Gitterstruktur über gesamten Quader
    // Module: Grid structure across the entire rectangular block
    module kletka() {
        difference() {
            // Basis-Quader
            translate([0, -w/2, 0])
                cube([l, w, t]);

            // Vertikale Streben (Abstand 6 mm)
            for (i = [0 : floor(l/6)]) {
                translate([i*6, -w/2, 0])
                    cube([1.2, w, t + 1]);
            }

            // Horizontale Streben (Abstand 4 mm)
            for (j = [0 : floor(w/4)]) {
                translate([0, j*4 - w/2, 0])
                    cube([l, 1.2, t + 1]);
            }
        }
    }

    // Hauptkörper: Quader minus Gitter
    // Main body: Rectangular block minus grid
    difference() {
        translate([0, -w/2, 0])
            cube([l, w, t]);
        kletka();
    }

    // Solid 2 mm bottom perimeter and separately sized, perforated side walls.
    contur();
    module perimeter(height, thickness) {
        difference() {
            translate([0, -w/2, 0])
                cube([l, w, height]);
            translate([thickness, -w/2 + thickness, -1])
                cube([l - 2*thickness, w - 2*thickness, height + 2]);
        }
    }

    module contur() {
        perimeter(t, 2);
        if (side_wall_height > 0) {
            // Match the floor's 6 x 4 mm pitch and 1.2 mm grid bars.
            // Keep a solid frame at the top, bottom and corners of each wall.
            frame = max(2, side_wall_thickness);
            columns_l = floor((l - 2*frame + 1.2)/6);
            columns_w = floor((w - 2*frame + 1.2)/6);
            rows = floor((side_wall_height - 2*frame + 1.2)/4);
            translate([0, 0, t])
                difference() {
                    perimeter(side_wall_height, side_wall_thickness);
                    if (rows > 0) {
                        // Openings through the two long walls.
                        if (columns_l > 0)
                            for (i = [0 : columns_l - 1], j = [0 : rows - 1],
                                 y = [-w/2, w/2 - side_wall_thickness])
                                translate([frame + i*6, y - 0.1, frame + j*4])
                                    cube([4.8, side_wall_thickness + 0.2, 2.8]);
                        // Openings through the two end walls.
                        if (columns_w > 0)
                            for (i = [0 : columns_w - 1], j = [0 : rows - 1],
                                 x = [0, l - side_wall_thickness])
                                translate([x - 0.1, -w/2 + frame + i*6, frame + j*4])
                                    cube([side_wall_thickness + 0.2, 4.8, 2.8]);
                    }
                }
        }
    }

    // Four corner hangers. Center each upright on the long edge of the grid.
    hook_reach = hook_inside_length + 2*hook_bar_thickness;
    hanger_y = w/2 + hook_reach - hook_bar_thickness/2;
    translate([6, -hanger_y, 0]) rog();
    translate([l - 6 - hook_bar_thickness, -hanger_y, 0]) rog();
    translate([6 + hook_bar_thickness, hanger_y, 0]) rotate([0, 0, 180]) rog();
    translate([l - 6, hanger_y, 0]) rotate([0, 0, 180]) rog();

    module rog() {
        b = hook_bar_thickness;
        assert(b > 0, "Hook bar thickness must be positive.");
        assert(hook_inside_length > 0, "Hook inside length must be positive.");
        assert(hook_inside_height > 0 && hook_inside_height < hook_depth,
               "Hook inside height must be positive and less than hook depth.");
        // Horizontal crossbar: its underside is exactly hook_depth above Z=0.
        translate([0, 0, hook_depth])
            cube([b, hook_reach, b]);
        // Triangular brace in the Y/Z plane, extruded to the hook bar width.
        // Equal horizontal run and vertical rise give a 45 degree underside.
        // Its tip stops short of the tub wall by hook_fit_clearance; the
        // remaining flat crossbar underside bears on the tub rim at Z=hook_depth.
        if (brace_run > 0)
            multmatrix([[0, 0, 1, 0],
                        [1, 0, 0, 0],
                        [0, 1, 0, 0],
                        [0, 0, 0, 1]])
                linear_extrude(height = b)
                    polygon([[hook_reach - b, hook_depth - brace_run],
                             [hook_reach - b, hook_depth],
                             [hook_reach - b - brace_run, hook_depth]]);
        // Outer vertical leg; the clear opening ends at its inner face, Y=b.
        translate([0, 0, hook_depth - hook_inside_height])
            cube([b, b, hook_inside_height + b]);
        // Upright with a flared foot, retaining the original 6 mm corner offset.
        hull() {
            translate([-6, hook_reach - b, 0])
                cube([b + 12, b, min(t, hook_depth)]);
            translate([0, hook_reach - b, hook_depth])
                cube([b, b, b]);
        }
    }
}
