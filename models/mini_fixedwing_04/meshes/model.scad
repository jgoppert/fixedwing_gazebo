part = "all"; // which part to show
brown = [0.8, 0.7, 0.6, 0.5];  // color of cardboard
white = [1, 1, 1, 0.5];  // white posterboard
grey = [0.5, 0.5, 0.5, 0.5];  // grey color for tires/motor
orig_dir = "stl_orig/";
vscale = [0.001, 0.001, 0.001];
vtrans = [0, 0, 0];
markers = true;

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

module cp() {
    color([1, 0, 0, 0.1])
    scale([0.01, 0.01, 0.03])
    sphere([1, 1, 1]);
}

module cm() {
    color([0, 1, 0, 0.5])
    scale([0.01, 0.01, 0.01])
    sphere([1, 1, 1]);
}

module joint() {
    color([0, 0, 1, 0.5])
    scale([0.02, 0.02, 0.02])
    cube([1, 1, 1], center=true);
}

if (part == "cp" || part == "all" && markers) {
    translate([-0.05, 0.175, 0.027]) cp(); // wing left
    translate([-0.05, -0.175, 0.027]) cp(); // wing right
    translate([-0.028, -0.15, 0.05]) cp(); // vtail left
    translate([-0.028, 0.15, 0.05]) cp(); // vtail right
}

if (part == "cm" || part == "all" && markers) {
    translate([0.1, 0, 0.01578]) scale([4, 4, 4]) cm(); // main
    translate([-0.148, 0.171, 0.01]) cm(); // aileron left
    translate([-0.148, -0.171, 0.01]) cm(); // aileron right
}

if (part == "joint" || part == "all" && markers) {
    translate([-0.125, 0.17, 0.007]) joint(); // aileron left
    translate([-0.125, -0.17, 0.007]) joint(); // aileron right
}
