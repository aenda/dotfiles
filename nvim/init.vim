set rtp^=$HOME/.dotfiles/nvim
"Install vim-plug if not present, and setup plugins
if empty(glob("$HOME/.dotfiles/nvim/autoload/plug.vim"))
    silent !curl -fLo $HOME/.dotfiles/nvim/autoload/plug.vim --create-dirs
      \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('$HOME/.dotfiles/nvim/plugged')
"Colors
"Plug 'morhetz/gruvbox'
"Plug 'iCyMind/NeoSolarized'
"Plug 'arcticicestudio/nord-vim'
Plug 'joshdick/onedark.vim'
"Statusline
Plug 'itchyny/lightline.vim'

"Microsoft Language Server Protocol
Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': './install.sh'
    \ }

"Autocompletion
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
"Plug 'roxma/nvim-completion-manager'
Plug 'w0rp/ale'
"Plug 'sheerun/vim-polyglot'
Plug 'ervandew/supertab'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'

"Specific functionality
Plug 'zchee/deoplete-jedi'
Plug 'sebastianmarkow/deoplete-rust'
Plug 'poppyschmo/deoplete-latex'
Plug 'davidhalter/jedi-vim'
Plug 'jalvesaq/nvim-r'
Plug 'lervag/vimtex'
"Plug 'gaalcaras/ncm-R'
Plug 'rust-lang/rust.vim'
Plug 'Shougo/neco-syntax'
"
"Miscellaneous
Plug 'tpope/vim-surround'
Plug 'junegunn/fzf'
" Multi-entry selection UI.
Plug 'junegunn/fzf.vim'
Plug 'mhinz/vim-startify'
Plug 'ryanoasis/vim-devicons'
call plug#end()

source $HOME/.config/nvim/general.vim
source $HOME/.config/nvim/plugins.vim
"source $HOME/.config/nvim/statusline.vim
"source $HOME/.config/nvim/color.vim
source $HOME/.config/nvim/netrw.vim
