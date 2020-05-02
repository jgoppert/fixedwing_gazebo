part = "all"; // which part to show
brown = [0.8, 0.7, 0.6, 0.5];  // color of cardboard
white = [1, 1, 1, 0.5];  // white posterboard
grey = [0.5, 0.5, 0.5, 0.5];  // grey color for tires/motor
orig_dir = "stl_orig/";
vscale = [0.001, 0.001, 0.001];
vrot = [0, 0, 0];
vtrans = [0, 0, 0];

for (p = ["fuselage"]) {
    if (part == p || part == "all") {
        color(brown)
        rotate(vrot) scale(vscale)
        translate([-1094, -450, -102.3])
        import(str(orig_dir, p, ".stl"));
    }
}

for (p = ["propeller"]) {
    if (part == p || part == "all") {
        color(grey)
        scale(vscale)
        translate([0, -11.2, -89])
        import(str(orig_dir, p, ".stl"));
    }
}

for (p = ["aileron_left"]) {
    if (p == part || part == "all") {
        color(white)
        rotate(vrot)
        scale(vscale)
        translate([-600, 0, -32])
        import(str(orig_dir, p, ".stl"));
    }
}

for (p = ["aileron_right"]) {
    if (p == part || part == "all") {
        color(white)
        rotate(vrot)
        scale(vscale)
        translate([-600, -450, -32])
        import(str(orig_dir, p, ".stl"));
    }
}
