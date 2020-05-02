part = "all"; // which part to show
brown = [0.8, 0.7, 0.6, 0.5];  // color of cardboard
white = [1, 1, 1, 0.5];  // white posterboard
grey = [0.5, 0.5, 0.5, 0.5];  // grey color for tires/motor
orig_dir = "stl_orig/";
vscale = [0.001, 0.001, 0.001];
vtrans = [-2000, -2000, -2000];

for (p = ["fuselage"]) {
    if (p == part || part == "all") {
        color(brown)
        scale(vscale) translate(vtrans)
        import(str(orig_dir, p, ".stl"));
    }
}

for (p = ["aileron_left", "aileron_right", "elevator", "rudder"]) {
    if (p == part || part == "all") {
        color(white)
        scale(vscale) translate(vtrans)
        import(str(orig_dir, p, ".stl"));
    }
}

for (p = ["propeller"]) {
    if (p == part || part == "all") {
        color(grey)
        scale(vscale)
        translate([20, -6, -57])
        import(str(orig_dir, p, ".stl"));
    }
}