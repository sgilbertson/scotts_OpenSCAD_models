// Länge des Quaders jetzt 180 mm / Length of the rectangular block is now 180 mm
l = 180;

// Breite des Quaders jetzt 75 mm / Width of the rectangular block is now 75 mm
w = 75;

// Materialstärke in Z / Material thickness in Z
t = 2;

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
                    cube([1.2, w, 3]);
            }

            // Horizontale Streben (Abstand 4 mm)
            for (j = [0 : floor(w/4)]) {
                translate([0, j*4 - w/2, 0])
                    cube([l, 1.2, 3]);
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

    // Modul: Außenkontur zur Wandstärke
    // Module: Outer outline defining the wall thickness
    contur();
    module contur() {
        difference() {
            // äußere Kontur
            translate([0, -w/2, 0])
                cube([l, w, t]);
            // innere Kontur (2 mm Wandstärke)
            translate([2, -w/2 + 2, 0])
                cube([l - 4, w - 4, t + 1]);
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
