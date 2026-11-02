$fn = 50;
l = 180;           // Länge des Quaders jetzt 180 mm
w = 75;            // Breite des Quaders jetzt 75 mm
t = 2;             // Materialstärke in Z

// Modul: Gitterstruktur über gesamten Quader
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
difference() {
    translate([0, -w/2, 0])
        cube([l, w, t]);
    kletka();
}

// Modul: Außenkontur zur Wandstärke
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
translate([6, -55, 0]) rog();
translate([170 , -55, 0]) rog();
translate([10,  55, 0]) rotate([0, 0, 180]) rog();
translate([174 ,  55, 0]) rotate([0, 0, 180]) rog();
module rog() {
    difference() {
        // Grundblöcke bis 55 mm Höhe
        cube([4, 20, 55]);
        translate([0, 2, 0]) cube([4, 14, 52]);
        translate([0, 4, 0]) cube([4, 12, 49]);
        cube([4,12,46]);
    }
    // Abrundung an der Spitze
    translate([0, 18, 0])
        hull() {
            translate([0, 0, 53]) cube([4, 1, 1]);
            translate([-6, 0, 0]) cube([16, 1, 1]);
        }
}
