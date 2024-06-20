#!/bin/bash


#bash -c = 'pactl set-sink-volume 0 +10%'
#volD = 'set-sink-volume 0 -10%'

#bash -c 'volE'

#pactl set-sink-volume 0 +10%

#amixer -D pulse sset Master 10%+
pactl set-sink-volume @DEFAULT_SINK@ +5%
