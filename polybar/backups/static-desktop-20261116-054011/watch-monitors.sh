#!/usr/bin/env bash
set -u
state="${XDG_STATE_HOME:-$HOME/.local/state}/polybar-menu"
mkdir -p "$state"
exec 7>"$state/monitors.lock"
flock -n 7 || exit 0
printf '%s\n' "$$" > "$state/watcher.pid"
previous=$(polybar --list-monitors)
while sleep 5; do
 current=$(polybar --list-monitors)
 if [[ -n $current && $current != "$previous" ]]; then
  "$HOME/.config/polybar/scripts/launch.sh" 7>&-
  previous=$current
 fi
done
