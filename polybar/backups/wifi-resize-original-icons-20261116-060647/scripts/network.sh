#!/usr/bin/env bash
export LC_ALL=C
if [[ ${1:-} == info ]]; then
 if command -v nm-connection-editor >/dev/null; then exec nm-connection-editor; fi
 info=$(timeout 2 nmcli -f DEVICE,TYPE,STATE device status 2>/dev/null || echo 'Network status unavailable')
 command -v notify-send >/dev/null && notify-send 'Network connections' "$info"
 exit 0
fi
if command -v nmcli >/dev/null; then
 links=$(timeout 2 nmcli -t -f TYPE,STATE device 2>/dev/null)
 if [[ $links == *wifi:connected* ]]; then echo ''; elif [[ $links == *ethernet:connected* ]]; then echo ''; else echo 'Offline'; fi
else
 ip -4 route show default | head -1 | awk '{if(NF) print "Net"; else print "Offline"}'
fi
