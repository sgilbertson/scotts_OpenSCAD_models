// Parametric Equipment Foot Generator v3
// Designed for Bambu Lab X2D (Nozzle 1: TPU, Nozzle 2: PETG)

/* [Global Parameters] */
part = "both"; // [base: PETG part only, upper: TPU part only, both: Assembled view]
cross_section = true; // [true: Show cross-section, false: Show full part]

/* [Base Plate (PETG)] */
base_diameter = 40;
base_height = 9;        // Adjusted to hold washer + interlocking groove
base_hole_dia = 4.5;    // Through-hole for mounting bolt
base_countersink_dia = 9;
base_countersink_depth = 3;

/* [Washer Cavity] */
washer_dia = 12;        // Diameter of the embedded washer cavity
washer_depth = 2.5;     // Depth/thickness of the washer cavity

/* [Upper Dampener (TPU)] */
upper_top_diameter = 25;
upper_bottom_diameter = 35;
upper_height = 15;
lip_height = 3.5;       // Deeper lip to clear the mechanical interlock
lip_tolerance = 0.2;    // Tighter tolerance since X2D handles dual-nozzle alignment tightly

/* [Mechanical Interlocking Joint] */
interlock_width = 2.5;  // How deep the dovetail/T-anchor wings flange outward
interlock_thick = 1.5;  // Thickness of the internal locking ring layer

/* [Fillets (TPU Tip)] */
outer_fillet_radius = 2.0;
inner_fillet_radius = 1.0;

$fn = 96; // Higher resolution for crisp circles

module mechanical_joint_profile(clearance = 0) {
    // Generates the 3D interlocking ring that traps the materials together
    // Now with a sloped dovetail profile for mechanical locking
    d_main = upper_bottom_diameter + (clearance * 2);
    d_flare = upper_bottom_diameter + (interlock_width * 2) + (clearance * 2);
    
    translate([0, 0, lip_height - interlock_thick])
        cylinder(d=d_flare, h=interlock_thick);
}

module base_plate() {
    color("DarkOrange") 
    difference() {
        // Main base body
        cylinder(d=base_diameter, h=base_height);
        
        // Mounting bolt hole
        translate([0, 0, -1])
            cylinder(d=base_hole_dia, h=base_height + 2);
            
        // Countersink on bottom
        translate([0, 0, -0.01])
            cylinder(d=base_countersink_dia, h=base_countersink_depth);
            
        // Washer Cavity
        translate([0, 0, base_countersink_depth - 0.01])
            cylinder(d=washer_dia, h=washer_depth + 0.02);
            
        // Main tapered recess for the TPU foot neck (dovetail profile)
        translate([0, 0, base_height - lip_height])
            cylinder(d1=upper_bottom_diameter + lip_tolerance * 2, 
                     d2=upper_bottom_diameter - interlock_width + lip_tolerance * 2, 
                     h=lip_height + 0.1);
            
        // INTERNAL INTERLOCK GROOVE: Cuts out an underground anchor cavern
        translate([0,0, base_height - lip_height])
            mechanical_joint_profile(clearance = lip_tolerance);
    }
}

module upper_dampener() {
    color("DimGray") 
    translate([0, 0, (part == "upper") ? 0 : base_height]) 
    difference() {
        union() {
            // Main tapered neck entering the base (dovetail profile)
            cylinder(d2=upper_bottom_diameter - interlock_width, 
                     d1=upper_bottom_diameter, 
                     h=lip_height);
            
            // THE MALE INTERLOCK MUSHROOM: Fills the base's underground cavern
            mechanical_joint_profile(clearance = 0);
            
            // Main visible dampener body
            translate([0, 0, lip_height])
                cylinder(d1=upper_bottom_diameter, d2=upper_top_diameter, h=upper_height - lip_height);
        }
            
        // Clear out the center mounting hole - sized to accommodate screw head
        translate([0, 0, -1])
            cylinder(d=washer_dia, h=upper_height + lip_height + 2);
            
        // --- Fillets via Subtraction ---
        if (outer_fillet_radius > 0) {
            translate([0, 0, upper_height])
                difference() {
                    translate([0, 0, -outer_fillet_radius])
                        cylinder(d=upper_top_diameter + 2, h=outer_fillet_radius + 0.1);
                    rotate_extrude()
                        translate([(upper_top_diameter/2) - outer_fillet_radius, -outer_fillet_radius, 0])
                            circle(r=outer_fillet_radius);
                }
        }
        
        if (inner_fillet_radius > 0) {
            translate([0, 0, upper_height])
                difference() {
                    translate([0, 0, -inner_fillet_radius])
                        cylinder(d=base_countersink_dia + inner_fillet_radius*2, h=inner_fillet_radius + 0.1);
                    translate([0, 0, -inner_fillet_radius - 0.1])
                        cylinder(d=base_countersink_dia, h=inner_fillet_radius + 0.2);
                    rotate_extrude()
                        translate([(base_countersink_dia/2) + inner_fillet_radius, -inner_fillet_radius, 0])
                            circle(r=inner_fillet_radius);
                }
        }
    }
}

module radial_cross_section() {
    difference() {
        children();
        translate([-100, 0, -20])
            cube([200, 100, 50], center=false);
    }
}


// Customizer Selector
module render_selected_part() {
    if (part == "base") {
        base_plate();
    } else if (part == "upper") {
        upper_dampener();
    } else {
        base_plate();
        upper_dampener();
    }
}
if (cross_section) {
    // Show cross-section by cutting the model in half
    radial_cross_section() render_selected_part();
} else {
    render_selected_part(); 
}
