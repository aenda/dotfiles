#!/bin/sh

read -r level < /sys/class/backlight/intel_backlight/actual_brightness
newlevel=`expr $level - 100`
#echo $newlevel
#echo $(expr $newlevel - 100 \> 0) 
if [ $newlevel -gt 0 ]; then
  echo $newlevel >> /sys/class/backlight/intel_backlight/brightness
fi
