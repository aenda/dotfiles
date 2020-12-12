let mapleader="\\"
let maplocalleader="-"
" alternate keys: <space> comma <cr>
" set dirs for vim data files
set viminfo+=n$HOME/.config/nvim/.viminfo
set backup undofile
set backupdir=$HOME/.local/share/nvim/backup
set undodir=$HOME/.local/share/nvim/undo
set directory=$HOME/.local/share/nvim/swap

" PYTHON PROVIDER CONFIGURATION ~
" Set provider to evaluate python code: makes startup faster, useful for venvs
" let g:python_host_prog  = '/usr/bin/python3.6' " this is for python2
let g:python3_host_prog = '/usr/bin/python3.9'
let g:loaded_python_provider = 1 "To disable Python 2 support
let g:loaded_ruby_provider = 1   "To disable Ruby support
let g:loaded_node_provider = 1   "To disable Node support

"set whichwrap+=<,>,[,] " Navigate line breaks with arrow keys

set clipboard+=unnamedplus "Use middle-click clipboard, use `"+` for system
" Handle tabs - one tab equates to 4 spaces, except in makefiles
set tabstop=4 softtabstop=0 shiftwidth=4 expandtab smartindent
augroup makefile
    autocmd!
    autocmd BufRead,BufNewFile *.mf setl noai noexpandtab
    autocmd filetype make setl noai noexpandtab
augroup end

set noshowmode "lightline shows insert/normal mode
set shortmess+=c " hide match k of n messages

" denote whitespace with special characters
set list listchars=tab:»\ ,eol:¬,trail:·

set splitright " open new splits to the right
set splitbelow

set relativenumber numberwidth=2 " Relative line numbers with thin gutter
" Highlight all columns past 80
let &colorcolumn=join(range(81,999),",")

let g:tex_flavor = "latex"
set conceallevel=2
let g:tex_conceal="abdmgs"

" LaTeX - alternative to vimtex
" augroup latex
"     autocmd!
"     let g:tex_flavor = "latex"
"     autocmd FileType tex :nnoremap <leader>ll :lcd %:h<CR>:w<CR>:!latexmk -pdf -pv "%:p"<CR>
"     autocmd FileType tex :nnoremap <leader>lv :!zathura %:r.pdf &<CR><CR>
" augroup end

" If not indenting, tab opens deoplete menu
inoremap <silent><expr> <TAB>
\ pumvisible() ? "\<C-n>" :
\ <SID>check_back_space() ? "\<TAB>" :
\ deoplete#mappings#manual_complete()
function! s:check_back_space() abort "{{{
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction"}}}

" tab thru everything
" use tab to forward cycle
inoremap <silent><expr> <TAB> (pumvisible() ? "\<C-n>" : "\<TAB>")
" use tab to backward cycle
inoremap <silent><expr><S-TAB> (pumvisible() ? "\<C-p>" : "\<s-tab>")

" enter (CR) hides completion menu and goes to new line
inoremap <expr> <CR>  (pumvisible() ? "\<c-y>\<cr>" : "\<CR>")

" Close the documentation window when completion is done
" autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif
