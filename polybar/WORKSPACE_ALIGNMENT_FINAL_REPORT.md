# Polybar workspace icon alignment

All 17 original glyphs now align to the existing highlight circle with a maximum measured error of **1 px per axis** at 96 and 120 DPI. All three live monitors use 96 DPI. The video camera moved 2 px left and 1 px up. The Telegram paper plane moved 2 px left, improving the apparent balance of its diagonal shape and increasing its minimum radial clearance.

## Root cause

Polybar’s native `internal/i3` module expands the same `%icon%` mapping into every theme state. The old labels painted a Symbols Nerd Font circle at `T6` and used a common `O-12pt` offset before the icon. At 96 DPI, the circle had a 22 px advance, placing each original icon pen at x=6 relative to its slot. The glyphs then rendered in Font Awesome Free Solid, Font Awesome Brands, or IcoMoon. Their original advances ranged from 10 to 16 px. The allocatable advance and the visible ink bounds gave different centers.

Primarily horizontal errors were visible at 96 DPI. The camera’s original ink spanned x=[6,21), putting its center 2 px right of the circle. The Telegram ink center was 1 px right, while its coverage-weighted center was 2.34 px right. The terminal’s advance was 16 px, but rasterized ink extended to x=22, giving a −1 px trailing ink bearing and placing its underside beyond the nominal circle radius. IcoMoon and Font Awesome also have different vertical metrics. Font Awesome’s hhea ascent/descent are 448/−64 at 512 units per em, and IcoMoon’s are 960/−64 at 1024 units per em. The circle font’s are 1638/−410 at 2048 units per em. The three icon faces retain their 10 pt size, and the circle retains its 18 pt size. The original vertical offsets were +2 px for icon fonts and +3 px for the circle. The measured raster bounds account for those baselines, bearings and font hinting.

The fix uses matching before/after horizontal offsets and three aliases for the same font faces with a +1 px vertical offset. The aliases move selected glyphs one rendered pixel up. The visible highlight retains its existing center and diameter in every state. Click slots include trailing spacing and are wider than the circle, so their geometric midpoints sit to its right. The icons use the circle center as the visual anchor, including when the circle is transparent.

## Per-icon measurements at 96 DPI

Bounds are half-open `[left, top, right, bottom)` in pixels relative to the slot origin. The circle bounds were **[0,3,23,26)** for every row before and after, with a pixel center at **(11,14)**. The 30 px-high slot has midpoint y=14.5 in pixel coordinates. The table uses negative offsets for left/up motion. Error is glyph bounding-box center minus circle center. Coverage center is the coverage-weighted center relative to that same circle center. Clearance is the minimum radial distance from a rendered ink pixel center to the nominal 11.5 px circle radius. Negative clearance indicates that the old ink crossed the radius.

| Workspace | Slot width / midpoint x | Original bearings L/R | Correction x,y | Ink bounds before → after | Error before → after | Coverage center before → after | Clearance before → after |
|---|---:|---:|---:|---|---|---|---:|
| 1 · Brave | 29 / 14 | 1/1 | -1, 0 | (7, 9, 18, 21) → (6, 9, 17, 21) | (+1, +0.5) → (0, +0.5) | (+0.81, +0.32) → (-0.19, +0.32) | 4.29 → 5.10 |
| 2 · Terminal | 32 / 15.5 | 0/-1 | -3, -1 | (6, 9, 23, 21) → (3, 8, 20, 20) | (+3, +0.5) → (0, -0.5) | (+0.89, +2.41) → (-2.11, +1.41) | -1.03 → 1.50 |
| 3 · Folder | 31 / 15 | 0/0 | -2, -1 | (6, 10, 21, 20) → (4, 9, 19, 19) | (+2, +0.5) → (0, -0.5) | (+0.86, +1.09) → (-1.14, +0.09) | 2.28 → 2.90 |
| 4 · Video | 31 / 15 | 0/0 | -2, -1 | (6, 10, 21, 20) → (4, 9, 19, 19) | (+2, +0.5) → (0, -0.5) | (+1.12, +0.62) → (-0.88, -0.38) | 1.20 → 2.90 |
| 5 · Code | 32 / 15.5 | 0/-1 | -3, -1 | (6, 8, 23, 22) → (3, 7, 20, 21) | (+3, +0.5) → (0, -0.5) | (+2.62, +0.63) → (-0.38, -0.37) | 0.45 → 3.44 |
| 6 · Tor | 29 / 14 | 2/2 | -1, 0 | (8, 8, 17, 21) → (7, 8, 16, 21) | (+1, 0) → (0, 0) | (+1.59, +1.56) → (+0.59, +1.56) | 4.29 → 4.79 |
| 7 · Safari | 29 / 14 | 0/0 | -1, -1 | (6, 9, 19, 21) → (5, 8, 18, 20) | (+1, +0.5) → (0, -0.5) | (+1.01, +0.59) → (+0.01, -0.41) | 3.88 → 4.79 |
| 8 · Telegram | 29 / 14 | 0/0 | -2, 0 | (6, 8, 19, 22) → (4, 8, 17, 22) | (+1, +0.5) → (-1, +0.5) | (+2.34, +0.88) → (+0.34, +0.88) | 2.28 → 3.69 |
| 9 · Docker | 32 / 15.5 | 0/-1 | -3, -1 | (6, 9, 23, 21) → (3, 8, 20, 20) | (+3, +0.5) → (0, -0.5) | (+1.58, +1.54) → (-1.42, +0.54) | 0.45 → 2.96 |
| 10 · GitHub | 28 / 13.5 | 0/-1 | -1, 0 | (6, 10, 19, 20) → (5, 10, 18, 20) | (+1, +0.5) → (0, +0.5) | (+0.61, 0) → (-0.39, 0) | 3.88 → 4.29 |
| 11 · Database | 27 / 13 | 0/-1 | 0, -1 | (6, 8, 18, 22) → (6, 7, 18, 21) | (+0.5, +0.5) → (+0.5, -0.5) | (+0.19, +0.57) → (+0.19, -0.43) | 3.01 → 3.01 |
| 12 · Java | 26 / 12.5 | 0/0 | 0, -1 | (6, 8, 16, 22) → (6, 7, 16, 21) | (-0.5, +0.5) → (-0.5, -0.5) | (-0.53, +2.26) → (-0.53, +1.26) | 3.44 → 4.29 |
| 13 · Music | 29 / 14 | 0/0 | -1, 0 | (6, 8, 19, 22) → (5, 8, 18, 22) | (+1, +0.5) → (0, +0.5) | (+2.14, +0.43) → (+1.14, +0.43) | 2.28 → 2.28 |
| 14 · Chart | 29 / 14 | 0/0 | -1, -1 | (6, 10, 19, 20) → (5, 9, 18, 19) | (+1, +0.5) → (0, -0.5) | (+0.74, +1.32) → (-0.26, +0.32) | 2.90 → 3.69 |
| 15 · Steam | 29 / 14 | 0/0 | -1, -1 | (6, 8, 19, 22) → (5, 7, 18, 21) | (+1, +0.5) → (0, -0.5) | (+0.93, +0.58) → (-0.07, -0.42) | 3.69 → 4.29 |
| 16 · Python | 27 / 13 | 0/-1 | 0, -1 | (6, 9, 18, 21) → (6, 8, 18, 20) | (+0.5, +0.5) → (+0.5, -0.5) | (+0.18, +0.59) → (+0.18, -0.41) | 4.79 → 5.18 |
| 17 · Unlock | 27 / 13 | 0/-1 | 0, -1 | (6, 8, 18, 22) → (6, 7, 18, 21) | (+0.5, +0.5) → (+0.5, -0.5) | (+0.08, +2.01) → (+0.08, +1.01) | 2.28 → 3.01 |
| default · Default desktop | 31 / 15 | 0/0 | -2, 0 | (6, 8, 21, 22) → (4, 8, 19, 22) | (+2, +0.5) → (0, +0.5) | (+1.83, +0.46) → (-0.17, +0.46) | 0.68 → 2.28 |

For Telegram, the one-pixel left bias in the bounding box brings the coverage center near the circle center and increases edge clearance from 2.28 px to 3.69 px. The terminal is the tightest fit, with approximately 1.50 px radial clearance at 96 DPI and 1.10 px at 120 DPI. Those estimates use pixel centers and the nominal radius. The guide images show the actual antialiased silhouettes.

## Diagnostic grids and live screenshots

Every grid uses actual Polybar pixels enlarged 3× with nearest-neighbor scaling. The same label, font setup, offsets, and colors as the live bar were rendered on a disposable X11 display. The guide variants add horizontal and vertical lines through the circle center after capture. The inactive column uses that same virtual center.

| Theme | Before | After | After with center guides |
|---|---|---|---|
| Light, 96 DPI | [Before](screenshots/workspace-alignment/before-96-light.png) | [After](screenshots/workspace-alignment/after-96-light.png) | [Guides](screenshots/workspace-alignment/after-96-light-guides.png) |
| Dark, 96 DPI | [Before](screenshots/workspace-alignment/before-96-dark.png) | [After](screenshots/workspace-alignment/after-96-dark.png) | [Guides](screenshots/workspace-alignment/after-96-dark-guides.png) |
| Light, 120 DPI | [Before](screenshots/workspace-alignment/before-120-light.png) | [After](screenshots/workspace-alignment/after-120-light.png) | [Guides](screenshots/workspace-alignment/after-120-light-guides.png) |
| Dark, 120 DPI | [Before](screenshots/workspace-alignment/before-120-dark.png) | [After](screenshots/workspace-alignment/after-120-dark.png) | [Guides](screenshots/workspace-alignment/after-120-dark-guides.png) |

| Live output | Width before → after | Captures |
|---|---:|---|
| DP-1 | 398 → 398 px | [Before](screenshots/workspace-alignment/before-live-DP-1.png) · [After](screenshots/workspace-alignment/after-live-DP-1.png) |
| eDP-1 | 426 → 426 px | [Before](screenshots/workspace-alignment/before-live-eDP-1.png) · [After](screenshots/workspace-alignment/after-live-eDP-1.png) |
| HDMI-1 | 403 → 403 px | [Before](screenshots/workspace-alignment/before-live-HDMI-1.png) · [After](screenshots/workspace-alignment/after-live-HDMI-1.png) |

## Verification

- Before and after diagnostic renders covered all 17 glyphs and the fallback in inactive, focused, and urgent styles for both themes. Matched circle-only renders isolated the colored icon pixels in the focused and urgent columns. Allowing for antialias color rounding at the edge of a glyph, the bounds agreed with the inactive render to within 1 px per edge. Visible uses exactly the focused format. Occupied inactive workspaces use the unfocused format. Each state expands the same per-icon position tags and the same original glyph.
- Isolated i3 hosted disposable clients while the native Polybar module handled real EWMH urgency. Workspaces 4 and 8 transitioned from inactive to urgent and focused. Four workspaces were urgent simultaneously. Native clicks switched to 4 and 8 and i3 cleared urgency at its normal pace. The bar stayed at 487 px with the menu shown and 178 px with the menu hidden, in both themes. [Light with menu](screenshots/workspace-alignment/native-light-show-4-8-urgent.png) · [Dark with menu hidden](screenshots/workspace-alignment/native-dark-hide-4-8-urgent.png)
- The width helper matched all 150 old/new width and menu-tier comparisons, covering singleton glyphs, the full workspace list, different width caps, and all three live output memberships at 96, 120, and 144 DPI. The isolated listener kept the same PID and width through urgency and focus, then resized **487 → 517 → 487 px** when workspace 99 was created and removed.
- All three live left capsules received a PID-targeted Polybar IPC restart. Their Apple and Global Menu pixels and last four right-edge pixels matched the before captures. The live desktop remained on Light with the Global Menu shown. It included focused, visible, inactive, and already-urgent workspaces. Dark, menu-hidden, and additional urgency events were exercised in the isolated session. The i3 socket and all recorded Polybar PIDs matched the backup. No live application received a test notification.
- Rendered alignment was verified at 96 and 120 DPI with the installed font files. Polybar uses integer placement. Other DPI values or replacement font files can change hinting and subpixel clearance.

## Files and rollback

- [config.ini](config.ini) adds three baseline aliases scoped to the left bar.
- [modules.ini](modules.ini) adds the paired offsets and per-glyph font choices in native workspace mappings.
- [scripts/left-width.py](scripts/left-width.py) measures the original glyph text so the compensated slot advances and the original right-edge sizing reference stay fixed.
- [Progress log](WORKSPACE_ALIGNMENT_PROGRESS.md) and [captures](screenshots/workspace-alignment/) document the verification.

Private pre-edit backup is `/home/h0p3/.local/state/polybar-menu/workspace-alignment-20261120-101442-1f38kV`.

To roll back, restore the three modified configuration files from that backup and refresh the current left capsules. The theme palettes retain the preceding urgency fix.

```bash
backup="/home/h0p3/.local/state/polybar-menu/workspace-alignment-20261120-101442-1f38kV"
(
  cache="${XDG_CACHE_HOME:-$HOME/.cache}/polybar-menu"
  config="$HOME/.config/polybar"
  flock -w 3 9 || exit 1
  cp -- "$backup"/{config.ini,modules.ini} "$config/" || exit 1
  cp -- "$backup/scripts/left-width.py" "$config/scripts/" || exit 1
  for file in "$cache"/*-left.pid; do
    [[ -r $file ]] || continue
    read -r pid < "$file"
    [[ $(ps -p "$pid" -o args=) == "polybar -c $config/config.ini left" ]] || continue
    timeout 3 polybar-msg -p "$pid" cmd restart
  done
) 9>"${XDG_STATE_HOME:-$HOME/.local/state}/polybar-menu/control.lock"
```
