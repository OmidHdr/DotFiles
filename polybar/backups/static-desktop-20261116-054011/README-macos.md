# macOS-inspired Polybar — installed configuration

Active default: **Light**. No packages or fonts were installed. This setup uses the already installed SF Pro Display, Symbols Nerd Font, Noto Sans and DejaVu Sans; no Apple font/assets were downloaded or redistributed.

## Use

From Fish, Bash, or a terminal:

```sh
polybar-theme light
polybar-theme dark
polybar-theme toggle
polybar-theme status
```

Click the Apple icon to toggle. Click VPN for a Windscribe status notification. Workspace click and wheel actions use native i3 IPC. Volume wheel/left click use the native PulseAudio module; right click opens pavucontrol. Network click opens nm-connection-editor if installed, or shows a connectivity notification.

`~/.config/polybar/launch.sh` launches/replaces the setup. Existing `exec_always --no-startup-id ~/.config/polybar/launch.sh` in i3 provides login/restart integration. i3 restart is unnecessary for theme changes.

Theme state: `${XDG_STATE_HOME:-~/.local/state}/polybar-menu/theme`. Controller operations use flock, atomic state replacement, and a single launcher. The launcher owns all Polybar processes belonging to this user, matching the previous launcher's ownership model. It does not manage other users' bars.

## Files and layout

- `config.ini`: shared bar definitions and geometry; `modules.ini`: functional modules.
- `themes/light.ini`, `themes/dark.ini`; `themes/current.ini`: controller-managed symlink.
- `scripts/launch.sh`: detects active monitors, Xft DPI, scaled dimensions, and compact layouts. Override logical DPI with `POLYBAR_DPI=120 ~/.config/polybar/launch.sh` if needed.
- `scripts/theme-switch.sh`, `~/.local/bin/polybar-theme`: persistent theme controller.
- `scripts/vpn-status.sh`: fresh Windscribe CLI status; only explicit state fields count as connected. Activated NetworkManager VPN state is a secondary source. Unknown remains amber; a tunnel interface, app process, or stale cached green is never sufficient. Cache lifetime is under four seconds; refresh every five seconds, CLI timeout three seconds. Simultaneous monitor calls share a lock/cache.
- `scripts/network.sh`: current NetworkManager device connectivity, dynamically detected.
- `scripts/macos-battery.sh`: existing sysfs detector; hides itself without a battery.
- `scripts/reserve-input.py`: X Shape input exclusion for transparent reservation windows **and i3's parent dock frames**, so clicks reach the capsules below.
- `scripts/watch-monitors.sh`: checks monitor geometry every five seconds, relaunches after changes, flock prevents duplicate watchers.
- Existing legacy macOS theme entry points delegate to the same controller.

Each monitor gets left, center and right capsules plus one transparent reservation dock. VPN center is exactly `(monitor width / 2)` (at most half-pixel rounding). Width constraints keep side sections outside its bounds. Titles truncate at 20 characters. Workspace lists are pinned to their actual output, sorted by workspace index, and remain interactive. Side capsules shrink and CPU/RAM modules disappear on narrow monitors. Very large workspace lists or exceptionally long workspace names can exceed available capsule width; Polybar clips within its window rather than painting across VPN.

The 46-pixel reservation (scaled with logical DPI) protects tiled content; existing i3 gaps remain intact. Floating windows can still be deliberately dragged over the menu area. Fullscreen follows i3/Polybar stacking behavior.

## Picom

Active config is `~/.config/picom.conf` (confirmed by installed Picom diagnostics), rather than `~/.config/picom/picom.conf`. Existing GLX/vsync startup and dual_kawase strength 6 remain in place. Picom watches its config and resets itself when it changes; do not start another compositor.

Changed legacy rules allow shadows/rounding for Polybar capsules, keep transparent reservation docks free of shadow/blur, and preserve shadow exclusions for other dock applications. Native Polybar radius supplies real capsule corners. Blur uses the existing compositor, not pseudo-transparency. Against the current largely black wallpaper, the frosted texture is subtle. Existing compositor warnings about refresh-rate and a missing X bold font predate this setup; the compositor continues functioning.

## Validation performed

- Polybar 3.7.2: i3, network and PulseAudio features present. Picom 13; X11 at 96 DPI. Three monitors: eDP-1 1920×1080, DP-1 and HDMI-1 1600×900.
- Bash syntax checks passed; `i3 -C -c ~/.config/i3/config` passed without errors.
- Actual Light and Dark screenshots inspected; bar-only crops in `screenshots/`.
- Apple click toggled dark to light. Actual workspace clicks switched 2 → 3 on eDP-1, and wheel navigation also switched workspaces. Restored eDP-1 workspace 2 and focused DP-1 workspace 1 afterward.
- Four sequential theme selections/toggles, launcher restart, and two simultaneous toggles passed persistence/process-count assertions. Final state Light, exactly 12 Polybar instances, one Picom compositor. Fish resolves `polybar-theme status`.
- Current Windscribe CLI explicitly reported connected. Parser fixtures for connected, disconnected, connecting and malformed status passed. VPN settings/connectivity were never changed.
- No battery device exists (`ACAD` AC supply only); module emits no output. Native PulseAudio connects to the actual default sink, which is currently muted. No audio settings were changed during testing.
- Bar logs contain no configuration errors, deprecation warnings or missing-glyph warnings after corrections. Logs: `~/.cache/polybar-menu/`, including `validation.log`.
- Reservation struts verified at 46 pixels and workspace rectangles start below them.
- Login integration statically validated and the same launch command tested in the live i3 session. No logout/reboot was performed. Monitor watcher installed; physical hotplug was not tested.

## Limits

The three referenced images were not present in the conversation; fidelity was assessed against the written requirements. Polybar cannot round individual workspace label backgrounds: active highlights are rectangular within a real rounded capsule. i3 deletes unused empty workspaces; this native module displays real workspaces, not invented empty slots. Focused, visible-on-output, unfocused and urgent states have separate styling. The active window title is the globally active X11 window, as provided by Polybar's native xwindow module.

## Backup and rollback

Full pre-change Polybar tree, both Picom configuration files and i3 configuration:

`/home/h0p3/.config/polybar/backups/20261116-052644`

No installation step remains. To restore the previous configuration:

```sh
bash ~/.config/polybar/scripts/rollback.sh
```

This stops the monitor watcher/bars, restores the backed-up Polybar files, i3 config and active Picom config, removes only the new runtime scripts/theme command, reloads i3 configuration, and launches the original bar. Backups, screenshots and these notes remain. The secondary Picom config was never modified. Persistent theme state can optionally be removed afterward from `~/.local/state/polybar-menu`.

Upstream references: [Polybar configuration](https://github.com/polybar/polybar/wiki/Configuration), [Picom manual](https://picom.app/picom.1.html).
