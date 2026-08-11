// Parametric Equipment Foot Generator v28 - Explicit Profile Master
// Designed for Dual-Material Co-Printing (e.g., TPU + PETG)

/* [Matrix View Controls] */
// Select the visual layout
model_view = "3D Cross Section"; // [3D Assembled, 3D Cross Section, 2D Sketch]
// Choose which components are visible
part_selection = "both"; // [base: PETG only, upper: TPU only, both: Full Assembly]

/* [Fastener Logic] */
fastener_type = "washer"; // [countersink: Flat-head screw, washer: Pan-head/Round-head + washer]
base_hole_dia = 4.5;    // Through-hole for mounting bolt shaft

// Countersink dimensions (Used if fastener_type == "countersink")
base_countersink_dia = 9;
countersink_angle = 90; 

// Washer dimensions (Used if fastener_type == "washer")
washer_dia = 12;        
washer_depth = 2.5;     

/* [Global Dimensions] */
base_diameter = 40;     // The master outer diameter of the equipment foot
base_height = 9;        
upper_top_diameter = 25; // The diameter of the flat top surface tip of the TPU part
upper_height = 15;      // Height of the flexible TPU upper body

/* [Sloped Mechanical Interlock] */
lip_height = 3.5;       // Depth of the interlocking cavity pocket
interlock_width = 3.0;  // How far the dovetail wedge flairs outward into the base
interlock_angle = 20;   // Dovetail wedge angle (degrees)

/* [Fillets (TPU Tip)] */
// Supports fine decimal increments (e.g. 0.5, 1.25). Set to 0 for perfectly sharp corners.
outer_fillet_radius = 1.0; // [0:0.1:10]
inner_fillet_radius = 2.0; // [0:0.1:10]

/* [Hidden] */
$fn = 96; 
base_shoulder_width = 0.0; // Permanently locked to 0 for flush wall fitment
lip_tolerance = 0.0;    

// --- Consolidated Math & Boundary Calculations ---
clearance_dia = (fastener_type == "washer") ? washer_dia : base_countersink_dia;
cs_rad_diff = (base_countersink_dia - base_hole_dia) / 2;
calculated_cs_depth = cs_rad_diff / tan(countersink_angle / 2);
pocket_depth = (fastener_type == "washer") ? washer_depth : calculated_cs_depth;

// Mathematical offset to eliminate coincident face errors and 2-manifold warnings
eps = 0.01; 
overlap_offset = (part_selection == "both") ? eps : 0;

// Master Radii mappings linked strictly to base_diameter
r_hole = base_hole_dia / 2;
r_clear = clearance_dia / 2;
r_base = base_diameter / 2;

// Dynamic step lock: aligned perfectly flush to the outer perimeter
r_step_edge = r_base - base_shoulder_width; 
r_cone_bot = r_step_edge; 
r_cone_top = upper_top_diameter / 2;
tpu_actual_height = upper_height - lip_height;

// Slope angle calculation of the outer cone face relative to the vertical axis
cone_angle = atan2((r_cone_bot - r_cone_top), tpu_actual_height);

// Strict under-cut dovetail coordinates
r_lock_neck = r_step_edge - interlock_width;
r_lock_floor = r_lock_neck + (lip_height * tan(interlock_angle));

// --- Core Master Matrix Switchboard ---
if (model_view == "2D Sketch") {
    render_2d_layer_selection();
} else if (model_view == "3D Cross Section") {
    difference() {
        render_3d_layer_selection();
        translate([-100, -100, -50]) cube(); 
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
    if (part_selection == "base" || part_selection == "both") {
        rotate_extrude() base_plate_2d_profile();
    } 
    if (part_selection == "upper" || part_selection == "both") {
        translate([0, 0, base_height])
            rotate_extrude() upper_dampener_2d_profile();
    }
}

// --- Component 2D Profile Geometries ---

module base_plate_2d_profile() {
    color("DarkOrange")
    polygon([
        [r_hole, -eps],                                             
        [r_base, -eps],                                             
        [r_base, base_height],                                      
        [r_step_edge + lip_tolerance, base_height],                 
        [r_lock_neck + lip_tolerance, base_height],                 
        [r_lock_floor + lip_tolerance, base_height - lip_height],   
        [r_clear, base_height - lip_height],                        
        [r_clear, base_height - lip_height - pocket_depth],         
        [r_hole, base_height - lip_height - pocket_depth]           
    ]);
}

module upper_dampener_2d_profile() {
    color("DimGray");
    
    // Exact geometric included angles to map the dynamic tangent contact points
    half_angle = (90 + cone_angle) / 2;
    dist_to_tangent = outer_fillet_radius / tan(half_angle);
    
    // Circle center offsets for true tangency alignment
    cx = r_cone_top - dist_to_tangent;
    cy = tpu_actual_height - outer_fillet_radius;
    
    difference() {
        // Master Continuous Outline Profile (FreeCAD Style Sketch Method)
        union() {
            // Main puzzle anchor base and cone profile hull
            polygon([
                [r_clear, 0],                            
                [r_clear, -lip_height - overlap_offset], 
                [r_lock_floor - overlap_offset, -lip_height - overlap_offset], 
                [r_lock_neck - overlap_offset, 0],       
                [r_step_edge, 0],                        
                [r_cone_bot, 0], 
                
                // Dynamic outer point: moves inward when fillet is active to make room for the round edge
                (outer_fillet_radius > 0.0) ? 
                    [r_cone_top + (outer_fillet_radius * sin(cone_angle)) - (dist_to_tangent * sin(cone_angle)), 
                     tpu_actual_height - (outer_fillet_radius * cos(cone_angle)) + (dist_to_tangent * cos(cone_angle))] 
                    : [r_cone_top, tpu_actual_height],
                
                // Flat top tangent transition point
                (outer_fillet_radius > 0.0) ? [r_cone_top - dist_to_tangent, tpu_actual_height] : [r_cone_top, tpu_actual_height],
                [r_clear, tpu_actual_height]     
            ]);
            
            // Adds the positive rolling tangent fillet circle directly to the profile wall boundary
            if (outer_fillet_radius > 0.0) {
                translate([cx, cy]) circle(r=outer_fillet_radius);
            }
        }
        
        // --- 2D Inner Fillet Trimming ---
        if (inner_fillet_radius > 0.0) {
            translate([r_clear + inner_fillet_radius, tpu_actual_height - inner_fillet_radius])
            difference() {
                translate([-inner_fillet_radius * 2, 0]) square([inner_fillet_radius * 2, inner_fillet_radius * 2]);
                circle(r=inner_fillet_radius);
            }
        }
    }
}
