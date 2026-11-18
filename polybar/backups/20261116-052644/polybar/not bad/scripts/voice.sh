#!/usr/bin/bash

chargSt=$(upower -i $(upower -e | grep BAT) | grep --color=never -E "state|to empty|percentage" | cut -d' ' -f 20 | sed -n 1p)
percentage=$(upower -i $(upower -e | grep BAT) | grep --color=never -E "state|to empty|percentage" | sed -n 3p | cut -d ' ' -f 15 | cut -d '%' -f 1)

if [ $chargSt == 'discharging' ]
then
  if [ $percentage -lt 80 ]
  then
    notify-send "Battery dieing ... "
    #exec amixer set 'Master' 80%
    mpv /home/sim0r/gilfoyle.mp3
  fi
fi
