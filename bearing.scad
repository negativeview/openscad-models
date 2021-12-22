include <MCAD/involute_gears.scad>

$fa = 1;
$fs = 0.1;

padding_amount = 0.001;

middle_shaft_length = 40;
bearing_height = 7;
bearing_inner_diameter = 8;
bearing_outer_diameter = 22;
bearing_inner_diameter_comp = 0.25;
bearing_sheath_diameter = 1;
gearing_height = 9;
screw_hole_size = 2.9;

module bearing(height = 7, inner_diameter = 8, outer_diameter = 22, sheath_diameter = 2) {
    sheath_depth = 1;

    difference() {
        cylinder(h = height, r = outer_diameter / 2, center = true);
        cylinder(h = height + 0.001, r = inner_diameter / 2, center = true);
        
        difference() {
            translate([0, 0, height - sheath_depth])
                cylinder(h = height + 0.001, d = outer_diameter - sheath_diameter, center = true);
            cylinder(h = height + 0.001, d = inner_diameter + sheath_diameter, center = true);
        }
        
        difference() {
            translate([0, 0, -height + sheath_depth])
                cylinder(h = height + 0.001, d = outer_diameter - sheath_diameter, center = true);
            cylinder(h = height + 0.001, d = inner_diameter + sheath_diameter, center = true);
        }
    }
}

module bearing_shaft(
    middle_shaft_length,
    bearing_height,
    bearing_inner_diameter,
    bearing_sheath_diameter
) {
    edge_length = 1;

    union() {
        difference() {
            union() {
                // Center bar
                cylinder(h = middle_shaft_length + bearing_height + bearing_height, d = bearing_inner_diameter + bearing_inner_diameter_comp, center = true);

                // Middle bar that is slightly thicker
                cylinder(h = middle_shaft_length - edge_length - edge_length, d = bearing_inner_diameter + bearing_inner_diameter_comp + bearing_sheath_diameter, center = true);

                // Bevel A
                translate([0, 0, (middle_shaft_length - edge_length) / 2])
                    cylinder(h = edge_length, d1 = bearing_inner_diameter + bearing_inner_diameter_comp + bearing_sheath_diameter, d2 = bearing_inner_diameter + bearing_inner_diameter_comp, center = true);
                
                // Bevel B
                translate([0, 0, -(middle_shaft_length - edge_length) / 2])
                    cylinder(h = edge_length, d2 = bearing_inner_diameter + bearing_inner_diameter_comp + bearing_sheath_diameter, d1 = bearing_inner_diameter + bearing_inner_diameter_comp, center = true);
            }

            // Central screw hole
            cylinder(h = middle_shaft_length + bearing_height + bearing_height + padding_amount, d = screw_hole_size, center = true);

            cylinder(h = gearing_height, d = bearing_inner_diameter + bearing_inner_diameter_comp + bearing_sheath_diameter + padding_amount, center = true);
            translate([0, 0, (gearing_height / 2) + (middle_shaft_length - gearing_height) / 4])
                rotate([0, 90, 0])
                    cylinder(h = bearing_outer_diameter, d = screw_hole_size, center = true);
            translate([0, 0, -((gearing_height / 2) + (middle_shaft_length - gearing_height) / 4)])
                rotate([0, 90, 0])
                    cylinder(h = bearing_outer_diameter, d = screw_hole_size, center = true);

        }

        translate([0, 0, -(gearing_height / 2)])
            gear(
                number_of_teeth = 15,
                circular_pitch = 90,
                rim_thickness = gearing_height,
                rim_width = 0,
                hub_thickness = 0,
                bore_diameter = 0,
                gear_thickness = gearing_height
            );
    }
}

module bearing_cap(height = 2) {
    difference() {
        cylinder(h = height, d = bearing_inner_diameter + bearing_inner_diameter_comp + bearing_sheath_diameter, center = true);
        cylinder(h = height + padding_amount, d = screw_hole_size, center = true);
    }
}

module hub() {
    hub_height = 10;
    hub_excess = 5;
    hub_arm_length = 50;

    difference() {
        union() {
            cylinder(h = hub_height, d = bearing_outer_diameter + hub_excess, center = true);
            translate([0, -hub_arm_length / 2, 0])
                cube([bearing_outer_diameter + hub_excess, hub_arm_length, 10], center = true);
        }
        translate([0, 0, -(hub_height - bearing_height + padding_amount)])
            cylinder(h = bearing_height, d = bearing_outer_diameter, center = true);
        translate([0, 0, hub_height - bearing_height + padding_amount])
            cylinder(h = hub_height, d = bearing_outer_diameter - bearing_sheath_diameter, center = true);
    }
    rotate([0, 0, -45])
        translate([bearing_outer_diameter + hub_excess, -hub_arm_length / 2, 0])
            cube([bearing_outer_diameter + hub_excess, hub_arm_length, 12], center = true);

}

translate([0, 0, ((middle_shaft_length + bearing_height) / 2)])
    bearing(height = bearing_height, outer_diameter = bearing_outer_diameter, sheath_diameter = bearing_sheath_diameter);
// translate([0, 0, -((middle_shaft_length + bearing_height) / 2)])
//     bearing(height = bearing_height, outer_diameter = bearing_outer_diameter, sheath_diameter = bearing_sheath_diameter);

bearing_shaft(middle_shaft_length, bearing_height, bearing_inner_diameter, bearing_sheath_diameter);

translate([0, 0, (middle_shaft_length + bearing_height + bearing_height) / 2])
    bearing_cap();

// translate([0, 0, -14])
//     bearing_cap();

translate([0, 0, ((middle_shaft_length + bearing_height) / 2)])
    hub();