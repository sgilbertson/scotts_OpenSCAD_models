// Parametric Equipment Foot Generator v41 - TPU-Wrapped Interlock (Version 2.4)
// Designed for Dual-Material Co-Printing (e.g., TPU + PETG)
// Attempts to be fully protected against breaking via Customizer assertions
// How it works:
// The PETG base is printed first, and the TPU upper is printed on top of it.
// The interlock mechanism is designed to prevent the TPU upper from falling off the PETG base.
// The TPU upper wraps around the outside of the PETG base, and the PETG base has a dovetail-shaped cavity that the TPU upper fits into.
// Each section is designed using a 2D sketch, which is then rotated around the Z-axis to create a 3D model.  The two sections are then
// combined into a single assembly for visualization, but they are exported as separate STL files for printing.

/* [Information For Users] */
// This model uses two-material printing to create a round foot that can be screwed to the bottom of furniture or equipment. It can be printed with a hard material like PLA or PETG for the base and a soft material like TPU for the upper, or you can print both parts in the same material.
Concept = true;
// The two parts are mechanically interlocked using dovetails, so the upper can not fall off the base. You can configure the number and dimensions of the dovetails.
Mechanical_interlock = true;
// A hard base is useful for larger diameter feet, where a soft TPU base alone could bend or tear under load. It also may eliminate the need for a washer in some cases.
Why_use_two_materials = true;
// You can also print both parts in TPU, if you don't need the extra rigidity of a hard base.
Can_print_both_parts_in_TPU = true;

/* [Matrix View Controls] */
// Select the visual layout
model_view = "3D Cutaway"; // [3D Assembled, 3D Cutaway, 2D Sketch]
// Choose which components are visible. For printing you can export "PETG only" and "TPU only" as separate STL files, then combine them as a part in Bambu Studio.
part_selection = "both"; // [base: PETG only, upper: TPU only, both: Full Assembly]

/* [Fastener Logic] */
// Choose the fastener pocket type (Countersink or Washer)
fastener_type = "countersink"; // [countersink: Flat-head screw, washer: Pan-head/Round-head with or without a washer]

// Through-hole slightly larger than screw shaft (about 4.5mm for #8 screw)
base_hole_dia = 4.5;

// Countersink dimensions when fastener_type == "countersink" (angle typically 82 or 90 degrees)
base_countersink_dia = 9.0; // [1:0.1:30]
countersink_angle = 82;

// Washer or screw head diameter (Used if fastener_type == "washer")
washer_dia = 12;
// Recess for washer or screw head in base plate (allowed to be negative!)
washer_depth = 2.5;     

/* [Global Dimensions] */
// The master outer diameter of the equipment foot
base_diameter = 40;
// The height of the base (typically PETG), which is printed first
base_height = 9;
// The diameter of the flat top surface tip of the TPU part
upper_top_diameter = 25;
// Height of the flexible TPU upper body
upper_height = 15;

/* [Sloped Mechanical Interlock] */
// How far the TPU skirt extends down around the PETG base
lip_height = 3.5;
// Radial width of the sloped PETG/TPU interlock
interlock_width = 3.0;  // [0.1:0.1:20]
// Interlock face angle (degrees)
interlock_angle = 20;
// Clearance gap (Keep 0 for dual-nozzle co-printing)
lip_tolerance = 0.0;    // [-2:0.1:2]
// Total number of concentric dovetails, including the original outer dovetail
dovetail_count = 1;     // [1:1:4]
// Minimum TPU thickness between an added dovetail and the sloped outer wall
minimum_tpu_outer_wall = 1.2;

// Look straight down at the XY plane whenever the 2D profile is selected.
$vpr = (model_view == "2D Sketch") ? [0, 0, 0] : $vpr;

/* [Fillets (TPU Tip)] */
// Supports fine decimal increments. Set to 0 for perfectly sharp corners.
outer_fillet_radius = 2.0; // [0:0.1:10]
inner_fillet_radius = 2.0; // [0:0.1:10]

/* [Hidden] */
$fn = 96;

// Visual-only separation between PETG and TPU in 3D Cutaway mode.
// Each profile is inset by half this amount, producing approximately this
// much visible space at their shared interface. It does NOT affect the
// assembled view or exported base/upper parts.
cutaway_material_gap = 0.16; 
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

dovetail_flare = lip_height * tan(interlock_angle);

// With multiple dovetails, move the original outer interlock inward far
// enough to preserve the requested TPU wall at both ends of its flank.
// A single dovetail deliberately retains the exact version 2 geometry.
required_radial_outer_wall = minimum_tpu_outer_wall / cos(cone_angle);
outer_lock_inward_shift = (dovetail_count > 1) ? max([
    0,
    r_lock_neck - (r_cone_bot - required_radial_outer_wall),
    r_lock_floor - (r_skirt_outer - required_radial_outer_wall)
]) : 0;
r_lock_neck_position = r_lock_neck - outer_lock_inward_shift;
r_lock_floor_position = r_lock_floor - outer_lock_inward_shift;
outer_tpu_wall_thickness = min(
    (r_cone_bot - r_lock_neck_position) * cos(cone_angle),
    (r_skirt_outer - r_lock_floor_position) * cos(cone_angle)
);

// Redistribute the added dovetails evenly inside the relocated outer lock.
// Their necks narrow automatically when necessary so neighboring dovetails
// cannot overlap, while retaining the selected depth and flank angle.
dovetail_spacing = (r_lock_neck_position - r_clear) / dovetail_count;
inner_dovetail_neck_width = min(interlock_width,
                                dovetail_spacing - (2 * dovetail_flare) - eps);
inner_dovetail_floor_half_width = (inner_dovetail_neck_width / 2) + dovetail_flare;
innermost_dovetail_center = r_clear + dovetail_spacing;
outermost_dovetail_center = r_clear + ((dovetail_count - 1) * dovetail_spacing);

minimum_base_bridge_width = 0.5;
inner_base_bridge_width = innermost_dovetail_center
    - inner_dovetail_floor_half_width - r_clear;
outer_base_bridge_width = r_lock_floor_position - outermost_dovetail_center
    - inner_dovetail_floor_half_width;
adjacent_base_bridge_width = dovetail_spacing
    - (2 * inner_dovetail_floor_half_width);
base_bridge_width = (dovetail_count > 2)
    ? min([inner_base_bridge_width, outer_base_bridge_width, adjacent_base_bridge_width])
    : min(inner_base_bridge_width, outer_base_bridge_width);

assert(dovetail_count >= 1 && dovetail_count == floor(dovetail_count),
       "ERROR: Dovetail count must be a positive whole number.");
assert(minimum_tpu_outer_wall >= 0,
       "ERROR: Minimum TPU outer wall must not be negative.");
assert(dovetail_count == 1 || outer_tpu_wall_thickness + eps >= minimum_tpu_outer_wall,
       "ERROR: Unable to preserve the requested minimum TPU outer wall.");
assert(dovetail_count == 1 || inner_dovetail_neck_width > eps,
       "ERROR: Too many dovetails for the available radius, lip height, and interlock angle.");
assert(dovetail_count == 1 || base_bridge_width >= minimum_base_bridge_width,
       str("ERROR: After preserving the ", minimum_tpu_outer_wall,
           "mm TPU outer wall, the dovetails leave only ", base_bridge_width,
           "mm of hard base; at least ", minimum_base_bridge_width,
           "mm is required. Reduce the dovetail count, width, lip height, or interlock angle."));

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
} else if (model_view == "3D Cutaway" || model_view == "3D Cross Section") {
    // A cutaway removes one complete half of the rotational model to expose
    // the internal PETG/TPU interface and fastener pocket.  In this view only,
    // each material profile is inset very slightly so a narrow light-colored
    // seam remains between the two materials.  The actual printable geometry
    // is unchanged.
    render(convexity = 10)
        render_3d_cutaway_selection();
} else {
    render_3d_layer_selection();
}

// Render the 2D profile of the selected part(s) for previewing in 2D Sketch mode.
module render_2d_layer_selection() {
    if (part_selection == "base") {
        complete_2d_profile() base_plate_2d_profile();
    } else if (part_selection == "upper") {
        complete_2d_profile() upper_dampener_2d_profile();
    } else {
        complete_2d_profile() base_plate_2d_profile();
        complete_2d_profile()
            translate([0, base_height]) upper_dampener_2d_profile();
    }

    settings_table_2d();
}

// The construction profiles describe one radius. Mirror them across the
// centerline in sketch mode to expose the complete fastener-hole section.
module complete_2d_profile() {
    children();
    mirror([1, 0, 0]) children();
}

// Draw a compact record of all applicable user-configurable geometry values.
// Matrix controls and the informational placeholder are intentionally omitted.
module settings_table_2d() {
    settings = concat(
        [
            ["Fastener type", fastener_type],
            ["Base hole diameter", str(base_hole_dia, " mm")]
        ],
        (fastener_type == "countersink") ?
            [
                ["Countersink diameter", str(base_countersink_dia, " mm")],
                ["Countersink angle", str(countersink_angle, " deg")]
            ] :
            [
                ["Washer/head diameter", str(washer_dia, " mm")],
                ["Washer/head depth", str(washer_depth, " mm")]
            ],
        [
            ["Base diameter", str(base_diameter, " mm")],
            ["Base height", str(base_height, " mm")],
            ["Upper top diameter", str(upper_top_diameter, " mm")],
            ["Upper height", str(upper_height, " mm")],
            ["Lip height", str(lip_height, " mm")],
            ["Interlock width", str(interlock_width, " mm")],
            ["Interlock angle", str(interlock_angle, " deg")],
            ["Lip tolerance", str(lip_tolerance, " mm")],
            ["Dovetail count", dovetail_count],
            ["Minimum TPU outer wall", str(minimum_tpu_outer_wall, " mm")],
            ["Outer fillet radius", str(outer_fillet_radius, " mm")],
            ["Inner fillet radius", str(inner_fillet_radius, " mm")]
        ]
    );

    columns = 2;
    rows = ceil(len(settings) / columns);
    table_width = max(base_diameter, 70);
    column_width = table_width / columns;
    row_height = 3.5;
    header_height = 4;
    table_height = header_height + (rows * row_height);
    table_top = -4;
    table_bottom = table_top - table_height;
    line_width = 0.08;

    color("Navy") {
        // Outer border and the grid separating settings.
        translate([-table_width / 2, table_bottom])
            difference() {
                square([table_width, table_height]);
                translate([line_width, line_width])
                    square([table_width - (2 * line_width),
                            table_height - (2 * line_width)]);
            }

        translate([-line_width / 2, table_bottom])
            square([line_width, table_height - header_height]);

        for (row = [1 : rows])
            translate([-table_width / 2,
                       table_bottom + (row * row_height) - (line_width / 2)])
                square([table_width, line_width]);

        translate([0, table_top - (header_height / 2)])
            text("Configured Settings", size = 1.8,
                 halign = "center", valign = "center");

        for (row = [0 : rows - 1], column = [0 : columns - 1])
            let(index = (row * columns) + column)
            if (index < len(settings))
                translate([
                    (-table_width / 2) + (column * column_width) + 1,
                    table_top - header_height - ((row + 0.5) * row_height)
                ])
                    text(str(settings[index][0], ": ", settings[index][1]),
                         size = 1.15, valign = "center");
    }
}


module cutaway_half() {
    // Remove the Y < 0 half of the rotational model.
    translate([-100, -100, -50])
        cube([200, 100, 100]);
}

// Render the 3D profile of the selected part(s) for previewing in 3D Assembled or 3D Cutaway mode.
module render_3d_cutaway_selection() {
    gap_inset = cutaway_material_gap / 2;

    // Keep the two materials as separate solids in this display mode.  If we
    // unioned them first, the deliberately introduced seam could disappear.
    if (part_selection == "base" || part_selection == "both") {
        color("DarkOrange")
        difference() {
            rotate_extrude()
                offset(delta = -gap_inset)
                    base_plate_2d_profile();
            cutaway_half();
        }
    }

    if (part_selection == "upper" || part_selection == "both") {
        color("DimGray")
        difference() {
            translate([0, 0, base_height])
                rotate_extrude()
                    offset(delta = -gap_inset)
                        upper_dampener_2d_profile();
            cutaway_half();
        }
    }
}

// Render the 3D profile of the selected part(s) for previewing in 3D Assembled mode.
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

// Base plate, which is printed first, normally in a hard material like PETG.
// This is the part that contacts the equipment and provides a rigid base for the TPU upper.
module base_plate_2d_profile() {
    // The interlock between halves works as follows:
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
        [r_lock_floor_position + lip_tolerance, base_height - lip_height + lip_tolerance],
        [r_lock_neck_position + lip_tolerance, base_height],

        // Additional TPU-filled annular dovetails, ordered outside to inside.
        if (dovetail_count > 1)
            for (i = [dovetail_count - 1 : -1 : 1]) each
                let(center = r_clear + (i * dovetail_spacing),
                    neck_half = inner_dovetail_neck_width / 2)
                [
                    [center + neck_half, base_height],
                    [center + inner_dovetail_floor_half_width, base_height - lip_height],
                    [center - inner_dovetail_floor_half_width, base_height - lip_height],
                    [center - neck_half, base_height]
                ],

        // Full-height PETG remains around the screw pocket.
        [r_clear, base_height],

        (fastener_type == "countersink") ?
            [r_hole, pocket_bottom_y] :
            [r_clear, pocket_bottom_y],

        [r_hole, pocket_bottom_y]
    ]);
}

// Upper dampener, which is printed second, normally in a flexible material like TPU.
// This is the part that contacts the surface on which the equipment sits, providing vibration damping.
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

                // Additional downward-flaring annular dovetails, inside to outside.
                if (dovetail_count > 1)
                    for (i = [1 : dovetail_count - 1]) each
                        let(center = r_clear + (i * dovetail_spacing),
                            neck_half = inner_dovetail_neck_width / 2)
                        [
                            [center - neck_half, 0],
                            [center - inner_dovetail_floor_half_width, -lip_height],
                            [center + inner_dovetail_floor_half_width, -lip_height],
                            [center + neck_half, 0]
                        ],

                [r_lock_neck_position - overlap_offset, 0],

                // TPU wraps DOWN around the outside of the PETG tongue.
                [r_lock_floor_position - overlap_offset, -lip_height - overlap_offset],

                // Keep the outside surface on the SAME taper all the way down
                // to the bottom of the TPU skirt; no cylindrical section here.
                [r_skirt_outer, -lip_height - overlap_offset],

                // Main tapered TPU body.  This point lies on the same straight line
                // from [r_base,-lip_height] to the upper tapered surface.
                [r_cone_bot, 0],
                
                (outer_fillet_radius > 0.0) ? 
                    [r_cone_top + (dist_to_tangent * sin(cone_angle)),
                     tpu_actual_height - (dist_to_tangent * cos(cone_angle))]
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
