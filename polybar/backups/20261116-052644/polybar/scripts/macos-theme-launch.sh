#!/usr/bin/env bash
set -euo pipefail
base="$HOME/.config/polybar"
state="$base/.macos-theme"
theme="$(cat "$state" 2>/dev/null || echo light)"
[[ "$theme" == dark || "$theme" == light ]] || theme=light
mkdir -p "$base"
printf '%s\n' "$theme" > "$state"
pidfile="$base/.macos-theme.pid"
if [[ -f "$pidfile" ]]; then
  old="$(cat "$pidfile")"
  if [[ "$old" =~ ^[0-9]+$ ]] && kill -0 "$old" 2>/dev/null; then
    # Only terminate the process when it is our Polybar instance.
    if [[ -r "/proc/$old/cmdline" ]] && tr '\0' ' ' < "/proc/$old/cmdline" | grep -Fq "config-macos-$theme"; then
      kill "$old" 2>/dev/null || true
    elif [[ -r "/proc/$old/cmdline" ]] && tr '\0' ' ' < "/proc/$old/cmdline" | grep -Eq 'config-macos-(dark|light)'; then
      kill "$old" 2>/dev/null || true
    fi
  fi
fi
sleep 0.2
polybar -c "$base/config-macos-$theme" macos >> "$base/macos-polybar.log" 2>&1 &
printf '%s\n' "$!" > "$pidfile"
