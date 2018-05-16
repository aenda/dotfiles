#!/bin/sh
# get largest packages from pacman (at least 1 MiB)
pacman -Qi | gawk '/^Name/ { x = $3 }; /^Installed Size/ { sub(/Installed Size  *:/, ""); print x":" $0 }' | sort -k2,3nr | grep MiB
