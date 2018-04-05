# Aliases
alias l='ls -q | column -c 80'
alias diff='diff --color=auto'
alias grep='grep --color=auto'
#alias la='ls -oAh'
alias la='ls -lah'
alias vim="nvim"
alias nvim="NVIM_LISTEN_ADDRESS=/tmp/nvimsocket nvim"
alias color="~/.dotfiles/changecolorargs.sh"
alias soph="cd /mnt/data/OneDrive\ -\ Washington\ University\ in\ St.\ Louis/Sophomore/"

#Misc options
export KEYTIMEOUT=5
DEFAULT_USER=gmend
#make ls use YYYY-MM-DD
export TIME_STYLE=long-iso
# Uncomment the following line to enable command auto-correction.
#ENABLE_CORRECTION="true"

#Hist options
if [ -z "$HISTFILE" ]; then
    HISTFILE=$HOME/.zsh_history
fi
HISTSIZE=1000 #We have plenty of memory, save our history
SAVEHIST=1000
# No annoying beeping
setopt NO_HIST_BEEP 
setopt INC_APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_DUPS HIST_EXPIRE_DUPS_FIRST

#if [ "$TERM" = "linux" ]; then
#    _SEDCMD='s/.*\*color\([0-9]\{1,\}\).*#\([0-9a-fA-F]\{6\}\).*/\1 \2/p'
#    for i in $(sed -n "$_SEDCMD" $HOME/.Xresources | awk '$1 < 16 {printf "\\e]P%X%s", $1, $2}'); do
#        echo -en "$i"
#    done
#    clear
#fi
