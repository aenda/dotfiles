#!/bin/sh

swaymsg 'workspace number 2:term; exec /bin/kitty; workspace number 1:vim; exec /bin/kitty; workspace number 3:browse; exec env MOZ_USE_XINPUT2=1 firefox -profile /home/gmend/.config/mozilla/firefox/ && sleep 1 && rm -r /home/gmend/.mozilla; workspace number 4:misc; exec /bin/spotify; workspace number 1:vim;'
