# Polybar Global Menu verification

The live left capsules now show **Apple | Finder | File | Edit | View | Go | Window | Help | Workspace Icons**. The Apple popup had stalled while asking X11 for a timestamp on the root window. It held the menu lock before GTK could display the dropdown. The fix uses the X11 current-time constant, places the menu four pixels below the clicked capsule, and enters the GTK event loop only after the menu maps.

## Results

| Area | Verified |
| --- | --- |
| Live popup wiring | Apple clicked on DP-1, eDP-1, and HDMI-1. Finder, File, Edit, View, Go, Window, and Help clicked on DP-1. Escape dismissed the menus. The overflow entry point and its Finder submenu worked in X11. All active bars currently use the full tier. |
| Action dispatch | Live About This System, Open File, Go to Folder, and i3 Shortcuts opened dialogs. Intercepted callbacks verified Finder launch, terminal launch, CopyQ, theme selection, Go Home, floating and fullscreen, Help, and close/reboot confirmation. |
| Popup styling | GTK resolved Light background/text/hover to `#f6f6fa / #1d1d1f / #d8e8fa` and Dark to `#25272f / #f5f5f7 / #315f95`. The desktop stayed in Dark. |
| Resizing | The production sizing script reproduced the live widths and increased each one for a simulated added workspace. It stayed within the cap at full, compact, small, and off thresholds. Earlier live resize logs show only the affected left capsule was replaced on workspace add/remove, with no replacements on an equal-width rename. |
| Existing functionality | Workspace icon configuration is unchanged. Windscribe was connected and the center module returned VPN On. The network module rendered Ethernet, Wi-Fi was idle, XKB advertised US and Persian, and the keyboard module remained in the right capsule. The active theme state and symlink agreed. |
| Runtime | 12 live Polybar processes matched the PID files. One workspace listener held its expected lock. No menu process or held popup lock remained. The current bar and listener logs had no matching error or warning entries. |
| Syntax and config | Python compilation, Bash syntax checks, Polybar module-list queries for both theme configurations, and `git diff --check` passed. |

| Output | Live left width | Width with one added workspace (simulated) | Live gap to VPN |
| --- | ---: | ---: | ---: |
| DP-1 | 528 px | 555 px | 186 px |
| eDP-1 | 465 px | 493 px | 409 px |
| HDMI-1 | 473 px | 501 px | 241 px |

## Native application coverage

| Application or fixture | Result |
| --- | --- |
| GTK GMenu test application | Export read over D-Bus from X11-advertised properties. File submenu resolved and its Gio action ran. |
| Canonical dbusmenu test application | Export read over D-Bus from X11-advertised KDE appmenu properties. Exporter received the clicked event. |
| Brave, kitty, mpv, Telegram Desktop, Windscribe | No usable export was available on the live windows. Desktop fallback applies. |
| GNOME Terminal | Isolated X11 window advertised GTK action-group properties without a menu model. Desktop fallback applies for that tested window. |
| Thunar, Mousepad, Nautilus | Isolated runs yielded no usable application window for inspection. Native compatibility remains unverified. |

No installed application was confirmed to expose a usable native export in the tested configurations. An application can support one of these protocols only when it publishes the corresponding menu for its window. To check an exporter manually, focus its window, open Finder, and look for the application submenu. Choose a harmless action there and confirm that the application receives it.

## Remaining limitations

- The sizing code can hide all extra menu labels in the off tier. If workspace icons alone exceed the width cap, the bar can clip them.
- The verification used computed GTK styles and isolated theme callbacks. A manual end-to-end theme check is to right-click Apple once, open a dropdown, verify the alternate palette, dismiss it, and right-click Apple again to restore the original theme.
- Live Wi-Fi connection changes, power actions, window moves, and keymap changes were omitted to preserve session state. The workspace resize check used current geometry, simulated additions, and the existing live resize logs.

## Files

- Changed during this continuation: `scripts/global-menu.py`, `scripts/menu_context.py`, `scripts/workspace-listener.py`, and `README-macos.md`. Added `GLOBAL_MENU_PROGRESS.md` and this report.
- Preserved from the earlier work: `config.ini`, `modules.ini`, `scripts/launch.sh`, `scripts/left-width.py`, `scripts/desktop_menu.py`, `scripts/native_menu.py`, and the active `themes/current.ini` symlink.

## Rollback to the supplied recovery snapshot

The archive at `~/.config-global-menu-resume-20261118-211222-yTNdt1/polybar.tar` contains the pre-continuation Global Menu implementation, including the old Apple popup code. To restore only the three implementation files changed in this continuation, save the current versions, extract those files to a staging directory, and copy the reviewed versions back together:

```bash
cd "$HOME/.config/polybar" || exit
stage=$(mktemp -d) || exit
archive="$HOME/.config-global-menu-resume-20261118-211222-yTNdt1/polybar.tar"
files=(scripts/global-menu.py scripts/menu_context.py scripts/workspace-listener.py)
mkdir "$stage/current" || exit
cp -p -- "${files[@]}" "$stage/current/" || exit
tar -xf "$archive" -C "$stage" "${files[@]/#/polybar/}" || exit
diff -u -- "$stage/polybar/scripts/global-menu.py" scripts/global-menu.py
# Review the staged files before restoring them.
for file in "${files[@]}"; do cp -p -- "$stage/polybar/$file" "$file" || exit; done
```

After restoring, replace only the Polybar workspace listener so it loads the restored code. Read `~/.local/state/polybar-menu/watcher.pid` and verify that PID runs this installation’s `scripts/workspace-listener.py` before sending it TERM. Once it exits, start `scripts/watch-monitors.sh` in the background with its output directed to the Polybar cache log. The listener refreshes the menu cache through Polybar IPC. The recovery archive, Git references, and i3 can stay as they are.
