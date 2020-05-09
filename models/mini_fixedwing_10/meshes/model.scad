part = "all"; // which part to show
brown = [0.8, 0.7, 0.6, 0.5];  // color of cardboard
white = [1, 1, 1, 0.5];  // white posterboard
grey = [0.5, 0.5, 0.5, 0.5];  // grey color for tires/motor
orig_dir = "stl_orig/";
vscale = [0.001, 0.001, 0.001];
markers = true;

parts = ["fuselage", "aileron_left", "aileron_right",
    "elevator", "wheel_left", "wheel_right", "propeller", "rudder"];

for (p = ["fuselage"]) {
    if (p == part || part == "all") {
        color(brown)
        scale(vscale)
        import(str(orig_dir, p, ".stl"));
    }
}

for (p = ["aileron_left"]) {
    if (p == part || part == "all") {
        color(white)
        translate([-0.216, 0.190, -0.025])
        rotate([5, -3, 0])
        scale(vscale)
        import(str(orig_dir, "aileron.stl"));
    }
}

for (p = ["aileron_right"]) {
    if (p == part || part == "all") {
        color(white)
        translate([-0.216, -0.190, -0.025])
        rotate([-5, -3, 0])
        scale(vscale)
        import(str(orig_dir, "aileron.stl"));
    }
}

for (p = ["elevator"]) {
    if (p == part || part == "all") {
        color(white)
        translate([-0.482, 0, -0.002782])
        scale(vscale)
        import(str(orig_dir, p, ".stl"));
    }
}

for (p = ["rudder"]) {
    if (p == part || part == "all") {
        color(white)
        translate([-0.478, -0.0025, -0.002782])
        scale(vscale)
        import(str(orig_dir, p, ".stl"));
    }
}

for (p = ["wheel_left"]) {
    if (p == part || part == "all") {
        color(grey)
        translate([-0.1055, 0.028, -0.093])
        scale(vscale)
        import(str(orig_dir, "wheel.stl"));
    }
}

for (p = ["wheel_right"]) {
    if (p == part || part == "all") {
        color(grey)
        translate([-0.1055, -0.044, -0.093])
        scale(vscale)
        import(str(orig_dir, "wheel.stl"));
    }
}

for (p = ["propeller"]) {
    if (p == part || part == "all") {
        color(grey)
        translate([0.0067, 0, -0.01997])
        scale(vscale)
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
    translate([-0.15, 0.25, -0.02]) cp(); // wing left
    translate([-0.15, -0.25, -0.02]) cp(); // wing right
    translate([-0.44, 0, -0.005]) cp();  // htail
    translate([-0.44, 0, 0.04]) cp(); // vtail
}

if (part == "cm" || part == "all" && markers) {
    translate([-0.144, 0, -0.02]) scale([3, 3, 3]) cm(); // main
    translate([-0.24, 0.189, -0.03]) cm(); // aileron left
    translate([-0.24, -0.189, -0.03]) cm(); // aileron right
    translate([-0.5, 0, -0.005]) cm();  // elevator
    translate([-0.495, 0, 0.05]) cm(); // rudder
}

if (part == "joint" || part == "all" && markers) {
    translate([-0.105, 0.035, -0.09]) joint(); // wheel left
    translate([-0.105, -0.035, -0.09]) joint(); // wheel right
    translate([-0.216, 0.189, -0.025]) joint(); // aileron left
    translate([-0.216, -0.189, -0.025]) joint(); // aileron right
    translate([-0.48, 0, -0.005]) joint();  // elevator
    translate([-0.48, 0, 0.05]) joint(); // rudder
}

// current exported files
if (part == "export") {
    for (p = parts) {
        import(str("stl/", p, ".stl"));
    }
}