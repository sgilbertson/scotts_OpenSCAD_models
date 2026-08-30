# Parametric Round Snap-On Lid with Optional Text

Create a custom round lid for a coffee can, tin, mug, pencil cup, storage container, or other cylindrical object. Enter the container diameter and the desired lid dimensions, then export a lid sized for your particular application.

The lid has an outer skirt and an optional half-round retaining bead on its inside edge. The bead is intended to pass over a rolled rim or similar feature and help the lid snap into place. Because printers, materials, and containers vary, expect to make a small test print or adjust the diameter before printing a large final lid.

## Parametric design

`ParametricRoundLid.scad` lets you customize:

- Lid diameter, measured without the outer lip
- Top thickness
- Outer lip thickness and height
- Diameter of the optional half-round retaining bead
- Chamfer around the upper edge
- Top-up or top-down print orientation
- Single-line or multiline text
- Typeface, style, and a custom installed font
- Text size as a percentage of the usable lid diameter
- Raised, flush, recessed, or full-depth lettering
- 2D sketch, complete model, lid-only, and lettering-only views
- Preview/export facet count (smoothness of circular features)

The model includes validation for dimensions that cannot produce workable geometry. Text is automatically scaled to remain within the selected circular area, including multiline labels and Unicode symbols supported by the selected font.

![Cross-section of the parametric lid and retaining bead](images/RoundLidCrossSection.svg)

*The 2D Sketch view shows the revolved cross-section of the lid, lip, and retaining bead.*

## Text and symbols

Set `text_lines` to one or more quoted strings. For example:

```scad
text_lines = ["COFFEE"];
text_lines = ["SILICA", "GEL"];
text_lines = ["COFFEE", "☕"];
```

The three Liberation font families are included as portable choices because they are commonly available with OpenSCAD. Select **Custom** to enter another installed font family. A Unicode symbol will only render if the selected font contains that glyph.

Lettering can be configured in several ways:

- Positive `text_height`: raised above the lid
- Zero `text_height`: flush with the top surface
- Negative `text_height`: recessed below the top surface
- `text_depth` equal to `top_thickness`: lettering passes through the complete top and appears reversed when viewed from inside

## Exporting and printing

### One-material print

Select **Single Part**, choose the desired print orientation, and export the complete model as an STL.

**Top Down** usually gives the cleanest unsupported top surface when the text is flush or recessed. The lower lip edge is rounded in this orientation. Raised text will require supports when printed top-down.

**Top Up** places the bottom of the lip on the build plate. This is useful for raised lettering, but the underside of the lid panel may require supports. One-eighth-circle transitions meet the outer lip walls tangentially and leave a flat contact area on the build plate.

### Two-material print

Select **Lid Only** and export the lid, then select **Lettering Only** and export the lettering as a second STL. The two files share the same origin and orientation:

1. Import both STL files into Bambu Studio at the same time.
2. When asked, load them as a single object with multiple parts.
3. Assign a different filament to each part.
4. Confirm the parts remain aligned before slicing.

The **Single Part** view previews the lid and lettering together in different colours. For a flush two-material label, use a positive `text_depth` and set `text_height` to zero. Use a negative `text_height` when the coloured lettering surface should sit below the lid surface.

## Fit and material considerations

- Measure the container in several places; thin cans and cups may not be perfectly round.
    - You can also wrap a strip of paper around the container and make a mark to measure the circumference (like taking a waist measurement). Divide by Pi and that's the diameter.
- Material shrinkage, extrusion width, and printer calibration all affect the final fit.
- PLA is easy to print but relatively rigid. PETG may provide a tougher and slightly more flexible snap lip. TPU is more flexible, allowing a tighter fit. Other materials can work if their properties suit the application.
- Start with a modest retaining bead and adjust it after a fit test. An overly large bead can make the lid difficult to install or remove.
- This model is not inherently airtight, watertight, or food-safe. Those properties depend on fit, material, printer, and post-processing.

## Example use case: mesh pencil-cup desiccant container

My inspiration for this project was that I wanted a container for silica gel desiccant. It seemed to me that a mesh pencil cup would allow plenty of air flow while properly retaining the beads. It just needed a lid, and as always I tried to make my design applicable to other use-cases.

The included `PencilCupLid75mm.3mf`, lid STL, and lettering STL are an example of this application, not a universal fit.

<!-- Still to do: I will add the detailed pencil-cup measurement, customization, slicing, filling, and assembly walkthrough here. -->

## Other possible uses

- Replacement lids for coffee cans and similar containers
- Covers for mugs or cylindrical storage cups
- Labelled workshop and craft-storage containers
- Dust covers for open-ended round objects
- Ventilated desiccant holders
- Colour-coded or symbol-labelled organization systems

## License & acknowledgments

Designed using OpenSCAD with coding help from [OpenAI Codex](https://openai.com/codex/). Feel free to customize, remix, and share according to the license attached to this model.

If you print this design, please share your make. I would enjoy seeing the containers, labels, symbols, materials, and parameter combinations people use.
