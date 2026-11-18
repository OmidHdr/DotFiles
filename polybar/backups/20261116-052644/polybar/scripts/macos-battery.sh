#!/usr/bin/env bash
shopt -s nullglob
for dev in /sys/class/power_supply/*; do
  [[ -f "$dev/type" ]] || continue
  [[ "$(<"$dev/type")" == Battery ]] || continue
  [[ -r "$dev/capacity" ]] || continue
  pct="$(<"$dev/capacity")"
  status="$(cat "$dev/status" 2>/dev/null)"
  if [[ "$status" == Charging ]]; then
    printf 'BAT %s%% +\n' "$pct"
  else
    printf 'BAT %s%%\n' "$pct"
  fi
  exit 0
done
# Desktop computers do not need an empty battery widget.
exit 0
