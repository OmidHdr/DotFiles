"""Persistent visibility and the existing theme controller's state."""
import os
from pathlib import Path
from tempfile import NamedTemporaryFile

BASE = Path(__file__).resolve().parents[1]
STATE = Path(os.environ.get("XDG_STATE_HOME", Path.home() / ".local/state")) / "polybar-menu"
CACHE = Path(os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache")) / "polybar-menu"
PREFERENCES = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config")) / "polybar"
VISIBILITY = PREFERENCES / "global-menu-visibility"


def read_choice(path, choices, default):
    try:
        value = path.read_text().strip()
    except (OSError, UnicodeError):
        return default
    return value if value in choices else default


def menu_visible():
    return read_choice(VISIBILITY, ("show", "hide"), "show") == "show"


def active_theme():
    return read_choice(STATE / "theme", ("light", "dark"), "light")


def save_visibility(visible):
    VISIBILITY.parent.mkdir(parents=True, exist_ok=True)
    with NamedTemporaryFile(mode="w", dir=VISIBILITY.parent, prefix=".visibility-", delete=False) as staged:
        temporary = Path(staged.name)
        try:
            staged.write("show\n" if visible else "hide\n")
            staged.flush()
            os.fsync(staged.fileno())
            os.replace(temporary, VISIBILITY)
        finally:
            temporary.unlink(missing_ok=True)
