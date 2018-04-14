" vim:fdm=marker et fdl=2 ft=vim sts=2 sw=2 ts=2
"
"Color Config
set termguicolors
"Set background - in file so its writable
"source $HOME/.config/nvim/background.vim
"let g:nord_italic=1
"let g:nord_comment_brightness=18
"colorscheme nord
colorscheme gruvbox
set background=dark
let g:lightline = { 'colorscheme': 'solarized', }
set noshowmode "lightline shows insert/normal mode
let g:rout_follow_colorscheme = 1 "nvim-r uses colorscheme
let g:Rout_more_colors = 1
"
"Vimtex Config
let g:vimtex_compiler_progname = 'nvr'
let g:vimtex_view_method = 'general'
let g:vimtex_view_general_viewer = 'qpdfview'
let g:vimtex_view_general_options
  \ = '--unique @pdf\#src:@tex:@line:@col'
let g:vimtex_view_general_options_latexmk = '--unique'
"and under okular set editor command: "nvr --remote-silent %f -c %l"
let g:vimtex_compiler_latexmk = {
    \ 'backend' : 'nvim',
    \ 'background' : 1,
    \ 'build_dir' : '',
    \ 'callback' : 1,
    \ 'continuous' : 1,
    \ 'executable' : 'latexmk',
    \ 'options' : [
    \   '-pdflua',
    \   '-verbose',
    \   '-file-line-error',
    \   '-synctex=1',
    \   '-interaction=nonstopmode',
    \ ],
    \}
"add after hook - latexmk -c will clean files?
"let g:vimtex_view_method = 'zathura' #window id/back search broken
"let g:vimtex_view_general_options = '--unique file:@pdf\#src:@line@tex'
"let g:vimtex_view_general_options_latexmk = '--unique'
"
""""""ALE config""""""
"All linters on by default, otherwise enable specific ones
"pyls: lint: mccabe, pycodestyle, pydocstyle, pyflakes, rope | autopep8, yapf
let g:ale_linters = { 'python': ['isort', 'mypy', 'pycodestyle',
\                               'pyflakes', 'pylint', 'pyls', ], }
let g:ale_fixers = {
\   'python': ['autopep8', 'yapf', 'isort'],
\   'rust': ['rustfmt']
\}
"let g:ale_lint_on_text_changed = 'never' "lint as you type options
let g:ale_lint_delay = 500 "delay of no typing to lint
let g:ale_list_window_size = 5 " Show 5 lines of errors (default: 10)
" if you don't want linters to run on opening a file
"let g:ale_lint_on_enter = 0
" use ale_set_loclist or ale_set_quickfix - loclist is default
" let g:ale_open_list = 1 "show quickfix window when file contains warnings
"""""""""""""""""""""""""""""""""""""

" autostart lang serv
let g:LanguageClient_autoStart = 1
" Use location list instead of quickfix
"let g:LanguageClient_diagnosticsList = 'Location'
"let g:LanguageClient_diagnosticsEnable = 0
let g:LanguageClient_serverCommands = {}
let g:LanguageClient_settingsPath = '$HOME/.dotfiles/nvim/'
let g:LanguageClient_loadSettings = 1
"v for some debug logging
if executable('pyls')
    let g:LanguageClient_serverCommands.python = ['pyls', '-v']
endif
if executable('rls')
    let g:LanguageClient_serverCommands.rust = ['rustup', 'run', 'nightly', 'rls']
    let g:ale_linters.rust = ['rls']
else
    let g:LanguageClient_serverCommands.rust = ['rustup', 'run', 'nightly']
    let g:ale_linters.rust = ['cargo']
endif
"    \ 'r': ['R', '--quiet', '--slave', '-e', 'languageserver::run()'],

"""""""""""""""""""""""""""""""""""""

augroup LanguageClientConfig
    autocmd!
    " <leader>ld to go to definition
    autocmd FileType python,json,css,less,html nnoremap <buffer> <leader>ld
      \ :call LanguageClient_textDocument_definition()<cr>
    " <leader>lf to autoformat document
    autocmd FileType python,json,css,less,html nnoremap <buffer> <leader>lf
      \ :call LanguageClient_textDocument_formatting()<cr>
    " <leader>lh for type info under cursor
    autocmd FileType python,json,css,less,html nnoremap <buffer> <leader>lh
      \ :call LanguageClient_textDocument_hover()<cr>
    " <leader>lr to rename variable under cursor
    autocmd FileType python,json,css,less,html nnoremap <buffer> <leader>lr
      \ :call LanguageClient_textDocument_rename()<cr>
    " <leader>lc to switch omnifunc to LanguageClient
    autocmd FileType python,json,css,less,html nnoremap <buffer> <leader>lc
      \ :setlocal omnifunc=LanguageClient#complete<cr>
    " <leader>ls to fuzzy find the symbols in the current document
    autocmd FileType python,json,css,less,html nnoremap <buffer> <leader>ls
      \ :call LanguageClient_textDocument_documentSymbol()<cr>
    " Use LanguageServer for omnifunc completion
    " autocmd FileType python,json,css,less,html,R setlocal omnifunc=LanguageClient#complete
augroup END

"nnoremap <silent> K :call LanguageClient_textDocument_hover()<CR>
nnoremap <silent> gd :call LanguageClient_textDocument_definition()<CR>
"nnoremap <silent> <F2> :call LanguageClient_textDocument_rename()<CR>

" nvim-completion-manager {{{
" Use fuzzy matching
let g:cm_matcher = {'case': 'smartcase', 'module': 'cm_matchers.fuzzy_matcher'}

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
let g:UltiSnipsExpandTrigger="<C-j>"

"Deoplete config
" automatically start
"let g:deoplete#enable_at_startup = 1
" could we gain startup time by lazy loading?
" let g:deoplete#enable_at_startup = 0
" call deoplete#enable()
"set completeopt=longest,menuone,preview
"let g:deoplete#sources = {}
"let g:deoplete#sources._ = ['file', 'ultisnips']

"Deoplete and vimtex config
"if !exists('g:deoplete#omni#input_patterns')
"    let g:deoplete#omni#input_patterns = {}
"endif
"let g:deoplete#omni#input_patterns.tex = '\\(?:'
"      \ .  '\w*cite\w*(?:\s*\[[^]]*\]){0,2}\s*{[^}]*'
"      \ . '|\w*ref(?:\s*\{[^}]*|range\s*\{[^,}]*(?:}{)?)'
"      \ . '|hyperref\s*\[[^]]*'
"      \ . '|includegraphics\*?(?:\s*\[[^]]*\]){0,2}\s*\{[^}]*'
"      \ . '|(?:include(?:only)?|input)\s*\{[^}]*'
"      \ . '|\w*(gls|Gls|GLS)(pl)?\w*(\s*\[[^]]*\]){0,2}\s*\{[^}]*'
"      \ . '|includepdf(\s*\[[^]]*\])?\s*\{[^}]*'
"      \ . '|includestandalone(\s*\[[^]]*\])?\s*\{[^}]*'
"      \ . '|usepackage(\s*\[[^]]*\])?\s*\{[^}]*'
"      \ . '|documentclass(\s*\[[^]]*\])?\s*\{[^}]*'
"      \ .')'

" We use deoplete-jedi for async completion
let g:jedi#completions_enabled = 0

"Get Vim-DevIcons to work with startify
function! StartifyEntryFormat()
    return 'WebDevIconsGetFileTypeSymbol(absolute_path) ." ". entry_path'
endfunction
