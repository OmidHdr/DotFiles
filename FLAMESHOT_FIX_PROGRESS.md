# Flameshot fix progress

## 1. Diagnosis and backup
- Arch Flameshot 15.0.0-1, installed November 6. Package had moved from 13.3.0-2 to 14.0.0-1 on June 13. v14 introduced monitor selection. Legacy X11 capture and monitor selection are separate in v15.
- Loaded Mod+X executes bash/flameshot.sh under Qt XCB. The wrapper adds a pre-existing two-second delay. No Flameshot-specific i3 rule.
- Saved private backup at /home/h0p3/.flameshot-fix-20261118-223557-5ZDd0s.
- Next: test whether the installed Qt XCB backend can expose the existing X11 root as a single Flameshot canvas without changing XRandR or replacing any binaries.

## 2. Live proof of compatibility
- Flameshot's legacy capture key bypasses the portal, while Qt XCB's QT_XCB_NO_XRANDR setting presents the existing root desktop as one screen to this process. Qt 6.12 on this machine has no Xinerama fallback in its XCB plugin.
- The first probe still had a per-output i3 fullscreen window. Changing that specific window to i3 global fullscreen produced a 5120×1080 X11 overlay at (0,0).
- A live stepped pointer drag from (1545,260) to (1655,330) produced a 110×70 PNG. No monitor picker or terminal input was used.
- Next: persist the daemon environment and have the already-bound wrapper apply global fullscreen to each capture window.

## 3. Install user-level configuration
- Added the legacy capture setting, replaced the bound wrapper's delay with immediate activation, and added a helper that promotes the fresh Flameshot overlay only.
- Added a user D-Bus service override and restarted only the existing Flameshot tray process. Verified that the activated process inherited its Qt XCB settings.
- No loaded i3 binding change or reload was needed. Next: verify the real Mod+X path, coordinate-correct drags and annotation/copy.

- Testing found that raw CLI captures can run in their own Flameshot process. The wrapper now supplies the same Qt environment to those launches as the user D-Bus service supplies to the tray daemon.
- Next: repeat the per-monitor and crossing geometry checks with the corrected wrapper.

## 4. Live geometry verification
- Verified a 5120×1080 overlay at root origin and successful region exports on DP-1, eDP-1, HDMI-1, and across the DP-1/eDP-1 seam.
- Compared each crop against an independent root capture. Used grayscale similarity where live focus-dependent compositor opacity changed the colors.
- Next: verify normal Mod+X, annotation, clipboard and Escape.

## 5. Verify the live binding command and cancellation
- The ordinary no-argument wrapper now calls Flameshot's official captureScreen D-Bus method so the tray daemon itself owns the overlay. Raw arguments still go to the CLI.
- Executed the exact loaded binding command through i3 IPC. The full-root overlay mapped in the single existing tray daemon. Escape was sent only while the overlay held input focus and closed it.
- A synthetic Mod+X keystroke was omitted because the nonterminal focus fixture did not pass preflight.
- Next: verify annotation and clipboard without changing the user's live clipboard.

## 6. Verify editing and clipboard
- In private X11 and D-Bus sessions, used the same installed Flameshot daemon to select a region, draw a rectangle, and copy it. Read a 220×160 PNG with annotation pixels from the private clipboard. The live clipboard was not written.
- Next: audit the final configuration and write the report.

## 7. Delivery
- Saved final report with evidence, source references, limitations, backup and selective rollback.
- Audited the only remaining Flameshot process and the unchanged i3 files, monitor layout and existing binding.
- Next: none.
