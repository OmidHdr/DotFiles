#!/usr/bin/env python3
"""Measure the actual Apple, Global Menu, and native workspace format runs."""
import configparser
import math
import re
import sys

sys.dont_write_bytecode = True

from bar_preferences import BASE, menu_visible
from font_metrics import Fonts
from menu_context import MENU_TIERS, i3_query, menu_format

TAGS = re.compile(r"%\{([^}]*)\}")
EDGE = 13


def extent(raw, dpi, space=0):
    if raw.endswith("pt"):
        return int(float(raw[:-2]) * dpi / 72)
    if raw.endswith("px"):
        return int(float(raw[:-2]))
    return int(raw) * space


def measure_format(text, fonts, dpi):
    position, ink, current, transparent = 0, 0, 0, False
    for index, part in enumerate(TAGS.split(text)):
        if index % 2 == 0:
            advance, end = fonts.measure(part, current)
            ink = max(ink, position + end) if end and not transparent else ink
            position += advance
            continue
        for tag in part.split():
            if tag.startswith("O"):
                position += extent(tag[1:], dpi)
            elif tag.startswith("F"):
                transparent = tag[1:] == "#00000000"
            elif tag.startswith("T"):
                current = max(0, int(tag[1:]) - 1) if tag[1:].isdigit() else 0
    return position, ink


def left_layout(monitor, dpi, maximum, workspaces, visible):
    config = configparser.ConfigParser(interpolation=None, strict=False)
    config.read_string("[includes]\n" + (BASE / "config.ini").read_text())
    config.read([BASE / "modules.ini", BASE / "themes/current.ini"])
    bar = dict(config["bar/base"]) | dict(config["bar/left"])
    module = config["module/i3"]
    apple = config["module/apple"]
    patterns = [bar[f"font-{index}"].rsplit(";", 1)[0]
                for index in range(sum(key.startswith("font-") for key in bar))]
    icons = dict(value.split(";", 1) for key, value in module.items()
                 if key.startswith("ws-icon-") and key != "ws-icon-default")
    selected = [w for w in workspaces if not module.getboolean("pin-workspaces")
                or w["output"] == monitor or (module.getboolean("show-urgent", fallback=False)
                                               and w.get("urgent"))]
    if module.getboolean("index-sort"):
        selected.sort(key=lambda w: w.get("num", -1))
    # Inline icon alignment offsets cancel out. Measure the original glyph
    # run so both the slot advance and the right-edge ink reference stay fixed.
    label = config["workspace-labels"]["unfocused"]
    separator = module.get("label-separator", "")
    workspace = separator.join(
        label.replace("%icon%", TAGS.sub("", icons.get(w["name"].strip(), module["ws-icon-default"])))
        for w in selected
    )
    apple = f'%{{T{apple["format-font"]}}}{apple["format"].strip(chr(34))}%{{T-}}'
    with Fonts(patterns, dpi) as fonts:
        space = int(fonts.measure(" ", 0)[0])
        left = extent(bar["padding-left"], dpi, space)
        right = extent(bar["padding-right"], dpi, space)
        margins = sum(extent(bar.get(f"module-margin-{side}", bar["module-margin"]), dpi, space)
                      for side in ("left", "right"))
        for tier in (*MENU_TIERS, "off") if visible else ("off",):
            menu = menu_format(tier, clickable=False)
            advance, ink = measure_format(apple + menu + workspace, fonts, dpi)
            units = 1 + bool(menu) + bool(workspace)
            width = math.ceil(left + margins * units + max(advance + right, ink + EDGE))
            if width <= maximum or tier == "off":
                return min(width, maximum), tier


if __name__ == "__main__":
    monitor, dpi, maximum, *preference = sys.argv[1:]
    visible = preference[0] == "show" if preference else menu_visible()
    print(*left_layout(monitor, int(dpi), int(maximum), i3_query("get_workspaces"), visible))
