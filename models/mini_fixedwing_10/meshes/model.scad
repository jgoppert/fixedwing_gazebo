part = "all"; // which part to show
brown = [0.8, 0.7, 0.6, 0.5];  // color of cardboard
white = [1, 1, 1, 0.5];  // white posterboard
grey = [0.5, 0.5, 0.5, 0.5];  // grey color for tires/motor
orig_dir = "stl_orig/";
vscale = [0.001, 0.001, 0.001];

for (p = ["fuselage"]) {
    if (p == part || part == "all") {
        color(brown)
        scale(vscale)
        import(str(orig_dir, p, ".stl"));
    }
}

for (p = ["left_aileron"]) {
    if (p == part || part == "all") {
        color(white)
        translate([-0.216, 0.190, -0.025])
        rotate([5, -3, 0])
        scale(vscale)
        import(str(orig_dir, "aileron.stl"));
    }
}

for (p = ["right_aileron"]) {
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

for (p = ["propeller"]) {
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
