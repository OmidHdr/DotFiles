
#!/bin/bash

read -p "Enter your screen mode (home/work): " status

if [ "$status" == 'home' ]; then
  xrandr --output eDP-1 --auto --output DP-1 --auto --output HDMI-1 --auto --output DP-1 --left-of eDP-1 --output HDMI-1 --right-of eDP-1
elif [ "$status" == 'work' ]; then
  xrandr --output eDP-1 --auto --output DP-1 --auto --output HDMI-1 --auto --output DP-1 --right-of eDP-1 --output HDMI-1 --left-of eDP-1
fi

