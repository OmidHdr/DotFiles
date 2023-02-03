#!/bin/sh
#source https://github.com/x70b1/polybar-scripts


updates_arch=$(sudo pacman -Sy | wc -l ); 

updates=$(("$updates_arch"))

if [ "$updates" -gt 0 ]; then
    echo " $updates"
    sudo pacman -Sy

else
    echo "0"
fi
