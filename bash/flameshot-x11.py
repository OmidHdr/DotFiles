"""Expand the Flameshot capture window from output to root fullscreen on i3."""
import fcntl
import json
import os
from pathlib import Path
import subprocess
import sys
import time

I3_ENV = {key: value for key, value in os.environ.items() if key != "I3SOCK"}


def i3(*args):
    return json.loads(subprocess.check_output(["i3-msg", "-r", *args], env=I3_ENV,
                                              text=True, timeout=1))


def overlay_ids(node):
    properties = node.get("window_properties") or {}
    if (node.get("fullscreen_mode") in (1, 2)
            and (properties.get("class") or "").casefold() == "flameshot"
            and node.get("window")):
        yield node["window"]
    for child in node["nodes"] + node["floating_nodes"]:
        yield from overlay_ids(child)


def main():
    runtime = Path(os.environ.get("XDG_RUNTIME_DIR", Path.home() / ".cache"))
    runtime.mkdir(parents=True, exist_ok=True)
    with (runtime / "flameshot-x11-launch.lock").open("a") as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            return 0
        if any(overlay_ids(i3("-t", "get_tree"))):
            return 0
        if sys.argv[1:]:
            command = ["/usr/bin/flameshot", "gui", *sys.argv[1:]]
        else:
            command = ["dbus-send", "--session", "--type=method_call",
                       "--dest=org.flameshot.Flameshot", "/",
                       "org.flameshot.Flameshot.captureScreen"]
        capture = subprocess.Popen(command)
        deadline = time.monotonic() + 3
        while time.monotonic() < deadline:
            new = set(overlay_ids(i3("-t", "get_tree")))
            if len(new) == 1:
                window, = new
                # i3 ignores a global enable on a container already fullscreen.
                i3(f'[id="{window:#x}"] fullscreen disable, fullscreen enable global')
                break
            if capture.poll() not in (None, 0):
                return capture.returncode
            time.sleep(.04)
    return capture.wait()


if __name__ == "__main__":
    raise SystemExit(main())
