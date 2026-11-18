#!/usr/bin/env python3
"""Measure Apple and native i3 icon labels using the same mapping as Polybar."""
import configparser, json, math, subprocess, sys
from pathlib import Path
from PIL import ImageFont
monitor, dpi = sys.argv[1], int(sys.argv[2])
def font(family, points):
 path = subprocess.check_output(['fc-match', '-f', '%{file}', family], text=True)
 return ImageFont.truetype(path, round(points*dpi/72))
text = font('SF Pro Display', 10)
icons = font('Symbols Nerd Font', 11)
workspace_icons = font('JetBrainsMono Nerd Font Mono', 13)
circle = font('Symbols Nerd Font', 18)
space = text.getlength(' ')
config = configparser.ConfigParser(interpolation=None)
config.read(Path.home()/'.config/polybar/modules.ini')
module = config['module/i3']
mapping = dict(value.split(';', 1) for key,value in module.items() if key.startswith('ws-icon-') and key != 'ws-icon-default')
workspaces = json.loads(subprocess.check_output(['i3-msg', '-t', 'get_workspaces'], text=True))
# Six text spaces cover bar padding and module margins; 6px cover rounding.
width = icons.getlength('\uf179') + 6*space
for w in workspaces:
 if w['output'] == monitor:
  glyph = mapping.get(w['name'], module['ws-icon-default'])
  width += circle.getlength('\uf111') + workspace_icons.getlength(glyph) - 4.5*dpi/72
print(math.ceil(width + 6*dpi/96))
