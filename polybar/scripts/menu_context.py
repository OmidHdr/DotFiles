"""Shared i3 context and Polybar menu presentation."""
import json
import subprocess

from bar_preferences import BASE, CACHE, STATE

APP_NAMES = {
    "brave-browser": "Brave", "chromium": "Chromium", "google-chrome": "Chrome",
    "firefox": "Firefox", "kitty": "Terminal", "alacritty": "Terminal",
    "xterm": "Terminal", "jetbrains-idea": "IntelliJ IDEA", "nvim": "Neovim",
    "neovide": "Neovim", "telegramdesktop": "Telegram", "thunar": "Files",
    "dolphin": "Files", "code": "VS Code", "mpv": "mpv", "windscribe2": "Windscribe",
    "copyq": "CopyQ", "org.gnome.terminal": "Terminal", "org.gnome.evince": "Evince",
}
LABELS = ("File", "Edit", "View", "Go", "Window", "Help")
MENU_TIERS = {
    "full": (("Finder", "app"), *((name, name.lower()) for name in LABELS)),
    "compact": (("Finder", "app"), ("File", "file"), ("Window", "window"), ("…", "more")),
    "small": (("…", "more"),),
}
MENU_LABEL_PADDING = 7
MENU_SEPARATOR = "%{F#809298a5}│%{F-}%{O6px}"


def i3_query(kind):
    return json.loads(subprocess.check_output(["i3-msg", "-r", "-t", kind], timeout=3))


def focused_window(node=None):
    if node is None:
        node = i3_query("get_tree")
    if node.get("focused"):
        return node
    for child in node["nodes"] + node["floating_nodes"]:
        found = focused_window(child)
        if found:
            return found
    return None


def app_label(window):
    metadata = (window or {}).get("window_properties") or {}
    for key in ("class", "instance"):
        label = APP_NAMES.get((metadata.get(key) or "").lower())
        if label:
            return label
    return "Finder"


def menu_format(tier, clickable=True):
    items = []
    for text, key in MENU_TIERS.get(tier, ()):
        font = 10 if key == "app" else 1
        padding = f"%{{O{MENU_LABEL_PADDING}px}}"
        label = f"{padding}%{{T{font}}}{text}%{{T-}}{padding}"
        if clickable:
            label = f"%{{A1:python3 ~/.config/polybar/scripts/global-menu.py {key}:}}{label}%{{A}}"
        items.append(label)
    return "".join(items) + (MENU_SEPARATOR if items else "")


def update_label():
    CACHE.mkdir(mode=0o700, parents=True, exist_ok=True)
    for tier in (*MENU_TIERS, "off"):
        path = CACHE / f"global-menu-{tier}"
        temporary = path.with_suffix(".tmp")
        temporary.write_text(menu_format(tier) + "\n")
        temporary.replace(path)


if __name__ == "__main__":
    update_label()
