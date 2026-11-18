#!/usr/bin/env python3
"""Keep Plank's animation surface separate from i3's bottom dock reservation."""
import ctypes as c
import fcntl
import json
import os
from pathlib import Path
import signal
import subprocess
import time

import gi

gi.require_version("Gio", "2.0")
from gi.repository import Gio, GLib

X = c.CDLL("libX11.so.6")
SHAPE = c.CDLL("libXext.so.6")
D, W, I, U = c.c_void_p, c.c_ulong, c.c_int, c.c_uint


class WindowAttributes(c.Structure):
    _fields_ = [
        ("background_pixmap", W), ("background_pixel", W),
        ("border_pixmap", W), ("border_pixel", W),
        ("bit_gravity", I), ("win_gravity", I), ("backing_store", I),
        ("backing_planes", W), ("backing_pixel", W), ("save_under", I),
        ("event_mask", c.c_long), ("do_not_propagate_mask", c.c_long),
        ("override_redirect", I), ("colormap", W), ("cursor", W),
    ]


def bind(lib, name, result, *args):
    function = getattr(lib, name)
    function.restype = result
    function.argtypes = args
    return function


open_display = bind(X, "XOpenDisplay", D, c.c_char_p)
close_display = bind(X, "XCloseDisplay", I, D)
root_window = bind(X, "XDefaultRootWindow", W, D)
atom = bind(X, "XInternAtom", W, D, c.c_char_p, I)
free = bind(X, "XFree", I, D)
sync = bind(X, "XSync", I, D, I)
create = bind(X, "XCreateSimpleWindow", W, D, W, I, I, U, U, U, W, W)
title = bind(X, "XStoreName", I, D, W, c.c_char_p)
move = bind(X, "XMoveWindow", I, D, W, I, I)
map_window = bind(X, "XMapWindow", I, D, W)
unmap = bind(X, "XUnmapWindow", I, D, W)
destroy = bind(X, "XDestroyWindow", I, D, W)
override = bind(X, "XChangeWindowAttributes", I, D, W, W, c.POINTER(WindowAttributes))
query = bind(X, "XQueryTree", I, D, W, c.POINTER(W), c.POINTER(W), c.POINTER(c.POINTER(W)), c.POINTER(U))
geometry = bind(X, "XGetGeometry", I, D, W, c.POINTER(W), c.POINTER(I), c.POINTER(I),
                c.POINTER(U), c.POINTER(U), c.POINTER(U), c.POINTER(U))
translate = bind(X, "XTranslateCoordinates", I, D, W, W, I, I, c.POINTER(I), c.POINTER(I), c.POINTER(W))
get_property = bind(X, "XGetWindowProperty", I, D, W, W, c.c_long, c.c_long, I, W,
                    c.POINTER(W), c.POINTER(I), c.POINTER(W), c.POINTER(W), c.POINTER(c.POINTER(W)))
change_property = bind(X, "XChangeProperty", I, D, W, W, W, I, I, c.POINTER(W), I)
shape_empty = bind(SHAPE, "XShapeCombineRectangles", None, D, W, I, I, I, D, I, I, I)
shape_reset = bind(SHAPE, "XShapeCombineMask", None, D, W, I, I, I, W, I)
ERROR_HANDLER = c.CFUNCTYPE(I, D, D)
# Windows can disappear between a query and a request as clients close.
ignore_x_error = ERROR_HANDLER(lambda *_: 0)
bind(X, "XSetErrorHandler", D, ERROR_HANDLER)(ignore_x_error)


def run(*args):
    return subprocess.run(args, capture_output=True, text=True, timeout=2)


def descendants(node):
    yield node
    for child in node["nodes"] + node["floating_nodes"]:
        yield from descendants(child)


class Reservation:
    def __init__(self):
        self.display = open_display(None)
        if not self.display:
            raise RuntimeError("Cannot open X11 display")
        self.root = root_window(self.display)
        self.atoms = {}
        self.dock = self.proxy = 0
        self.plan = self.frame = None
        self.suppressed = False
        self.prefs = Gio.Settings.new_with_path("net.launchpad.plank.dock.settings",
                                                "/net/launchpad/plank/docks/dock1/")

    def atom(self, name):
        if name not in self.atoms:
            self.atoms[name] = atom(self.display, name.encode(), False)
        return self.atoms[name]

    def prop(self, window, name):
        data = c.POINTER(W)()
        count, remain, kind, fmt = W(), W(), W(), I()
        get_property(self.display, window, self.atom(name), 0, 12, False, 0,
                     c.byref(kind), c.byref(fmt), c.byref(count), c.byref(remain), c.byref(data))
        try:
            return tuple(data[i] for i in range(count.value)) if data and fmt.value == 32 else ()
        finally:
            if data:
                free(data)

    def set_prop(self, window, name, kind, values):
        change_property(self.display, window, self.atom(name), self.atom(kind),
                        32, 0, (W * len(values))(*values), len(values))

    def parent(self, window):
        root, parent, children, count = W(), W(), c.POINTER(W)(), U()
        query(self.display, window, c.byref(root), c.byref(parent), c.byref(children), c.byref(count))
        if children:
            free(children)
        return parent.value

    def rect(self, window):
        root, child, x, y = W(), W(), I(), I()
        width, height, border, depth = U(), U(), U(), U()
        if not geometry(self.display, window, c.byref(root), c.byref(x), c.byref(y),
                        c.byref(width), c.byref(height), c.byref(border), c.byref(depth)):
            return None
        translate(self.display, window, self.root, 0, 0, c.byref(x), c.byref(y), c.byref(child))
        return x.value, y.value, width.value, height.value

    def remap(self, window, unmanaged):
        position = self.rect(window)
        if position is None:
            return False
        unmap(self.display, window)
        sync(self.display, False)
        for _ in range(30):
            if self.parent(window) == self.root:
                attrs = WindowAttributes(override_redirect=unmanaged)
                override(self.display, window, 1 << 9, c.byref(attrs))
                move(self.display, window, *position[:2])
                map_window(self.display, window)
                sync(self.display, False)
                return True
            time.sleep(.02)
        map_window(self.display, window)
        sync(self.display, False)
        return False

    def find_dock(self):
        for candidate in run("xdotool", "search", "--class", "^Plank$").stdout.split():
            window = int(candidate)
            if self.atom("_NET_WM_WINDOW_TYPE_DOCK") in self.prop(window, "_NET_WM_WINDOW_TYPE"):
                return window
        return 0

    def reserve(self, plan):
        if plan != self.plan:
            if self.proxy:
                destroy(self.display, self.proxy)
            self.proxy, self.frame = 0, None
            self.plan = plan
            if plan:
                x, y, width, height, bottom = plan
                self.proxy = create(self.display, self.root, x, y, width, height, 0, 0, 0)
                title(self.display, self.proxy, b"Plank space reservation")
                self.set_prop(self.proxy, "_NET_WM_WINDOW_TYPE", "ATOM",
                              (self.atom("_NET_WM_WINDOW_TYPE_DOCK"),))
                self.set_prop(self.proxy, "_NET_WM_STRUT", "CARDINAL", (0, 0, 0, bottom))
                self.set_prop(self.proxy, "_NET_WM_STRUT_PARTIAL", "CARDINAL",
                              (0, 0, 0, bottom, 0, 0, 0, 0, 0, 0, x, x + width - 1))
                self.set_prop(self.proxy, "_NET_WM_WINDOW_OPACITY", "CARDINAL", (0,))
                shape_empty(self.display, self.proxy, 0, 0, 0, None, 0, 0, 0)
                shape_empty(self.display, self.proxy, 2, 0, 0, None, 0, 0, 0)
                map_window(self.display, self.proxy)
                print(f"Plank reservation: {width}×{height}+{x}+{y} (root bottom strut {bottom})", flush=True)
            # Submit deletion even when no dock is left to query on this tick.
            sync(self.display, False)
        if self.proxy:
            frame = self.parent(self.proxy)
            if frame and frame not in (self.root, self.frame):
                self.frame = frame
                shape_empty(self.display, frame, 0, 0, 0, None, 0, 0, 0)
                shape_empty(self.display, frame, 2, 0, 0, None, 0, 0, 0)

    def suppress(self, yes):
        if yes != self.suppressed:
            if yes:
                shape_empty(self.display, self.dock, 0, 0, 0, None, 0, 0, 0)
            else:
                shape_reset(self.display, self.dock, 0, 0, 0, 0, 0)
            self.suppressed = yes

    def update(self):
        if self.dock and self.rect(self.dock) is None:
            self.dock, self.suppressed = 0, False
        if self.prefs.get_string("position") != "bottom":
            self.release()
            return
        candidate = self.dock or self.find_dock()
        if not candidate:
            self.reserve(None)
            return
        # Discover i3 from this X display, even if a parent shell exported
        # an IPC socket belonging to a different display.
        result = run("env", "-u", "I3SOCK", "i3-msg", "-t", "get_tree")
        if result.returncode:
            self.reserve(None)
            return
        tree = json.loads(result.stdout)
        position = self.rect(candidate)
        if position is None:
            return
        px, py, pw, ph = position
        outputs = [node for node in tree["nodes"] if node["type"] == "output" and not node["name"].startswith("__")]
        def proximity(node):
            r = node["rect"]
            overlap = max(0, min(px + pw, r["x"] + r["width"]) - max(px, r["x"]))
            return overlap, -abs(py + ph - r["y"] - r["height"])
        if not outputs:
            self.reserve(None)
            return
        output = max(outputs, key=proximity)
        x, y, width, height = (output["rect"][name] for name in ("x", "y", "width", "height"))
        global_fullscreen = any(node["fullscreen_mode"] == 2 for node in descendants(tree))
        active = next((node for node in descendants(output)
                       if node["type"] == "workspace" and node["fullscreen_mode"] == 1), None)
        fullscreen = global_fullscreen or bool(active and any(
            node["fullscreen_mode"] for node in descendants(active) if node["type"] != "workspace"))
        if not self.dock:
            self.dock = candidate
            self.suppress(fullscreen)
            if not self.remap(candidate, True):
                self.suppress(False)
                self.dock = 0
                return
        self.suppress(fullscreen)
        strut = self.prop(self.dock, "_NET_WM_STRUT_PARTIAL")
        root_height = self.rect(self.root)[3]
        bottom = y + height
        depth = strut[3] - (root_height - bottom) if len(strut) == 12 else 0
        matches_output = len(strut) == 12 and x <= strut[10] <= strut[11] < x + width
        if (self.prefs.get_string("hide-mode") == "none" and matches_output
                and proximity(output)[0] > 0 and 0 < depth <= ph):
            reserved = depth
            self.reserve((x, bottom - reserved, width, reserved, root_height - bottom + reserved))
        else:
            self.reserve(None)
        sync(self.display, False)

    def release(self):
        self.reserve(None)
        if self.dock:
            self.suppress(False)
            self.remap(self.dock, False)
            self.dock = 0
        sync(self.display, False)


def main():
    runtime = Path(os.environ.get("XDG_RUNTIME_DIR", Path.home() / ".cache"))
    runtime.mkdir(parents=True, exist_ok=True)
    display_name = os.environ.get("DISPLAY", "").replace("/", "_")
    with (runtime / f"plank-reservation-{display_name}.lock").open("a") as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            return
        reservation = Reservation()
        stopping = False

        def stop(*_):
            nonlocal stopping
            stopping = True

        signal.signal(signal.SIGTERM, stop)
        signal.signal(signal.SIGINT, stop)
        try:
            while not stopping:
                try:
                    # Deliver dconf's cross-process preference notifications.
                    context = GLib.MainContext.default()
                    while context.pending():
                        context.iteration(False)
                    reservation.update()
                except (OSError, subprocess.SubprocessError, ValueError) as error:
                    reservation.reserve(None)
                    print(error, flush=True)
                time.sleep(.35)
        finally:
            reservation.release()
            close_display(reservation.display)


if __name__ == "__main__":
    main()
