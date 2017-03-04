set rtp^=$HOME/.dotfiles/nvim
"Install vim-plug if not present, and setup plugins
if empty(glob("$HOME/.dotfiles/nvim/autoload/plug.vim"))
	silent !curl -fLo $HOME/.dotfiles/nvim/autoload/plug.vim --create-dirs
	  \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
    endif

call plug#begin('$HOME/.dotfiles/nvim/plugged')
Plug 'iCyMind/NeoSolarized'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
call plug#end()

source $HOME/.config/nvim/general.vim
source $HOME/.config/nvim/plugins.vim
