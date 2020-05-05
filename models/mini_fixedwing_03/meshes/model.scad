part = "all"; // which part to show
brown = [0.8, 0.7, 0.6, 0.5];  // color of cardboard
white = [1, 1, 1, 1];  // white posterboard
grey = [0.5, 0.5, 0.5, 0.5];  // grey color for tires/motor
orig_dir = "stl_orig/";
vrot =[0.73, 0, 0];
vscale = [0.0254, 0.0254, 0.0254];
vtrans = [0, 0, 0];
markers = true;

parts = ["fuselage", "aileron_left", "aileron_right",
    "elevator", "wheel_left", "wheel_right", "propeller"];

if (part == "fuselage" || part == "all") {
    color(brown)
    translate(vtrans)
    rotate(vrot)
    scale(vscale)
    import(str(orig_dir, "fuselage.stl"));
}

if (part == "aileron_left" || part == "all") {
    color(white)
    mirror([0, 1, 0]) 
    translate(vtrans)
    rotate(vrot)
    scale(vscale)
    import(str(orig_dir, "aileron_right.stl"));
}

if (part == "aileron_right" || part == "all") {
    color(white)
    translate(vtrans)
    rotate(vrot)
    scale(vscale)
    import(str(orig_dir, "aileron_right.stl"));
}

if (part == "elevator" || part == "all") {
    color(white)
    scale(vscale)
    import(str(orig_dir, "elevator.stl"));
}

if (part == "propeller" || part == "all") {
    color("grey")
    scale(vscale)
    import(str(orig_dir, "propeller.stl"));
}

if (part == "wheel_left" || part == "all") {
    color(brown)
    translate([0, 0, 0])
    scale(vscale)
    import(str(orig_dir, "wheel_left.stl"));
}

if (part == "wheel_right" || part == "all") {
    color(brown)
    mirror([0, 1, 0])
    scale(vscale)
    import(str(orig_dir, "wheel_left.stl"));}

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
    translate([-0.2, 0.19, 0.01]) cp(); // wing left
    translate([-0.2, -0.19, 0.01]) cp(); // wing right
    translate([-0.4, 0, 0.024]) cp();  // htail
    translate([-0.4, -0.122, 0.024]) cp(); // vtail right
    translate([-0.4, 0.122, 0.024]) cp(); // vtail left
}

if (part == "cm" || part == "all" && markers) {
    translate([-0.183, 0, 0]) scale([3, 3, 3]) cm(); // main
    translate([-0.276, 0.2265, -0.012]) cm(); // aileron left
    translate([-0.276, -0.2265, -0.012]) cm(); // aileron right
    translate([-0.44, 0, 0.023]) cm();  // elevator
}

if (part == "joint" || part == "all" && markers) {
    translate([-0.155, 0.04, -0.068]) rotate([10, 0, 0]) joint(); // wheel left
    translate([-0.155, -0.04, -0.068]) rotate([-10, 0, 0]) joint(); // wheel right
    translate([-0.26, 0.2265, -0.01]) joint(); // aileron left
    translate([-0.26, -0.2265, -0.01]) joint(); // aileron right
    translate([-0.425, 0, 0.023]) joint();  // elevator
}

// current exported files
if (part == "export") {
    for (p = parts) {
        import(str("stl/", p, ".stl"));
    }
}