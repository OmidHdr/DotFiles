#!/usr/bin/env bash

# Polybar module output for both the current windscribe-cli and legacy
# windscribe commands. LC_ALL=C keeps the status fields predictable.
export LC_ALL=C

green="#00FF00"
red="#ff0000"
yellow="#EFBF04"
icon=""
cache_dir="${XDG_CACHE_HOME:-${HOME}/.cache}/polybar"
cache_file="${cache_dir}/windscribe-status.cache"
error_file="${cache_dir}/windscribe-status.error"
lock_file="${cache_dir}/windscribe-status.lock"
max_cache_age=120

mkdir -p "$cache_dir" 2>/dev/null

print_status() {
	local color="$1"
	local text="$2"
	printf '%%{F%s}%s VPN: %s%%{F-}\n' "$color" "$icon" "$text"
}

save_status() {
	local color="$1"
	local text="$2"
	local output
	local temporary_file

	output="$(print_status "$color" "$text")"
	printf '%s\n' "$output"

	temporary_file="${cache_file}.$$"
	if printf '%s\n' "$output" >"$temporary_file" 2>/dev/null; then
		mv -f "$temporary_file" "$cache_file"
	else
		rm -f "$temporary_file"
	fi
}

show_cached_status() {
	local now
	local modified
	local age

	if [ -s "$cache_file" ]; then
		now="$(date +%s)"
		modified="$(stat -c %Y "$cache_file" 2>/dev/null || printf '0')"
		age=$((now - modified))

		if [ "$age" -le "$max_cache_age" ]; then
			cat "$cache_file"
			return
		fi
	fi

	print_status "$yellow" "Status unknown"
}

save_error() {
	{
		date '+%Y-%m-%d %H:%M:%S'
		printf '%s\n' "$status"
	} >"$error_file" 2>/dev/null || true
}

# Multiple Polybar instances can otherwise call the Windscribe IPC client at
# the same time. A busy instance displays the recent valid result from cache.
if command -v flock >/dev/null 2>&1; then
	exec 9>"$lock_file"
	if ! flock -n 9; then
		show_cached_status
		exit 0
	fi
fi

if [ -x /usr/bin/windscribe-cli ]; then
	cli="/usr/bin/windscribe-cli"
elif command -v windscribe-cli >/dev/null 2>&1; then
	cli="$(command -v windscribe-cli)"
elif command -v windscribe >/dev/null 2>&1; then
	cli="$(command -v windscribe)"
else
	show_cached_status
	exit 0
fi

if command -v timeout >/dev/null 2>&1; then
	status="$(timeout 8s "$cli" status 9>&- 2>&1)"
else
	status="$("$cli" status 9>&- 2>&1)"
fi

# Remove terminal colour sequences before parsing the CLI output.
status="$(printf '%s\n' "$status" | sed $'s/\033\[[0-9;]*[[:alpha:]]//g')"

# New versions use "Connect state"; older ones may use "Connection state".
connection="$(
	printf '%s\n' "$status" |
		sed -nE 's/^[[:space:]]*Connect(ion)? state:[[:space:]]*//p' |
		head -n 1
)"

case "$connection" in
\*Connected:* | Connected:*)
	location="${connection#*:}"
	location="${location# }"
	save_status "$green" "$location"
	;;
\*Connected | Connected)
	location="$(
		printf '%s\n' "$status" |
			sed -nE 's/^[[:space:]]*(Connected to|Location|Server):[[:space:]]*//p' |
			head -n 1
	)"
	save_status "$green" "${location:-Connected}"
	;;
Connecting:* | Connecting)
	save_status "$yellow" "Connecting…"
	;;
Disconnecting:* | Disconnecting)
	save_status "$yellow" "Disconnecting…"
	;;
Disconnected:* | Disconnected)
	save_status "$red" "Disconnected"
	;;
*)
	if printf '%s\n' "$status" | grep -Eqi 'not logged in|logged out'; then
		save_status "$red" "Logged out"
	else
		save_error
		show_cached_status
	fi
	;;
esac
