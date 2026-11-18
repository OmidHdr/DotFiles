# Restore the Flameshot multi-monitor overlay

## Cause

Arch package **Flameshot 15.0.0-1** is installed. The package log shows the upgrade from 13.3.0-2 to 14.0.0-1 on June 13 and to 15.0.0-1 on November 6. v14 changed the editor to prompt for one monitor. The v15 release added native X11 fallback and monitor-selector fixes, but did not restore cross-monitor region selection. The source chooses and crops the monitor after obtaining the desktop image, so enabling the legacy backend alone still leaves the picker. Capture Active Monitor skips the picker by restricting capture to one monitor. [v14 announcement](https://github.com/flameshot-org/flameshot/discussions/4750), [release notes](https://github.com/flameshot-org/flameshot/releases), [v15 capture source](https://github.com/flameshot-org/flameshot/blob/v15.0.0/src/utils/screengrabber.cpp)

The loaded i3 shortcut had already called the same wrapper preserved in Git history, with a Qt XCB environment override. The wrapper ran `flameshot gui -d 2000`. The separately stored i3 script with a three-second delay was unused. No Flameshot-specific i3 window rule caused the regression. Upstream's cursor-following proposal does not provide a region spanning outputs. [Upstream proposal](https://github.com/flameshot-org/flameshot/pull/4965)

## Installed configuration

| File | Change |
| --- | --- |
| `~/.config/flameshot/flameshot.ini` | Enabled `useX11LegacyScreenshot=true`. Existing `drawThickness` and `savePath` retained. |
| `~/.config/bash/flameshot.sh` | Removed the two-second delay. Supplies Flameshot's own XCB environment and calls the helper in X11. |
| `~/.config/bash/flameshot-x11.py` | Requests the normal capture through Flameshot's D-Bus API and promotes only its new i3 capture window to global fullscreen. |
| `${XDG_DATA_HOME:-$HOME/.local/share}/dbus-1/services/org.flameshot.Flameshot.service` | Starts the installed daemon with `QT_QPA_PLATFORM=xcb`, `QT_XCB_NO_XRANDR=1`, and `QT_SCALE_FACTOR=1`. |
| `FLAMESHOT_FIX_PROGRESS.md` and this report | Procedure, evidence, and recovery notes. |

Qt's XCB setting makes Flameshot see the 5120×1080 X11 root as one screen. i3 otherwise gives the editor an output-sized fullscreen window, so the helper uses i3's global fullscreen action for that editor alone. Raw CLI test arguments still pass through to the Flameshot executable. The existing Mod+X binding immediately picks up the changed wrapper. Restarted only the Flameshot daemon. XRandR, i3 configuration, Polybar, Plank, and network configuration were left in place. No package change was made.

## Verification

- Live X11 overlay mapped at (0,0) with size 5120×1080. The loaded binding command, invoked via i3 IPC, opened it in the single tray daemon without a monitor picker. Focus-checked Escape closed it.
- Repeated launches exported 120×65 on DP-1, 125×75 on eDP-1, 130×35 on HDMI-1, and 110×29 from a continuous drag across DP-1 and eDP-1. The pointer started on eDP-1 for every test. Independent root crops confirmed the coordinates. Compositor opacity changes accounted for color differences in the HDMI sample.
- An isolated X11 session with the same installed binary confirmed rectangle annotation and clipboard export as a 220×160 PNG. This spared the live clipboard. Interactive save was not exercised. The saved path and editor remained in place.
- Final checks found one Flameshot daemon and the same three XRandR outputs. Shell syntax, Python compilation, and `git diff --check` passed. A synthetic physical Mod+X was omitted after the safe-focus fixture failed preflight, so verification used the exact command from the live binding.

This is an X11/i3 compatibility workaround. Qt's process-level setting makes monitor-specific Flameshot tray and CLI choices see one root screen. The global fullscreen promotion is tied to the existing shortcut wrapper, so captures launched directly from the tray are outside the verified workflow. After changing monitor topology or scaling, a Flameshot daemon restart may be needed to refresh its root geometry. A future Qt update may change the behavior of the XCB environment option.

## Recovery

Private backup and test evidence are in [the recovery directory](/home/h0p3/.flameshot-fix-20261118-223557-5ZDd0s).

To roll back, restore `wrapper.sh` to `~/.config/bash/flameshot.sh` and restore the saved INI or remove only `useX11LegacyScreenshot=true` if you have since edited other Flameshot preferences. Remove the new user D-Bus override after checking that it still contains this change, or restore `user-dbus.service` if that file exists in the backup. The helper can then be moved aside. Restart only the Flameshot tray daemon so it reads the original settings and no longer inherits the Qt override. No i3 reload or Git operation is required.
