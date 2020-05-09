part = "all"; // which part to show
brown = [0.8, 0.7, 0.6, 0.5];  // color of cardboard
white = [1, 1, 1, 0.5];  // white posterboard
grey = [0.5, 0.5, 0.5, 0.5];  // grey color for tires/motor
orig_dir = "stl_orig/";
vscale = [0.001, 0.001, 0.001];
vrot = [0, 0, 0];
vtrans = [0, 0, 0];
markers = true;

parts = ["fuselage",
    "elevator", "wheel_left", "wheel_right", "propeller", "rudder"];

for (p = ["fuselage"]) {
    if (p == part || part == "all") {
        color(brown)
        rotate(vrot) scale(vscale) translate(vtrans)
        import(str(orig_dir, p, ".stl"));
    }
}

for (p = ["rudder", "elevator"]) {
    if (p == part || part == "all") {
        color(white)
        rotate(vrot) scale(vscale) translate(vtrans)
        import(str(orig_dir, p, ".stl"));
    }
}

for (p = ["propeller", "wheel_left"]) {
    if (p == part || part == "all") {
        color(grey)
        rotate(vrot) scale(vscale)
        import(str(orig_dir, p, ".stl"));
    }
}

for (p = ["wheel_right"]) {
    if (p == part || part == "all") {
        color(grey)
        rotate(vrot)
        translate([0, -0.17, 0])
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
    translate([-0.14, 0.2, 0.02]) cp(); // wing left
    translate([-0.14, -0.2, 0.02]) cp(); // wing right
    translate([-0.5, 0, 0]) cp();  // htail
    translate([-0.49, 0, 0.05]) cp(); // vtail
}

if (part == "cm" || part == "all" && markers) {
    translate([-0.131, 0, 0]) scale([6, 6, 6]) cm(); // main
    translate([-0.565, 0, 0]) cm();  // elevator
    translate([-0.535, 0, 0.07]) cm(); // rudder
}

if (part == "joint" || part == "all" && markers) {
    translate([-0.114, 0.085, -0.081]) joint(); // wheel left
    translate([-0.114, -0.085, -0.081]) joint(); // wheel right
    translate([-0.547, 0, 0]) joint();  // elevator
    translate([-0.515, 0, 0.07]) joint(); // rudder
}


// current exported files
if (part == "export") {
    for (p = parts) {
        import(str("stl/", p, ".stl"));
    }
}