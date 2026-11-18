#!/usr/bin/env python3
"""Measure Apple and native i3 icon labels using the same mapping as Polybar."""
import configparser, json, math, subprocess, sys
from pathlib import Path
from PIL import ImageFont
monitor, dpi = sys.argv[1], int(sys.argv[2])
def font(family, points):
 path = subprocess.check_output(['fc-match', '-f', '%{file}', family], text=True)
 return ImageFont.truetype(path, round(points*dpi/72))
icons = font('Symbols Nerd Font', 11)
workspace_icons = font('Font Awesome 5 Free:style=Solid', 10)
brands = font('Font Awesome 5 Brands', 10)
icomoon = font('icomoon', 10)
from fontTools.ttLib import TTFont
faces = []
for family, face in [('Font Awesome 5 Free:style=Solid', workspace_icons), ('Font Awesome 5 Brands', brands), ('icomoon', icomoon)]:
 path = subprocess.check_output(['fc-match','-f','%{file}',family],text=True)
 faces.append((TTFont(path).getBestCmap(), face))
def glyph_width(glyph):
 for cmap, face in faces:
  if ord(glyph) in cmap: return face.getlength(glyph)
 return icons.getlength(glyph)
circle = font('Symbols Nerd Font', 18)
config = configparser.ConfigParser(interpolation=None, strict=False)
base = Path(__file__).resolve().parents[1]
config.read_string('[includes]\n' + (base/'config.ini').read_text())
config.read(base/'modules.ini')
bar = config['bar/left']
apple = config['module/apple']
apple_pattern = bar[f"font-{apple.getint('format-font') - 1}"].split(';', 1)[0]
apple_family, apple_size = apple_pattern.rsplit(':size=', 1)
apple_font = font(apple_family, float(apple_size))
module = config['module/i3']
mapping = dict(value.split(';', 1) for key,value in module.items() if key.startswith('ws-icon-') and key != 'ws-icon-default')
workspaces = json.loads(subprocess.check_output(['i3-msg', '-t', 'get_workspaces'], text=True))
apple_glyph, apple_offset = apple['format'].split('%{O', 1)
width = apple_font.getlength(apple_glyph)
width += sum(int(value.removesuffix('px')) for value in (
 bar['padding-left'], bar['padding-right'], apple_offset.removesuffix('}')
))
for w in workspaces:
 if w['output'] == monitor:
  glyph = mapping.get(w['name'], module['ws-icon-default'])
  width += circle.getlength('\uf111') + glyph_width(glyph) - 4.5*dpi/72
print(math.ceil(width))
