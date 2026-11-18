#!/usr/bin/env python3
"""Native controls for Polybar's existing theme and menu visibility settings."""
import configparser
import sys

sys.dont_write_bytecode = True

import gi

gi.require_version("Gtk", "3.0")
gi.require_version("Gdk", "3.0")
from gi.repository import Gdk, Gio, GLib, Gtk, Pango

from bar_preferences import BASE, active_theme, menu_visible, save_visibility
from menu_context import MENU_TIERS

APP_ID = "io.github.polybar.Settings"
ICON = BASE / "assets/polybar-settings.svg"
THEME_SWITCH = BASE / "scripts/theme-switch.sh"

CSS = """
.settings { background: #f4f5f8; color: #22242d; }
.settings.dark { background: #202229; color: #f0f1f6; }
.settings headerbar { background: #f4f5f8; color: #22242d; border-bottom: 1px solid #dcdfe7; box-shadow: none; }
.settings.dark headerbar { background: #202229; color: #f0f1f6; border-color: #353842; }
.section-title { font-weight: bold; font-size: 13pt; }
.secondary { opacity: 0.77; }
.card { padding: 10px; border: 2px solid transparent; border-radius: 12px;
        background: #ffffff; color: #22242d; box-shadow: none; }
.dark .card { background: #2c303a; color: #f0f1f6; }
.card:checked { border-color: #2374dc; }
.dark .card:checked { border-color: #76b3ff; }
.card:focus { outline: 2px dotted #2374dc; outline-offset: 2px; }
.dark .card:focus { outline-color: #76b3ff; }
.preview-surface { padding: 12px 10px; border-radius: 12px; background: #dce3f0; }
.dark .preview-surface { background: #363f53; }
.pill { padding: 4px 9px; border-radius: 12px; font-size: 9pt; }
.visibility { padding: 12px; border-radius: 12px; background: #ffffff; }
.dark .visibility { background: #2c303a; }
.error { color: #bb272e; }
.dark .error { color: #ff999e; }
"""


def label(text, style=None):
    widget = Gtk.Label(label=text, xalign=0)
    if style:
        widget.get_style_context().add_class(style)
    return widget


def palette(theme):
    parser = configparser.ConfigParser(interpolation=None)
    parser.read(BASE / f"themes/{theme}.ini")
    colors = parser["colors"]
    return ("#" + colors["background"][-6:], colors["foreground"], colors["accent"])


def pill(theme, markup, name):
    bg, fg, _ = palette(theme)
    widget = Gtk.Label()
    widget.set_markup(markup)
    widget.get_accessible().set_name(name)
    widget.get_style_context().add_class("pill")
    provider = Gtk.CssProvider()
    provider.load_from_data(f"label {{ background-color: {bg}; color: {fg}; }}".encode())
    widget.get_style_context().add_provider(provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)
    return widget


def glyph(character, family):
    return f'<span font_family="{family}">{character}</span>'


APPLE = glyph("", "Font Awesome 5 Brands")
WORKSPACES = f'{glyph("", "icomoon")}  {glyph("", "Font Awesome 5 Free")}  {glyph("", "Font Awesome 5 Free")}'


class SettingsWindow(Gtk.ApplicationWindow):
    def __init__(self, app):
        super().__init__(application=app, title="Polybar Settings")
        self.set_type_hint(Gdk.WindowTypeHint.DIALOG)
        self.set_position(Gtk.WindowPosition.CENTER)
        self.set_default_size(540, 420)
        self.set_icon_from_file(str(ICON))
        self.get_style_context().add_class("settings")
        header = Gtk.HeaderBar(title="Polybar Settings", show_close_button=True)
        self.set_titlebar(header)
        self.theme_job = None
        self.displayed = None
        self.syncing = False
        css = Gtk.CssProvider()
        css.load_from_data(CSS.encode())
        Gtk.StyleContext.add_provider_for_screen(self.get_screen(), css, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)
        body = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10, margin=20)
        self.add(body)
        body.pack_start(label("Appearance", "section-title"), False, False, 0)
        cards = Gtk.Box(spacing=12, homogeneous=True)
        body.pack_start(cards, False, False, 0)
        self.cards = {}
        group = None
        for theme in ("light", "dark"):
            card = Gtk.RadioButton.new_from_widget(group)
            group = card
            card.set_mode(False)
            card.get_style_context().add_class("card")
            card.get_accessible().set_name(f"{theme.title()} appearance")
            card.set_tooltip_text(f"Use the {theme.title()} Polybar theme")
            segment = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
            segment.add(pill(theme, f"{APPLE}   Finder   File   {WORKSPACES}", f"{theme.title()} appearance sample"))
            title = Gtk.Label(label=theme.title())
            segment.add(title)
            card.add(segment)
            card.connect("toggled", self.on_theme, theme)
            cards.add(card)
            self.cards[theme] = card
        body.pack_start(label("Global Menu", "section-title"), False, False, 0)
        visibility = Gtk.Box(spacing=12)
        visibility.get_style_context().add_class("visibility")
        description = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=4)
        description.add(label("Show Global Menu"))
        description.add(label("Show Finder and menu labels next to Apple.", "secondary"))
        visibility.pack_start(description, True, True, 0)
        self.switch = Gtk.Switch(valign=Gtk.Align.CENTER)
        self.switch.get_accessible().set_name("Show Global Menu")
        self.switch.connect("notify::active", self.on_visibility)
        visibility.pack_end(self.switch, False, False, 0)
        body.pack_start(visibility, False, False, 0)
        body.pack_start(label("Live Preview", "section-title"), False, False, 0)
        self.preview = Gtk.Box(spacing=8)
        self.preview.get_style_context().add_class("preview-surface")
        body.pack_start(self.preview, False, False, 0)
        self.status = label("", "secondary")
        self.status.set_ellipsize(Pango.EllipsizeMode.END)
        body.pack_end(self.status, False, False, 0)
        self.show_all()
        self.sync()
        self.timer = GLib.timeout_add(250, self.sync)
        self.connect("destroy", lambda *_: GLib.source_remove(self.timer))

    def sync(self):
        theme, visible = active_theme(), menu_visible()
        state = (theme, visible)
        if state == self.displayed:
            return GLib.SOURCE_CONTINUE
        self.displayed = state
        self.syncing = True
        style = self.get_style_context()
        if theme == "dark":
            style.add_class("dark")
        else:
            style.remove_class("dark")
        if self.theme_job is None:
            self.cards[theme].set_active(True)
        self.switch.set_active(visible)
        self.syncing = False
        for child in self.preview.get_children():
            child.destroy()
        menu = "  ".join(text for text, _ in MENU_TIERS["full"])
        center = f"  {menu}  │  " if visible else "  "
        self.preview.pack_start(pill(theme, APPLE + center + WORKSPACES,
                                    f'{theme.title()} preview, Global Menu {"shown" if visible else "hidden"}'),
                                False, False, 0)
        self.preview.pack_end(pill(theme, '<span foreground="#299b56">●</span> VPN',
                                  "VPN capsule preview"), False, False, 0)
        self.preview.show_all()
        if self.theme_job is None:
            self.feedback(f"{theme.title()} appearance · Global Menu {'shown' if visible else 'hidden'}")
        return GLib.SOURCE_CONTINUE

    def feedback(self, text, error=False):
        style = self.status.get_style_context()
        if error:
            style.add_class("error")
        else:
            style.remove_class("error")
        self.status.set_text(text)
        self.status.set_tooltip_text(text)

    def on_theme(self, button, theme):
        if button.get_active() and not self.syncing:
            self.apply_theme(theme)

    def apply_theme(self, theme):
        if theme not in self.cards or self.theme_job is not None or active_theme() == theme:
            return
        try:
            self.theme_job = Gio.Subprocess.new([str(THEME_SWITCH), theme],
                Gio.SubprocessFlags.STDOUT_SILENCE | Gio.SubprocessFlags.STDERR_PIPE)
        except GLib.Error as exc:
            self.displayed = None
            self.sync()
            self.feedback(str(exc), error=True)
            return
        for card in self.cards.values():
            card.set_sensitive(False)
        self.feedback(f"Applying {theme.title()} appearance…")
        self.theme_job.communicate_utf8_async(None, None, self.theme_finished)

    def theme_finished(self, job, result):
        try:
            _, _, error = job.communicate_utf8_finish(result)
            failure = None if job.get_successful() else error.strip() or "Theme switch failed."
        except GLib.Error as exc:
            failure = str(exc)
        self.theme_job = None
        if not self.get_visible():
            return
        for card in self.cards.values():
            card.set_sensitive(True)
        self.displayed = None
        self.sync()
        if failure:
            self.feedback(failure, error=True)

    def on_visibility(self, switch, _):
        if not self.syncing:
            self.apply_visibility(switch.get_active())

    def apply_visibility(self, visible):
        try:
            save_visibility(visible)
        except OSError as exc:
            self.displayed = None
            self.sync()
            self.feedback(str(exc), error=True)
            return
        self.sync()


class Settings(Gtk.Application):
    def __init__(self):
        super().__init__(application_id=APP_ID)
        for name, signature, dispatch in (
            ("theme", "s", lambda window, value: window.apply_theme(value.get_string())),
            ("visibility", "b", lambda window, value: window.apply_visibility(value.get_boolean())),
        ):
            action = Gio.SimpleAction.new(name, GLib.VariantType(signature))
            action.connect("activate", lambda _, value, callback=dispatch: self.dispatch(callback, value))
            self.add_action(action)

    def dispatch(self, callback, value):
        if window := self.get_active_window():
            callback(window, value)

    def do_activate(self):
        window = self.get_active_window() or SettingsWindow(self)
        window.present()


if __name__ == "__main__":
    GLib.set_prgname(APP_ID)
    raise SystemExit(Settings().run(sys.argv))
