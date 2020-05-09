part = "all"; // which part to show
brown = [0.8, 0.7, 0.6, 0.5];  // color of cardboard
white = [1, 1, 1, 0.5];  // white posterboard
grey = [0.5, 0.5, 0.5, 0.5];  // grey color for tires/motor
orig_dir = "stl_orig/";
vscale = [0.001, 0.001, 0.001];
vtrans = [-2000, -2000, -2000];
markers = true;

parts = ["fuselage", "aileron_left", "aileron_right",
    "elevator", "wheel_left", "wheel_right", "propeller", "rudder"];

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
    translate([-0.42, 0.27, 0]) cp(); // wing left
    translate([-0.42, -0.27, 0]) cp(); // wing right
    translate([-0.41, 0, 0.03]) cp();  // htail
    translate([-0.93, 0, 0.08]) cp(); // vtail
}

if (part == "cm" || part == "all" && markers) {
    translate([-0.417, 0, 0.0175]) scale([6, 6, 6]) cm(); // main
    translate([-0.60, 0.3275, -0.005]) cm(); // aileron left
    translate([-0.60, -0.3275, -0.005]) cm(); // aileron right
    translate([-0.995, 0, 0.04]) cm();  // elevator
    translate([-0.982, 0, 0.1]) cm(); // rudder
}

if (part == "joint" || part == "all" && markers) {
    translate([-0.56, 0.3275, 0.005]) joint(); // aileron left
    translate([-0.56, -0.3275, 0.005]) joint(); // aileron right
    translate([-0.97, 0, 0.04]) joint();  // elevator
    translate([-0.952, 0, 0.1]) joint(); // rudder
}

// current exported files
if (part == "export") {
    for (p = parts) {
        import(str("stl/", p, ".stl"));
    }
}