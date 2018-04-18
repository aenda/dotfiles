#!/usr/bin/env zsh

if [ -z "$ZDOTDIR" ]; then ZDOTDIR="$XDG_CONFIG_HOME/zsh"; export ZDOTDIR; fi
if [[ ! -d $ZDOTDIR/repos/ ]];
then
    mkdir $ZDOTDIR/repos -p
    git clone https://github.com/zsh-users/zsh-autosuggestions $ZDOTDIR/repos/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-completions $ZDOTDIR/repos/zsh-completions
    git clone https://github.com/zsh-users/zsh-history-substring-search $ZDOTDIR/repos/zsh-history-substring-search
    git clone https://github.com/zsh-users/zsh-syntax-highlighting $ZDOTDIR/repos/zsh-syntax-highlighting
    git clone https://github.com/denysdovhan/spaceship-prompt $ZDOTDIR/repos/spaceship-prompt
    if [[ ! -d $ZDOTDIR/fpath/ ]]; then mkdir $ZDOTDIR/fpath; fi
    ln -sf "$ZDOTDIR/repos/spaceship-prompt/spaceship.zsh" "$ZDOTDIR/fpath/prompt_spaceship_setup"
fi

#if [[ -d $plugindir/src/ ]]; then fpath+=($plugindir/src); fi;
#fpath+=($plugindir)
for plugindir in $ZDOTDIR/repos/*/; do
    plugindir=${plugindir%*/}
    echo "Updating $plugindir"
    (cd "${plugindir}" && git checkout master && git remote update -p; git merge --ff-only @{u})
    printf "\n"
done
