#!/usr/bin/env python

import os
import subprocess

parts = ['body', 'canopy', 'motor', 'gear_wire', 'rudder', 'elevator', 'tire', 'wheel']

for part in parts:
    out_filename = "./stl/{}.stl".format(part)
    openscad_cmd = "openscad -o {} -Dpart=\"{}\" miniscout.scad ".format(out_filename, part)
    print(openscad_cmd)
    with open(out_filename, "w+") as f:
        subprocess.call(openscad_cmd.split())

subprocess.call("blender --python subdivide.py".split())
