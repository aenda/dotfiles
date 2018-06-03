#!/bin/env zsh
bluetoothctl connect "$(bluetoothctl paired-devices | grep "$1" | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}')"
