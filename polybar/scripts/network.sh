#!/usr/bin/env bash
export LC_ALL=C
if [[ ${1:-} == info ]]; then
 exec "$HOME/.config/polybar/scripts/wifi-menu.sh"
fi
if command -v nmcli >/dev/null; then
 links=$(timeout 2 nmcli -t -f TYPE,STATE device 2>/dev/null)
 if [[ $links == *wifi:connected* ]]; then echo ''; elif [[ $links == *ethernet:connected* ]]; then echo ''; else echo 'Offline'; fi
else
 ip -4 route show default | head -1 | awk '{if(NF) print "Net"; else print "Offline"}'
fi
