part = "all"; // which part to show
brown = [0.8, 0.7, 0.6, 0.5];  // color of cardboard
white = [1, 1, 1, 0.5];  // white posterboard
grey = [0.5, 0.5, 0.5, 0.5];  // grey color for tires/motor
orig_dir = "stl_orig/";
vscale = [1, 1, 1];
vtrans = [0, 0, 0];

parts = ["fuselage", "aileron_left", "aileron_right",
    "elevator", "wheel_left", "wheel_right", "propeller", "rudder"];
    
for (p = ["fuselage"]) {
    if (p == part || part == "all") {
        color(brown)
        scale(vscale) translate(vtrans)
        import(str(orig_dir, p, ".stl"));
    }
}

module aileron() {
    color(white)
    translate([-0.08, 0.321, -0.017])
    rotate([-10, -10, 92])
    scale(vscale) translate(vtrans)
    import(str(orig_dir, "aileron_left.stl"));
}

for (p = ["aileron_left"]) {
    if (p == part || part == "all") {
        aileron();
    }
}

for (p = ["aileron_right"]) {
    if (p == part || part == "all") {
        mirror([0, 1, 0]) aileron();
    }
}

for (p = ["rudder"]) {
    if (p == part || part == "all") {
        translate([-0.3866, 0, 0.012])
        rotate([0, 0, 180])
        color(white)
        scale(vscale) translate(vtrans)
        import(str(orig_dir, p, ".stl"));
    }
}

for (p = ["elevator"]) {
    if (p == part || part == "all") {
        color(white)
        translate([-0.3866, 0, 0.012])
        rotate([0, 180, 0])
        scale(vscale) translate(vtrans)
        import(str(orig_dir, p, ".stl"));
    }
}

module wheel() {
    color(grey)
    translate([0, -0.0005, 0])
    import(str(orig_dir, "wheel.stl"));
}

for (p = ["wheel_left"]) {
    if (p == part || part == "all") {
        color(grey)
        translate([0.183, 0.06, -0.1035])
        scale(vscale) translate(vtrans) wheel();
    }
}

for (p = ["wheel_right"]) {
    if (p == part || part == "all") {
        color(grey)
        translate([0.183, -0.06, -0.1035])
        scale(vscale) translate(vtrans) wheel();
    }
}


for (p = ["propeller"]) {
    if (p == part || part == "all") {
        color(grey)
        translate([0.22, 0, 0])
        rotate([0, 90, 0])
        scale(vscale)
        import(str(orig_dir, p, ".stl"));
    }
}

// current exported files
if (part == "export") {
    for (p = parts) {
        import(str("stl/", p, ".stl"));
    }
}