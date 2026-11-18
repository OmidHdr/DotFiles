#!/usr/bin/env python3
"""Open one keyboard-accessible popup beside a clicked Polybar menu label."""
import fcntl
import re
import subprocess
import sys

sys.dont_write_bytecode = True

import gi
gi.require_version("Gtk", "3.0")
gi.require_version("Gdk", "3.0")
gi.require_version("GdkX11", "3.0")

from gi.repository import Gdk, GdkX11, GLib, Gtk

from desktop_menu import desktop_menu, message
from bar_preferences import STATE, active_theme, menu_visible
from menu_context import LABELS, app_label, focused_window
from native_menu import Item, exported_menu


def menu_rows(key, window):
    native = exported_menu((window or {}).get("window")) if key != "apple" else []

    def rows(section):
        if section == "app":
            finder = desktop_menu(section, window)
            if native:
                label = app_label(window)
                if label == "Finder":
                    label = "Application"
                finder.append(Item(label + " Menu", children=native))
            return finder
        for item in native:
            if re.sub(r"[^\w]", "", item.label).casefold() == section and item.children:
                return item.children
        return desktop_menu(section, window)
    if key == "apple":
        return desktop_menu(key, window)
    if key == "more":
        return [Item(label, children=items) for section, label in
                (("app", "Finder"), *((label.lower(), label) for label in LABELS))
                if (items := rows(section))]
    return rows(key)


def add_theme():
    dark = active_theme() == "dark"
    bg, fg, hover, border = ("#25272f", "#f5f5f7", "#315f95", "#494b54") if dark else (
        "#f6f6fa", "#1d1d1f", "#d8e8fa", "#d3d4dc")
    css = f"""
    menu.global-menu {{
      background-color: {bg}; color: {fg}; border: 1px solid {border};
      border-radius: 10px; padding: 5px;
      box-shadow: 0 3px 12px rgba(0,0,0,0.30);
      font-family: "SF Pro Display", sans-serif; font-size: 12pt;
    }}
    menu.global-menu menuitem {{ padding: 4px 14px; border-radius: 5px; min-height: 20px; }}
    menu.global-menu menuitem:hover {{ background-color: {hover}; color: {fg}; }}
    menu.global-menu separator {{ background-color: {border}; min-height: 1px; margin: 4px 8px; }}
    """.encode()
    style = Gtk.CssProvider()
    style.load_from_data(css)
    Gtk.StyleContext.add_provider_for_screen(Gdk.Screen.get_default(), style,
                                             Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)


def build_menu(rows, selected):
    menu = Gtk.Menu()
    menu.set_direction(Gtk.TextDirection.LTR)
    menu.set_reserve_toggle_size(False)
    menu.get_style_context().add_class("global-menu")
    for row in rows:
        if not row.label:
            item = Gtk.SeparatorMenuItem()
        elif row.checked is not None:
            item = Gtk.CheckMenuItem(label=row.label)
            item.set_active(row.checked)
        else:
            item = Gtk.MenuItem(label=row.label)
        if row.children:
            item.set_submenu(build_menu(row.children, selected))
        elif row.activate is not None:
            item.connect("activate", lambda _, action=row.activate: selected.append(action))
        item.set_sensitive(row.enabled and bool(row.activate or row.children))
        menu.append(item)
    return menu


def anchor(display, device):
    root = Gdk.get_default_root_window()
    _, x, y = device.get_position()
    bottom = y + 4
    windows = subprocess.run(["xdotool", "search", "--onlyvisible", "--name", "^polybar-left_"],
                             capture_output=True, text=True, timeout=1).stdout.split()
    for xid in windows:
        window = GdkX11.X11Window.foreign_new_for_display(display, int(xid))
        if window is None:
            continue
        _, wx, wy = window.get_origin()
        width, height = window.get_width(), window.get_height()
        if wx <= x < wx + width and wy <= y < wy + height:
            bottom = wy + height + 4
            break
    rect = Gdk.Rectangle()
    rect.x, rect.y, rect.width, rect.height = x, bottom, 1, 1
    return root, rect


def main():
    key = sys.argv[1] if len(sys.argv) == 2 else ""
    if key not in {"apple", "app", "more", *(label.lower() for label in LABELS)}:
        return
    if key != "apple" and not menu_visible():
        return
    STATE.mkdir(mode=0o700, parents=True, exist_ok=True)
    selected = []
    with (STATE / "global-menu.lock").open("a") as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            return
        display = Gdk.Display.get_default()
        device = display.get_default_seat().get_pointer()
        root, rect = anchor(display, device)
        window = focused_window()
        rows = menu_rows(key, window)
        if not rows:
            rows = [Item("No actions for this window", enabled=False)]
        add_theme()
        menu = build_menu(rows, selected)
        menu.connect("deactivate", lambda _: Gtk.main_quit())
        menu.show_all()
        event = Gdk.Event.new(Gdk.EventType.BUTTON_PRESS)
        event.window = root
        event.button = 1
        # Polybar launches a new process, so there is no originating GDK event.
        event.time = Gdk.CURRENT_TIME
        event.set_device(device)
        menu.popup_at_rect(root, rect, Gdk.Gravity.NORTH_WEST, Gdk.Gravity.NORTH_WEST, event)
        if menu.get_mapped():
            if key != "apple":
                def dismiss_if_hidden():
                    if not menu_visible():
                        Gtk.main_quit()
                    return GLib.SOURCE_CONTINUE
                watch = GLib.timeout_add(100, dismiss_if_hidden)
            Gtk.main()
            if key != "apple":
                GLib.source_remove(watch)
        menu.destroy()
    if selected and (key == "apple" or menu_visible()):
        try:
            selected[0]()
        except (OSError, GLib.Error, RuntimeError, subprocess.SubprocessError, ValueError) as exc:
            message("Action unavailable", str(exc))


if __name__ == "__main__":
    main()
