#!/bin/sh
currTime=`date +%k%M`
check_time_to_color()
{
    #export colorMode=$1
    echo "Time is:" $currTime
    if [[ $currTime -gt 900 ]] && [[ $currTime -lt 2100 ]]; then 
        echo "day: between 9 AM and 9 PM"
        echo "\"set background=dark" > /home/gmend/.dotfiles/nvim/background.vim
        ln -sfv /home/gmend/.dotfiles/termite/config-gruvbox-light /home/gmend/.config/termite/config
        ln -sfv /home/gmend/.dotfiles/nvim/color-light.vim /home/gmend/.config/nvim/color.vim
    else
        echo "night: after 9 PM and before 9 AM"
        echo "set background=dark" > /home/gmend/.dotfiles/nvim/background.vim
        ln -sfv /home/gmend/.dotfiles/termite/config-gruvbox-dark /home/gmend/.config/termite/config
        ln -sfv /home/gmend/.dotfiles/nvim/color-dark.vim /home/gmend/.config/nvim/color.vim
    fi
}

check_time_to_color $currentTime
