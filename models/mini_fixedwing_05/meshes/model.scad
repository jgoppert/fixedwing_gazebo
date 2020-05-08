part = "all"; // which part to show
brown = [0.8, 0.7, 0.6, 0.5];  // color of cardboard
white = [1, 1, 1, 0.5];  // white posterboard
grey = [0.5, 0.5, 0.5, 0.5];  // grey color for tires/motor
orig_dir = "stl_orig/";
vscale = [0.0254, 0.0254, 0.0254];
vtrans = [0, 0, 0];
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

for (p = ["propeller", "wheel_left", "wheel_right"]) {
    if (p == part || part == "all") {
        color(grey)
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
    translate([-0.1705, 0.239, -0.019]) cp(); // wing left
    translate([-0.1705, -0.239, -0.019]) cp(); // wing right
    translate([-0.6, 0, -0.024]) cp();  // htail
    translate([-0.6, 0, 0.058]) cp(); // vtail
}

if (part == "cm" || part == "all" && markers) {
    translate([-0.156, 0, 0.008]) scale([5, 5, 5]) cm(); // main
    translate([-0.304, 0.239, -0.020]) cm(); // aileron left
    translate([-0.304, -0.239, -0.020]) cm(); // aileron right
    translate([-0.640, 0, -0.024]) cm();  // elevator
    translate([-0.639, 0, 0.067]) cm(); // rudder
}

if (part == "joint" || part == "all" && markers) {
    translate([-0.112, 0.087, -0.074]) joint(); // wheel left
    translate([-0.112, -0.087, -0.074]) joint(); // wheel right
    translate([-0.266, 0.239, -0.019]) rotate([2, 0, 0]) joint(); // aileron left
    translate([-0.266, -0.239, -0.019]) rotate([-2, 0, 0]) joint(); // aileron right
    translate([-0.606, 0, -0.024]) joint();  // elevator
    translate([-0.606, 0, 0.058]) joint(); // rudder
}


// current exported files
if (part == "export") {
    for (p = parts) {
        import(str("stl/", p, ".stl"));
    }
}