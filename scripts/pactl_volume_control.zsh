#!/bin/env zsh

#SINK=$( pactl list short sinks | sed -e 's,^\([0-9][0-9]*\)[^0-9].*,\1,' | head -n 1 )
SINK="$( pactl list short sinks | awk '/RUNNING/ {print $1}' )"
get_sink_vol() {
    pactl list sinks | grep '^[[:space:]]Volume:' | head -n $(( $SINK + 1 )) | tail -n 1 | sed -e 's,.* \([0-9][0-9]*\)%.*,\1,'
}
check_headphones() {
    pacmd list-cards | grep Headphones
}

if [[ "$1" == "mute" ]]; then
    /usr/bin/pactl set-sink-mute "${$(pactl info | grep Sink)#*:\ }" toggle
elif [[ "$1" == "up" ]]; then
    if [[ "$(check_headphones)" == *yes* ]]; then
        if [[ "$(get_sink_vol)" -lt 20 ]]; then
            exec /usr/bin/pactl set-sink-volume "${$(pactl info | grep Sink)#*:\ }" "+5%";
        fi;
    else;
        exec /usr/bin/pactl set-sink-volume "${$(pactl info | grep Sink)#*:\ }" "+5%";
    fi;
elif [[ "$1" == "down" ]]; then
    exec /usr/bin/pactl set-sink-volume "${$(pactl info | grep Sink)#*:\ }" "-5%"
else
    exec echo
fi
