source $HOME/.config/nvim/general.vim

"Install vim-plug if not present, and setup plugins
if empty(glob("$HOME/.config/nvim/autoload/plug.vim"))
    silent !curl -fLo $HOME/.config/nvim/autoload/plug.vim --create-dirs
      \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('$HOME/.local/share/nvim/plugged')
"Colors
Plug 'joshdick/onedark.vim'
Plug 'icymind/NeoSolarized'
"Statusline
Plug 'itchyny/lightline.vim'

"Microsoft Language Server Protocol
Plug 'autozimu/LanguageClient-neovim', {'branch': 'next', 'do': 'bash install.sh',}

"Autocompletion
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
"Plug 'ervandew/supertab' " mappings good enough

"Specific functionality
Plug 'jalvesaq/nvim-r'
Plug 'lervag/vimtex'
Plug 'rust-lang/rust.vim'
Plug 'Shougo/neco-syntax'
"
"Miscellaneous
Plug 'tpope/vim-surround'
Plug 'junegunn/fzf' " Multi-entry selection UI for LCN
Plug 'junegunn/fzf.vim'

" Pretty start screen
Plug 'mhinz/vim-startify'
Plug 'ryanoasis/vim-devicons'
call plug#end()

source $HOME/.config/nvim/plugins.vim
source $HOME/.config/nvim/color.vim
source $HOME/.config/nvim/netrw.vim

"source $HOME/.config/nvim/statusline.vim
