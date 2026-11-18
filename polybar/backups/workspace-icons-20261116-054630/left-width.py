#!/usr/bin/env python3
"""Measure the static label and actual output workspaces; never read window titles."""
import json, math, subprocess, sys
from PIL import ImageFont
monitor, dpi = sys.argv[1], int(sys.argv[2])
def font(family, points):
 path = subprocess.check_output(['fc-match', '-f', '%{file}', family], text=True)
 return ImageFont.truetype(path, round(points*dpi/72))
text = font('SF Pro Display', 10)
icons = font('Symbols Nerd Font', 11)
space = text.getlength(' ')
workspaces = json.loads(subprocess.check_output(['i3-msg', '-t', 'get_workspaces'], text=True))
names = [w['name'] for w in workspaces if w['output'] == monitor]
# Bar padding, inter-module margins, native i3 label padding, and rounding allowance.
width = icons.getlength('\uf179') + text.getlength('i3 Desktop') + 8*space
width += sum(text.getlength(name) + 2*space for name in names)
print(math.ceil(width + 12*dpi/96))
