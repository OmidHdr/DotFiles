"""Desktop actions for windows without exported application menus."""
import json
from pathlib import Path
import platform
import re
import shutil
import subprocess

from gi.repository import Gdk, Gio, GLib, Gtk

from menu_context import BASE, i3_query
from native_menu import Item


def launch(*args):
    subprocess.Popen(args, stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL,
                     stderr=subprocess.DEVNULL, start_new_session=True)


def executable(name):
    return shutil.which(str(name)) is not None


def command(label, *args):
    return [Item(label, lambda: launch(*args))] if executable(args[0]) else []


def message(title, detail, confirm=False):
    dialog = Gtk.MessageDialog(
        modal=True, text=title, secondary_text=detail,
        message_type=Gtk.MessageType.QUESTION if confirm else Gtk.MessageType.INFO,
        buttons=Gtk.ButtonsType.OK_CANCEL if confirm else Gtk.ButtonsType.CLOSE,
    )
    dialog.set_default_response(Gtk.ResponseType.CANCEL if confirm else Gtk.ResponseType.CLOSE)
    result = dialog.run()
    dialog.destroy()
    return result == Gtk.ResponseType.OK


def text_dialog(title, text):
    dialog = Gtk.Dialog(title=title, modal=True)
    dialog.add_button("Close", Gtk.ResponseType.CLOSE)
    dialog.set_default_size(640, 480)
    scroller = Gtk.ScrolledWindow()
    viewer = Gtk.TextView(editable=False, monospace=True, wrap_mode=Gtk.WrapMode.WORD_CHAR)
    viewer.set_left_margin(12)
    viewer.set_top_margin(12)
    viewer.get_buffer().set_text(text)
    scroller.add(viewer)
    dialog.get_content_area().pack_start(scroller, True, True, 0)
    dialog.show_all()
    dialog.run()
    dialog.destroy()


def prompt(title, detail):
    dialog = Gtk.Dialog(title=title, modal=True)
    dialog.add_button("Cancel", Gtk.ResponseType.CANCEL)
    dialog.add_button("Continue", Gtk.ResponseType.OK)
    dialog.set_default_response(Gtk.ResponseType.OK)
    box = dialog.get_content_area()
    box.set_border_width(12)
    box.set_spacing(8)
    box.add(Gtk.Label(label=detail, xalign=0))
    entry = Gtk.Entry(activates_default=True, width_chars=42)
    box.add(entry)
    dialog.show_all()
    result = entry.get_text() if dialog.run() == Gtk.ResponseType.OK else None
    dialog.destroy()
    return result


def choose_location(title, directory=False):
    action = Gtk.FileChooserAction.SELECT_FOLDER if directory else Gtk.FileChooserAction.OPEN
    dialog = Gtk.FileChooserDialog(title=title, action=action)
    dialog.add_button("Cancel", Gtk.ResponseType.CANCEL)
    dialog.add_button("Choose", Gtk.ResponseType.OK)
    dialog.set_current_folder(str(Path.home()))
    path = dialog.get_filename() if dialog.run() == Gtk.ResponseType.OK else None
    dialog.destroy()
    return Path(path) if path else None


def open_path(path):
    Gio.AppInfo.launch_default_for_uri(path.absolute().as_uri(), None)


def file_manager():
    association = Gio.AppInfo.get_default_for_type("inode/directory", False)
    supported = ("thunar", "dolphin", "pcmanfm", "nautilus")
    if association:
        name = Path(association.get_executable()).name.lower()
        if name in supported and executable(name):
            return name
    return next((name for name in supported if executable(name)), None)


def directories():
    result = [("Home", Path.home())]
    for label, key, enum in (
        ("Desktop", "DESKTOP", GLib.UserDirectory.DIRECTORY_DESKTOP),
        ("Documents", "DOCUMENTS", GLib.UserDirectory.DIRECTORY_DOCUMENTS),
        ("Downloads", "DOWNLOAD", GLib.UserDirectory.DIRECTORY_DOWNLOAD),
    ):
        value = GLib.get_user_special_dir(enum)
        if value:
            path = Path(value)
            if path.is_dir() and path != Path.home():
                result.append((label, path))
    projects = Path.home() / "Projects"
    if projects.is_dir():
        result.append(("Projects", projects))
    return result


def navigation(manager):
    if not manager:
        return []
    rows = [Item(label, lambda path=path: launch(manager, str(path))) for label, path in directories()]
    if manager == "thunar":
        rows.append(Item("Computer", lambda: launch(manager, "computer:///")))
    elif manager:
        rows.append(Item("Computer", lambda: launch(manager, "/")))
    return rows


def go_to_folder(manager):
    value = prompt("Go to Folder", "Enter an absolute folder path or one beginning with ~.")
    if value is None:
        return
    path = Path(value).expanduser()
    if not path.is_absolute() or not path.is_dir():
        message("Folder unavailable", "Enter the path of an existing folder.")
        return
    launch(manager, str(path))


def new_folder(manager):
    folder = choose_location("Choose a parent folder", directory=True)
    if folder is None:
        return
    name = prompt("New Folder", "Enter a name for the new folder.")
    if name is None:
        return
    if not name.strip() or name in (".", "..") or "/" in name or "\0" in name:
        message("Invalid folder name", "Use a single, nonempty folder name.")
        return
    path = folder / name
    if message("Create this folder?", str(path), confirm=True):
        path.mkdir()
        launch(manager, str(path))


def appearance():
    theme = Path.home() / ".local/bin/polybar-theme"
    return [row for label, value in (("Light", "light"), ("Dark", "dark"), ("Toggle Theme", "toggle"))
            for row in command(label, str(theme), value)]


def system_information():
    events = i3_query("get_version")
    release = platform.freedesktop_os_release()
    return "\n".join((
        release.get("PRETTY_NAME", platform.system()),
        f"Kernel  {platform.release()}",
        f"Architecture  {platform.machine()}",
        f"i3  {events['human_readable']}  ·  X11",
    ))


def power_actions():
    if not executable("systemctl"):
        return []
    try:
        bus = Gio.bus_get_sync(Gio.BusType.SYSTEM, None)
    except GLib.Error:
        return []
    result = []
    for label, method, argument in (("Sleep", "CanSuspend", "suspend"),
                                    ("Restart…", "CanReboot", "reboot"),
                                    ("Shut Down…", "CanPowerOff", "poweroff")):
        try:
            allowed, = bus.call_sync("org.freedesktop.login1", "/org/freedesktop/login1",
                                     "org.freedesktop.login1.Manager", method, None, None,
                                     Gio.DBusCallFlags.NO_AUTO_START, 450, None).unpack()
        except GLib.Error:
            continue
        if allowed not in ("yes", "challenge"):
            continue
        def confirm(label=label, argument=argument):
            if message(label.rstrip("…") + "?", "Confirm this system action.", confirm=True):
                launch("systemctl", argument)
        result.append(Item(label, confirm))
    return result


def i3_command(command_text):
    response = subprocess.check_output(["i3-msg", "-r", command_text], timeout=3)
    if not all(row["success"] for row in json.loads(response)):
        raise RuntimeError("i3 could not complete the action.")


def window_actions(window):
    if not window or not window.get("window"):
        return []
    con = int(window["id"])
    target = f"[con_id={con}]"
    rows = []
    for direction in ("left", "right", "up", "down"):
        rows.append(Item("Focus " + direction.title(), lambda direction=direction:
                         i3_command(f"{target} focus; focus {direction}")))
    rows.extend([
        Item("Toggle Floating", lambda: i3_command(f"{target} floating toggle")),
        Item("Toggle Fullscreen", lambda: i3_command(f"{target} fullscreen toggle")),
    ])
    numbers = sorted({w["num"] for w in i3_query("get_workspaces") if w["num"] >= 1} | set(range(1, 18)))
    rows.append(Item("Move to Workspace", children=[
        Item(str(n), lambda n=n: i3_command(f"{target} move container to workspace number {n}"))
        for n in numbers
    ]))
    rows.append(Item("Close Window", lambda: message("Close the original window?",
                "Unsaved work may be lost.", confirm=True) and i3_command(f"{target} kill")))
    return rows


def i3_shortcuts():
    version = i3_query("get_version")
    config = Path(version["loaded_config_file_name"]).read_text()
    commands = [line.strip() for line in config.splitlines()
                if re.match(r"\s*(?:bindsym\s|bindcode\s|set\s+\$mod\s)", line)]
    text_dialog("i3 Keyboard Shortcuts", "\n".join(commands))


def desktop_menu(key, window):
    manager = file_manager()
    if key == "apple":
        settings = [
            *command("Display Settings", "lxrandr"),
            *command("GTK Appearance", "lxappearance"),
            *command("Wallpaper Settings", "nitrogen"),
            *command("Sound Settings", "pavucontrol"),
        ]
        rows = [Item("About This System", lambda: message("About This System", system_information()))]
        rows += command("Polybar Settings…", str(BASE / "scripts/polybar-settings"))
        if settings:
            rows.append(Item("System Settings…", children=settings))
        if choices := appearance():
            rows.append(Item("Appearance", children=choices))
        rows += command("Applications…", "rofi", "-show", "drun")
        rows += command("Lock Screen", str(BASE.parent / "i3/i3lock-fancy"))
        return rows + power_actions()
    if key == "app":
        return ([Item("Open File Manager", lambda: launch(manager))] if manager else []) + (
            navigation(manager) + command("Search Files", "catfish", str(Path.home()))
        )
    if key == "file":
        def chooser(directory=False):
            if path := choose_location("Open Folder" if directory else "Open File", directory):
                if directory:
                    launch(manager, str(path))
                else:
                    open_path(path)
        rows = command("New Terminal", "kitty")
        if manager:
            rows += [Item("New File Manager Window", lambda: launch(manager))]
        rows += [Item("Open File…", chooser)]
        if manager:
            rows += [Item("Open Folder…", lambda: chooser(True)),
                     Item("New Folder…", lambda: new_folder(manager))]
        return rows
    if key == "edit":
        return command("Clipboard History", "copyq", "show") + command("Clipboard Manager", "copyq", "menu")
    if key == "view":
        theme = appearance()
        labels = ("Light Appearance", "Dark Appearance", "Toggle Appearance")
        for row, label in zip(theme, labels):
            row.label = label
        return (theme + command("Display Settings", "lxrandr") + command("Wallpaper Settings", "nitrogen")
                + command("Reload Polybar", str(BASE / "launch.sh")))
    if key == "go":
        return navigation(manager) + ([Item("Go to Folder…", lambda: go_to_folder(manager))] if manager else [])
    if key == "window":
        return window_actions(window)
    if key == "help":
        return [
            Item("i3 Keyboard Shortcuts", i3_shortcuts),
            Item("Polybar Help", lambda: text_dialog("Polybar Help", (BASE / "README-macos.md").read_text())),
            Item("Theme Switching Help", lambda: message("Appearance", "Apple → Appearance or right-click Apple.\n"
                                                        "Fish command: polybar-theme light|dark|toggle|status")),
            Item("System Information", lambda: message("System Information", system_information())),
        ]
    return []
