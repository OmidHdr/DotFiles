"""Read menu exports belonging to the focused X11 window."""
from dataclasses import dataclass, field
import re
import subprocess

from gi.repository import Gio, GLib


@dataclass
class Item:
    label: str
    activate: object = None
    children: list = field(default_factory=list)
    enabled: bool = True
    checked: bool | None = None


PROPERTIES = (
    "_KDE_NET_WM_APPMENU_SERVICE_NAME", "_KDE_NET_WM_APPMENU_OBJECT_PATH",
    "_GTK_UNIQUE_BUS_NAME", "_GTK_MENUBAR_OBJECT_PATH", "_GTK_APP_MENU_OBJECT_PATH",
    "_GTK_APPLICATION_OBJECT_PATH", "_GTK_WINDOW_OBJECT_PATH",
)


def window_properties(xid):
    try:
        output = subprocess.check_output(
            ["xprop", "-id", str(xid), *PROPERTIES], text=True, timeout=1,
            stderr=subprocess.DEVNULL,
        )
    except (OSError, subprocess.SubprocessError):
        return {}
    return dict(re.findall(r'^([A-Z_]+)\([^)]*\) = "([^"\n]+)"$', output, re.M))


def clean_label(label, mnemonic):
    escaped = mnemonic * 2
    label = re.sub(re.escape(mnemonic) + r"(?!"+ re.escape(mnemonic) + r")|"
                   + re.escape(escaped), lambda m: mnemonic if m[0] == escaped else "", label)
    return "".join(char for char in label if char.isprintable())


def call(bus, service, path, interface, method, signature, args):
    return bus.call_sync(service, path, interface, method, GLib.Variant(signature, args),
                         None, Gio.DBusCallFlags.NO_AUTO_START, 550, None)


def canonical_menu(bus, service, path):
    interface = "com.canonical.dbusmenu"

    def request(method, signature, args):
        return call(bus, service, path, interface, method, signature, args)

    def load(parent, depth):
        try:
            request("AboutToShow", "(i)", (parent,))
        except GLib.Error:
            pass
        _, (_, _, children) = request("GetLayout", "(iias)", (parent, 1, [])).unpack()
        rows = []
        for ident, props, _ in children[:100]:
            if not props.get("visible", True):
                continue
            if props.get("type") == "separator":
                rows.append(Item(""))
                continue
            label = clean_label(props.get("label", ""), "_")
            if not label:
                continue
            enabled = props.get("enabled", True)
            submenu = props.get("children-display") == "submenu"
            nested = load(ident, depth - 1) if submenu and depth and enabled else []
            toggle = props.get("toggle-state") if props.get("toggle-type") else None
            action = None if submenu else lambda ident=ident: request(
                "Event", "(isvu)", (ident, "clicked", GLib.Variant("i", 0), 0)
            )
            rows.append(Item(label, action, nested, enabled, bool(toggle) if toggle is not None else None))
        return rows
    return load(0, 3)


def gtk_menu(bus, props):
    service = props["_GTK_UNIQUE_BUS_NAME"]
    paths = {"app": props.get("_GTK_APPLICATION_OBJECT_PATH"), "win": props.get("_GTK_WINDOW_OBJECT_PATH")}
    groups = {key: Gio.DBusActionGroup.get(bus, service, path) for key, path in paths.items() if path}
    models = [
        Gio.DBusMenuModel.get(bus, service, props[key])
        for key in ("_GTK_MENUBAR_OBJECT_PATH", "_GTK_APP_MENU_OBJECT_PATH") if key in props
    ]
    def drain():
        context = GLib.MainContext.default()
        for _ in range(32):
            if not context.pending():
                break
            context.iteration(False)

    def warm(models):
        for model in models:
            model.get_n_items()
        for group in groups.values():
            group.list_actions()
        if not models:
            return
        loop = GLib.MainLoop()
        GLib.timeout_add(55, lambda: (loop.quit(), False)[1])
        loop.run()
        drain()

    def convert(model, depth):
        if depth == 0:
            return []
        links = []
        for idx in range(min(model.get_n_items(), 100)):
            links.append((idx, model.get_item_link(idx, "section"), model.get_item_link(idx, "submenu")))
        warm([link for _, section, submenu in links for link in (section, submenu) if link is not None])
        rows = []
        for idx, section, submenu in links:
            if section is not None:
                if rows:
                    rows.append(Item(""))
                rows.extend(convert(section, depth - 1))
                continue
            value = model.get_item_attribute_value(idx, "label", None)
            if value is None:
                continue
            label = clean_label(value.get_string(), "_")
            if submenu is not None:
                nested = convert(submenu, depth - 1)
                if nested:
                    rows.append(Item(label, children=nested))
                continue
            action = model.get_item_attribute_value(idx, "action", None)
            if action is None or "." not in action.get_string():
                continue
            prefix, name = action.get_string().split(".", 1)
            group = groups.get(prefix)
            if group is None or not group.has_action(name):
                continue
            target = model.get_item_attribute_value(idx, "target", None)
            state = group.get_action_state(name)
            checked = (state.equal(target) if target is not None else state.get_boolean()) if (
                state is not None and (target is not None or state.is_of_type(GLib.VariantType("b")))
            ) else None
            def activate(group=group, name=name, target=target):
                group.activate_action(name, target)
                bus.flush_sync(None)
            rows.append(Item(label, activate, enabled=group.get_action_enabled(name), checked=checked))
        return rows
    warm(models)
    return [item for model in models for item in convert(model, 5)]


def exported_menu(xid):
    if not xid:
        return []
    props = window_properties(xid)
    try:
        bus = Gio.bus_get_sync(Gio.BusType.SESSION, None)
    except GLib.Error:
        return []
    endpoints = []
    if all(key in props for key in PROPERTIES[:2]):
        endpoints.append(tuple(props[key] for key in PROPERTIES[:2]))
    if "_GTK_UNIQUE_BUS_NAME" in props:
        try:
            rows = gtk_menu(bus, props)
            if rows:
                return rows
        except (GLib.Error, TypeError, ValueError):
            pass
    if not endpoints:
        try:
            endpoints.append(call(bus, "com.canonical.AppMenu.Registrar", "/com/canonical/AppMenu/Registrar",
                                  "com.canonical.AppMenu.Registrar", "GetMenuForWindow", "(u)", (xid,)).unpack())
        except GLib.Error:
            pass
    for service, path in endpoints:
        if not Gio.dbus_is_name(service) or not GLib.Variant.is_object_path(path):
            continue
        try:
            rows = canonical_menu(bus, service, path)
            if rows:
                return rows
        except GLib.Error:
            pass
    return []
