#!/bin/sh

swaymsg 'workspace number 2:term; exec /bin/kitty; workspace number 1:vim; exec /bin/kitty; workspace number 3:browse; exec env MOZ_USE_XINPUT2=1 firefox -profile /home/gmend/.config/mozilla/firefox/; exec sleep 1 && rm -r /home/gmend/.mozilla; workspace number 4:misc; exec spotify; exec sleep 10 && rm -r /home/gmend/.pki; workspace number 1:vim;'
