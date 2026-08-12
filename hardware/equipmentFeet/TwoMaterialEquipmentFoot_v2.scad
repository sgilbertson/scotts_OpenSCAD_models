// Parametric Equipment Foot Generator v39 - TPU-Wrapped Interlock (Version 2.2)
// Designed for Dual-Material Co-Printing (e.g., TPU + PETG)
// Fully protected against breaking via Customizer assertions

/* [Matrix View Controls] */
// Select the visual layout
model_view = "3D Cross Section"; // [3D Assembled, 3D Cross Section, 2D Sketch]
// Choose which components are visible
part_selection = "both"; // [base: PETG only, upper: TPU only, both: Full Assembly]

/* [Fastener Logic] */
// Choose the fastener pocket type (Countersink or Washer)
fastener_type = "countersink"; // [countersink: Flat-head screw, washer: Pan-head/Round-head + washer]
base_hole_dia = 4.5;    // Through-hole for mounting bolt shaft

// Countersink dimensions (Used if fastener_type == "countersink")
base_countersink_dia = 9;
countersink_angle = 90; // Angle of flat head screw (usually 82 or 90 degrees)

// Washer dimensions (Used if fastener_type == "washer")
washer_dia = 12;        
washer_depth = 2.5;     

/* [Global Dimensions] */
base_diameter = 40;     // The master outer diameter of the equipment foot
base_height = 9;        
upper_top_diameter = 25; // The diameter of the flat top surface tip of the TPU part
upper_height = 15;      // Height of the flexible TPU upper body

/* [Sloped Mechanical Interlock] */
lip_height = 3.5;       // How far the TPU skirt extends down around the PETG base
interlock_width = 3.0;  // Radial width of the sloped PETG/TPU interlock
interlock_angle = 20;   // Interlock face angle (degrees)
lip_tolerance = 0.0;    // Clearance gap (Keep 0 for dual-nozzle co-printing)

/* [Fillets (TPU Tip)] */
// Supports fine decimal increments. Set to 0 for perfectly sharp corners.
outer_fillet_radius = 2.0; // [0:0.1:10]
inner_fillet_radius = 2.0; // [0:0.1:10]

/* [Hidden] */
$fn = 96; 
base_shoulder_width = 0.0; 

// --- Consolidated Math & Boundary Calculations ---
clearance_dia = (fastener_type == "washer") ? washer_dia : base_countersink_dia;
cs_rad_diff = (base_countersink_dia - base_hole_dia) / 2;
calculated_cs_depth = cs_rad_diff / tan(countersink_angle / 2);
pocket_depth = (fastener_type == "washer") ? washer_depth : calculated_cs_depth;

// Mathematical offset to eliminate coincident face errors and preview calculation bugs
eps = 0.01; 
overlap_offset = (part_selection == "both") ? eps : 0;

// Master Radii mappings linked strictly to base_diameter
r_hole = base_hole_dia / 2;
r_clear = clearance_dia / 2;
r_base = base_diameter / 2;

// Dynamic step lock: aligned perfectly flush to the outer perimeter
r_step_edge = r_base - base_shoulder_width; 
r_cone_top = upper_top_diameter / 2;
tpu_actual_height = upper_height - lip_height;

// The outside TPU taper now runs from the very bottom of the TPU skirt
// (at exactly the base radius) all the way to the top.  Therefore the
// taper angle is based on the full TPU height, including the skirt.
cone_angle = atan2((r_step_edge - r_cone_top), upper_height);

// Radius of that same continuous taper where it crosses the PETG top plane.
// This is intentionally smaller than r_base so the TPU cannot project beyond
// the PETG footprint at the bottom of the skirt.
r_cone_bot = r_step_edge - (lip_height * tan(cone_angle));

// Strict under-cut dovetail coordinates
r_lock_neck = r_step_edge - interlock_width;
// Positive interlock_angle now makes the PETG tongue flare inward toward its lower edge,
// matching the intended undercut direction.  (Version 2 originally had this sign reversed.)
r_lock_floor = r_lock_neck - (lip_height * tan(interlock_angle));

// The maximum TPU radius is locked to the PETG/base radius.  This makes the
// TPU skirt meet the PETG exactly at the outside edge rather than overhanging it.
r_skirt_outer = r_base;

// --- MakerWorld Input Validation Asserts (Safety Limits) ---
max_inner_radius = r_cone_top - r_clear;
max_outer_radius = tpu_actual_height / cos(cone_angle);

assert(inner_fillet_radius < max_inner_radius, 
       str("ERROR: Inner Fillet (", inner_fillet_radius, "mm) is too large! Maximum allowed is ", max_inner_radius, "mm based on current diameters."));

assert(outer_fillet_radius < max_outer_radius, 
       str("ERROR: Outer Fillet (", outer_fillet_radius, "mm) is too large! Maximum allowed is ", max_outer_radius, "mm based on current height."));

// --- Core Master Matrix Switchboard ---
if (model_view == "2D Sketch") {
    render_2d_layer_selection();
} else if (model_view == "3D Cross Section") {
    render(convexity = 10) {
        difference() {
            render_3d_layer_selection();
            translate([-100, 0, -50]) cube(); 
        }
    }
} else {
    render_3d_layer_selection();
}

module render_2d_layer_selection() {
    if (part_selection == "base") {
        base_plate_2d_profile();
    } else if (part_selection == "upper") {
        upper_dampener_2d_profile();
    } else {
        base_plate_2d_profile();
        translate([0, base_height]) upper_dampener_2d_profile();
    }
}

module render_3d_layer_selection() {
    union() {
        if (part_selection == "base" || part_selection == "both") {
            rotate_extrude() base_plate_2d_profile();
        } 
        if (part_selection == "upper" || part_selection == "both") {
            // FIXED: The translate layer is now locked active across both single export and full assembly view.
            // This forces the file coordinates to match perfectly when imported via Add Part -> Load.
            translate([0, 0, base_height])
                rotate_extrude() upper_dampener_2d_profile();
        }
    }
}

// --- Component 2D Profile Geometries ---

module base_plate_2d_profile() {
    // Version 2 reverses the interlock from version 1:
    // the PETG base is shorter at its outside edge, while the TPU skirt
    // comes down around it.  The PETG still rises to full base_height
    // around the fastener pocket so the mounting geometry is unchanged.
    pocket_bottom_y = base_height - pocket_depth;
    
    color("DarkOrange")
    polygon([
        [r_hole, -eps],
        [r_base, -eps],

        // Short outer PETG wall.
        [r_base, base_height - lip_height + lip_tolerance],

        // Sloped tongue under the TPU wrap.
        [r_lock_floor + lip_tolerance, base_height - lip_height + lip_tolerance],
        [r_lock_neck + lip_tolerance, base_height],

        // Full-height PETG remains around the screw pocket.
        [r_clear, base_height],

        (fastener_type == "countersink") ?
            [r_hole, pocket_bottom_y] :
            [r_clear, pocket_bottom_y],

        [r_hole, pocket_bottom_y]
    ]);
}

module upper_dampener_2d_profile() {
    half_angle = (90 + cone_angle) / 2;
    dist_to_tangent = outer_fillet_radius / tan(half_angle);
    
    cx = r_cone_top - dist_to_tangent;
    cy = tpu_actual_height - outer_fillet_radius;
    
    color("DimGray")
    difference() {
        union() {
            polygon([
                // Flat TPU/PETG interface at full base height.
                [r_clear, 0],
                [r_lock_neck - overlap_offset, 0],

                // TPU wraps DOWN around the outside of the PETG tongue.
                [r_lock_floor - overlap_offset, -lip_height - overlap_offset],

                // Keep the outside surface on the SAME taper all the way down
                // to the bottom of the TPU skirt; no cylindrical section here.
                [r_skirt_outer, -lip_height - overlap_offset],

                // Main tapered TPU body.  This point lies on the same straight line
                // from [r_base,-lip_height] to the upper tapered surface.
                [r_cone_bot, 0],
                
                (outer_fillet_radius > 0.0) ? 
                    [r_cone_top + (outer_fillet_radius * sin(cone_angle)) - (dist_to_tangent * sin(cone_angle)), 
                     tpu_actual_height - (outer_fillet_radius * cos(cone_angle)) + (dist_to_tangent * cos(cone_angle))] 
                    : [r_cone_top, tpu_actual_height],
                
                (outer_fillet_radius > 0.0) ? [r_cone_top - dist_to_tangent, tpu_actual_height] : [r_cone_top, tpu_actual_height],
                [r_clear, tpu_actual_height]
            ]);
            
            if (outer_fillet_radius > 0.0) {
                translate([cx, cy]) circle(r=outer_fillet_radius);
            }
        }
        
        if (inner_fillet_radius > 0.0) {
            translate([r_clear + inner_fillet_radius, tpu_actual_height - inner_fillet_radius])
            difference() {
                translate([-inner_fillet_radius * 2, 0]) square([inner_fillet_radius * 2, inner_fillet_radius * 2]);
                circle(r=inner_fillet_radius);
            }
        }
    }
}
