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

zsh - zplug (switch to zim/antibody?)
bindkey | grep "^[" -F fix escape commands learn other zsh shortcuts
zsh autosuggestions 
https://github.com/zsh-users/zsh-autosuggestions/blob/master/src/config.zsh
http://zsh.sourceforge.net/Guide/zshguide04.html

*************************UTILITIES*************************

zathura with setup as described in vimtex
ls dircolors - set by function in zshrc
browser: firefox. pass: keepassxc. 

*************************SYSTEM****************************
documentation of settings in /etc to make setting up new systems easier

ACPI handles volume/headphone events and brightness events
config in /etc/acpi copied directly from arch wiki
spotify play pause handler:
`
#!/bin/sh
#exec sudo -H -u gmend bash -c "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause"
#machinectl shell --uid=gmend .host /bin/bash -c "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause"
`

TLP for laptop power tools
config in /etc/tlp.conf

using keychain with git/ssh to push, and for gpg
(...i don't remember how i set any of that up. will try & figure it out again)
(i think polkit was involved too but i didn't understand that either ._.)

systemd enabled
gpg-agent-browser.socket -> /usr/lib/systemd/user/gpg-agent-browser.socket
gpg-agent-extra.socket, gpg-agent-ssh.socket, gpg-agent.socket, p11-kit-server.socket

disabled systemd capscontrol.service for caps control, use setkeycodes
now using interception tools/caps2esc
systemd: udevmon.service, config in: /etc/udevmon.yaml
https://askubuntu.com/questions/979359/how-do-i-install-caps2esc

alternatives
https://github.com/ItayGarin/ktrl
https://github.com/myfreeweb/evscript
disabled /etc/X11/xorg.conf.d/10-keyboard.conf.disabled
Section "InputClass"
        Identifier "system-keyboard"
        MatchIsKeyboard "on"
        Option "XkbOptions" "ctrl:nocaps"
EndSection
disabled caps-ctrl in zshprofile
export XKB_DEFAULT_OPTIONS=ctrl:nocaps
disabled caps setkeycodes systemd service
[Service]
Type=idle
ExecStart=/usr/bin/setkeycodes 3a 29
[Install]
WantedBy=multi-user.target
https://unix.stackexchange.com/questions/49650/how-to-get-keycodes-for-xmodmap

very loud pop on start/stop audio playback
meh i give up
suggestions
/etc/modprobe.d/audio_powersave.conf
/etc/pulse/default.pa : comment out load-module module-suspend-on-idle
/etc/pulse/default.pa : load-module module-udev-detect tsched=0
/etc/pulse/daemon.pa : exit-idle-time -1
https://bbs.archlinux.org/viewtopic.php?id=224560
tried installing tlp and disabling power save in /etc/tlp.conf

zathura reverse search DONE
https://magmath.com/vim-how-to-use-reverse-and-forward-search-with-vim-and-zathura.html
https://vi.stackexchange.com/questions/4714/how-to-have-forward-search-using-zathura-pdf-viewer-and-latex-box-plugin

Use netctl-auto for automatic known access point connections
set up w/ systemd; also systemd for suspend on power/lid/etc
pulseaudio (with shortcuts in sway) for volume
ssh-agent for gpg keyring w/thunderbird+enigmail and github(/aws??) ssh key

/etc/environment read by PAM to set env variables

/etc/sysctl.d : kernel.sysrq=1 for magic sysrq
vm.dirty_writeback_centisecs = 3000 - something w/ kernel page and power saving

/etc/zsh/zshenv: `export ZDOTDIR=$HOME/.config/zsh`

/etc/R/Renviron: R_LIBS_USER '~/.local/share/R/x86_64-pc-linux-gnu-library/4.0

pulseaudio config
messed with a bunch of stuff in /etc/pulse but audio still pops :/

(disabled)
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

timer info in; https://wiki.archlinux.org/index.php/Systemd/Timers
`OnCalendar=* *-*-* 09:00:00`
`OnCalendar=* *-*-* 21:00:00`

packages
acpi/acpid // tlp
bluez / netctl / dhcpcd
pulseaudio(-bluetooth)
yay, xdg-user-dirs, xdg-utils
btrfs / ntfs-3g / unionfs-fuse / base-devel / ntp / parted
bemenu/sway/i3blocks/i3status/grimshot/swaybg/swayidle/swaylock/wl-clipboard/wl-sunset
zsh/exa/fd/fzf/ranger/ripgrep/ag(silversearcher)
imagemagick/imv/vlc
zathura/qpdfview
firefox/hunspell/ffmpeg
keepassxc
termite/kitty
vim/neovim
noto-fonts(-emoji)/otf-fira-mono/otf-latinmodern-math
interception-caps2esc
keychain/gnupg/git/openssh/etc
r/pandoc-bin
python, jedi, language-server, numpy, pandas, pillow, pip, pycodestyle, pyflakes, pynvim, yapf
texinfo/texlive

(etckeeper, idk i never use it)
