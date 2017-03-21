#!/bin/bash
#This script should be run with an argument of "light" or "dark"
export colormode=$1

if [ $colormode = "light" ]
then
    rm ~/.dotfiles/nvim/background.vim
    echo "\"set background=dark" >> ~/.dotfiles/nvim/background.vim
    ln -sfv ~/.dotfiles/termite/config-gruvbox-light ~/.config/termite/config
    ln -sfv ~/.dotfiles/nvim/color-light.vim ~/.config/nvim/color.vim
elif [ $colormode = "dark" ]
then
    echo "set background=dark" >> ~/.dotfiles/nvim/background.vim
    ln -sfv ~/.dotfiles/termite/config-gruvbox-dark ~/.config/termite/config
    ln -sfv ~/.dotfiles/nvim/color-dark.vim ~/.config/nvim/color.vim
else
    echo "Call with arg light or dark"
fi
