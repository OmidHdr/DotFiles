#!/bin/bash

while true; do
  battery_level=$(acpi -b | grep -P -o '[0-9]+(?=%)')
  charg_level=$(acpi -b | cut -d ' ' -f 3)
  length=${#charg_level}
  if [ "$battery_level" -le 25 ]; then
    if [ "$length" -eq 12 ]; then
      notify-send -u critical "Battery Low" "Your battery is $battery_level%. Please plug in the charger."
      paplay /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga # اجرای صدای هشدار
    fi
    sleep 9
  fi

  if [ "$battery_level" -eq 100 ]; then
    if [ "$length" -eq 5 ]; then
      notify-send -u critical "Battery Full" "Your battery is $battery_level%. Please unplug the charger."
      paplay /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga # اجرای صدای هشدار
    fi
    sleep 600
  fi

  sleep 60
done
