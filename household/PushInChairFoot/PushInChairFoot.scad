//
// Press-in chair foot
// Intended for 95A TPU
//
// Print with foot on build plate and stem pointing upward.
//
// Initial design by ChatGPT per specification from Scott Gilbertson

$fn = 96;

// ---------- Socket / stem ----------

// Measured chair socket
socket_diameter = 11.5;
socket_depth    = 27.0;

// Main body of stem.  Slight interference fit for TPU.
stem_diameter = 10.6;
stem_length   = 24;

// Axial hole makes the stem easier to compress.
// Set to 0 for a solid stem.
stem_hole_diameter = 4.5;

// Lead-in at top of stem
lead_in_length   = 2.0;
lead_in_diameter = 9.5;


// ---------- Retaining ribs ----------

rib_count = 4;

// Maximum diameter at each rib.
// This is probably the most useful dimension to tune after
// trying the first print.
rib_diameter = 11.1;

// Axial height of each rib
rib_height = 1.4;

// Distance between rib centers
rib_spacing = 4;

// Distance from shoulder to center of first rib
first_rib_height = 5.0;


// ---------- Foot ----------

arm_width = 20;

// Diameter of floor-contacting foot
foot_diameter = 26;

// Overall height of foot below metal arm
foot_height = 8;

// Thickness of flat shoulder immediately below arm
shoulder_height = 2.0;

// Diameter of shoulder.
// Slightly larger than arm width so it cannot enter the socket.
shoulder_diameter = 22;

// Round-over approximation at bottom edge
bottom_radius = 2.0;


// ---------- Model ----------

module rounded_foot()
{
    // A simple rotational profile gives a rounded lower edge
    // without Minkowski() making the model unnecessarily slow.

    rotate_extrude(convexity=10)
        polygon([
            [0, 0],
            [foot_diameter/2 - bottom_radius, 0],
            [foot_diameter/2 - bottom_radius/2, 0.3],
            [foot_diameter/2 - 0.15, bottom_radius],
            [foot_diameter/2, bottom_radius + 0.5],
            [foot_diameter/2, foot_height - shoulder_height],
            [shoulder_diameter/2, foot_height - shoulder_height],
            [shoulder_diameter/2, foot_height],
            [0, foot_height]
        ]);
}


module retaining_rib(z)
{
    // Symmetrical shallow bulge.
    // The TPU will compress as it enters the socket.

    translate([0,0,z-rib_height/2])
        cylinder(
            h=rib_height/2,
            d1=stem_diameter,
            d2=rib_diameter
        );

    translate([0,0,z])
        cylinder(
            h=rib_height/2,
            d1=rib_diameter,
            d2=stem_diameter
        );
}


module stem()
{
    difference()
    {
        union()
        {
            // Main stem, stopping before the tapered lead-in
            cylinder(
                h=stem_length-lead_in_length,
                d=stem_diameter
            );

            // Tapered insertion end
            translate([0,0,stem_length-lead_in_length])
                cylinder(
                    h=lead_in_length,
                    d1=stem_diameter,
                    d2=lead_in_diameter
                );

            // Retention ribs
            for (i=[0:rib_count-1])
                retaining_rib(
                    first_rib_height + i*rib_spacing
                );
        }

        // Central compliance hole.
        // It stops short of the bottom so the foot remains
        // completely closed against the floor.
        if (stem_hole_diameter > 0)
            translate([0,0,-0.01])
                cylinder(
                    h=stem_length+0.02,
                    d=stem_hole_diameter
                );
    }
}


module chair_foot()
{
    union()
    {
        rounded_foot();

        translate([0,0,foot_height])
            stem();
    }
}


chair_foot();
