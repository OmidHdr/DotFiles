#!/bin/bash


#pactl set-sink-volume 0 -10%


#amixer -D pulse sset Master 10%-
pactl set-sink-volume @DEFAULT_SINK@ -5%
