let mapleader="\\"
set viminfo+=n$HOME/.config/nvim/.viminfo
set backup undofile
set backupdir=$HOME/.local/share/nvim/backup
set undodir=$HOME/.local/share/nvim/undo
set directory=$HOME/.local/share/nvim/swap

"Navigate line breaks with arrow keys
"set whichwrap+=<,>,[,]
"Cursor shape changes on insert
"set fonts
set encoding=utf8
"set guifont=Inconsolata\ Nerd\ Font\ Complete\ Mono\ 11
"set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50
"\,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor
"\,sm:block-blinkwait175-blinkoff150-blinkon175
"
set clipboard+=unnamed "Use middle-click clipboard
"Handle tabs - one tab equates to 4 spaces, except in makefiles
set tabstop=4 softtabstop=0 shiftwidth=4 expandtab smartindent

"denote whitespace with special characters
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
"augroup latex
"    autocmd!
"    let g:tex_flavor = "latex"
""    autocmd FileType tex :nnoremap <leader>ll :lcd %:h<CR>:w<CR>:!latexmk -pdf -pv "%:p"<CR>
""    autocmd FileType tex :nnoremap <leader>lv :!zathura %:r.pdf &<CR><CR>
"augroup end

"PYTHON PROVIDER CONFIGURATION ~
"Program to use for evaluating Python code. Setting this makes startup faster.
"Also useful for working with virtualenvs. >
let g:python_host_prog  = '/usr/bin/python3.6'
"let g:python_host_prog = '/usr/bin/python'
let g:python3_host_prog = '/usr/bin/python3.6'
"To disable Python 2 support
let g:loaded_python_provider = 1
"To disable Ruby support
let g:loaded_ruby_provider = 1
"To disable Node support
let g:loaded_node_provider = 1
