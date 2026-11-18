# Plank spacing progress

## 1. Diagnose and back up

- One Plank process, one dock. The tooltip and GTK helper have no struts. DP-1 (1600×900) is the intended output. No bottom dock reservation on eDP-1 or HDMI-1.
- Plank's native bottom strut is 212 root pixels, including 180 pixels below the DP-1 monitor in the 1080-pixel root. Only 32 pixels describe Plank's visible footprint. i3 uses the 116-pixel X11 dock window height, which includes transparent animation space, to size its bottomdock. Normal per-workspace gaps are separate.
- DP-1 currently shows fullscreen playback, so live before geometry was captured without changing workspaces or touching playback. The visible-area comparison will use an isolated X11 session where needed.
- Private backup: `~/.plank-spacing-20261118-222101-nEo3un`.
- Next: split the transparent animation window from the measured i3 reservation and exercise the fix in a nested X11 session.

## 2. Implement the reservation split

- The existing Plank startup hook now starts a per-display helper. The helper lets Plank keep its own animation-sized X11 surface and publishes a separate, transparent, input-free i3 dock at the height Plank reports for the visible dock, plus three pixels.
- Non-reserving hide modes remove the companion window. The helper suppresses the animation surface while an application is fullscreen on that output.
- Syntax checks passed. No changes have been applied to the live dock yet.
- Next: verify window management, tiling and hide transitions in an isolated X11/i3 session.

## 3. Isolate the D-Bus test environment

- The first Xvfb run exposed that the isolated D-Bus daemon had inherited the live dconf directory. Restored the original monitor and icon order from the backup and compared the complete Plank dconf dump before continuing.
- Redirected isolated D-Bus activation to private XDG directories and copied launchers into the fixture. The corrected run verifies the theme and icon size before starting Plank.
- Next: run the corrected geometry and hide-mode tests.

- Corrected the second isolation issue: the nested harness inherited the live I3SOCK, which caused its workspace focus commands to reach the live session. The harness now unsets that variable, starts i3 on a private socket, and asserts the nested loaded config before any tests. No live app was closed or sent a media command. The current playback remains fullscreen. Captured DP-1's visible dock and tiled gap without further live focus changes.
- Next: validate the tool against the explicitly isolated socket before applying it live.

## 4. Validate reservation and hide behavior in isolation

- With the isolated i3 socket verified, the first valid run showed a transparent companion reservation in always-visible mode, zero reservation after changing to auto-hide or intelligent-hide, and a real dock reveal without tiled windows resizing.
- Removed the extra three pixels from the reservation to respect the live workspace's existing 10-pixel separation. Stabilized the test fixture's terminal window identifiers before the fullscreen and floating assertions.
- Next: run the final nested checks, then apply to the live dock without restarting it.

## 5. Apply the live fix

- Started the reservation helper against the existing live Plank window. Plank itself and the i3 and Polybar processes were left running.
- Captured the matching DP-1 crop and before/after i3 trees. Polybar PIDs are unchanged.
- Next: check the exact live geometry, compare the screenshots, and audit final nested test results.

## 6. Confirm live geometry

- Existing Brave on DP-1 gained 84 client pixels in height (706 → 790). The workspace grew from 728 to 812 and the bottom reservation fell from 116 to 32. The visible gap above the dock fell from 94 to 10 pixels, and the animation canvas is still 116 pixels.
- eDP-1 and HDMI-1 still reserve zero bottom pixels. The live application and workspace IDs, output assignments, and visibility flags matched across the actual fix. Existing fullscreen playback retained its full output rectangle.
- Next: finish the isolated fullscreen, floating, and restart checks, then document results and rollback.

## 7. Fix cleanup when Plank exits

- Nested tests passed side-by-side terminals, workspace switching, floating and fullscreen, and the VLC window. The stopped-dock test found a queued X11 destroy that could stay buffered if Plank had gone away. Flush the destroy immediately when changing the reservation plan.
- Deployed the corrected helper, leaving the same Plank process running. The helper also treats fullscreen split containers like fullscreen application windows.
- Next: rerun nested close/relaunch and final invariants, then finish the report.

## 8. Final verification

- The corrected nested run confirmed 116 → 32 pixels in always-visible mode, zero bottom reservation when auto-hidden or revealed and in intelligent mode, zero after Plank exited, and a single 32-pixel reservation after relaunch.
- Both tiled test terminals gained 84 pixels, floating and workspace switching worked, VLC tiled at the expected height, and the fullscreen test terminal covered 1280×800 with the dock visually absent.
- Confirmed one live helper, one live Plank, unchanged Polybar PIDs, matching Plank settings, and clean syntax. Physical monitor hotplug was omitted.
- Next: write the final report with screenshot links and rollback.

## 9. Delivery complete

- Saved PLANK_SPACING_FINAL_REPORT.md with live and isolated measurements, verified cases, limitations, screenshots, and a selective rollback.
- Final live state is one Plank process and one helper, 32 pixels reserved only on DP-1, and the original always-visible mode. Polybar is unchanged.
- Next: none.
