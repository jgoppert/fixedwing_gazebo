part = "all"; // which part to show
brown = [0.8, 0.7, 0.6, 0.5];  // color of cardboard
white = [1, 1, 1, 0.5];  // white posterboard
grey = [0.5, 0.5, 0.5, 0.5];  // grey color for tires/motor
orig_dir = "stl_orig/";
vscale = [0.001, 0.001, 0.001];
vrot = [0, 0, 0];
vtrans = [0, 0, -0.6];

for (p = ["fuselage"]) {
    if (p == part || part == "all") {
        color(brown)
        rotate(vrot) scale(vscale) 
        import(str(orig_dir, p, ".stl"));
    }
}

for (p = ["elevator", "rudder"]) {
    if (p == part || part == "all") {
        color(white)
        rotate(vrot) scale(vscale) translate(vtrans)
        import(str(orig_dir, p, ".stl"));
    }
}

for (p = ["aileron_left"]) {
    if (p == part || part == "all") {
        color(white)
        rotate(vrot) scale(vscale) translate(vtrans)
        import(str(orig_dir, "aileron.stl"));
    }
}

for (p = ["wheel_left"]) {
    if (p == part || part == "all") {
        color(white)
        rotate(vrot) scale(vscale) translate(vtrans)
        import(str(orig_dir, "wheel.stl"));
    }
}

for (p = ["propeller"]) {
    if (p == part || part == "all") {
        color(grey)
        rotate(vrot) scale(vscale)
        import(str(orig_dir, p, ".stl"));
    }
}
