#!/usr/bin/env bash
set -euo pipefail
base="$HOME/.config/polybar"
backup=$(cat "$base/backup-location")
[[ -d $backup/polybar && -f $backup/i3-config && -f $backup/picom.conf ]] || { echo 'Backup is incomplete' >&2; exit 1; }
state="${XDG_STATE_HOME:-$HOME/.local/state}/polybar-menu"
if [[ -f $state/watcher.pid ]]; then
 pid=$(cat "$state/watcher.pid")
 if [[ $pid =~ ^[0-9]+$ && -r /proc/$pid/cmdline ]] && tr '\0' ' ' <"/proc/$pid/cmdline" | grep -Fq 'polybar/scripts/watch-monitors.sh'; then kill "$pid" || true; fi
fi
"$base/scripts/launch.sh" --stop
cp -a "$backup/polybar/." "$base/"
cp -a "$backup/i3-config" "$HOME/.config/i3/config"
cp -a "$backup/picom.conf" "$HOME/.config/picom.conf"
# Remove only files introduced by this setup. Keep backups and documentation.
rm -f "$base/config.ini" "$base/modules.ini" "$base/themes/light.ini" "$base/themes/dark.ini" "$base/themes/current.ini"
rm -f "$base/scripts/launch.sh" "$base/scripts/theme-switch.sh" "$base/scripts/vpn-status.sh" "$base/scripts/network.sh" "$base/scripts/watch-monitors.sh" "$base/scripts/reserve-input.py"
rm -f "$HOME/.local/bin/polybar-theme"
i3-msg 'reload' >/dev/null
i3-msg 'exec --no-startup-id ~/.config/polybar/launch.sh' >/dev/null
printf 'Restored %s\n' "$backup"
