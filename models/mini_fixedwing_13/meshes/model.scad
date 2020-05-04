part = "all"; // which part to show
brown = [0.8, 0.7, 0.6, 0.5];  // color of cardboard
white = [1, 1, 1, 0.5];  // white posterboard
grey = [0.5, 0.5, 0.5, 0.5];  // grey color for tires/motor
orig_dir = "stl_orig/";
vscale = [0.001, 0.001, 0.001];
vtrans = [-0.09, 0.3076, -0.61777];

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
        translate([0, 0.065, 0]) wheel();
    }
}

for (p = ["wheel_right"]) {
    if (p == part || part == "all") {
        translate([0, -0.065, 0]) wheel();
    }
}

for (p = ["propeller"]) {
    if (p == part || part == "all") {
        color(grey)
        translate([0, -0.2223, -0.0007])
        translate(vtrans)
        scale(vscale)
        import(str(orig_dir, p, ".stl"));
    }
}
