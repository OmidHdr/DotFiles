# Polybar Settings progress

## 1. Baseline and recovery — complete

- Read both Global Menu handoff documents and inspected the current launcher, listener, themes, and sizing script.
- Private backup: `~/.polybar-settings-20261118-220003-pYfzrp/polybar.tar`. Original state was Dark with Global Menu enabled (no visibility setting existed).
- Captured the live three-monitor before screenshot and X11 geometry in the same private directory.
- The previous sizing code used fixed allowances of 380, 223, and 31 pixels for the menu tiers and an estimate for each workspace label. Neither tracks Polybar's actual font fallback and offsets.
- Next: replace the estimates with measured format runs and verify the existing layout before introducing settings.

## 2. Content measurement — implementation complete

- The width helper now measures the configured Fontconfig/Cairo faces in Polybar fallback order, walks the actual workspace formatting tags, and measures only labels in the selected menu tier.
- Apple and menu spacing are preserved. Capsule width includes the existing margins and padding, with a 13-pixel target after the final painted extent. The VPN clearance cap still applies.
- Added persistent visibility reader with validation and atomic writer. Default is show.
- Next: wire persistence and targeted runtime refresh, then compare against live X11 screenshots.

## 3. Runtime wiring and first live resize

- Corrected parsing of Polybar's repeated include directive. The new helper measured all three live outputs successfully.
- The listener checks the atomic visibility preference and reuses its existing targeted replacement path when width or tier changes. Non-Apple dropdowns check the preference and close when hidden. The popup lock now ends with the popup, before a selected dialog or app runs.
- Refreshed only the dedicated listener and captured the after-sizing X11 screenshot. Next: measure its right-edge padding, then implement the settings window and launchers.

## 4. Settings application and launchers — implemented

- Added GTK 3 single-instance settings with Light/Dark cards, visibility switch, and live preview. It invokes the existing theme controller and reads shared state so external changes appear in the window.
- Added the Apple action, desktop launcher, SVG icon, and executable command. Installed the three user-local launcher/icon symlinks.
- Next: open from the command line, inspect the window and desktop launcher, and verify all four configurations in X11.

## 5. Settings window and desktop activation

- The terminal command opened the GTK application. The desktop entry launched the adjusted compact window with a dialog hint so it floats under i3. Verified the live D-Bus application name.
- Made each live resize pass use one visibility snapshot for all monitors. The preference guard also prevents dispatch from a stale label when the user hides the Global Menu.
- Next: inspect the captured settings window and measure all four appearance/visibility combinations.

- Confirmed repeated terminal and desktop-entry launches reused the same X11 settings window.

## 6. Refine padding against the X11 capture

- The first after-sizing screenshot showed that two inactive workspace icons still had about 17–18 pixels of gap. Their transparent focus circles were being counted as painted ink.
- The measurement now counts the circle's advance, including the real offsets, and targets 13 pixels after the final icon glyph. Also matched Polybar's preferred-font swap order and per-run advance rounding.
- Next: verify actual screenshot pixels and geometry under all four states.

## 7a. Dark with Global Menu hidden — verified

- Live geometry, saved state, hidden action markup, and workspace edge pixels passed on all three displays. Captured the bar and settings window.
- Next: verify Dark with the menu shown, then both Light combinations.

## 7c. Light with Global Menu shown — verified

- Settings applied Light using the existing theme controller. Saved theme and active symlink agree.
- All three X11 left capsules passed sizing, rounded corner, 14-pixel workspace padding, action markup, and VPN clearance checks.
- A fullscreen window covered DP-1 in the desktop strip, so per-window X11 captures were added for accurate checks on obscured capsules.
- Next: close a live File menu by switching visibility off and verify Light hidden.

- The first live hide test exposed a GTK behavior gap: popdown alone did not end the menu loop or release its lock. Terminated the verified test popup only and changed the preference callback to quit the loop and destroy the menu through its normal cleanup path.
- Next: repeat the failed File dismissal check, then verify Light hidden.

## 7d. Light with Global Menu hidden — verified

- Clicked File on eDP-1, observed the real X11 dropdown, and hid Global Menu through settings. The popup closed and released its lock without keyboard input.
- All three left capsules shrank by 309 pixels and passed the roundness, workspace padding, width, persistence, and VPN clearance checks. Center, right, and reserve PIDs stayed unchanged.
- Next: verify Apple opens settings with the menu hidden, then switch back to Dark.

## 8. Apple entry and application lifecycle — verified

- Closed Settings via its own window message and confirmed all Polybar PIDs stayed unchanged. With the Global Menu hidden, clicked Apple on eDP-1 and selected Polybar Settings from the captured dropdown. X11 reused the window ID after close, but the application PID changed.
- Repeated terminal and desktop-entry launches had previously reused the same running instance.
- Next: switch back to Dark and capture the two final Dark states.

## 9a. Final Dark hidden capture

- Dark with menus hidden passed the per-window pixel, rounding, geometry, and setting checks on all displays.
- Next: verify actual workspace membership-driven growth/shrink, then capture Dark shown and restore the original default preference.

## 9b. Live workspace add and remove — verified

- Created an unused empty workspace on the currently focused output and returned to the original nonempty workspace. The new native i3 icon increased left width, and removal returned it to exactly its original width. All other bar PIDs stayed unchanged.
- Next: restore default visibility and capture Dark shown.

## 9c. Original state restored and Dark shown verified

- Restored the initial Dark theme and default-enabled Global Menu state. Removed the temporary test preference file that did not exist before testing.
- Captured all three left windows and the settings window. Dark shown passed width, pixel padding, rounded-edge, icon visibility, and clearance checks. Only left PIDs changed within the Dark visibility cycle.
- Next: verify external settings synchronization, run final read-only checks, and write the report.

## 10a. Native workspace click — verified

- Clicked the workspace 8 icon on eDP-1 in Dark/show. i3 focused the expected workspace and every bar PID stayed unchanged. Returned to the original workspace 6 and restored the pointer.
- Next: run isolated preference/UI synchronization tests and final process, network, and syntax checks.

## 10b. Preference synchronization and desktop discovery — verified

- Isolated GTK test covered safe missing/corrupt preferences, atomic user-only writes, external Dark selection, visibility synchronization, and preview label removal/restoration.
- Gio resolved the installed desktop launcher with its intended command.
- Next: close the verified settings window, audit the runtime and repository, and finish the documentation.

## 11. Final runtime and syntax audit — complete

- Python/Bash syntax, Polybar module lists, git diff --check, and sizing tiers over four DPI settings passed.
- After closing Settings, the 12 Polybar PIDs stayed in place. One listener remains, and no popup or settings process or stale popup/control lock remains. Current Polybar logs have no matching errors.
- VPN On, network label, and EN/FA XKB configuration were confirmed by read-only commands. Original Dark and default-enabled Global Menu remain active.
- Next: record the results and selective rollback instructions in the final report.

## 12. Documentation and delivery — complete

- Added the user controls to README-macos.md and created POLYBAR_SETTINGS_FINAL_REPORT.md with per-configuration measurements, real screenshots, verification limits, modified files, and selective rollback.
- Matched the width helper's default for cross-monitor urgent workspaces to Polybar's own default and rechecked the restored Dark/shown layout on all three displays.
- Final state: Dark, menu shown by default, no test preference file, 12 bars, one listener, and no session test windows or held popup lock.
- Next: no implementation steps pending. Use the final report for screenshots, verification limits, and recovery.
