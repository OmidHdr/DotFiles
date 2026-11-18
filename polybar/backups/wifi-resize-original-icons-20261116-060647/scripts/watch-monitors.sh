#!/usr/bin/env bash
set -u
state="${XDG_STATE_HOME:-$HOME/.local/state}/polybar-menu"
mkdir -p "$state"
exec 7>"$state/monitors.lock"
flock -n 7 || exit 0
printf '%s\n' "$$" > "$state/watcher.pid"
signature() {
 polybar --list-monitors
 i3-msg -t get_workspaces | python3 -c 'import json,sys; print(sorted((w["output"],w["name"]) for w in json.load(sys.stdin)))'
}
previous=$(signature)
while sleep 5; do
 current=$(signature)
 if [[ -n $current && $current != "$previous" ]]; then
  "$HOME/.config/polybar/scripts/launch.sh" 7>&-
  previous=$current
 fi
done
