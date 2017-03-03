set rtp^=$HOME/.dotfiles/vim
"Install vim-plug if not present, and setup plugins
if empty(glob("$HOME/.dotfiles/vim/autoload/plug.vim"))
	silent !curl -fLo $HOME/.dotfiles/vim/autoload/plug.vim --create-dirs
	  \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
    endif

call plug#begin('$HOME/.dotfiles/nvim/plugged')
Plug 'iCyMind/NeoSolarized'
Plug 'vim-airline'
Plug 'vim-airline-themes'
call plug#end()

source $HOME/.config/nvim/general.vim
source $HOME/.config/nvim/plugins.vim
