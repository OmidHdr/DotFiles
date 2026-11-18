#!/usr/bin/env bash

# Wait for picom and monitor layout
sleep 2

# Start Plank only if it is not already running
if ! pgrep -x plank >/dev/null; then
	/usr/bin/plank >/tmp/plank.log 2>&1 &
fi

# Find Plank's main DOCK window
plank_id=""

for _ in $(seq 1 50); do
	while read -r id; do
		if xprop -id "$id" _NET_WM_WINDOW_TYPE 2>/dev/null |
			grep -q '_NET_WM_WINDOW_TYPE_DOCK'; then
			plank_id="$id"
			break
		fi
	done < <(xdotool search --class Plank 2>/dev/null || true)

	[[ -n "$plank_id" ]] && break
	sleep 0.1
done

[[ -n "$plank_id" ]] || exit 0

# Preserve Plank's compositor-aware geometry so zoom still works
eval "$(xdotool getwindowgeometry --shell "$plank_id")"
plank_hex=$(printf '0x%x' "$plank_id")

# Make it a floating normal window so i3 does not reserve a huge dock area
xdotool windowunmap "$plank_id"

xprop -id "$plank_id" \
	-f _NET_WM_WINDOW_TYPE 32a \
	-set _NET_WM_WINDOW_TYPE _NET_WM_WINDOW_TYPE_NORMAL

xdotool windowmap "$plank_id"

sleep 0.2

i3-msg "[id=\"$plank_hex\"] floating enable, sticky enable, border pixel 0" \
	>/dev/null

# Restore original full-size geometry
xdotool windowsize "$plank_id" "$WIDTH" "$HEIGHT"
xdotool windowmove "$plank_id" "$X" "$Y"
