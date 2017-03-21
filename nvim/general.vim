let mapleader="\\"
set viminfo+=n$HOME/.config/nvim/.viminfo
set backup undofile
set backupdir=$HOME/.local/share/nvim/backup
set undodir=$HOME/.local/share/nvim/undo
set directory=$HOME/.local/share/nvim/swap

"Cursor shape changes on insert
let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1
let $NVIM_TUI_ENABLE_TRUE_COLOR=1
set clipboard+=unnamed,unnamedplus "Use system clipboard for yank/put/delete
"Handle tabs - one tab equates to 4 spaces, except in makefiles
set tabstop=4 softtabstop=0 shiftwidth=4 expandtab smartindent

set list listchars=tab:»\ ,eol:¬,trail:·

"Line numbers with thin gutter
set number numberwidth=2
"Highlight all columns past 80
let &colorcolumn=join(range(81,999),",")
augroup makefile
    autocmd!
    autocmd BufRead,BufNewFile *.mf setl noai noexpandtab
    autocmd filetype make setl noai noexpandtab
augroup end

"LaTeX
augroup latex
    autocmd!
    let g:tex_flavor = "latex"
"    autocmd FileType tex :nnoremap <leader>ll :lcd %:h<CR>:w<CR>:!latexmk -pdf -pv "%:p"<CR>
"    autocmd FileType tex :nnoremap <leader>lv :!zathura %:r.pdf &<CR><CR>
augroup end
