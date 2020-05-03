#!/usr/bin/env python3
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent.parent.parent.parent/'tools'))
from stl_tools import openscad_stl_export, subdivide, decimate


parts = ['fuselage',
        'elevator', 'rudder', 'propeller', 'wheel_left', 'wheel_right']
in_dir = Path('stl_orig')
out_dir = Path('stl')

for part in parts:
    openscad_stl_export(
        scad_file='model.scad',
        part=part,
        out_dir=out_dir)

for part in ['fuselage']:
    subdivide(
        file_in=out_dir/(part + '.stl'), 
        file_out=out_dir/(part + '.stl'),
        n=2)
    decimate(
        file_in=out_dir/(part + '.stl'), 
        file_out=out_dir/(part + '.stl'),
        ratio=0.1)

for part in ['wheel_left', 'wheel_right']:
    subdivide(
        file_in=out_dir/(part + '.stl'), 
        file_out=out_dir/(part + '.stl'),
        n=1)
    decimate(
        file_in=out_dir/(part + '.stl'), 
        file_out=out_dir/(part + '.stl'),
        ratio=0.1)


for part in ['elevator', 'rudder']:
    subdivide(
        file_in=out_dir/(part + '.stl'), 
        file_out=out_dir/(part + '.stl'),
        n=1)
    decimate(
        file_in=out_dir/(part + '.stl'), 
        file_out=out_dir/(part + '.stl'),
        ratio=0.5)


for part in ['propeller']:
    decimate(
        file_in=out_dir/(part + '.stl'), 
        file_out=out_dir/(part + '.stl'),
        ratio=0.01)

