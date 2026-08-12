## Fully Parametric Dual-Material Equipment Foot (TPU + PETG)
This is a 100% parametric, high-utility anti-vibration equipment foot featuring a hard, rigid base plate (engineered for PETG) integrated with a flexible vibration-damping upper core (engineered for TPU/TPE).
Unlike standard designs that rely on chemical bonds between incompatible plastics, this model features an internal interlocking dovetail ring. The flexible TPU flows straight into an under-cut socket inside the PETG base during printing, creating a permanent mechanical enclosure that cannot be pulled apart under stress or shear loads.
## 🛠️ Key Design Features

* Universal Fastener Layout: Supports an integrated selector dropdown for standard Washer-seating hardware (Pan-head/Round-head) or Countersink-seating hardware (Flat-head machine/wood screws).
* True Sloped Tangency Fillets: Features mathematically driven inner and outer tip fillets. The outer radius dynamically scales along the conical wall angle without creating awkward steps, ledges, or hooks.
* MakerWorld Customizer Safe: Tucked with background assert() boundary error-checks. If a user inputs a fillet size that exceeds the physical dimensions of the cone, the script safely halts execution and guides them on the maximum value allowed.

------------------------------
## 🚀 How to Export & Slice (Bambu Studio Workflow)
This design is optimized for dual-toolhead setups (like the Bambu Lab X2D or independent IDEX configurations) which eliminate purging waste completely.
## Step 1: Exporting from OpenSCAD

   1. Inside the OpenSCAD Customizer panel, change your dimensions to match your target hardware.
   2. Change part_selection to "base". Hit F6 (Render), then Export as STL (name it base.stl).
   3. Change part_selection to "upper". Hit F6 (Render), then Export as STL (name it upper.stl).

## Step 2: Slicing Setup in Bambu Studio

   1. Drag both base.stl and upper.stl files onto your print bed simultaneously.
   2. Bambu Studio will prompt you: "Multi-part object detected. Do you want to load these files as a single object with multiple parts?" Click YES.
   3. Go to the left-hand Objects panel tab:
   * Select your base sub-component and assign it to your PETG toolhead/extruder slot.
      * Select your upper sub-component and assign it to your TPU toolhead/extruder slot.
   4. Set lip_tolerance = 0.0 inside your original project setup to ensure that the co-extruded layers melt directly against each other for a perfect seal.

------------------------------
## 🖨️ Recommended Print Settings

* Primary Material (TPU Core): 0.20mm layer height, 3 wall loops, 25% Gyroid infill (for balanced vibration damping). Limit volumetric speed to 3.5 mm³/s to avoid drive tangles.
* Secondary Material (PETG Base): 0.20mm layer height, 4 wall loops, 40% Grid/Rectilinear infill to withstand heavy fastener bolting tension without crushing.
* Supports: Completely disabled. Every overhang angle in the model tracks within standard self-supporting boundaries!

