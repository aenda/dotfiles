set termguicolors
set background=dark
colorscheme NeoSolarized
let mapleader="\\"
set viminfo+=n$HOME/.config/nvim/.viminfo
set backup undofile
set backupdir=$HOME/.local/share/nvim/backup
set undodir=$HOME/.local/share/nvim/undo
set directory=$HOME/.local/share/nvim/swap
"Cursor shape changes on insert
let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1

"Handle tabs - one tab equates to 4 spaces, except in makefiles

set tabstop=8 softtabstop=0 shiftwidth=4 expandtab smarttab

augroup makefile
    autocmd!
    autocmd BufRead,BufNewFile *.mf setl noai noexpandtab
    autocmd filetype make setl noai noexpandtab
augroup end

set list listchars=tab:»\ ,eol:¬,trail:·

"LaTeX
augroup latex
    autocmd!
    let g:tex_flavor = "latex"
"    autocmd FileType tex :nnoremap <leader>ll :lcd %:h<CR>:w<CR>:!latexmk -pdf -pv "%:p"<CR>
"    autocmd FileType tex :nnoremap <leader>lv :!zathura %:r.pdf &<CR><CR>
augroup end
