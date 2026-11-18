# macOS-inspired Polybar: icon-only workspaces

The left capsule contains only the Apple icon and native, clickable i3 workspace icons. No workspace numbers/names, desktop label, window titles, app names, or binding-mode text are rendered.

## Workspace mapping

| Actual workspace name | Icon meaning |
|---|---|
| 1 | Terminal |
| 2 | Code |
| 3 | Globe/browser |
| 4 | Chat |
| 5 | Folder |
| 6 | Music |
| 7 | Video |
| 8 | Settings |
| 9 | Desktop |
| 10 | Applications grid |
| Other workspaces, including 17 | Neutral desktop |

The actual i3 names are numeric (`1` through `22` in the i3 configuration). Native `ws-icon-N` mappings match exact names, with `fuzzy-match = false`; mapping indices do not refer to display positions. Workspace 10 remains named `10` and uses the existing Mod+0 binding. i3 names, assignments and bindings are unchanged. Newly renamed nonnumeric workspaces get the neutral icon until an exact mapping is added.

`modules.ini` retains `internal/i3`, output pinning, index sorting, native click and wheel actions. Every state uses only `%icon%`. Empty workspace visibility remains controlled by i3; unused empty workspaces disappear normally.

## Appearance and sizing

Installed Symbols Nerd Font supplies Apple and round highlight backgrounds; installed JetBrainsMono Nerd Font Mono provides equal-width workspace glyphs. Glyph availability was verified directly against each font's cmap. No fonts were downloaded or installed.

Focused and visible workspaces use a blue icon over a small round blue highlight, inactive workspaces use gray icons, and urgent workspaces use a red round highlight with a white icon. Polybar font/offset tags overlay the icon on a circle glyph without a rectangular background. Both fonts and offsets scale with logical DPI (point units).

`themes/light.ini` and `themes/dark.ini` own these labels/colors. Native capsule corners and existing Picom effects are preserved. `scripts/left-width.py` measures Apple, icon cells and padding using the same exact icon mapping as Polybar. The existing monitor/workspace watcher updates geometry when workspace membership changes. Very large workspace sets remain constrained to avoid overlapping VPN.

The primary monitor's current three-workspace capsule is 112 pixels wide at 96 DPI. Monitors with one workspace get a correspondingly smaller capsule.

## Themes and startup

```sh
polybar-theme light
polybar-theme dark
polybar-theme toggle
polybar-theme status
```

Apple click toggles themes. Light is currently active. Theme controller, locking, persistent state, i3 autostart and monitor watcher are unchanged by the icon update. i3 runs `~/.config/polybar/launch.sh`. Theme state is in `~/.local/state/polybar-menu/theme`.

Each monitor has three capsules and one transparent reservation dock: 12 Polybar processes for three monitors. A 46px reserved strip protects tiled content. Existing input exclusions let clicks pass through the reservation dock to the capsules.

VPN detection, center geometry, right-side modules and their geometry, Picom configuration, i3 bindings/assignments and startup were not modified. The center/right configuration portions were compared byte-for-byte against the pre-update backup.

## Validation

- Actual clicks on every mapped icon 1–10 switched to the correct numeric workspace, including 10. Temporary X11 test windows kept otherwise-empty workspaces available during testing; all were removed afterward.
- Also clicked the default icon for existing workspace 17 successfully.
- Original per-output workspace visibility restored: DP-1 workspace 1, HDMI-1 workspace 5, eDP-1 workspace 2. All user application windows remain in their original workspaces.
- Verified inactive, active and urgent appearance in real screenshots. Temporarily set urgency on the existing inactive workspace-3 window, confirmed i3 reported urgent, captured red styling, then cleared the test urgency.
- Apple click toggled Light → Dark → Light. Actual wheel-down switched workspace 2 to 3; clicking the code icon restored 2.
- Screenshot crops: `screenshots/workspace-icons-light.png`, `workspace-icons-dark.png`, `workspace-icons-urgent.png`.
- No Polybar errors or missing-glyph warnings after final reload. Exactly 12 Polybar instances and one compositor remain. No VPN, audio or network settings were changed.
- Click-test log: `~/.cache/polybar-menu/icon-validation.log`; individual bar logs are in the same directory.

## Changed files and backups

Changed for icon-only workspaces:

- `config.ini`: remove desktop label; add installed fonts for equal-width glyphs and round highlights.
- `modules.ini`: exact icon mapping and icon-only native i3 labels.
- `themes/light.ini`, `themes/dark.ini`: state-specific icon labels/colors.
- `scripts/left-width.py`: measure icon cells rather than workspace names/static label.
- `README-macos.md`: current documentation.

Pre-icon versions are in `backups/workspace-icons-20261116-054630/`. The earlier full original configuration backup remains in `backups/20261116-052644/`. Original-setup rollback remains available via `bash ~/.config/polybar/scripts/rollback.sh`.

Upstream formatting reference: https://github.com/polybar/polybar/wiki/Formatting
