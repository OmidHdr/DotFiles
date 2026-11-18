# Global Menu progress

## 1. Inspect existing popup — complete

- Files modified: this progress log. Existing configuration and recovery backup preserved.
- The existing GTK popup uses a synthetic button press on the root window and enters Gtk.main unconditionally.
- Tests: inspected the popup, menu providers, and live Polybar configuration. DISPLAY=:0 is accessible.
- Completed features: existing Apple/Finder and menu wiring inventoried.
- Remaining: diagnose the stuck owner, fix and test Apple, then verify Finder, File, Edit, View, Go, Window, Help, and overflow.
- Next: inspect the lock owner and X11 windows.

## 2. Inspect popup and lock ownership — complete

- Files modified: this progress log.
- PID 3179781 (global-menu.py apple) held the exclusive FLOCK on ~/.local/state/polybar-menu/global-menu.lock. X11 showed only its 10×10 GTK helper window. New invocations exit on contention.
- Tests: inspected lslocks, /proc/3179781/fd, xwininfo, and the three live left capsules.
- Next: terminate only that stale popup and reproduce the startup failure with stderr captured before patching.

## 3. Reproduce the Apple startup failure — complete

- Files modified: this progress log.
- Terminated only stale Apple PID 3179781. A fresh bounded run reproduced the GTK helper window without a dropdown. A faulthandler trace pinned the stall to the synchronous GdkX11.x11_get_server_time(root) call, before GTK reaches popup_at_rect.
- Remaining: patch the timestamp, positioning, and failed-map handling, then test from the actual Apple click.
- Next: use the X11 current-time constant and anchor the top of the popup below the clicked capsule.

## 4. Fix popup startup and positioning — complete

- Files modified: scripts/global-menu.py and this log.
- Replaced the blocking X11 timestamp lookup with Gdk.CURRENT_TIME. Anchored the popup directly at the capsule bottom plus four pixels and skip the GTK loop if the popup fails to map.
- Tests: a bounded direct Apple invocation mapped a 185×234 X11 menu at (30,42), directly below the DP-1 capsule ending at y=38. Escape closed it and released the lock.
- Remaining: confirm the live Polybar click, keyboard activation, and other menus.
- Next: click Apple on each live left capsule, check the mapped geometry, and open About This System.

## 5. Verify Apple from the running bar — complete

- Files modified: this progress log.
- Tests: clicked Apple on DP-1, eDP-1, and HDMI-1. Each opened a 185×234 popup at its click x coordinate and y=42. Escape released each popup and allowed the next click. Down and Return opened the About This System dialog, which was dismissed with Escape.
- Completed features: Apple popup startup, placement, live click handling, keyboard activation, and lock recovery.
- Remaining: verify Finder/Application, File, Edit, View, Go, Window, Help, and overflow.
- Next: inspect live menu labels and verify the Finder/Application entry from Polybar.

## 6. Restore the requested Finder label — complete

- Files modified: scripts/menu_context.py, scripts/workspace-listener.py, scripts/global-menu.py, and this log.
- The existing bar rendered the focused application's name in the Finder slot. The slot now stays labeled Finder. It retains its desktop actions and exposes any focused application's exported menu in a submenu. The named sections still prefer matching native menus.
- Tests: refreshed the dedicated Polybar workspace listener and sent the menu IPC hook to the live left capsules. Confirmed the existing DP-1 left capsule PID remained running.
- Remaining: verify Finder and every other popup and safe actions.
- Next: click Finder on DP-1 and verify its file-manager action.

## Live Finder popup — complete

- Files modified: this progress log.
- Tests: clicked the Finder label on DP-1, verified the app process and live X11 geometry 162x206+64+42, then dismissed it with Escape and verified the process exited.
- Completed feature: Finder popup wiring and positioning.
- Remaining: any unlisted menus, action checks, overflow, and final verification.
- Next: verify the next label in Finder, File, Edit, View, Go, Window, Help order, then run safe action checks.

## Live File popup — complete

- Files modified: this progress log.
- Tests: clicked the File label on DP-1, verified the file process and live X11 geometry 212x150+108+42, then dismissed it with Escape and verified the process exited.
- Completed feature: File popup wiring and positioning.
- Remaining: any unlisted menus, action checks, overflow, and final verification.
- Next: verify the next label in Finder, File, Edit, View, Go, Window, Help order, then run safe action checks.

## Live Edit popup — complete

- Files modified: this progress log.
- Tests: clicked the Edit label on DP-1, verified the edit process and live X11 geometry 165x66+142+42, then dismissed it with Escape and verified the process exited.
- Completed feature: Edit popup wiring and positioning.
- Remaining: any unlisted menus, action checks, overflow, and final verification.
- Next: verify the next label in Finder, File, Edit, View, Go, Window, Help order, then run safe action checks.

## Live View popup — complete

- Files modified: this progress log.
- Tests: clicked the View label on DP-1, verified the view process and live X11 geometry 166x178+182+42, then dismissed it with Escape and verified the process exited.
- Completed feature: View popup wiring and positioning.
- Remaining: any unlisted menus, action checks, overflow, and final verification.
- Next: verify the next label in Finder, File, Edit, View, Go, Window, Help order, then run safe action checks.

## Live Go popup — complete

- Files modified: this progress log.
- Tests: clicked the Go label on DP-1, verified the go process and live X11 geometry 128x178+217+42, then dismissed it with Escape and verified the process exited.
- Completed feature: Go popup wiring and positioning.
- Remaining: any unlisted menus, action checks, overflow, and final verification.
- Next: verify the next label in Finder, File, Edit, View, Go, Window, Help order, then run safe action checks.

## Live Window popup — complete

- Files modified: this progress log.
- Tests: clicked the Window label on DP-1, verified the window process and live X11 geometry 193x234+264+42, then dismissed it with Escape and verified the process exited.
- Completed feature: Window popup wiring and positioning.
- Remaining: any unlisted menus, action checks, overflow, and final verification.
- Next: verify the next label in Finder, File, Edit, View, Go, Window, Help order, then run safe action checks.

## Live Help popup — complete

- Files modified: this progress log.
- Tests: clicked the Help label on DP-1, verified the help process and live X11 geometry 188x122+314+42, then dismissed it with Escape and verified the process exited.
- Completed feature: Help popup wiring and positioning.
- Remaining: any unlisted menus, action checks, overflow, and final verification.
- Next: verify the next label in Finder, File, Edit, View, Go, Window, Help order, then run safe action checks.

## file dialog action — complete

- Files modified: this progress log.
- Tests: selected the action from the live bar with Down and Return, verified the X11 dialog (798x476+5+5), and dismissed it.
- Next: check unverified menus and overflow.

## go dialog action — complete

- Files modified: this progress log.
- Tests: selected the action from the live bar with Down and Return, verified the X11 dialog (420x125+5+5), and dismissed it.
- Next: check unverified menus and overflow.

## help dialog action — complete

- Files modified: this progress log.
- Tests: selected the action from the live bar with Down and Return, verified the X11 dialog (640x480+5+5), and dismissed it.
- Next: check unverified menus and overflow.

## Overflow popup and submenu — complete

- Files modified: this progress log.
- Tests: invoked the overflow entry point at the live DP-1 capsule, verified the X11 root popup, opened Finder with Down and Right, and dismissed both levels with Escape. Active monitors all fit the full tier.
- Next: verify action wiring and both theme styles without changing the active theme.

## Remaining check 1. Action dispatch — complete

- Files modified: this log.
- Verified GTK queues one callback per item and checked intercepted Finder launch, new terminal, both CopyQ commands, Light and Dark switches, Go Home, floating and fullscreen commands, Help, and the close/reboot confirmation guards.
- Earlier live dialog tests remain valid. No session-changing commands were dispatched.
- Next: verify Light and Dark GTK styling with isolated state.

## Remaining check 2. Popup styling — complete

- Files modified: this log.
- Verified GTK computed background, text, and hover colors for Light (f6f6fa, 1d1d1f, d8e8fa) and Dark (25272f, f5f5f7, 315f95). Used a separate temporary state directory for each style. The desktop theme stayed as it was.
- Next: inspect live applications for native exports and test the supported protocols.

## Remaining check 3. Native application menus — complete

- Files modified: this log.
- Verified real D-Bus calls through both native readers in isolated X11/D-Bus fixtures. The GTK GMenu fixture returned a File submenu and handled a Gio action. The Canonical dbusmenu fixture returned an item and received its clicked event.
- Current live Brave, kitty, mpv, Telegram Desktop, and Windscribe windows returned no export. GNOME Terminal in an isolated X11 session had GTK action-group properties without an exported menu. Thunar, Mousepad, and Nautilus did not present a usable test window in that isolated run. No installed application was positively verified as exporting a usable menu.
- Next: verify existing workspace sizing and VPN clearances.

## Remaining check 4. Workspace sizing and VPN clearance — complete

- Files modified: this log.
- Read-only X11 geometry and current workspace measurement agree on all monitors. Clearance from left to centered VPN is DP-1 186 px, eDP-1 409 px, HDMI-1 241 px.
- The production width script grew each capsule for a synthetic extra workspace and stayed within its cap. Exercised full, compact, small, and off thresholds. Existing resize logs show an actual workspace add/remove replaced only the affected left capsule, and an equal-width rename replaced none. No workspace or i3 state was changed during this check.
- Next: verify the existing workspace, VPN, Wi-Fi, keyboard, right capsule, and theme wiring.

## Remaining check 5. Existing Polybar behavior — complete

- Files modified: this log.
- Workspace icon mapping and label styling are unchanged. The center and right configurations are intact. Windscribe connected and the script rendered VPN On. NetworkManager reported Ethernet connected and Wi-Fi idle, and the network script returned a valid Ethernet label. XKB exposes us,ir and the live right bar includes the keyboard module.
- The theme status command and active symlink agree on Dark. Both presets remain present. Verified switch argument dispatch separately and kept the active desktop theme. No connectivity changes or live workspace/keymap switches were performed.
- Next: check process and lock ownership and current logs.

## Remaining check 6. Runtime hygiene — complete

- Files modified: this log.
- Verified 12 unique live bar PIDs match the per-output PID files (three of each role), with one subscribed workspace listener holding its expected monitors.lock. Retired two idle shell wrappers from the earlier listener refresh, preserving the running listener PID. No popup process, held popup lock, or errors in current bar/watcher logs.
- The old vpn.lock file is unheld and obsolete. Lock files remain in place.
- Next: run Python, shell, and Polybar config validation.

## Remaining check 7. Syntax and configuration — complete

- Files modified: this log.
- Python compilation passed for the six menu/listener/sizing scripts. Bash syntax passed for launch, watcher, and theme entry points. Polybar parsed all four bar roles and returned the expected module lists with both theme includes. git diff --check passed.
- Next: update the README and write the final report with the verified recovery archive layout.

## Remaining check 8. Documentation and final report — complete

- Files modified: README-macos.md, GLOBAL_MENU_FINAL_REPORT.md, and this log.
- Documented the current menu controls, actual verification results, protocol and installed-application coverage, unexercised live actions, and selective rollback to the verified archive members.
- Tests: checked the recovery archive member names, final report presence, and git diff --check.
- Completed: all eight requested remaining checks.
- Remaining tasks: none in the requested scope. See the final report for manual checks that would alter the desktop or foreground focus.
- Next: use GLOBAL_MENU_FINAL_REPORT.md as the handoff.
