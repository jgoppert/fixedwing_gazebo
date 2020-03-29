t = 0.5; // thickness of foam board, cm
camber = 0.1;  // % chord
chord = 15;  // chord, cm
max_camber = 0.3;  // max camber location, % chord
wing_incidence = 5;  // wing incidence angle, deg
dihedral = 3;  // wing dihedral angle, deg
span = 60;  // wing full span, cm
brown = [0.8, 0.7, 0.6];  // color of cardboard
white = [1, 1, 1];  // white posterboard
grey = [0.5, 0.5, 0.5];  // grey color for tires/motor
part = "all";

module airfoil() {
    polygon([
      [0, 0],
      [chord*max_camber, chord*camber],
      [chord, 0],
      [chord, t],
      [chord*max_camber, chord*camber + t],
      [0, t]
      ]);
}

module wing() {
    color(brown) rotate([-dihedral + 90, 0, 180])
    linear_extrude(span/2)
    rotate(-wing_incidence)
    airfoil();
}

module fuselage() {
    rotate([0, 90, 180]) {
        color(brown) linear_extrude(25) {
            square([5, 4], center=true);
        }
        color(brown) translate([0, 0, 24]) rotate([0, -4, 0])
        linear_extrude(18, scale=0.5) {
            square([5, 4], center=true);
        }
    }
}

module canopy() {
    difference() {
        rotate([0, 90, 180]) {
                color("white") difference() {
                    translate([-2, 0, 0.1]) linear_extrude(20) {
                        circle(r=2, $fn=60);
                    }
                    translate([-4.5, 0, 16]) sphere(r=2, $fn=60);
                }
                color("white") translate([-2, 0, 20])
                rotate([0, 5, 0]) linear_extrude(7, scale=0.6) {
                    circle(r=2, $fn=60);
                }
            }
        fuselage();
    }
}

module htail_shape() {
    linear_extrude(t) polygon([
      [0, 0],
      [0, 1],
      [7, 12],
      [9, 13],
      [9, 0],
      ]);
}

module htail() {
    color(brown) rotate([0, 0, 180]) {
        htail_shape();
        mirror([0, 1, 0]) htail_shape();
    }
}

module vtail() {
    color(brown) rotate([90, 0, 180]) linear_extrude(t) polygon([
      [0, 0],
      [0, 1],
      [4, 6],
      [9, 7],
      [9, 0],
      ]);
}

module rudder() {
    color(brown) rotate([90, 0, 180]) linear_extrude(t) polygon([
      [0, 0],
      [0, 7],
      [3, 7],
      [3, -1.5],
      [0, -2],
      ]);
}

module elevator_shape() {
    color(brown) rotate([0, 0, 180]) linear_extrude(t) polygon([
      [0, 0],
      [0, 13],
      [3.5, 12],
      [3.5, 3],
      [0.5, 1],
      [0.5, 0],
      ]);
}

module elevator() {
    elevator_shape();
    mirror([0, 1, 0]) elevator_shape();
}

module motor() {
    color([0.6, 0.6, 0.6]) {
        translate([0, 0, 1]) rotate([0, -90, 180]) linear_extrude(2, scale=0.4) {
            circle(r=1, $fn=60);
        }
    }
}

module wheel() {
    color(white) rotate([90, 0, 0]) linear_extrude(0.3, center=true) {
        circle(r=2, $fn=60);
    }
}

module tire() {
    color(grey) rotate([90, 0, 0]) linear_extrude(0.5, center=true) {
        difference() {
            circle(r=2.5, $fn=60);
            circle(r=2, $fn=60);
        }
    }
}

module gear_wire_shape() {
    color(grey) rotate([90, 0, 90]) linear_extrude(0.3) polygon([
      [0, 0],
      [2, 0],
      [4, -4],
      [5, -4],
      [5, -3.7],
      [4, -3.7],
      [2, 0.3],
      [0, 0.3]
    ]);
}

module gear_wire() {
    translate([0, 0, -2.7]) gear_wire_shape();
    translate([0, 0, -2.7]) mirror([0, -1, 0]) gear_wire_shape();
}

module body() {
    translate([-7, 0, 0]) wing();
    translate([-7, 0, 0]) mirror([0, 1, 0]) wing();
    fuselage();
    translate([-33, 0, 2.3]) htail();
    translate([-33, 0, 2.3]) vtail();
}

module all() {
  motor();
  body();
  canopy();
  translate([-8, 0, 0]) gear_wire();
  translate([-42.1, 0, 2.3]) rudder();
  translate([-42.1, 0, 2.3]) elevator();
  translate([-8, -4.2, -6.5]) tire();
  translate([-8, 4.2, -6.5]) tire();
  translate([-8, 4.2, -6.5]) wheel();
  translate([-8, -4.2, -6.5]) wheel();
}

if (part == "all") {
    all();
} else if (part == "body") {
    body();
} else if (part == "canopy") {
    canopy();
} else if (part == "motor") {
    motor();
} else if (part == "gear_wire") {
    gear_wire();
} else if (part == "rudder") {
    rudder();
} else if (part == "elevator") {
    elevator();
} else if (part == "tire") {
    tire();
} else if (part == "wheel") {
    wheel();
}
