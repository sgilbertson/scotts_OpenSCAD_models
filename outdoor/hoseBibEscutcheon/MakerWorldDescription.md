# Parametric Escutcheon / Wall Plate for Hose Bib, Outdoor Faucet, and Plumbing Pipes

## Overview

This semi-decorative escutcheon design professionally covers unsightly gaps around hose bibs, outdoor faucets, spigots, and other exterior plumbing pipes. I claim the raised petal pattern adds visual appeal (😁 Feel free to remix if you disagree!) while the parametric design allows customization for different pipe sizes and mounting configurations.

## Key Features

- **Fully Parametric Design** - Customize for your exact pipe diameter, wall spacing, and mounting requirements
- **Decorative Petal Pattern** - Raised flower-like petals create an attractive finish (12 petals default, customizable)
- **Two Installation Options:**
  - Split upper/lower design for installation over existing hose bibs
  - Single-piece version for installation over bare pipes
- **Weather-Resistant Design** - Integrated foam seal rim on the back accepts neoprene weatherstripping
- **Integrated Standoffs** - Optional standoffs prevent over-tightening and accommodate uneven walls
- **Pipe Sleeve** - Elegant S-curved sleeve transitions smoothly from escutcheon to pipe
- **Flexible Mounting** - Four screw holes on 76mm circle, configurable for flat-head or round-head screws
- **Hidden Fasteners** - Split-line designed along petal edges to conceal the seam when assembled

## Customization Parameters

The OpenSCAD source provides extensive customization:

- **Pipe diameter** (default 25.4mm / 1") with adjustable clearance
- **Overall diameter** (default 120mm)
- **Petal count, width, and depth** - adjust the decorative pattern
- **Sleeve height and profile** - modify the pipe transition
- **Screw hole types, positions and sizes** - match your hardware
- **Standoff thickness** - strength vs. compactness for the optional standoffs
- **Foam rim dimensions** - customize the optional seal cavity, so that the foam is slightly compressed when instaleld

## Print Settings

- **Material:** PETG or ASA recommended for outdoor use (PLA+ acceptable for indoor/protected areas)
- **Layer Height:** 0.2mm recommended
- **Infill:** 15-20% sufficient
- **Supports:** Required for the pipe sleeve (on the Bambu X2D I used PETG supports with PLA interface layer)
- **Orientation:** Print decorative side up
- **Print Time:** Approximately 3-5 hours per part (depending on size)

## Assembly & Installation

**For Split Version (to get past existing hose bib or other fitting):**
1. Print upper and lower parts separately (select "Upper part" or "Lower part" in the model view when exporting)
2. Cut neoprene foam weatherstripping to fit inside the back rim (optional but recommended for better seal)
3. Install foam over the pipe (slit the foam to facilitate this step)
4. Position lower part around pipe, mark screw holes
5. Pre-drill wall and install lower part with two screws
6. Slide upper part over pipe, align with lower part
7. Install the two connecting screws through both parts
8. Install top screw through upper part

_Note:_ In the 30-second video you'll see that I did it a bit differently, clicking the two parts together before driving screws, and using deck screws that didn't need a pilot hole. Do whatever works for your case.

**For Single-Piece Version (over bare pipe):**
- Print the single-piece escutcheon (Select "All in one" in the model view when exporting)
- Install before attaching the hose bib or pipe fixture
- Slide over pipe, position, and secure with four screws

Detailed installation photos and a 30-second video are included showing the process.

## Use Cases

- **Hose Bibs / Outdoor Faucets** - Cover gaps where pipes enter siding
- **Outdoor Sheds** - Improve appearance of utility plumbing
- **Irrigation Systems** - Professional-looking pipe covers
- **General Plumbing** - Any exposed pipe penetration needing a decorative cover
- **New Construction / Renovation** - Finishing touch for exterior plumbing

## Design Documentation

I've documented the complete design process, including how I used AI (ChatGPT/Codex) to generate the OpenSCAD code from natural language descriptions. This may be instructional for others learning OpenSCAD or AI-assisted design:

[View Design Process on GitHub](https://github.com/sgilbertson/scotts_OpenSCAD_models/blob/main/outdoor/hoseBibEscutcheon/design_process.md)

The detailed documentation includes:
- Step-by-step design iterations
- Problem-solving approaches
- Parameter tuning examples
- Installation tips for non-flat walls

## Technical Details

- Designed in OpenSCAD (parametric source included) with coding help from [OpenAI Codex](https://openai.com/codex/) because ~~I'm lazy~~ I'm a beginner with OpenSCAD (but I've used FreeCAD a fair bit)
- Default size: 120mm diameter × 23mm max height (with 18mm sleeve)
- Center opening: 26.6mm (for 25.4mm pipe + 1.2mm clearance)
- Mounting circle: 76mm diameter
- Back rim: 2mm deep, accepts weatherstripping up to 3mm thick
- Tab connection: 2mm thick with 0.25mm fit clearance

## License

Released under an open-source license - feel free to remix and share your customized versions!

## Support

If you print this design, please share your make! I'd love to see how you customized it for your specific application. Questions? Leave a comment or check the GitHub repository for detailed documentation.

