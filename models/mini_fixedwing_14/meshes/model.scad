part = "all"; // which part to show
brown = [0.8, 0.7, 0.6, 0.5];  // color of cardboard
white = [1, 1, 1, 0.5];  // white posterboard
grey = [0.5, 0.5, 0.5, 0.5];  // grey color for tires/motor
orig_dir = "stl_orig/";
vscale = [0.01, 0.01, 0.01];
vrot = [0, 0, 0];
vtrans = [-0.695, 0, 0.016];
markers = true;

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
    translate([-0.14, 0.2286, 0.03]) cp(); // wing left
    translate([-0.14, -0.2286, 0.03]) cp(); // wing right
    translate([-0.67, 0, 0.02]) cp();  // htail
    translate([-0.67, 0, 0.06]) cp(); // vtail
}

if (part == "cm" || part == "all" && markers) {
    translate([-0.13, 0, -0.014]) scale([6, 6, 6]) cm(); // main
    translate([-0.165, 0.23, 0.03]) cm(); // aileron left
    translate([-0.165, -0.23, 0.03]) cm(); // aileron right
    translate([-0.72, 0, 0.02]) cm();  // elevator
    translate([-0.72, 0, 0.07]) cm(); // rudder
}

if (part == "joint" || part == "all" && markers) {
    translate([-0.105, 0.0667, -0.09]) joint(); // wheel left
    translate([-0.105, -0.0667, -0.09]) joint(); // wheel right
    translate([-0.2, 0.17, 0.035]) rotate([5, 0, 0]) joint(); // aileron left
    translate([-0.2, -0.17, 0.035]) rotate([-5, 0, 0]) joint(); // aileron right
    translate([-0.7, 0, 0.02]) joint();  // elevator
    translate([-0.7, 0, 0.07]) joint(); // rudder
}

// current exported files
if (part == "export") {
    for (p = parts) {
        import(str("stl/", p, ".stl"));
    }
}