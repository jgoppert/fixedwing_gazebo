part = "all"; // which part to show
brown = [0.8, 0.7, 0.6, 1];  // color of cardboard
white = [1, 1, 1, 1];  // white posterboard
grey = [0.5, 0.5, 0.5, 1];  // grey color for tires/motor
orig_dir = "stl_orig/";
vscale = [0.0254, 0.0254, 0.0254];
vtrans = [0, 0, 0];

parts = ["fuselage", "aileron_left", "aileron_right",
    "elevator", "rudder", "wheel_left", "wheel_right", "propeller"];

if (part == "fuselage" || part == "all") {
    color(brown)
    scale(vscale)
    import(str(orig_dir, "fuselage.stl"));
}

if (part == "aileron_left" || part == "all") {
    color(white)
    translate([-0.077, 0, 0.026])
    rotate([0, 0, 90])
    scale(vscale)
    import(str(orig_dir, "aileron_left.stl"));
}

if (part == "aileron_right" || part == "all") {
    color(white)
    translate([-0.077, 0, 0.026])
    rotate([0, 0, 90])
    scale(vscale)
    import(str(orig_dir, "aileron_right.stl"));
}

if (part == "elevator" || part == "all") {
    color(white)
    translate([-0.366, 0, 0.03])
    rotate([0, 0, 90])
    scale(vscale)
    import(str(orig_dir, "elevator.stl"));
}

if (part == "rudder" || part == "all") {
    color(white)
    translate([-0.33, 0, 0.0175])
    rotate([0, 0, 90])
    scale(vscale)
    import(str(orig_dir, "rudder.stl"));
}

if (part == "propeller" || part == "all") {
    if (part == "all") {
        translate([0.01, 0, 0.017])
        color("grey") import(str(orig_dir, "propeller.stl"));
    } else {
        color("grey") import(str(orig_dir, "propeller.stl"));
    }
}

module wheel() {
    color(brown)
    translate([0, -0.0025, 0])
    scale(vscale)
    import(str(orig_dir, "wheel_right.stl"));
}

if (part == "wheel_left" || part == "all") {
    translate([-0.073, 0.068, -0.04]) wheel();
}

if (part == "wheel_right" || part == "all") {
    translate([-0.073, -0.068, -0.04]) wheel();
}


// current exported files
if (part == "export") {
    for (p = parts) {
        import(str("stl/", p, ".stl"));
    }
}