#!/bin/sh
#This script should be run with an argument of "light" or "dark"
export colormode=$1
if [[ $colormode = "light" ]]; then
    echo "\"set background=dark" > /home/gmend/.dotfiles/nvim/background.vim
    ln -sfv /home/gmend/.dotfiles/termite/config-gruvbox-light /home/gmend/.config/termite/config
    ln -sfv /home/gmend/.dotfiles/nvim/color-light.vim /home/gmend/.config/nvim/color.vim
elif [[ $colormode = "dark" ]]; then
    echo "set background=dark" > /home/gmend/.dotfiles/nvim/background.vim
    ln -sfv /home/gmend/.dotfiles/termite/config-gruvbox-dark /home/gmend/.config/termite/config
    ln -sfv /home/gmend/.dotfiles/nvim/color-dark.vim /home/gmend/.config/nvim/color.vim
else
    echo "Call with arg light or dark"
fi
