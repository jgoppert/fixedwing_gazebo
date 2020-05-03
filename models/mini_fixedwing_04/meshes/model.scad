part = "all"; // which part to show
brown = [0.8, 0.7, 0.6, 1];  // color of cardboard
white = [1, 1, 1, 1];  // white posterboard
grey = [0.5, 0.5, 0.5, 1];  // grey color for tires/motor
orig_dir = "stl_orig/";
vscale = [0.001, 0.001, 0.001];
vtrans = [0, 0, 0];

parts = ["fuselage", "aileron_left", "aileron_right",
    "propeller_left", "propeller_right"];

if (part == "fuselage" || part == "all") {
    color(brown)
    scale(vscale)
    import(str(orig_dir, "fuselage.stl"));
}

if (part == "aileron_left" || part == "all") {
    color(white)
    scale(vscale)
    import(str(orig_dir, "aileron_left.stl"));
}

if (part == "aileron_right" || part == "all") {
    color(white)
    scale(vscale)
    import(str(orig_dir, "aileron_right.stl"));
}

if (part == "propeller_left" || part == "all") {
    color("grey")
    scale(vscale)
    import(str(orig_dir, "propeller_left.stl"));
}

if (part == "propeller_right" || part == "all") {
    color("grey") 
    scale(vscale)
    import(str(orig_dir, "propeller_right.stl"));
}

// current exported files
if (part == "export") {
    for (p = parts) {
        import(str("stl/", p, ".stl"));
    }
}