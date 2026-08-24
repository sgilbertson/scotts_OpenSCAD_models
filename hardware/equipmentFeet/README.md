## Fully Parametric Dual-Material Equipment Foot (TPU + PETG)

This is a 100% parametric, high-utility anti-vibration equipment foot featuring a hard, rigid base plate integrated with a flexible vibration-damping upper body. Ot os designed specifically for dual-toolhead printers like the Bambu Lab X2D.

I have published it on MakerWorld: [makerworld.com/en/models/3214790-parametric-foot-for-equipment-furniture-etc](https://makerworld.com/en/models/3214790-parametric-foot-for-equipment-furniture-etc)

In this document I've assumed that the rigid section is PETG (for strength around the screw hole) and the flexible section is TPU (for flexibility).

Since the two materials are physically interlocked rather than chemically bonded, this design is compatible with any combination of materials that can be printed together on a dual-toolhead printer.

On the Bambu Lab X2D, the PETG base is printed on the build plate, while the TPU upper is printed on top of it. This avoids any contact between the TPU and the build plate, which can be problematic for adhesion. Note that TPU must be printed using the primary extruder, while PETG is printed using the secondary extruder and an external spool holder. The secondary extruder on the X2D will jam if you try to use it to print TPU, so the PETG must be printed with the secondary extruder.

My printer setup includes the Bambu Lab TPU Feed Assist module, but I am led to understand that you can also feed TPU directly from a spool to the primary extruder.

### Version 2 (Current/Recommended)

**TwoMaterialEquipmentFoot_v2.scad** is the current production version. In this design, the TPU wraps around the outside of the PETG base, creating a mechanical interlock via a sloped dovetail joint. The flexible TPU skirt extends downward around the PETG tongue, locking the materials together during simultaneous co-printing. This approach:

- Prints PETG-side-down (TPU side up), avoiding TPU contact with the build plate
- Creates a secure mechanical dovetail lock preventing separation under stress
- Maintains the full base diameter in PETG for maximum stability
- Allows the screw head/washer to pass through the TPU upper portion

### Version 1 (Alternative)

**TwoMaterialEquipmentFoot_v1.scad** reverses the approach - PETG wraps around the outside of a TPU core that inserts into a cavity in the PETG base. Both versions use mechanical interlocking rather than relying on chemical bonding between incompatible plastics.

I switched the wrapping around in version 2 so that the hard base can be thinner, mainly just providing strength around the screw hole.

---

## 🛠️ Key Design Features (Version 2)

* **Universal Fastener Support**: Integrated dropdown selector for either washer-seating hardware (pan-head/round-head screws) or countersink-seating hardware (flat-head machine/wood screws). The fastener type automatically configures the internal pocket geometry.
* **Sloped Dovetail Interlock**: TPU skirt wraps down around a sloped PETG tongue, creating a permanent mechanical lock with configurable angle and width parameters.
* **Mathematically Tangent Fillets**: Inner and outer top fillets on the TPU body use calculated tangency points to create smooth, continuous curves without sharp edges.
* **3D Cutaway Visualization**: Built-in cutaway view mode that introduces a thin visual gap between materials, making it easy to inspect the internal interface geometry.
* **Customizer Safety Checks**: Assert statements validate fillet dimensions against physical constraints, preventing impossible geometry and providing helpful error messages.
* **Zero-Tolerance Co-Printing**: Designed for simultaneous dual-nozzle printing with `lip_tolerance = 0.0` so materials fuse directly together.

---

## 🚀 How to Export & Slice (Bambu Studio Workflow)

This design is optimized for dual-toolhead setups (like the Bambu Lab X2D or IDEX printers) which eliminate purging waste completely.

### Step 1: Exporting from OpenSCAD

1. Open **TwoMaterialEquipmentFoot_v2.scad** in OpenSCAD
2. Adjust parameters in the Customizer panel:
   - Set your desired dimensions (base_diameter, upper_height, etc.)
   - Choose fastener_type (countersink or washer) to match your mounting hardware
   - Set model_view to "3D Assembled" for export
3. Export the PETG base:
   - Set `part_selection = "base"`
   - Hit **F6** (Render)
   - Export as STL (name it `EquipmentFoot_Base_PETG.stl`)
4. Export the TPU upper:
   - Set `part_selection = "upper"`
   - Hit **F6** (Render)
   - Export as STL (name it `EquipmentFoot_Upper_TPU.stl`)

### Step 2: Slicing Setup in Bambu Studio

1. Import both STL files:
   - Drag both `EquipmentFoot_Base_PETG.stl` and `EquipmentFoot_Upper_TPU.stl` onto the build plate simultaneously
   - When prompted "Multi-part object detected. Do you want to load these files as a single object with multiple parts?" click **YES**
2. Assign materials:
   - In the Objects panel, select the base component and assign it to your PETG filament/extruder
   - Select the upper component and assign it to your TPU filament/extruder  
3. Orient for printing:
   - The part should be oriented PETG-side-down (flat base on build plate)
   - TPU prints on top, avoiding build plate adhesion issues
4. Verify interlocking geometry:
   - In the sliced preview, examine the layers where PETG and TPU meet
   - You should see the TPU skirt wrapping around the PETG tongue with zero gap

---

## 🖨️ Recommended Print Settings

**PETG Base (contacts build plate):**
- Layer height: 0.20mm
- Wall loops: 4
- Infill: 40% Grid or Rectilinear (for rigidity under fastener compression)
- Speed: Normal PETG speeds (60-80 mm/s)

**TPU Upper (vibration dampener):**
- Layer height: 0.20mm  
- Wall loops: 3
- Infill: 25% Gyroid (good balance of flexibility and damping)
- Speed: Limit volumetric flow to 3.5 mm³/s to prevent extruder skipping
- Retraction: Minimal or disabled

**Build Plate & Supports:**
- No supports required - all overhangs are printable
- Use textured PEI build plate (PETG adheres well, TPU never touches plate)
- No glue or adhesion aids needed

---

## 📐 Key Parameters Explained

- **base_diameter**: Overall footprint diameter - keep this matched to your equipment mounting points
- **base_height**: Height of the PETG base (typically 8-10mm for structural integrity)
- **upper_height**: Total height of the TPU body including the skirt portion
- **lip_height**: How far the TPU skirt extends down around the PETG base (3-4mm typical)
- **interlock_width**: Radial width of the dovetail lock (2.5-3.5mm recommended)
- **interlock_angle**: Slope angle of the dovetail (15-25° works well)
- **lip_tolerance**: Clearance gap between materials (keep at 0.0 for dual-nozzle co-printing)
- **outer_fillet_radius** / **inner_fillet_radius**: Rounds the TPU top edges (2mm typical)

