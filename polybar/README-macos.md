# macOS-style Polybar: Wi-Fi, local resizing, original icons

Current theme: Light. All configuration and scripts are installed; no packages, fonts, network services, i3 bindings, or Picom settings were installed/changed by this fix.

## Root causes and fixes

1. The old network click handler tried a missing `nm-connection-editor`, then only showed a notification. The network module now invokes `scripts/wifi-menu.sh` → `wifi-menu.py`, a NetworkManager/Rofi menu. The legacy `network.sh info` entry point delegates to it too.
2. The old five-second watcher called the complete `launch.sh` on workspace membership changes. That killed/relaunched every Polybar process, including transparent reservation docks. i3 did not restart; temporarily losing dock struts caused visible desktop relayout. `watch-monitors.sh` now runs `workspace-listener.py`, which subscribes to native i3 workspace/output events. Workspace init/empty/move/rename events recompute widths under the same control lock as theme changes. A width change terminates/replaces only that output's verified left-bar PID. Focus/urgency changes need no replacement, and equal widths cause no replacement. Center, right and reservation windows remain running. Real monitor topology changes can still invoke the existing full launcher so monitor hotplug behavior is preserved.
3. The previous icon-only design used the requested alternative mapping instead of the original familiar mapping. `modules.ini` now copies all 17 original mappings exactly from the untouched legacy `config`. The installed original IcoMoon, Font Awesome 5 Free Solid, and Font Awesome 5 Brands fonts are used, with fallback ordering chosen to preserve their original glyphs. No glyph was substituted.

## Wi-Fi menu

Click the network icon. The current active Internet connection is wired; wlan0 is a NetworkManager-managed Wi-Fi adapter, currently enabled but disconnected. The icon may therefore show Ethernet while still opening Wi-Fi management.

The menu provides available SSIDs, signal percentages, security type, a connected marker, Refresh, Saved connections, and Enable/Disable Wi-Fi. Disconnect appears only when the selected Wi-Fi adapter is connected. Disable and Disconnect require a second menu selection. Adapter selection is offered with multiple Wi-Fi adapters. Missing or unmanaged adapters are handled without changing ownership or starting another service.

A visible network uses an existing matching saved profile when available (UUID and interface, plus BSSID), or connects by BSSID. Saved connections can also be selected directly by UUID. Saved enterprise profiles are supported; creating a new enterprise/EAP configuration needs a preconfigured NetworkManager profile and is not guessed by this menu.

SSID/profile strings are displayed as plain text and selected by numeric row index. Escaped nmcli fields are decoded; display control characters are sanitized. No shell evaluation is used. `nmcli` receives argument arrays, and a new network is selected by validated BSSID, so SSIDs containing spaces, Unicode, colons, apostrophes, dollar signs, or shell-like text cannot become shell commands/options.

Passwords are requested using a masked Rofi entry and passed to `nmcli --ask` through an anonymous PTY with echo disabled. They are never placed in process argv, environment variables, temporary files, scripts, logs, or this configuration. Normal saved credential persistence remains NetworkManager's responsibility. Rofi history is disabled. No diagnostic output from the credential conversation is logged. Cancel exits the prompt/activation attempt.

Only explicit user menu actions activate/disconnect/disable connections. Merely opening the menu does not rescan, connect or change radio settings. Refresh explicitly requests a Wi-Fi scan without disconnecting the active connection.

## Workspace mapping

```ini
ws-icon-0 = 1;
ws-icon-1 = 2;
ws-icon-2 = 3;
ws-icon-3 = 4;
ws-icon-4 = 5;
ws-icon-5 = 6;
ws-icon-6 = 7;
ws-icon-7 = 8;
ws-icon-8 = 9;
ws-icon-9 = 10;
ws-icon-10 = 11;
ws-icon-11 = 12;
ws-icon-12 = 13;
ws-icon-13 = 14;
ws-icon-14 = 15;
ws-icon-15 = 16;
ws-icon-16 = 17;
```

Actual i3 workspace names are numeric. Exact matching is used; mapping entry indices are not display positions and do not rename workspaces. Mod+0 still means workspace 10. Other workspaces use the existing neutral desktop fallback. Native `internal/i3` handles clicks, output pinning, scrolling, active/visible/urgent states. Only icons are rendered. No desktop/app/title/name/number labels are displayed.

The left capsule preserves Apple → icons, real rounded capsule corners, and round blue/red icon highlights. The Apple glyph and system icons retain installed font fallbacks. The width helper measures the original glyphs, including the IcoMoon and Font Awesome brand glyphs, rather than assuming a monospace font.

## Global Menu

The full left capsule shows Apple, Finder, File, Edit, View, Go, Window, Help, and the workspace icons. On narrow displays, an ellipsis gives access to sections hidden by the compact layout. Use the arrow keys and Enter to navigate and Escape to dismiss.

Finder provides file-manager shortcuts. When the focused X11 window publishes a usable GTK GMenu or Canonical dbusmenu export, Finder also includes an application submenu. File, Edit, View, Go, Window, and Help use matching native sections when available, with desktop actions as the fallback. See [the verification report](GLOBAL_MENU_FINAL_REPORT.md) for application coverage and rollback instructions.

## Polybar Settings

Open **Apple → Polybar Settings…**, choose **Polybar Settings** from the application launcher, or run `polybar-settings`. The two appearance cards use the existing theme switcher. The Global Menu switch leaves Apple and the workspace icons available in both states and updates every left capsule.

Visibility is saved as `show` or `hide` in `${XDG_CONFIG_HOME:-$HOME/.config}/polybar/global-menu-visibility`. A missing or invalid preference defaults to showing the menu. The existing `polybar-theme` command and Apple right-click shortcut remain available.

See [the settings report](POLYBAR_SETTINGS_FINAL_REPORT.md) for verification, screenshots, launcher installation, and rollback.

## Themes and runtime

```sh
polybar-theme light
polybar-theme dark
polybar-theme toggle
polybar-theme status
```

Left-click Apple to open the system menu. Right-click Apple or use Apple → Appearance to switch themes. The same commands work from Fish. Existing i3 autostart still runs `~/.config/polybar/launch.sh`; it starts a single listener, protected by flock. The theme controller and listener share the control lock, so a theme switch cannot race a left-bar replacement. The listener verifies a PID's actual Polybar command/config before terminating it, copies that bar's current monitor/DPI environment, and updates its individual PID file. Child wait threads prevent zombies.

Logs: `~/.cache/polybar-menu/`. Individual PID files are `MONITOR-left.pid`, `MONITOR-center.pid`, etc. The current three-monitor setup has 12 intended Polybar instances: three capsules plus a transparent reservation dock per output. Theme state is `~/.local/state/polybar-menu/theme`. The center VPN detection/script and geometry are unchanged.

## Actual validation

- Confirmed `GENERAL.NM-MANAGED=yes` for wlan0; NetworkManager and Rofi already installed. No new manager was started, no network ownership changed.
- Opened the Wi-Fi menu by clicking the actual right-side network icon. Read available SSIDs/signal/security, exercised Refresh, and opened the real Saved connections menu. Seventeen saved Wi-Fi profiles were readable.
- Both Light and Dark menus captured and inspected. A standalone invocation of the actual credential-entry function displayed masked synthetic input; a fake nmcli subprocess tested secret delivery through the PTY without any network operation.
- Simulated missing adapter, unmanaged adapter, disabled radio, connected AP marker, escaped colon/backslash SSIDs and shell-like SSID strings. These paths passed without changing the real adapter/radio.
- All 17 mappings compared exactly against original `~/.config/polybar/config`. Every required codepoint verified in the original installed font cmaps. Restored browser (1), terminal (2), folder (3), and lock (17) buttons clicked successfully in the live desktop. Native scroll and urgent styling remain configured as before.
- Creating test workspace 99 changed only eDP-1's left PID and expanded its width 183 → 214px. Leaving the empty test workspace shrank it to 183px and again changed only that left PID. Every center/right/reservation PID remained unchanged. i3 and Picom PIDs remained unchanged; an i3 IPC audit reported no reload/restart event.
- Renaming only a temporary test workspace from 99 to 98 kept the same required width and caused zero Polybar restarts. After deleting the empty test workspace, existing user-window workspace assignments, geometry and layouts matched the pre-test snapshot exactly.
- Apple toggled Dark → Light successfully; Light is active. Final counts: 12 Polybar processes, one i3, one Picom, one workspace listener. No final Polybar configuration/glyph warnings. Python/Bash syntax checks passed.
- Windscribe still reports connected. Active wired/bridge/loopback UUIDs were identical before and after network menu tests. No live Wi-Fi activation, disconnection, radio disable, or real password submission was performed. Live connection success and polkit permissions remain unverified until the user chooses a network.
- Physical monitor hotplug and login/reboot were not exercised; existing startup integration is unchanged.

Screenshots are in `screenshots/`: `restored-light.png`, `restored-dark.png`, `restored-all-monitors.png`, `wifi-menu.png`, `wifi-menu-dark.png`, `wifi-saved.png`, and `wifi-password-test.png`. Runtime evidence: `resize-validation.log`, `resize-events.log`, and `noop-resize-validation.log` in the cache directory.

## Files changed

Modified: `config.ini`, `modules.ini`, `scripts/launch.sh`, `scripts/watch-monitors.sh`, `scripts/left-width.py`, `scripts/network.sh`, and this README.
Added: `scripts/workspace-listener.py`, `scripts/wifi-menu.py`, `scripts/wifi-menu.sh`.

Theme INIs, theme-switch controller, VPN script, Picom config, i3 config and autostart are unchanged by this fix. No package installation is needed.

## Backup and rollback

Pre-fix files are preserved under:

`~/.config/polybar/backups/wifi-resize-original-icons-20261116-060647/`

To restore exactly those files and remove the new scripts:

```sh
bash ~/.config/polybar/backups/wifi-resize-original-icons-20261116-060647/restore.sh
```

The restore script stops the event listener, replaces the bars/configuration with the previous setup, and starts the previous launcher via i3 exec. It does not reload/restart i3 or run any network command. The older full-original backup and original rollback script remain available separately.

References: [i3 IPC](https://i3wm.org/docs/ipc.html), [NetworkManager nmcli](https://networkmanager.dev/docs/api/latest/nmcli).
