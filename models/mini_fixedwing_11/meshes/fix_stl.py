#!/usr/bin/env python3

import os
import subprocess
import pathlib

parts = ['fuselage', 'aileron_left', 'aileron_right', 'elevator', 'rudder', 'propeller', 'wheel_left', 'wheel_right']
parts_subdivide = ['aileron_left', 'aileron_right', 'elevator', 'rudder']
parts_decimate = ['fuselage']

pathlib.Path('stl').mkdir(parents=True, exist_ok=True)

for part in parts:
    out_filename = "./stl/{}.stl".format(part)
    openscad_cmd = "openscad -o {} -Dpart=\"{}\" model.scad ".format(out_filename, part)
    print(openscad_cmd)
    with open(out_filename, "w+") as f:
        subprocess.call(openscad_cmd.split())

subdivide_script = """
import bpy

parts = {:s}

for part in parts:
    bpy.ops.object.mode_set(mode='OBJECT')
    bpy.ops.object.select_by_type(type='MESH')
    bpy.ops.object.delete(use_global=False)

    print('importing', part)
    bpy.ops.import_mesh.stl(filepath="./stl/" + part + ".stl")

    print('subdividing')
    bpy.ops.object.select_all(action='DESELECT')
    print(list(bpy.data.objects))

    bpy.ops.object.mode_set(mode='OBJECT')
    bpy.ops.object.select_by_type(type='MESH')
    bpy.ops.object.editmode_toggle()
    bpy.ops.mesh.subdivide()
    bpy.ops.mesh.subdivide()
    print('exporting')
    bpy.ops.export_mesh.stl(filepath="./stl/" + part + ".stl")

print('exporting complete')
bpy.ops.wm.quit_blender()
""".format(str(parts_subdivide))

print(subdivide_script)
with open("/tmp/subdivide.py", "w") as f:
    f.write(subdivide_script)
subprocess.call("blender --python /tmp/subdivide.py".split())

decimate_script = """
import bpy

parts = {:s}
decimateRatio=0.1

for part in parts:
    bpy.ops.object.mode_set(mode='OBJECT')
    bpy.ops.object.select_by_type(type='MESH')
    bpy.ops.object.delete(use_global=False)

    print('importing', part)
    bpy.ops.import_mesh.stl(filepath="./stl/" + part + ".stl")

    print('decimating')
    bpy.ops.object.select_all(action='DESELECT')
    print(list(bpy.data.objects))

    bpy.ops.object.mode_set(mode='OBJECT')
    bpy.ops.object.select_by_type(type='MESH')
    bpy.ops.object.editmode_toggle()
    bpy.ops.mesh.decimate(ratio=decimateRatio)
    print('exporting')
    bpy.ops.export_mesh.stl(filepath="./stl/" + part + ".stl")

print('exporting complete')
bpy.ops.wm.quit_blender()
""".format(str(parts_decimate))

print(decimate_script)
with open("/tmp/decimate.py", "w") as f:
    f.write(decimate_script)

subprocess.call("blender --python /tmp/decimate.py".split())
