part = "all"; // which part to show
brown = [0.8, 0.7, 0.6, 0.5];  // color of cardboard
white = [1, 1, 1, 0.5];  // white posterboard
grey = [0.5, 0.5, 0.5, 0.5];  // grey color for tires/motor
orig_dir = "stl_orig/";
vscale = [0.001, 0.001, 0.001];
vrot = [0, 0, 0];
vtrans = [0, 0, 0];

parts = ["fuselage",
    "elevator", "wheel_left", "wheel_right", "propeller", "rudder"];

for (p = ["fuselage"]) {
    if (p == part || part == "all") {
        color(brown)
        rotate(vrot) scale(vscale) translate(vtrans)
        import(str(orig_dir, p, ".stl"));
    }
}

for (p = ["elevator", "aileron_left", "aileron_right"]) {
    if (p == part || part == "all") {
        color(white)
        rotate(vrot) scale(vscale) translate(vtrans)
        import(str(orig_dir, p, ".stl"));
    }
}

for (p = ["rudder"]) {
    if (p == part || part == "all") {
        color(white)
        rotate(vrot) scale(vscale) translate(vtrans)
        import(str(orig_dir, p, ".stl"));
    }
}

for (p = ["propeller", "wheel_left"]) {
    if (p == part || part == "all") {
        color(grey)
        rotate(vrot) scale(vscale)
        import(str(orig_dir, p, ".stl"));
    }
}

for (p = ["wheel_right"]) {
    if (p == part || part == "all") {
        color(grey)
        rotate(vrot)
        translate([0, -0.17, 0])
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