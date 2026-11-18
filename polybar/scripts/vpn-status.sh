#!/usr/bin/env bash
set -u
export LC_ALL=C
umask 077
cache="${XDG_CACHE_HOME:-$HOME/.cache}/polybar-menu"
mkdir -p "$cache"
# Official local IPC status only: neither an interface nor another NM VPN
# establishes Windscribe's connection state. Never persist raw account/IP data.
if [[ ${1:-} == info ]]; then
 exec notify-send 'Windscribe connection' "$("$0" | sed 's/%{[^}]*}//g')"
fi
emit() {
 case $1 in
  on) printf '%%{F#299B56}● VPN On%%{F-}\n';;
  off) printf '%%{F#D95050}● VPN Off%%{F-}\n';;
  connecting) printf '%%{F#B78317}● VPN Connecting%%{F-}\n';;
  *) printf '%%{F#B78317}● VPN ?%%{F-}\n';;
 esac
}
recent() {
 [[ -f $cache/windscribe-state ]] || return 1
 local saved state now
 read -r saved state < "$cache/windscribe-state"
 now=$(date +%s)
 [[ $saved =~ ^[0-9]+$ && $((now-saved)) -ge 0 && $((now-saved)) -lt 3 ]] || return 1
 emit "$state"
}
# A new dedicated lock avoids the old permanently contended vpn.lock.
# Close the descriptor in the IPC client so children cannot retain ownership.
exec 8>"$cache/windscribe-status-v2.lock"
if ! flock -w 1 8; then recent || emit unknown; exit; fi
recent && exit
state=unknown
cli=$(command -v windscribe-cli || command -v windscribe || true)
if [[ -n $cli ]] && output=$(timeout -k 1s 3s "$cli" status 8>&- 2>/dev/null); then
 connection=$(printf '%s\n' "$output" | sed $'s/\033\\[[0-9;]*[[:alpha:]]//g' | sed -nE 's/^[[:space:]]*Connect(ion)? state:[[:space:]]*//p' | head -1)
 case "$connection" in
  Connected|Connected:*|\*Connected|\*Connected:*) state=on;;
  Disconnected|Disconnected:*) state=off;;
  Connecting*|Disconnecting*|Reconnecting*) state=connecting;;
 esac
fi
# Fail closed to unknown after a short debounce; no stale green on CLI failure.
printf '%s %s\n' "$(date +%s)" "$state" > "$cache/windscribe-state.$$"
mv "$cache/windscribe-state.$$" "$cache/windscribe-state"
emit "$state"
