#!/bin/bash

# بررسی وضعیت wlan0 و wlan1
for iface in wlan0 wlan1; do
	if ip link show "$iface" 2>/dev/null | grep -q "UP"; then
		ssid=$(iw dev "$iface" link 2>/dev/null | grep SSID | awk '{print $2}')
		if [ -n "$ssid" ]; then
			echo "$iface: $ssid"
			exit 0
		fi
	fi
done

echo "Disconnected"
