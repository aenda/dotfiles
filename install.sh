#!/bin/bash

# Get current dir (so run this script from anywhere)

export DOTFILES_DIR
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Update dotfiles itself first

[ -d "$DOTFILES_DIR/.git" ] && git --work-tree="$DOTFILES_DIR" --git-dir="$DOTFILES_DIR/.git" pull origin master

#Home dir symlinks
ln -sfv "$DOTFILES_DIR/git/gitconfig" ~/.gitconfig
ln -sfv "$DOTFILES_DIR/zsh/zshrc" ~/.zshrc
ln -sfv "$DOTFILES_DIR/zsh/zprofile" ~/.zprofile
ln -sfv "$DOTFILES_DIR/dircolors-uni" ~/.dircolors
#X config
ln -sfv "$DOTFILES_DIR/X/.*" ~
#Make .config directory then make symlinks
[[ -d "$HOME/.config" ]] || mkdir "$HOME/.config"
ln -sfv "$DOTFILES_DIR/i3" "$HOME/.config/i3"
ln -sfv "$DOTFILES_DIR/i3status" "$HOME/.config/i3status"
ln -sfv "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
ln -sfv "$DOTFILES_DIR/termite" "$HOME/.config/termite"
