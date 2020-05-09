part = "all"; // which part to show
brown = [0.8, 0.7, 0.6, 0.5];  // color of cardboard
white = [1, 1, 1, 0.5];  // white posterboard
grey = [0.5, 0.5, 0.5, 0.5];  // grey color for tires/motor
orig_dir = "stl_orig/";
vscale = [0.001, 0.001, 0.001];
vrot = [0, 0, 0];
vtrans = [0, 0, 0];
markers = true;

parts = ["fuselage", "aileron_left", "aileron_right",
    "elevator", "propeller"];

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

for (p = ["elevator"]) {
    if (p == part || part == "all") {
        color(white)
        rotate(vrot)
        translate([-1.044, -0.2, -0.0228])
        scale(vscale)
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
    translate([-0.391, 0.21, 0]) cp(); // wing left
    translate([-0.391, -0.21, 0]) cp(); // wing right
    translate([-0.94, 0, -0.02]) cp();  // htail
    translate([-0.96, 0, 0.05]) cp(); // vtail
}

if (part == "cm" || part == "all" && markers) {
    translate([-0.35, 0, -0.013]) scale([6, 6, 6]) cm(); // main
    translate([-0.565, -0.23, -0.02]) cm(); // aileron left
    translate([-0.565, 0.23, -0.02]) cm(); // aileron right
    translate([-1.02, 0, -0.02]) cm();  // elevator
}

if (part == "joint" || part == "all" && markers) {
    translate([-0.525, -0.23, -0.015]) joint(); // aileron left
    translate([-0.525, 0.23, -0.015]) joint(); // aileron right
    translate([-0.99, 0, -0.02]) joint();  // elevator
}

// current exported files
if (part == "export") {
    for (p = parts) {
        import(str("stl/", p, ".stl"));
    }
}