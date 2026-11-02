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

$fn = 50;

// Resolve coplanar Boolean faces before previewing, so F5 matches F6.
// This adds a geometry evaluation step when the preview is rebuilt.
render(convexity = 10) tray();

module tray() {
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

    // Hörner an den vier Ecken
    // Horns at the four corners
    // Keep the default corner offsets as the tray length and width change.
    translate([6, -w/2 - 17.5, 0]) rog();
    translate([l - 10, -w/2 - 17.5, 0]) rog();
    translate([10, w/2 + 17.5, 0]) rotate([0, 0, 180]) rog();
    translate([l - 6, w/2 + 17.5, 0]) rotate([0, 0, 180]) rog();
    module rog() {
        difference() {
            // Grundblöcke bis 55 mm Höhe
            // Base blocks up to 55 mm high
            cube([4, 20, 55]);
            translate([0, 2, 0]) cube([4, 14, 52]);
            translate([0, 4, 0]) cube([4, 12, 49]);
            cube([4,12,46]);
        }
        // Abrundung an der Spitze
        // Rounding at the tip
        translate([0, 18, 0])
            hull() {
                translate([0, 0, 53]) cube([4, 1, 1]);
                translate([-6, 0, 0]) cube([16, 1, 1]);
            }
    }
}
