part = "all"; // which part to show
brown = [0.8, 0.7, 0.6, 0.5];  // color of cardboard
white = [1, 1, 1, 0.5];  // white posterboard
grey = [0.5, 0.5, 0.5, 0.5];  // grey color for tires/motor
orig_dir = "stl_orig/";
vscale = [0.001, 0.001, 0.001];
vtrans = [-0.097, 0.3076, -0.61777];
markers = true;

parts = ["fuselage", "aileron_left", "aileron_right",
    "elevator", "rudder", "wheel_left", "wheel_right", "propeller"];

for (p = ["fuselage"]) {
    if (p == part || part == "all") {
        color(brown)
        translate(vtrans)
        scale(vscale) 
        import(str(orig_dir, p, ".stl"));
    }
}

for (p = ["elevator"]) {
    if (p == part || part == "all") {
        color(white)
        translate([-0.6148, -0.1591, 0])
        translate(vtrans)
        scale(vscale)
        import(str(orig_dir, p, ".stl"));
    }
}

for (p = ["rudder"]) {
    if (p == part || part == "all") {
        color(white)
        translate([-0.579, -0.308, 0])
        translate(vtrans)
        scale(vscale)
        import(str(orig_dir, p, ".stl"));
    }
}

module aileron() {
    color(white)
    translate([-0.1953, 0, 0])
    translate(vtrans)
    scale(vscale)
    import(str(orig_dir, "aileron.stl"));
}

for (p = ["aileron_left"]) {
    if (p == part || part == "all") {
        aileron();
    }
}

for (p = ["aileron_right"]) {
    if (p == part || part == "all") {
        mirror([0, 1, 0]) aileron();
    }
}

module wheel() {
    color(grey)
    translate([0, -0.3076, 0])
    translate(vtrans)
    scale(vscale)
    import(str(orig_dir, "wheel.stl"));
}

for (p = ["wheel_left"]) {
    if (p == part || part == "all") {
        translate([-0.01, 0.065, 0]) wheel();
    }
}

for (p = ["wheel_right"]) {
    if (p == part || part == "all") {
        translate([-0.01, -0.065, 0]) wheel();
    }
}

for (p = ["propeller"]) {
    if (p == part || part == "all") {
        color(grey)
        translate([-0.01, -0.2223, -0.0007])
        translate(vtrans)
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
    translate([-0.2, 0.15, -0.02]) cp(); // wing left
    translate([-0.2, -0.15, -0.02]) cp(); // wing right
    translate([-0.68, 0, -0.0358]) cp();  // htail
    translate([-0.64, 0, 0.05]) cp(); // vtail
}

if (part == "cm" || part == "all" && markers) {
    translate([-0.184, 0, -0.01]) scale([6, 6, 6]) cm(); // main
    translate([-0.315, 0.22, -0.02]) cm(); // aileron left
    translate([-0.315, -0.22, -0.02]) cm(); // aileron right
    translate([-0.725, 0, -0.035]) cm();  // elevator
    translate([-0.69, 0, 0.0467]) cm(); // rudder
}

if (part == "joint" || part == "all" && markers) {
    translate([-0.1319, 0.064, -0.0974]) joint(); // wheel left
    translate([-0.1319, -0.064, -0.0974]) joint(); // wheel right
    translate([-0.29, 0.22, -0.02]) rotate([3, 0, 0]) joint(); // aileron left
    translate([-0.29, -0.22, -0.02]) rotate([-3, 0, 0]) joint(); // aileron right
    translate([-0.705, 0, -0.035]) joint();  // elevator
    translate([-0.67, 0, 0.0467]) joint(); // rudder
}

// current exported files
if (part == "export") {
    for (p = parts) {
        import(str("stl/", p, ".stl"));
    }
}
