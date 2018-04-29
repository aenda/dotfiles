#!/bin/bash

# Get current dir (this should be run from the .dotfiles
# DOTFILES_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# We want XDG_CONFIG_HOME and ZDOTDIR set for this
# fallbacks if not

# set root of git repository
export DOTFILES_DIR
DOTFILES_DIR="$(git rev-parse --show-toplevel)"

# Update dotfiles itself first

[ -d "$DOTFILES_DIR/.git" ] && git --work-tree="$DOTFILES_DIR" --git-dir="$DOTFILES_DIR/.git" pull origin master

#Home dir symlinks
ln -sfv "$DOTFILES_DIR/git/gitconfig" $XDG_CONFIG_HOME/git/config
[ -d "$HOME/.ssh/config" ] && ln -sfv "$DOTFILES_DIR/ssh/config" $HOME/.ssh/config || (mkdir $HOME/.ssh && ln -sfv "$DOTFILES_DIR/ssh/config" $HOME/.ssh/config)
#ln -sfv "$DOTFILES_DIR/dircolors-uni" $HOME/.dircolors
#ln -sfv "$DOTFILES_DIR/tmux/tmux.conf" ~/.tmux.conf

#X config
#ln -sfv "$DOTFILES_DIR/X/.*" $HOME/

#Make .config directory then make symlinks
# do xdg-config-home checks instead?
[[ -d "$HOME/.config" ]] || mkdir "$HOME/.config"
ln -sfv "$DOTFILES_DIR/zsh/zshrc" $ZDOTDIR/.zshrc
ln -sfv "$DOTFILES_DIR/zsh/zprofile" $ZDOTDIR/.zprofile
exec $DOTFILES_DIR/scripts/zshplugins.zsh
# do i need to link zsh sources? FIXME
ln -sfv "$DOTFILES_DIR/i3" "$HOME/.config/i3"
ln -sfv "$DOTFILES_DIR/i3status" "$HOME/.config/i3status"
ln -sfv "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
ln -sfv "$DOTFILES_DIR/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
