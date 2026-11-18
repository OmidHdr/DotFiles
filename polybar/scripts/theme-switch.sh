#!/usr/bin/env bash
set -euo pipefail
base="$HOME/.config/polybar"
state="${XDG_STATE_HOME:-$HOME/.local/state}/polybar-menu"
mkdir -p "$state"
exec 9>"$state/control.lock"
flock 9
current=$(cat "$state/theme" 2>/dev/null || echo light)
[[ $current == dark ]] || current=light
case ${1:-toggle} in
 status) echo "$current"; exit;;
 light|dark) next=$1;;
 toggle) if [[ $current == light ]]; then next=dark; else next=light; fi;;
 *) echo 'Usage: polybar-theme {light|dark|toggle|status}' >&2; exit 2;;
esac
printf '%s\n' "$next" > "$state/theme.tmp"
mv "$state/theme.tmp" "$state/theme"
# Close lock in spawned bars; retain it until the launch operation completes.
"$base/scripts/launch.sh" --locked
echo "$next"
