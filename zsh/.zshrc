# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
  export ZSH=~/.oh-my-zsh

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"
# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
 DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to disable auto-setting terminal title.
DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# ssh
export SSH_KEY_PATH="~/.ssh/rsa_id"
added_keys=`ssh-add -l`

if [ ! $(echo $added_keys | grep -o -e id_rsa) ]; then
    ssh-add "$HOME/.ssh/id_rsa"
fi
#eval `keychain --eval id_rsa`

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
alias vim="vim --servername vim"
# Load powerlevel9k
#DISABLE_AUTO_TITLE="true"
POWERLEVEL9K_BATTERY_CHARGING='yellow'
POWERLEVEL9K_BATTERY_CHARGED='green'
POWERLEVEL9K_BATTERY_DISCONNECTED='$DEFAULT_COLOR'
POWERLEVEL9K_BATTERY_LOW_THRESHOLD='10'
POWERLEVEL9K_BATTERY_LOW_COLOR='red'
POWERLEVEL9K_BATTERY_ICON='\uf1e6 '
POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=''
POWERLEVEL9K_MULTILINE_SECOND_PROMPT_PREFIX='\uf0da'
#POWERLEVEL9K_VCS_GIT_ICON='\ue60a'
POWERLEVEL9K_VCS_MODIFIED_BACKGROUND='yellow'
POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND='yellow'
#POWERLEVEL9K_VCS_UNTRACKED_ICON='?'
#removed os_icon
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(status battery context dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(time background_jobs ram virtualenv rbenv rvm)
POWERLEVEL9K_SHORTEN_STRATEGY="truncate_middle"
POWERLEVEL9K_SHORTEN_DIR_LENGTH=4
##POWERLEVEL9K_CUSTOM_TIME_FORMAT="%D{\uf017 %H:%M:%S}"
POWERLEVEL9K_TIME_FORMAT="%D{\uf017 %H:%M \uf073 %d.%m.%y}"
POWERLEVEL9K_TIME_BACKGROUND='147'
POWERLEVEL9K_RAM_BACKGROUND='068'
POWERLEVEL9K_STATUS_VERBOSE=false
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_MODE='awesome-fontconfig'
POWERLEVEL9K_COLOR_SCHEME='light'

# Load antigen and plugins
ADOTDIR="$HOME/.config/antigen"
source /usr/share/zsh/scripts/antigen/antigen.zsh
antigen use oh-my-zsh
antigen bundle command-not-found
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-autosuggestions
antigen theme bhilburn/powerlevel9k powerlevel9k
antigen apply

if [[ -f ~/.dircolors ]] ;
    then eval "$(dircolors -b ~/.dircolors)"
elif [[ -f /etc/DIR_COLORS ]] ;
    then eval $(dircolors -b /etc/DIR_COLORS)
fi

auto-ls () { ls; }
chpwd_functions=( auto-ls $chpwd_functions )
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg-12'
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
DEFAULT_USER=gmend

zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
#autoload -Uz compinit
#compinit
