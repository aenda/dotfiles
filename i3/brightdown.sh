#!/bin/sh

read -r level < /sys/class/backlight/intel_backlight/actual_brightness
newlevel=`expr $level - 100`
echo $newlevel >> /sys/class/backlight/intel_backlight/brightness
