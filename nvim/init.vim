set rtp^=$HOME/.dotfiles/nvim
"Install vim-plug if not present, and setup plugins
if empty(glob("$HOME/.dotfiles/nvim/autoload/plug.vim"))
    silent !curl -fLo $HOME/.dotfiles/nvim/autoload/plug.vim --create-dirs
      \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('$HOME/.dotfiles/nvim/plugged')
"Plug 'iCyMind/NeoSolarized'
"Plug 'vim-airline/vim-airline'
"Plug 'vim-airline/vim-airline-themes'
"Colors
Plug 'morhetz/gruvbox'
"Autocompletion
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'ervandew/supertab'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
"Miscellaneous
Plug 'tpope/vim-surround'
Plug 'mhinz/vim-startify'
"Plug 'ctrlpvim/ctrlp.vim'
"Plug 'scrooloose/nerdtree'
Plug 'ryanoasis/vim-devicons'

"Plug 'zchee/deoplete-jedi'
"Plug 'poppyschmo/deoplete-latex'
"SPecific functionality
Plug 'jalvesaq/nvim-r'
Plug 'lervag/vimtex'
call plug#end()

source $HOME/.config/nvim/general.vim
source $HOME/.config/nvim/plugins.vim
source $HOME/.config/nvim/statusline.vim
source $HOME/.config/nvim/color.vim
