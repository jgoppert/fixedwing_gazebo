import os
import subprocess
from pathlib import Path
from typing import List

parts_subdivide = []
parts_decimate = []

def openscad_stl_export(scad_file: Path, part: str, out_dir: Path):
    """
    Export stl components from an openscad model.
    """
    out_dir.mkdir(parents=True, exist_ok=True)
    out_filename = out_dir/"{}.stl".format(part)
    openscad_cmd = "openscad -o {} -Dpart=\"{}\" {}".format(out_filename, part, scad_file)
    print(openscad_cmd)
    with open(out_filename, "w+") as f:
        subprocess.call(openscad_cmd.split())

subdivide_script = """
import bpy

file_in = "{file_in:s}"
file_out = "{file_out:s}"
n = {n:d}

print('deleting meshes')
bpy.ops.object.mode_set(mode='OBJECT')
bpy.ops.object.select_by_type(type='MESH')
bpy.ops.object.delete(use_global=False)

print('importing', file_in)
bpy.ops.import_mesh.stl(filepath=file_in)

print('selecting mesh')
bpy.ops.object.select_all(action='DESELECT')
bpy.ops.object.mode_set(mode='OBJECT')
bpy.ops.object.select_by_type(type='MESH')
bpy.ops.object.editmode_toggle()

print('subdividing', n, 'times')
for i in range(n):
    bpy.ops.mesh.subdivide()

print('exporting', file_out)
bpy.ops.export_mesh.stl(filepath=file_out)

print('quit')
bpy.ops.wm.quit_blender()
"""

def subdivide(file_in: Path, file_out: Path, n: float):
    """
    subidivide an stl model n times
    """
    script = subdivide_script.format(**{
        'file_in': str(file_in), 'file_out': str(file_out), 'n': n})
    #print(script)
    with open("/tmp/subdivide.py", "w") as f:
        f.write(script)
    subprocess.call("blender --python /tmp/subdivide.py".split())

decimate_script = """
import bpy

file_in = "{file_in:s}"
file_out = "{file_out:s}"
ratio = {ratio:f}

print('selecting part')
bpy.ops.object.mode_set(mode='OBJECT')
bpy.ops.object.select_by_type(type='MESH')
bpy.ops.object.delete(use_global=False)

print('importing', file_in)
bpy.ops.import_mesh.stl(filepath=file_in)

print('selecting mesh')
bpy.ops.object.select_all(action='DESELECT')
bpy.ops.object.mode_set(mode='OBJECT')
bpy.ops.object.select_by_type(type='MESH')
bpy.ops.object.editmode_toggle()

print('decimating at ratio', ratio)
bpy.ops.mesh.decimate(ratio=ratio)

print('exporting', file_out)
bpy.ops.export_mesh.stl(filepath=file_out)

print('quit')
bpy.ops.wm.quit_blender()
"""

def decimate(file_in: Path, file_out: Path, ratio: float):
    assert ratio > 0 and ratio < 1
    script = decimate_script.format(**{
        'file_in': str(file_in), 'file_out': str(file_out), 'ratio': ratio})
    #print(script)
    with open("/tmp/decimate.py", "w") as f:
        f.write(script)
    subprocess.call("blender --python /tmp/decimate.py".split())
