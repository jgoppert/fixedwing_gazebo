part = "all"; // which part to show
brown = [0.8, 0.7, 0.6, 1];  // color of cardboard
white = [1, 1, 1, 1];  // white posterboard
grey = [0.5, 0.5, 0.5, 1];  // grey color for tires/motor
orig_dir = "stl_orig/";
vscale = [0.001, 0.001, 0.001];
vtrans = [0, 0, 0];

parts = ["fuselage", "aileron_left", "aileron_right",
    "elevator", "rudder", "wheel_left", "wheel_right", "propeller"];

if (part == "fuselage" || part == "all") {
    color(brown)
    translate([-0.6, -0.3887, -0.0676])
    scale(vscale)
    import(str(orig_dir, "fuselage.stl"));
}

if (part == "aileron_left" || part == "all") {
    color(white)
    translate([-0.02, -0.29, -0.055])
    translate([-0.252, 0.29, 0.055])
    scale(vscale)
    import(str(orig_dir, "aileron_left.stl"));
}

if (part == "aileron_right" || part == "all") {
    color(white)
    translate([-0.02, -0.097, -0.055])
    translate([-0.252, -0.29, 0.055])
    scale(vscale)
    import(str(orig_dir, "aileron_right.stl"));
}

if (part == "elevator" || part == "all") {
    color(white)
    translate([-0.64, -0.12, 0])
    scale(vscale)
    import(str(orig_dir, "elevator.stl"));
}

if (part == "rudder" || part == "all") {
    color(white)
    translate([-0.64, -0.0025, 0])
    scale(vscale)
    import(str(orig_dir, "rudder.stl"));
}

module propeller() {
    rotate([0, 0, 5])
    translate([-0.0236, -0.0563, -0.0466])
    scale(vscale)
    import(str(orig_dir, "propeller.stl"));
}


if (part == "propeller" || part == "all") {
    color(grey)
    if (part == "all") {
        rotate([0, 0, -5])
        translate([0.01, 0, 0])
        propeller();
    } else {
        propeller();
    }
}

module wheel() {
    color(brown)
    translate([-0.0305, -0.0035, -0.0305])
    scale(vscale)
    import(str(orig_dir, "wheel_right.stl"));
}

if (part == "wheel_left" || part == "all") {
    translate([-0.075, 0.052, -0.0652]) wheel();
}

if (part == "wheel_right" || part == "all") {
    translate([-0.075, -0.052, -0.0652]) wheel();
}


// current exported files
if (part == "export") {
    for (p = parts) {
        import(str("stl/", p, ".stl"));
    }
}