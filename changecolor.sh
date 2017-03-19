#!/bin/bash
#This script should be run with an argument of "light" or "dark"
export colormode=$1

if [ $colormode = "light" ]
then
    rm ~/.dotfiles/nvim/background.vim
    echo "\"set background=dark" >> ~/.dotfiles/nvim/background.vim
    ln -sfv ~/.dotfiles/termite/config-light ~/.config/termite/config
elif [ $colormode = "dark" ]
then
    echo "set background=dark" >> ~/.dotfiles/nvim/background.vim
    ln -sfv ~/.dotfiles/termite/config-dark ~/.config/termite/config
else
    echo "Call with arg light or dark"
fi
