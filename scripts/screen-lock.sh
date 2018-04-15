#!/usr/bin/env bash

# handle being called from systemd service
if [ -z "$XDG_RUNTIME_DIR" ] && [ -z "$SWAYSOCK"]; then
    uid=$(id -u $USER)
    export XDG_RUNTIME_DIR="/run/user/"$uid"/"
    export SWAYSOCK=$(find $XDG_RUNTIME_DIR -iname sway*sock)
fi

swaygrab /home/$USER/.dotfiles/sway/lockblur.png
convert -blur 0x6 /home/$USER/.dotfiles/sway/lockblur.png /home/$USER/.dotfiles/sway/lockblur.png

swaylock -i /home/$USER/.dotfiles/sway/lockblur.png
