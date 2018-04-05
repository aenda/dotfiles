# http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html
# http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html#Zle-Builtins
# http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html#Standard-Widgets
#
# source from https://github.com/zimfw/zimfw/blob/master/modules/input/init.zsh
# and https://github.com/robbyrussell/oh-my-zsh/blob/master/lib/key-bindings.zsh

# Make sure that the terminal is in application mode when zle is active, since
# only then values from $terminfo are valid
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
  function zle-line-init() {
    echoti smkx
  }
  function zle-line-finish() {
    echoti rmkx
  }
  zle -N zle-line-init
  zle -N zle-line-finish
fi

# Use human-friendly identifiers.
zmodload zsh/terminfo
typeset -gA key_info
key_info=(
    'Control'      '\C-'
    'ControlLeft'  '\e[1;5D' # \e[5D \e\e[D \eOd \eOD'
    'ControlRight' '\e[1;5C' # \e[5C \e\e[C \eOc \eOC'
    'Escape'       '\e'
    'Meta'         '\M-'
    'Backspace'    "^?"
    'Delete'       "^[[3~"
    'F1'           "${terminfo[kf1]}"
    'F2'           "${terminfo[kf2]}"
    'F3'           "${terminfo[kf3]}"
    'F4'           "${terminfo[kf4]}"
    'F5'           "${terminfo[kf5]}"
    'F6'           "${terminfo[kf6]}"
    'F7'           "${terminfo[kf7]}"
    'F8'           "${terminfo[kf8]}"
    'F9'           "${terminfo[kf9]}"
    'F10'          "${terminfo[kf10]}"
    'F11'          "${terminfo[kf11]}"
    'F12'          "${terminfo[kf12]}"
    'Insert'       "${terminfo[kich1]}"
    'Home'         "${terminfo[khome]}"
    'PageUp'       "${terminfo[kpp]}"
    'End'          "${terminfo[kend]}"
    'PageDown'     "${terminfo[knp]}"
    'Up'           "${terminfo[kcuu1]}"
    'Left'         "${terminfo[kcub1]}"
    'Down'         "${terminfo[kcud1]}"
    'Right'        "${terminfo[kcuf1]}"
    'BackTab'      "${terminfo[kcbt]}"
)

#bindkey '\ew' kill-region     # [Esc-w] - Kill from the cursor to the mark
#bindkey '^@' set-mark-command #ctrl-space

# start typing + [Up-Arrow] - fuzzy find history forward
if [[ "${terminfo[kcuu1]}" != "" ]]; then
  autoload -U up-line-or-beginning-search
  zle -N up-line-or-beginning-search
  bindkey "${terminfo[kcuu1]}" up-line-or-beginning-search
fi
# start typing + [Down-Arrow] - fuzzy find history backward
if [[ "${terminfo[kcud1]}" != "" ]]; then
  autoload -U down-line-or-beginning-search
  zle -N down-line-or-beginning-search
  bindkey "${terminfo[kcud1]}" down-line-or-beginning-search
fi

# [Home] - to beginning of line
if [[ -n "${key_info[Home]}" ]]; then
  bindkey "${key_info[Home]}" beginning-of-line
fi
# [End]-to end of line
if [[ -n "${key_info[End]}" ]]; then
  bindkey "${key_info[End]}"  end-of-line
fi
#if [[ "${terminfo[kend]}" != "" ]]; then
#  bindkey "${terminfo[kend]}"  end-of-line       # [End]-to end of line
#fi
bindkey "${key_info[Left]}" backward-char
bindkey "${key_info[Right]}" forward-char

local key
for key in "${(s: :)key_info[ControlLeft]}"; do
  bindkey ${key} backward-word
done
for key in "${(s: :)key_info[ControlRight]}"; do
  bindkey ${key} forward-word
done
#bindkey '^[[1;5C' forward-word    #[Ctrl-RightArrow] - move forward one word
#bindkey '^[[1;5D' backward-word   #[Ctrl-LeftArrow] - move backward one word

#[Shift-Tab] - move through the completion menu backwards
if [[ "${terminfo[kcbt]}" != "" ]]; then
  bindkey "${terminfo[kcbt]}" reverse-menu-complete 
fi

bindkey '^?' backward-delete-char             # [Backspace] - delete backward
if [[ "${terminfo[kdch1]}" != "" ]]; then
  bindkey "${terminfo[kdch1]}" delete-char    # [Delete] - delete forward
else
  bindkey "^[[3~" delete-char
  bindkey "^[3;5~" delete-char
  bindkey "\e[3~" delete-char
fi
# file rename magick
bindkey "^[m" copy-prev-shell-word


if [[ -n "${key_info[PageUp]}" ]]; then
  bindkey "${key_info[PageUp]}" up-line-or-history
fi

if [[ -n "${key_info[PageDown]}" ]]; then
  bindkey "${key_info[PageDown]}" down-line-or-history
fi

if [[ -n "${key_info[Insert]}" ]]; then
  bindkey "${key_info[Insert]}" overwrite-mode
fi
