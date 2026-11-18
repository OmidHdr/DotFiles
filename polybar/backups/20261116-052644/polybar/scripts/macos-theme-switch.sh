#!/usr/bin/env bash
set -euo pipefail
base="$HOME/.config/polybar"
state="$base/.macos-theme"
current="$(cat "$state" 2>/dev/null || echo light)"
case "${1:-toggle}" in
  light|dark) next="$1" ;;
  toggle) if [[ "$current" == light ]]; then next=dark; else next=light; fi ;;
  *) echo 'Usage: macos-theme-switch.sh [light|dark|toggle]' >&2; exit 2 ;;
esac
mkdir -p "$base"
printf '%s\n' "$next" > "$state"
exec "$base/scripts/macos-theme-launch.sh"
