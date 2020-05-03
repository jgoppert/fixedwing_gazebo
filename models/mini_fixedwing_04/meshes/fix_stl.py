#!/usr/bin/env python3
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent.parent.parent.parent/'tools'))
from stl_tools import openscad_stl_export, subdivide, decimate


parts = ['fuselage', 'aileron_left', 'aileron_right',
        'propeller_left', 'propeller_right']
in_dir = Path('stl_orig')
out_dir = Path('stl')

for part in parts:
    openscad_stl_export(
        scad_file='model.scad',
        part=part,
        out_dir=out_dir)

for part in ['fuselage']:
    decimate(
        file_in=out_dir/(part + '.stl'), 
        file_out=out_dir/(part + '.stl'),
        ratio=0.05)

for part in ['propeller_left', 'propeller_right']:
    decimate(
        file_in=out_dir/(part + '.stl'), 
        file_out=out_dir/(part + '.stl'),
        ratio=0.05)

for part in ['aileron_left', 'aileron_right']:
    decimate(
        file_in=out_dir/(part + '.stl'), 
        file_out=out_dir/(part + '.stl'),
        ratio=0.1)


