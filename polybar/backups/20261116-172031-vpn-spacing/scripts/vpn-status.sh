#!/usr/bin/env bash
set -u
export LC_ALL=C
cache="${XDG_CACHE_HOME:-$HOME/.cache}/polybar-menu"
mkdir -p "$cache"
# Fresh CLI evidence only. No process/interface inference and no stale green cache.
if [[ ${1:-} == info ]]; then
 info=$(timeout 4 windscribe-cli status 2>/dev/null || true)
 command -v notify-send >/dev/null && notify-send 'Windscribe connection' "${info:-Status unavailable. Open Windscribe for details.}"
 exit 0
fi
exec 8>"$cache/vpn.lock"
flock -w 4 8 || { echo '%{F#B78317}● VPN ?%{F-}'; exit; }
now=$(date +%s)
if [[ -f $cache/vpn && $((now - $(stat -c %Y "$cache/vpn"))) -lt 4 ]]; then cat "$cache/vpn"; exit; fi
state=unknown
cli=$(command -v windscribe-cli || command -v windscribe || true)
if [[ -n $cli ]]; then
 output=$(timeout 3 "$cli" status 2>/dev/null || true)
 connection=$(printf '%s\n' "$output" | sed -nE 's/^[[:space:]]*Connect(ion)? state:[[:space:]]*//p' | head -1)
 case "$connection" in
  Connected|Connected:*|\*Connected|\*Connected:*) state=on;;
  Disconnected|Disconnected:*) state=off;;
  Connecting*|Disconnecting*|Reconnecting*) state=connecting;;
 esac
fi
# Only NM's activated VPN state is authoritative; a WireGuard interface alone is insufficient.
if [[ $state == unknown ]] && command -v nmcli >/dev/null; then
 while IFS=: read -r uuid type; do
  [[ $type == vpn ]] || continue
  active=$(timeout 2 nmcli -g VPN.VPN-STATE connection show "$uuid" 2>/dev/null || true)
  [[ $active == '5 '* || $active == '5'*activated* ]] && state=on
 done < <(timeout 2 nmcli -t -f UUID,TYPE connection show --active 2>/dev/null)
fi
case $state in
 on) text='%{F#299B56}● VPN On%{F-}';;
 off) text='%{F#D95050}● VPN Off%{F-}';;
 connecting) text='%{F#B78317}● VPN …%{F-}';;
 *) text='%{F#B78317}● VPN ?%{F-}';;
esac
printf '%s\n' "$text" > "$cache/vpn.tmp"
mv "$cache/vpn.tmp" "$cache/vpn"
printf '%s\n' "$text"
