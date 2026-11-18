#!/usr/bin/env bash
set -euo pipefail
backup=$(cd -- "$(dirname -- "$0")" && pwd)
base="$HOME/.config/polybar"
state="${XDG_STATE_HOME:-$HOME/.local/state}/polybar-menu"
if [[ -f $state/watcher.pid ]]; then
 pid=$(cat "$state/watcher.pid")
 if [[ $pid =~ ^[0-9]+$ && -r /proc/$pid/cmdline ]] && tr '\0' ' ' <"/proc/$pid/cmdline" | grep -Fq 'polybar/scripts/workspace-listener.py'; then kill "$pid"; fi
fi
"$base/scripts/launch.sh" --stop
for relative in config.ini modules.ini scripts/launch.sh scripts/watch-monitors.sh scripts/left-width.py scripts/network.sh themes/light.ini themes/dark.ini README-macos.md; do
 cp -a "$backup/$relative" "$base/$relative"
done
rm -f "$base/scripts/workspace-listener.py" "$base/scripts/wifi-menu.py" "$base/scripts/wifi-menu.sh"
i3-msg 'exec --no-startup-id ~/.config/polybar/launch.sh' >/dev/null
printf 'Restored pre-fix Polybar configuration from %s\n' "$backup"
