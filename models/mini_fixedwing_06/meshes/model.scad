part = "all"; // which part to show
brown = [0.8, 0.7, 0.6, 0.5];  // color of cardboard
white = [1, 1, 1, 0.5];  // white posterboard
grey = [0.5, 0.5, 0.5, 0.5];  // grey color for tires/motor
orig_dir = "stl_orig/";
vscale = [0.0254, 0.0254, 0.0254];
    vtrans = [0, 0, 0.024];
vrot = [0, 0, 0];
markers = true;

parts = ["fuselage", "aileron_left", "aileron_right",
    "elevator", "wheel_left", "wheel_right", "propeller", "rudder"];
    
for (p = ["fuselage"]) {
    if (p == part || part == "all") {
        color(brown)
        translate(vtrans) scale(vscale) rotate(vrot)
        import(str(orig_dir, p, ".stl"));
    }
}

for (p = ["aileron_left", "aileron_right", "elevator", "rudder"]) {
    if (p == part || part == "all") {
        color(white)
        translate(vtrans)  scale(vscale) rotate(vrot)
        import(str(orig_dir, p, ".stl"));
    }
}

for (p = ["propeller", "wheel_left", "wheel_right"]) {
    if (p == part || part == "all") {
        color(grey)
        translate(vtrans)  scale(vscale) rotate(vrot)
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
    translate([-0.3, 0.2, 0.02]) cp(); // wing left
    translate([-0.3, -0.2, 0.02]) cp(); // wing right
    translate([-0.83, 0, -0.02]) cp();  // htail
    translate([-0.83, 0, 0.02]) cp(); // vtail
}

if (part == "cm" || part == "all" && markers) {
    translate([-0.302, 0, -0.01]) scale([6, 6, 6]) cm(); // main
    translate([-0.36, 0.25, 0.01]) rotate([0, 4, 0]) cm(); // aileron left
    translate([-0.36, -0.25, 0.01]) rotate([0, 4, 0]) cm(); // aileron right
    translate([-0.865, 0, -0.02]) cm();  // elevator
    translate([-0.85, 0, 0.023]) cm(); // rudder
}

if (part == "joint" || part == "all" && markers) {
    translate([-0.178, 0.049, -0.09]) joint(); // wheel left
    translate([-0.178, -0.049, -0.09]) joint(); // wheel right
    translate([-0.31, 0.25, 0.01]) joint(); // aileron left
    translate([-0.31, -0.25, 0.01]) joint(); // aileron right
    translate([-0.85, 0, -0.02]) joint();  // elevator
    translate([-0.83, 0, 0.023]) joint(); // rudder
    translate([0.02, 0, 0]) joint(); // prop
}

// current exported files
if (part == "export") {
    for (p = parts) {
        import(str("stl/", p, ".stl"));
    }
}