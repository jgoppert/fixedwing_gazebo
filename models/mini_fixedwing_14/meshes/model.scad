part = "all"; // which part to show
brown = [0.8, 0.7, 0.6, 0.5];  // color of cardboard
white = [1, 1, 1, 0.5];  // white posterboard
grey = [0.5, 0.5, 0.5, 0.5];  // grey color for tires/motor
orig_dir = "stl_orig/";
vscale = [0.01, 0.01, 0.01];
vrot = [0, 0, 0];
vtrans = [-0.695, 0, 0.016];

parts = ["fuselage", "aileron_left", "aileron_right",
    "elevator", "wheel_left", "wheel_right", "propeller", "rudder"];

for (p = ["fuselage"]) {
    if (p == part || part == "all") {
        color(brown)
        rotate(vrot) translate(vtrans) scale(vscale)
        import(str(orig_dir, p, ".stl"));
    }
}

for (p = ["aileron_left", "aileron_right", "rudder"]) {
    if (p == part || part == "all") {
        color(white)
        rotate(vrot) translate(vtrans) scale(vscale)
        import(str(orig_dir, p, ".stl"));
    }
}

for (p = ["wheel_left", "wheel_right"]) {
    if (p == part || part == "all") {
        color(grey)
        rotate(vrot) translate(vtrans) scale(vscale)
        import(str(orig_dir, p, ".stl"));
    }
}

for (p = ["propeller"]) {
    if (p == part || part == "all") {
        color(white)
        translate([-0.696, 0, 0.016])
        scale([0.0255, 0.0254, 0.0254])
        import(str(orig_dir, p, ".stl"));
    }
}

for (p = ["elevator"]) {
    if (p == part || part == "all") {
        color(white)
        translate([-0.721, 0, 0.019])
        cube([0.05, 0.292, 0.005], center=true);
    }
}

// current exported files
if (part == "export") {
    for (p = parts) {
        import(str("stl/", p, ".stl"));
    }
}