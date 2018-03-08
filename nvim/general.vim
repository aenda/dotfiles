let mapleader="\\"
set viminfo+=n$HOME/.config/nvim/.viminfo
set backup undofile
set backupdir=$HOME/.local/share/nvim/backup
set undodir=$HOME/.local/share/nvim/undo
set directory=$HOME/.local/share/nvim/swap

"Navigate line breaks with arrow keys
"set whichwrap+=<,>,[,]
"Cursor shape changes on insert

"set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50
"\,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor
"\,sm:block-blinkwait175-blinkoff150-blinkon175
set clipboard+=unnamed "Use middle-click clipboard
"Handle tabs - one tab equates to 4 spaces, except in makefiles
set tabstop=4 softtabstop=0 shiftwidth=4 expandtab smartindent

set list listchars=tab:»\ ,eol:¬,trail:·

"Line numbers with thin gutter
set relativenumber numberwidth=2
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

"KiTTY does not support background color erase
let &t_ut=''
