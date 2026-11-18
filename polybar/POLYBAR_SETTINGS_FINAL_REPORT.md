# Polybar Settings final report

Open **Apple → Polybar Settings…**, search for **Polybar Settings** in the application launcher, or run `polybar-settings`. The application reuses the existing theme switcher and previews both menu visibility states. The original Dark appearance and default-enabled Global Menu were restored after testing.

## Sizing correction

The old sizing code reserved 380 pixels for the full menu and estimated the workspace widths using fixed font choices and one combined offset. The menu actually consumes 309 pixels at the session's 96 DPI. The new sizing code measures the same font patterns, fallback order, glyph advances, spacing tags, separator, and padding as the rendered layout. It measures only workspaces rendered by the pinned i3 module and only the selected menu tier. It uses the final workspace glyph as the 13-pixel padding reference. The 16-pixel minimum clearance policy before the VPN capsule still applies.

Polybar takes width from its startup configuration. The existing listener uses Polybar IPC to refresh the menu cache and replaces just the affected left instances when their width or menu tier changes. It leaves those instances alone when the computed layout is unchanged. Theme changes continue to use the existing full Polybar theme relaunch. i3 was never restarted or reloaded.

## Live X11 results

Widths and clearances are in pixels. Every row passed the measured-width, menu markup, rounded-corner, screenshot padding, and VPN clearance checks on all three monitors.

| Theme | Global Menu | DP-1 width / gap | eDP-1 width / gap | HDMI-1 width / gap | Last icon padding |
| --- | --- | ---: | ---: | ---: | ---: |
| Light | Shown | 458 / 256 | 424 / 450 | 403 / 311 | 14 px |
| Light | Hidden | 149 / 565 | 115 / 759 | 94 / 620 | 14 px |
| Dark | Shown | 458 / 256 | 424 / 450 | 403 / 311 | 14 px |
| Dark | Hidden | 149 / 565 | 115 / 759 | 94 / 620 | 14 px |

- Before the change, the left widths were 528, 465, and 473 pixels on DP-1, eDP-1, and HDMI-1 respectively. The final eDP-1 measurement includes an additional workspace created during the session. At the original workspace count its adjusted width was 395 pixels.
- Switching menu visibility removed or restored all seven labels, their action regions, and their divider. Hidden mode removed 309 pixels per monitor. Center, right, and reserve PIDs remained unchanged within each theme's visibility cycle.
- Hiding the menu closed an open File dropdown and released its lock. With menus hidden, clicking Apple's **Polybar Settings…** entry opened Settings. The terminal command and installed desktop entry reused the same window on repeat launches. Closing Settings left Polybar running.
- In Dark/hidden, a real workspace add and removal on eDP-1 resized the left capsule from 115 to 145 and back to 115 pixels. That targeted relaunch kept the saved hidden preference. In Dark/shown, clicking the workspace 8 icon focused workspace 8 and restarted no bars. The original workspace was restored.
- Atomic settings writes, corrupt or missing preference defaults, external state synchronization, and preview updates passed an isolated GTK test. Baseline theme storage and theme files were preserved.
- The final audit found 12 distinct Polybar processes, one listener, no Settings or dropdown process, and no held menu or control lock. Python and Bash syntax, Polybar module queries, sizing tier checks at 72/96/120/144 DPI, and `git diff --check` passed. Windscribe reported VPN On. The network indicator returned its Ethernet label, and XKB still exposed US/Persian.

## Screenshots

The screenshot files and JSON geometry records are in the private backup directory. Root captures can show an app covering a capsule, so each configuration also has direct captures of the three left X11 windows.

- [Before sizing](/home/h0p3/.polybar-settings-20261118-220003-pYfzrp/screenshots/01-before.png) and [final Dark desktop strip](/home/h0p3/.polybar-settings-20261118-220003-pYfzrp/screenshots/dark-show.png)
- [Apple Settings entry with Global Menu hidden](/home/h0p3/.polybar-settings-20261118-220003-pYfzrp/screenshots/apple-settings-entry.png)

| Config | Settings window | Real left capsule captures |
| --- | --- | --- |
| Light, shown | [Settings](/home/h0p3/.polybar-settings-20261118-220003-pYfzrp/screenshots/settings-light-show.png) | [DP-1](/home/h0p3/.polybar-settings-20261118-220003-pYfzrp/screenshots/light-show-DP-1.png), [eDP-1](/home/h0p3/.polybar-settings-20261118-220003-pYfzrp/screenshots/light-show-eDP-1.png), [HDMI-1](/home/h0p3/.polybar-settings-20261118-220003-pYfzrp/screenshots/light-show-HDMI-1.png) |
| Light, hidden | [Settings](/home/h0p3/.polybar-settings-20261118-220003-pYfzrp/screenshots/settings-light-hide.png) | [DP-1](/home/h0p3/.polybar-settings-20261118-220003-pYfzrp/screenshots/light-hide-DP-1.png), [eDP-1](/home/h0p3/.polybar-settings-20261118-220003-pYfzrp/screenshots/light-hide-eDP-1.png), [HDMI-1](/home/h0p3/.polybar-settings-20261118-220003-pYfzrp/screenshots/light-hide-HDMI-1.png) |
| Dark, shown | [Settings](/home/h0p3/.polybar-settings-20261118-220003-pYfzrp/screenshots/settings-dark-show.png) | [DP-1](/home/h0p3/.polybar-settings-20261118-220003-pYfzrp/screenshots/dark-show-DP-1.png), [eDP-1](/home/h0p3/.polybar-settings-20261118-220003-pYfzrp/screenshots/dark-show-eDP-1.png), [HDMI-1](/home/h0p3/.polybar-settings-20261118-220003-pYfzrp/screenshots/dark-show-HDMI-1.png) |
| Dark, hidden | [Settings](/home/h0p3/.polybar-settings-20261118-220003-pYfzrp/screenshots/settings-dark-hide.png) | [DP-1](/home/h0p3/.polybar-settings-20261118-220003-pYfzrp/screenshots/dark-hide-DP-1.png), [eDP-1](/home/h0p3/.polybar-settings-20261118-220003-pYfzrp/screenshots/dark-hide-eDP-1.png), [HDMI-1](/home/h0p3/.polybar-settings-20261118-220003-pYfzrp/screenshots/dark-hide-HDMI-1.png) |

## Limits of verification

- Workspace icons and active highlighting were visible in the four states. A real workspace click was tested once, in Dark/shown. Workspace add/remove was tested in Dark/hidden. A full logout/reboot, physical monitor hotplug, and a complete accessibility traversal were omitted.
- Existing i3, right-hand widget, VPN, Wi-Fi, theme, and native app-menu implementations were preserved. Wi-Fi association, volume, layout switching, and the previously verified native exporters were outside this live interaction test.
- At narrow widths the existing overflow tiers still apply. If the workspace strip alone exceeds the VPN-safe cap, the bar can clip some workspaces. A changed X11 window width causes a brief targeted replacement.
- GTK reported metadata warnings from the installed icon theme. Settings still opened and rendered with its application icon and native controls.

## Files and launchers

| Role | Files |
| --- | --- |
| Sizing | `scripts/left-width.py`, new `scripts/font_metrics.py` |
| Preference and update | New `scripts/bar_preferences.py`, `scripts/workspace-listener.py`, `scripts/menu_context.py` |
| Settings UI and Apple integration | New `scripts/polybar_settings.py`, `scripts/polybar-settings`, `assets/io.github.polybar.Settings.desktop`, `assets/polybar-settings.svg`, plus `scripts/desktop_menu.py` and `scripts/global-menu.py` |
| Documentation | `README-macos.md`, `POLYBAR_SETTINGS_PROGRESS.md`, and this report |

Installed the command symlink in `~/.local/bin`, the desktop entry in `~/.local/share/applications`, and the matching icon in `~/.local/share/icons/hicolor/scalable/apps`. These link to the source files above. The bar config, workspace mapping, theme implementation, and unrelated pre-existing changes were kept.

## Recovery and rollback

The pre-change snapshot is [polybar.tar](/home/h0p3/.polybar-settings-20261118-220003-pYfzrp/polybar.tar). It contains the existing Polybar tree, including uncommitted Global Menu work. To roll back just this task, extract the changed existing files into a staging directory first.

```bash
cd "$HOME/.config/polybar" || exit
snapshot="$HOME/.polybar-settings-20261118-220003-pYfzrp/polybar.tar"
stage=$(mktemp -d) || exit
files=(README-macos.md scripts/left-width.py scripts/workspace-listener.py
       scripts/menu_context.py scripts/desktop_menu.py scripts/global-menu.py)
tar -xf "$snapshot" -C "$stage" "${files[@]/#/polybar/}" || exit
for file in "${files[@]}"; do diff -u -- "$stage/polybar/$file" "$file"; done
```

After reviewing the diffs, copy the staged versions back together. Close Settings, then disable the three installed symlinks if they still point into this installation. Move any visibility preference and the new Settings source files aside if you also want to remove them. Verify the current watcher PID from `~/.local/state/polybar-menu/watcher.pid` runs this installation's workspace listener, terminate that PID alone, and start `scripts/watch-monitors.sh` in the background. The revived listener refreshes the cache and recalculates the old left widths. There is no i3 or Git operation in this rollback.
