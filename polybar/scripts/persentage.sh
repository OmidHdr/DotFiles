#!/usr/bin/bash


chargSt=$(upower -i $(upower -e | grep BAT) | grep --color=never -E "state|to empty|percentage" | cut -d' ' -f 20 | sed -n 1p)

if [ $chargSt == 'charging' ]
then
	#upower -i $(upower -e | grep BAT) | grep --color=never -E "state|to empty|percentage" | sed -n 3p | cut -d ' ' -f 15
  #upower -i $(upower -e | grep BAT) | grep --color=never -E "state|to empty|percentage" | grep percentage: | cut -d' ' -f 15
  upower -i $(upower -e | grep BAT) | grep --color=never -E "state|to empty|percentage" | grep percentage: | cut -d' ' -f 15
fi

if [ $chargSt == 'discharging' ]
then
  upower -i $(upower -e | grep BAT) | grep --color=never -E "state|to empty|percentage" | grep percentage: | cut -d' ' -f 15
fi

if [ $chargSt == 'fully-charged' ]
then
  upower -i $(upower -e | grep BAT) | grep --color=never -E "state|to empty|percentage" | grep percentage: | cut -d' ' -f 15
fi
