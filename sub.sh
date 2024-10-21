#!/bin/bash
sub_file="$1"

notify-send "Subtitle File Path: $sub_file"
echo "sub-add \"$sub_file\"" | socat - /tmp/mpvsocket

