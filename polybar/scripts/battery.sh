#!/usr/bin/bash


chargSt=$(upower -i $(upower -e | grep BAT) | grep --color=never -E "state|to empty|percentage" | cut -d' ' -f 20 | sed -n 1p)

if [ $chargSt == 'charging' ]
then
	echo 
fi

if [ $chargSt == 'discharging' ]
then
	echo 
#	notify-send "Need charging"
  sleep 10
fi

if [ $chargSt == 'fully-charged' ]
then
	echo 
fi

