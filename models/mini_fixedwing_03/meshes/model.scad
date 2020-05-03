part = "all"; // which part to show
brown = [0.8, 0.7, 0.6, 1];  // color of cardboard
white = [1, 1, 1, 1];  // white posterboard
grey = [0.5, 0.5, 0.5, 1];  // grey color for tires/motor
orig_dir = "stl_orig/";
vrot =[0.73, 0, 0];
vscale = [0.0254, 0.0254, 0.0254];
vtrans = [0, 0, 0];

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


// current exported files
if (part == "export") {
    for (p = parts) {
        import(str("stl/", p, ".stl"));
    }
}