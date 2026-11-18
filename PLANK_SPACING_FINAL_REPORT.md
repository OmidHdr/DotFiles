# Plank bottom spacing fix

i3 was reserving **116 pixels** on DP-1 for Plank's X11 window. Only **32 pixels** were occupied by the visible dock. Plank keeps the rest of that surface available for zoom and other animations. i3 sizes its dock area from the dock window's geometry. The resulting 84-pixel excess was independent of the existing i3 gaps. There was one Plank process and one managed dock. The tooltip and GTK helper did not reserve space. [i3 renderer](https://raw.githubusercontent.com/i3/i3/4.25.1/src/render.c), [Plank strut calculation](https://raw.githubusercontent.com/zquestz/plank-reloaded/e108978/lib/PositionManager.vala)

## Live measurements

| DP-1 measurement | Before | After |
|---|---:|---:|
| Monitor height | 900 px | 900 px |
| Plank X11 window height | 116 px | 116 px |
| Visible dock height | 32 px | 32 px |
| i3 bottom reservation | 116 px | 32 px |
| Workspace 1 rectangle | 1590×728 at (5, 51) | 1590×812 at (5, 51) |
| Brave client height | 706 px | 790 px |
| Brave tiled frame height | 718 px | 802 px |
| Visible gap from Brave frame to dock | 94 px | 10 px |

The root window is 1080 pixels high, so the bottom strut value of 212 includes the 180 pixels below DP-1. The monitor-local depth is 32. The partial horizontal range is 0–1599. Before the change the native dock carried this strut. After the change the visible Plank surface retains its native properties and has override-redirect enabled. The companion window advertises the same strut and is the only Plank window managed in i3's dock area. i3 did not expose `_NET_WORKAREA`; the IPC tree provided the effective per-output rectangles.

| Output | Geometry | i3 bottom reserve before → after |
| --- | --- | ---: |
| DP-1 | 1600×900 at (0, 0) | 116 → 32 px |
| eDP-1 | 1920×1080 at (1600, 0) | 0 → 0 px |
| HDMI-1 | 1600×900 at (3520, 0) | 0 → 0 px |

## Changes and verification

- `i3/center_plank.sh` still starts Plank if absent. It starts the new `i3/plank-reservation.py` helper through the existing startup hook. The helper keeps Plank's animation surface intact and reserves only its visible height through a transparent, input-free dock on the matching output. It removes that reservation in hide modes and after Plank exits. It suppresses Plank's surface on a fullscreen output.
- The live fix reused the existing Plank window and process. The saved Plank preferences match the original dump, including always-visible mode, DP-1, theme, icon size, zoom, and pinned order. The existing i3 config, gaps, and Polybar files were left in place. i3 was neither restarted nor reloaded. Polybar PIDs were unchanged. No network state was changed.
- Tested the visible dock and tiled Brave window on the live desktop. Existing fullscreen playback was sampled at the full 1920×1080 eDP-1 rectangle during the fix. Application and workspace assignments did not change across the deployment.
- In isolated X11/i3, tested two tiled terminals, workspace switching, a floating terminal, fullscreen, and VLC's tiled main window. The isolated fullscreen terminal occupied 1280×800 with Plank absent from the screenshot.
- Auto-hide and pointer reveal changed the screenshot while the tiled rectangles stayed identical and the bottom reservation stayed zero. Intelligent-hide had zero persistent reservation. Plank exit removed the reservation and a targeted isolated relaunch restored exactly one 32-pixel reservation.
- Two early test attempts inherited live session settings. The first affected the saved monitor and pin order, which were restored and compared against the backup. The other briefly switched live workspace focus. It sent no playback controls and closed no existing application. The final tests verified the private i3 socket and config before running workspace commands.
- Physical hotplug, live VLC playback, and live hide-mode changes were omitted. The runtime recomputes the reservation from the current X11 strut and i3 output geometry. The live desktop stays in the original always-visible mode.

## Screenshots and recovery

- [Live before](/home/h0p3/.plank-spacing-20261118-222101-nEo3un/live-before.png) and [live after](/home/h0p3/.plank-spacing-20261118-222101-nEo3un/live-after.png)
- [Isolated hidden](/home/h0p3/.plank-spacing-20261118-222101-nEo3un/nested-hidden.png), [revealed](/home/h0p3/.plank-spacing-20261118-222101-nEo3un/nested-revealed.png), and [fullscreen](/home/h0p3/.plank-spacing-20261118-222101-nEo3un/nested-fullscreen.png)
- [Private backup and raw measurements](/home/h0p3/.plank-spacing-20261118-222101-nEo3un)

To roll back, compare the backed-up `center_plank.sh` to the current script and copy back the saved version. Then find the running helper, verify its command line points to this installation's `plank-reservation.py`, and send TERM to that PID alone. The helper destroys its companion window and returns Plank to ordinary window management. The backup's `plank.dconf` and `i3-config` are reference copies. The rollback requires no dconf restore, Git operation, i3 reload, or Polybar restart.
