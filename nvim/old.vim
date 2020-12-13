"old plugins
"Colors
"Plug 'morhetz/gruvbox'
"Plug 'arcticicestudio/nord-vim'
"Plug 'roxma/nvim-completion-manager'
"Plug 'w0rp/ale'
"Plug 'sheerun/vim-polyglot'
"Plug 'ervandew/supertab'

"Specific functionality
"Plug 'sebastianmarkow/deoplete-rust'
"Plug 'zchee/deoplete-jedi'
"Plug 'poppyschmo/deoplete-latex'
"Plug 'davidhalter/jedi-vim'
Plug 'gaalcaras/ncm-R'
Plug 'rust-lang/rust.vim'
Plug 'Shougo/neco-syntax'
"
"Miscellaneous
Plug 'tpope/vim-surround'

""""""ALE config"""""""{{{
"let g:ale_enabled = 0
"autocmd FileType r let g:ale_enabled = 1
"All linters on by default, otherwise enable specific ones
"pyls: lint: mccabe, pycodestyle, pydocstyle, pyflakes, rope | autopep8, yapf
let g:ale_linters = { 'python': ['pycodestyle',
                               \ 'pyflakes', 'pylint', 'pyls'] }
function! ALEEnableMypy() abort 
"    "let b:previous_ale_fixers = {}
"    "let b:previous_ale_fixers.python = g:ale_linters['python']
    try
        let b:ale_linters = g:ale_linters
        let b:ale_linters['python'] += ['mypy']
"        "let b:ale_fixers.python: b:previous_ale['python'] + ['isort']
"    "    ALEFix
"    "finally
"    "    unlet b:ale_linters
    endtry
endfunction
let g:ale_fixers = {
\   'python': ['autopep8', 'yapf', 'isort'],
\   'rust': ['rustfmt']
\}
""let g:ale_lint_on_text_changed = 'never' "lint as you type options
let g:ale_lint_delay = 500 "delay of no typing to lint
let g:ale_list_window_size = 5 " Show 5 lines of errors (default: 10)
" if you don't want linters to run on opening a file
"let g:ale_lint_on_enter = 0
" use ale_set_loclist or ale_set_quickfix - loclist is default
" let g:ale_open_list = 1 "show quickfix window when file contains warnings
""""""""""""""""""""""""""""""""""""""}}}

""" deoplete-racer config
"let g:deoplete#sources#rust#racer_binary='/usr/local/bin/racer'
"let g:deoplete#sources#rust#rust_source_path='$HOME/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/lib/rustlib/src/rust/src'

" We use deoplete-jedi for async completion - also jedi superseded by LCN
" let g:jedi#completions_enabled = 0

"let g:SuperTabDefaultCompletionType = "<C-x><C-o>"

" nvim-completion-manager {{{
" Use fuzzy matching
let g:cm_matcher = {'case': 'smartcase', 'module': 'cm_matchers.fuzzy_matcher'}
" disable keyword matching
let g:cm_sources_override = { 'cm-bufkeyword': { 'enable' : 0 } }
" this way happens before ncm is loaded and doesn't work
"autocmd BufRead * call cm#disable_source('cm-bufkeyword')

augroup my_cm_setup
  autocmd!
  autocmd User CmSetup call cm#register_source({
        \ 'name' : 'vimtex',
        \ 'priority': 8,
        \ 'scoping': 1,
        \ 'scopes': ['tex'],
        \ 'abbreviation': 'tex',
        \ 'cm_refresh_patterns': g:vimtex#re#ncm,
        \ 'cm_refresh': {'omnifunc': 'vimtex#complete#omnifunc'},
        \ })
augroup END

" enter (CR) hides menu and goes to new line
inoremap <expr> <CR> (pumvisible() ? "\<c-y>\<cr>" : "\<CR>")

let g:SuperTabDefaultCompletionType = "<C-x><C-o>"
