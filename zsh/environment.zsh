# Aliases
alias l='ls -q | column -c 80'
alias diff='diff --color=auto'
alias grep='grep --color=auto'
#alias la='ls -oAh'
alias la='ls -lah'
alias nv="nvim"
alias vim="nvim"
alias nvimtex="NVIM_LISTEN_ADDRESS=/tmp/texsocket nvim"
alias color="~/.dotfiles/changecolorargs.sh"
alias soph="cd /mnt/data/OneDrive\ -\ Washington\ University\ in\ St.\ Louis/Sophomore/"
alias reboot="systemctl reboot"
alias shutdown="systemctl poweroff"

### Misc options ###
export KEYTIMEOUT=5
DEFAULT_USER=gmend
#make ls use YYYY-MM-DD
export TIME_STYLE=long-iso
# Uncomment the following line to enable command auto-correction.
#ENABLE_CORRECTION="true"
####################

### Hist options ###
if [ -z "$HISTFILE" ]; then
    HISTFILE=$XDG_CONFIG_HOME/zsh/zsh_history
fi
HISTSIZE=10000 #We have plenty of memory, save our history
SAVEHIST=10000
# No annoying beeping
setopt NO_HIST_BEEP 
setopt INC_APPEND_HISTORY EXTENDED_HISTORY SHARE_HISTORY HIST_IGNORE_DUPS HIST_EXPIRE_DUPS_FIRST
####################

# from https://github.com/zimfw/zimfw/blob/master/modules/environment/init.zsh
# https://github.com/zimfw/zimfw/blob/master/modules/directory/init.zsh
# Treat single word simple commands without redirection as candidates for resumption of an existing job.
setopt AUTO_RESUME
# List jobs in the long format by default.
setopt LONG_LIST_JOBS
# Report bg job status immediately, don't wait until just before printing a prompt.
setopt NOTIFY
# Recognize comments starting with `#`.
setopt INTERACTIVE_COMMENTS
# Run all background jobs at a lower priority. This option is set by default.
unsetopt BG_NICE
# Send the HUP signal to running jobs when the shell exits.
unsetopt HUP
# Report bg/suspended job status before exit; second exit will succeed.
# Only use NO_CHECK_JOBS with NO_HUP, or such jobs will be killed automatically.
unsetopt CHECK_JOBS
# Remove path separtor from WORDCHARS.
WORDCHARS=${WORDCHARS//[\/]}

# Set less or more as the default pager.
if (( ! ${+PAGER} )); then
  if (( ${+commands[less]} )); then
    export PAGER=less
  else
    export PAGER=more
  fi
fi

# Make cd push the old directory onto the directory stack.
setopt AUTO_PUSHD
# Don’t push multiple copies of the same directory onto the directory stack.
setopt PUSHD_IGNORE_DUPS
# Do not print the directory stack after pushd or popd.
setopt PUSHD_SILENT
# Have pushd with no arguments act like ‘pushd ${HOME}’.
setopt PUSHD_TO_HOME

### Globbing and fds ###
# Treat the ‘#’, ‘~’ and ‘^’ characters as part of patterns for filename generation, etc.
# (An initial unquoted ‘~’ always produces named directory expansion.)
setopt EXTENDED_GLOB
# Perform implicit tees or cats when multiple redirections are attempted.
setopt MULTIOS
# Disallow ‘>’ redirection to overwrite existing files.
# ‘>|’ or ‘>!’ must be used to overwrite a file.
setopt NO_CLOBBER

# auto color VT
#if [ "$TERM" = "linux" ]; then
#    _SEDCMD='s/.*\*color\([0-9]\{1,\}\).*#\([0-9a-fA-F]\{6\}\).*/\1 \2/p'
#    for i in $(sed -n "$_SEDCMD" $HOME/.Xresources | awk '$1 < 16 {printf "\\e]P%X%s", $1, $2}'); do
#        echo -en "$i"
#    done
#    clear
#fi
