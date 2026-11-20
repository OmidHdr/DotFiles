# Workspace urgency progress

- Private backup created at `/home/h0p3/.local/state/polybar-menu/workspace-urgency-20261120-100329-jvm7xJ`.
- Inspected live configuration. The native i3 module owns state and actions. Light and Dark have identical geometry tags for every state. Urgency paints a solid red circle and a white icon.
- Captured the existing left capsules on DP-1, eDP-1 and HDMI-1. Workspace 8 was already urgent on eDP-1.
- An isolated i3 instance reproduced real EWMH attention without touching the desktop. The old urgent circle occupied a 23 px footprint, matching the focused circle. Both palettes now use the requested tint and red icon. Geometry tags, native i3 actions and the width helper require the existing geometry and were preserved.
- Applied the palette through PID-targeted Polybar IPC restarts on the three left capsules. Live widths remained 398 px (DP-1), 426 px (eDP-1), and 403 px (HDMI-1). All 12 Polybar PID files matched the backup. Center, right and reservation processes kept running.
- The width helper produced identical results with no urgency and all workspaces urgent for each live output, with Global Menu shown or hidden. Old-palette isolated runs passed native clicks into 4 and 8, natural urgency clearing, simultaneous urgency, and add/remove width calculations in both themes and menu settings.
- Completed 48 isolated before-and-after captures across both themes and both Global Menu settings. Workspace 4 and 8 circle footprints matched focused and urgent, and the opaque icon masks matched inactive, focused and urgent. Every unaffected slot, the separator, and the right-edge padding matched pixel for pixel in the isolated comparisons.
- Isolated native clicks focused 4 and 8. i3 cleared their urgency naturally. A separate run with the actual resize listener kept the same 487 px bar and PID through four simultaneous urgent workspaces and focusing workspace 4, then resized 487 → 517 → 487 px on workspace 99 creation and removal.
- Wrote the final report with measurement coordinates, screenshot links, coverage limits, and rollback.
