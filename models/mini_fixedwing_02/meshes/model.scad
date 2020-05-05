$fn = 10;
part = "all"; // which part to show
brown = [0.8, 0.7, 0.6, 1];  // color of cardboard
white = [1, 1, 1, 1];  // white posterboard
grey = [0.5, 0.5, 0.5, 1];  // grey color for tires/motor
orig_dir = "stl_orig/";
vscale = [0.0254, 0.0254, 0.0254];
vtrans = [0, 0, 0];
markers = true;

parts = ["fuselage", "aileron_left", "aileron_right",
    "elevator", "rudder", "wheel_left", "wheel_right", "propeller"];

if (part == "fuselage" || part == "all") {
    color(brown)
    translate(vtrans) scale(vscale) 
    import(str(orig_dir, "fuselage.stl"));
}

if (part == "aileron_left" || part == "all") {
    color(white)
    translate([-0.077, 0, 0.026])
    rotate([0, 0, 90])
    translate(vtrans) scale(vscale) 
    import(str(orig_dir, "aileron_left.stl"));
}

if (part == "aileron_right" || part == "all") {
    color(white)
    translate([-0.077, 0, 0.026])
    rotate([0, 0, 90])
    translate(vtrans) scale(vscale) 
    import(str(orig_dir, "aileron_right.stl"));
}

if (part == "elevator" || part == "all") {
    color(white)
    translate([-0.366, 0, 0.03])
    rotate([0, 0, 90])
    translate(vtrans) scale(vscale) 
    import(str(orig_dir, "elevator.stl"));
}

if (part == "rudder" || part == "all") {
    color(white)
    translate([-0.33, 0, 0.0175])
    rotate([0, 0, 90])
    translate(vtrans) scale(vscale) 
    import(str(orig_dir, "rudder.stl"));
}

if (part == "propeller" || part == "all") {
    if (part == "all") {
        translate([0.01, 0, 0.0173])
        color("grey") import(str(orig_dir, "propeller.stl"));
    } else {
        color("grey") import(str(orig_dir, "propeller.stl"));
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
    translate([-0.12, 0.2, 0.03]) cp(); // wing left
    translate([-0.12, -0.2, 0.03]) cp(); // wing right
    translate([-0.41, 0, 0.03]) cp();  // htail
    translate([-0.39, 0, 0.08]) cp(); // vtail
}

if (part == "cm" || part == "all" && markers) {
    translate([-0.1, 0, 0.0173]) scale([3, 3, 3]) cm(); // main
    translate([-0.165, 0.23, 0.03]) cm(); // wing left
    translate([-0.165, -0.23, 0.03]) cm(); // wing right
    translate([-0.44, 0, 0.035]) cm();  // elevator
    translate([-0.418, 0, 0.08]) cm(); // rudder
}

if (part == "joint" || part == "all" && markers) {
    translate([-0.073, 0.066, -0.039]) joint(); // left wheel
    translate([-0.073, -0.066, -0.039]) joint(); // right wheel
    translate([-0.15, 0.23, 0.03]) joint(); // left wing
    translate([-0.15, -0.23, 0.03]) joint(); // right wing
    translate([-0.43, 0, 0.035]) joint();  // elevator
    translate([-0.405, 0, 0.08]) joint(); // rudder
}

module wheel() {
    color(brown)
    translate([0, -0.0025, 0])
    translate(vtrans) scale(vscale) 
    import(str(orig_dir, "wheel_right.stl"));
}

if (part == "wheel_left" || part == "all") {
    translate([-0.073, 0.066, -0.04]) wheel();
}

if (part == "wheel_right" || part == "all") {
    translate([-0.073, -0.066, -0.04]) wheel();
}


// current exported files
if (part == "export") {
    for (p = parts) {
        import(str("stl/", p, ".stl"));
    }
}