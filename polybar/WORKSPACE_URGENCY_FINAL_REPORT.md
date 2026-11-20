# Polybar workspace urgency

The live left capsules now show a red workspace icon on a tinted circle when i3 reports urgency. Light uses `#DC3545` on `#FCE0E3`. Dark uses `#FF6969` on `#49282F`.

## Root cause

The active renderer is Polybar’s native `internal/i3` module in `modules.ini`. The runtime configuration is `config.ini`, which includes the active Light or Dark palette via `themes/current.ini`. `workspace-listener.py` subscribes to i3 IPC for left capsule resizing. `left-width.py` measures the selected workspace list using the unfocused label and Fontconfig/Cairo metrics. The Global Menu script supplies its own labels and separator. Workspace colors and glyphs come directly from the native module and theme labels.

Before the fix, the urgent label painted a solid `#D95050` circle with a white icon in both themes. This palette made the urgent highlight look larger and changed the perceived icon weight. Isolated screenshots measured a 23 × 23 px footprint for both the old urgent circle and the focused circle. The focused, visible, unfocused, and urgent labels already shared a single geometry pattern in both themes. The visible label is identical to focused. An occupied inactive workspace uses unfocused.

All four states draw the same circle glyph `` in formatting font `T6` (`font-5`, Symbols Nerd Font, 18 pt, vertical offset 3). It has a 22 px measured advance at 96 DPI and is transparent when unfocused. The labels then apply `O-12pt`, draw the original workspace glyph in `T5` (`font-4`, Font Awesome 5 Free Solid, 10 pt, vertical offset 2), and apply `O4.5pt` and `O3pt`. At 96 DPI those offsets are −16, +6, and +4 px. Polybar uses the existing IcoMoon or Font Awesome Brands fallback when the preferred face lacks a glyph. Every label has zero additional label padding. The shared font indices and vertical offsets preserve the glyph baseline. The clickable span is the advance of the native label. The 17 mappings were checked and retain their original glyphs and individual advances across all states.

Only the urgent color tags changed in [Light](themes/light.ini) and [Dark](themes/dark.ini). The focused and visible palettes, native click and scroll handling, width measurement, and listener behavior retain their existing configuration.

## Before and after measurements

Isolated X11 captures at 96 DPI. Coordinates are relative to the bar’s top left and represent the centers of the measured pixel bounds. Inactive icons have a transparent circle. The urgent and focused circle footprints matched in both themes before and after.

| Workspace | Icon advance | Slot width | Icon footprint | Icon center, menu shown / hidden | Circle footprint | Circle center, menu shown / hidden |
|---|---:|---:|---:|---|---:|---|
| 4 | 15 px | 31 px | 15 × 10 px | (377, 14.5) / (68, 14.5) | 23 × 23 px | (375, 14) / (66, 14) |
| 8 | 13 px | 29 px | 13 × 14 px | (407, 14.5) / (98, 14.5) | 23 × 23 px | (406, 14) / (97, 14) |

The two glyphs have different original shapes and advances. Each glyph’s opaque pixel mask matched across inactive, old urgent, new urgent, and focused. With the menu shown, workspace slots started at x=335, 364, 395, 424, and 456 for workspaces 1, 4, 8, 9, and 17. Hiding the menu moved that entire sequence 309 px left. The gap between workspace 4 and 8 icon bounds stayed 16 px. Comparisons across the urgency transitions found identical pixels in neighboring unchanged slots and in the Global Menu separator. Each state occupied the same 487 px capsule with the menu shown and 178 px with it hidden. The renderer ended at x=483 and x=174 respectively, leaving the same 4 px total right-side allocation in each capture, including the configured 2 px bar padding.

## Verification

- The isolated i3 instance hosted disposable XTerm windows in workspaces 1, 4, 8, 9, and 17. EWMH attention requests set real i3 urgency on 4, then 4 and 8 together, then 4, 8, 9, and 17 together. Native Polybar clicks switched to 4 and 8 and i3 cleared their urgency after its normal delay. The full sequence ran before and after for Light and Dark with the Global Menu shown and hidden.
- A separate isolated run with the actual workspace listener kept the same left-bar PID and 487 px width through urgency and focus. Creating workspace 99 grew the bar to 517 px. Removing the empty workspace restored 487 px.
- Each live left capsule was refreshed with a PID-targeted Polybar IPC restart. All 12 recorded Polybar PIDs matched the pre-edit snapshot. The live i3 instance was neither restarted nor reloaded. No workspace commands or keyboard input were sent to the live session.
- Workspace 8 was already urgent on eDP-1. Before and after captures show the palette change at the same live capsule width. Workspace 4 was visible on DP-1 during live inspection. The HDMI-1 and DP-1 captures preserve their respective capsule widths. Feeding the live output membership into the width helper with all urgency flags clear and then set gave the same results in both cases.

| Live output | Actual width before → after | Calculated width with menu hidden |
|---|---:|---:|
| DP-1 | 398 → 398 px | 89 px |
| eDP-1 | 426 → 426 px | 117 px |
| HDMI-1 | 403 → 403 px | 94 px |

The live desktop stayed on its selected theme and menu setting. Dark, menu-hidden, additional urgency transitions, native clicks, and workspace add/remove were exercised in the isolated session. Telegram, video, and browser applications received no test traffic. The isolated XTerm attention requests used the same i3 urgency path as application attention requests.

## Screenshots

All images are X11 captures of the capsule window. The [capture directory](screenshots/workspace-urgency/) contains the full set.

| Case | Before | After |
|---|---|---|
| Live eDP-1, existing workspace 8 urgency | [Before](screenshots/workspace-urgency/before-live-eDP-1.png) | [After](screenshots/workspace-urgency/after-live-eDP-1.png) |
| Live DP-1 | [Before](screenshots/workspace-urgency/before-live-DP-1.png) | [After](screenshots/workspace-urgency/after-live-DP-1.png) |
| Live HDMI-1 | [Before](screenshots/workspace-urgency/before-live-HDMI-1.png) | [After](screenshots/workspace-urgency/after-live-HDMI-1.png) |
| Light, menu shown, 4 and 8 urgent | [Before](screenshots/workspace-urgency/before-light-show-4-8-urgent.png) | [After](screenshots/workspace-urgency/after-light-show-4-8-urgent.png) |
| Dark, menu hidden, four urgent | [Before](screenshots/workspace-urgency/before-dark-hide-multiple-urgent.png) | [After](screenshots/workspace-urgency/after-dark-hide-multiple-urgent.png) |
| Light, workspace 4 focused | [Before](screenshots/workspace-urgency/before-light-show-4-focused.png) | [After](screenshots/workspace-urgency/after-light-show-4-focused.png) |
| Dark, workspace 8 focused | [Before](screenshots/workspace-urgency/before-dark-show-8-focused.png) | [After](screenshots/workspace-urgency/after-dark-show-8-focused.png) |

## Backup and rollback

The private pre-edit backup is `/home/h0p3/.local/state/polybar-menu/workspace-urgency-20261120-100329-jvm7xJ`. Previous recovery references and existing Git modifications were preserved.

To roll back, copy just the two theme files back and refresh the current left capsules. Use the current PID files, since workspace membership changes may replace a left capsule.

```bash
backup="/home/h0p3/.local/state/polybar-menu/workspace-urgency-20261120-100329-jvm7xJ"
(
  cache="${XDG_CACHE_HOME:-$HOME/.cache}/polybar-menu"
  config="$HOME/.config/polybar"
  flock -w 3 9 || exit 1
  cp -- "$backup"/themes/{light,dark}.ini "$config/themes/" || exit 1
  for file in "$cache"/*-left.pid; do
    [[ -r $file ]] || continue
    read -r pid < "$file"
    [[ $(ps -p "$pid" -o args=) == "polybar -c $config/config.ini left" ]] || continue
    timeout 3 polybar-msg -p "$pid" cmd restart
  done
) 9>"${XDG_STATE_HOME:-$HOME/.local/state}/polybar-menu/control.lock"
```
