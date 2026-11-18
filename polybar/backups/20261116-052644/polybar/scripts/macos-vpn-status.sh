#!/usr/bin/env bash
# Green = connected; red = explicitly disconnected; amber = unverified.
# To customize detection, edit this script; never assume a normal internet link is VPN.
original="$HOME/.config/polybar/scripts/windscribe-status.sh"
if [[ -f "$original" ]]; then
  output="$(bash "$original" 2>/dev/null)"
  lower="${output,,}"
  if [[ "$lower" =~ disconnected|not[[:space:]_-]*connected|inactive|logged[[:space:]_-]*out ]]; then
    printf '%%{F#FF7777}● VPN Off%%{F-}\n'; exit
  elif [[ "$lower" =~ connected|active ]]; then
    printf '%%{F#72D9A7}● VPN On%%{F-}\n'; exit
  fi
fi
if command -v nmcli >/dev/null 2>&1; then
  if nmcli -t -f TYPE connection show --active 2>/dev/null | grep -Eq '^(vpn|wireguard)$'; then
    printf '%%{F#72D9A7}● VPN On%%{F-}\n'; exit
  fi
fi
# Windscribe may connect outside NetworkManager; do not misreport as OFF.
if command -v windscribe >/dev/null 2>&1; then
  output="$(timeout 3 windscribe status 2>/dev/null || true)"
  lower="${output,,}"
  if [[ "$lower" =~ disconnected|not[[:space:]_-]*connected ]]; then
    printf '%%{F#FF7777}● VPN Off%%{F-}\n'; exit
  elif [[ "$lower" =~ connected ]]; then
    printf '%%{F#72D9A7}● VPN On%%{F-}\n'; exit
  fi
fi
printf '%%{F#E9C46A}● VPN ?%%{F-}\n'
