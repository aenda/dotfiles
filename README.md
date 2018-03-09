Dotfiles directory for arch linux, containing configuration files for zsh, neovim, termite, X, git, and i3/i3status, as well as a custom dircolors file
Requires symbolic links in .config; installer script should handle this automatically


*************************DOTFILES**************************

dotfiles in home
install.sh makes symlinks for init files, which then load from ~/.dotfiles
or symlinks directories?
dotfiles for kitty/termite, i3/i3status/sway, neovim/vim, zsh
also for git/tmux/X

*************************NEOVIM****************************

fzf in vim
use ale/lintr?
nvim-qt or other gui - cursor on insert

*************************ZSH*******************************

zsh - zplug (switch to zim??)
bindkey | grep "^[" -F fix escape commands learn other zsh shortcuts
zsh autosuggestions 
https://github.com/zsh-users/zsh-autosuggestions/blob/master/src/config.zsh
http://zsh.sourceforge.net/Guide/zshguide04.html

*************************UTILITIES*************************

okular with setup as described in vimtex
ls dircolors - set by function in zshrc
browser: firefox. pass: keepassxc. 

*************************SYSTEM****************************

colorscheme set in terminal config and by vim plugin/option
/etc/systemd/system/colorswitch.service relying on colorswitch.sh in dotfiles
argument for solarized light/dark, or time based

colorswitch.service
[Service]
Type=idle
ExecStart=/home/gmend/.dotfiles/changecolor.sh
RemainAfterExit=yes
#EnvironmentFile=/etc/colorargs

[Install]
WantedBy=multi-user.target
timer info in; https://wiki.archlinux.org/index.php/Systemd/Timers<Paste>
OnCalendar=* *-*-* 09:00:00
OnCalendar=* *-*-* 21:00:00
/etc/rc.local for backlight hack and caps lock/control

Use netctl-auto for automatic known access point connections
systemd for suspend on power/lid/etc
pulseaudio (with shortcuts in sway) for volume

*************************SERVER****************************

add amavisd/clamav to mail server? set up dane?

***********************************************************
