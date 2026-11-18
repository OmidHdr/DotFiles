#!/usr/bin/env bash
set -euo pipefail
base="$HOME/.config/polybar"
state="${XDG_STATE_HOME:-$HOME/.local/state}/polybar-menu"
cache="${XDG_CACHE_HOME:-$HOME/.cache}/polybar-menu"
mkdir -p "$state" "$cache"
if [[ ${1:-} != --locked ]]; then exec 9>"$state/control.lock"; flock 9; fi
if [[ ${1:-} == --stop ]]; then stop_only=1; else stop_only=0; fi
# This launcher owns the session's Polybar installation. Terminate only this user's Polybar.
pkill -u "$(id -u)" -x polybar || true
for ((i=0;i<30;i++)); do pgrep -u "$(id -u)" -x polybar >/dev/null || break; sleep .05; done
[[ $stop_only == 0 ]] || exit 0
theme=$(cat "$state/theme" 2>/dev/null || echo light)
[[ $theme == dark ]] || theme=light
printf '%s\n' "$theme" > "$state/theme"
ln -sfn "$theme.ini" "$base/themes/current.ini"
: > "$cache/pids"
# Logical DPI defaults to the X server, rather than treating physical monitor size as UI scaling.
dpi=$(xrdb -query | awk '/Xft.dpi:/ {print int($2); exit}')
export BAR_DPI=${POLYBAR_DPI:-${dpi:-96}}
scale=$BAR_DPI
export BAR_HEIGHT=$((30*scale/96)) BAR_TOP=$((8*scale/96)) RESERVE_HEIGHT=$((46*scale/96))
while read -r MONITOR geometry rest; do
 export MONITOR
 width=${geometry%%x*}
 export LEFT_X=$((12*scale/96))
 export CENTER_WIDTH=$((148*scale/96))
 export CENTER_X=$(((width-CENTER_WIDTH)/2))
 max=$((CENTER_X-LEFT_X-16*scale/96))
 export LEFT_WIDTH=$((440*scale/96)) RIGHT_WIDTH=$((440*scale/96))
 ((LEFT_WIDTH>max)) && LEFT_WIDTH=$max
 ((RIGHT_WIDTH>max)) && RIGHT_WIDTH=$max
 export RIGHT_X=$((width-LEFT_X-RIGHT_WIDTH))
 export RIGHT_MODULES='cpu memory network pulseaudio battery date'
 ((RIGHT_WIDTH<420*scale/96)) && RIGHT_MODULES='network pulseaudio battery date'
 ((RIGHT_WIDTH<340*scale/96)) && RIGHT_MODULES='pulseaudio date'
 for bar in reserve left center right; do
  nohup polybar -c "$base/config.ini" "$bar" >"$cache/$MONITOR-$bar.log" 2>&1 </dev/null 9>&- &
  echo "$!" >> "$cache/pids"
 done
done < <(polybar --list-monitors | sed 's/: / /')

python3 "$base/scripts/reserve-input.py"
nohup "$base/scripts/watch-monitors.sh" >"$cache/monitors.log" 2>&1 </dev/null 9>&- &
