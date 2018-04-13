" vim:fdm=marker et fdl=2 ft=vim sts=2 sw=2 ts=2
"
"Color Config
set termguicolors
"Set background - in file so its writable
"source $HOME/.config/nvim/background.vim
let g:nord_italic=1
let g:nord_comment_brightness=18
"colorscheme nord
colorscheme gruvbox
set background=dark
let g:lightline = { 'colorscheme': 'solarized', }
set noshowmode
let g:rout_follow_colorscheme = 1
let g:Rout_more_colors = 1
"
"Vimtex Config
"let g:vimtex_latexmk_progname = 'nvr'
let g:vimtex_compiler_progname = 'nvr'
"let g:vimtex_view_method = 'zathura' #window id/back search broken
let g:vimtex_view_method = 'general'
let g:vimtex_view_general_viewer = 'qpdfview'
let g:vimtex_view_general_options
  \ = '--unique @pdf\#src:@tex:@line:@col'
let g:vimtex_view_general_options_latexmk = '--unique'
"let g:vimtex_view_general_options = '--unique file:@pdf\#src:@line@tex'
"let g:vimtex_view_general_options_latexmk = '--unique'
"let g:vimtex_fold_enabled = 0
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

let g:SuperTabDefaultCompletionType = "<C-x><C-o>"
let g:UltiSnipsExpandTrigger="<C-j>"

" autostart lang serv
let g:LanguageClient_autoStart = 1
" Use location list instead of quickfix
"let g:LanguageClient_diagnosticsList = 'Location'
"let g:LanguageClient_diagnosticsEnable = 0
let g:LanguageClient_serverCommands = {}
"v for some debug logging
if executable('pyls')
    let g:LanguageClient_serverCommands.python = ['pyls', '-v']
endif
"    \ 'r': ['R', '--quiet', '--slave', '-e', 'languageserver::run()'],
"    \ 'rust': ['rustup', 'run', 'nightly', 'rls'],

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
    autocmd FileType python,json,css,less,html,R setlocal omnifunc=LanguageClient#complete
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

"ALE config
"All linters on by default, otherwise enable specific ones
let g:ale_linters = {'python': ['autopep8', 'mccabe', 'mypy', 'pycodestyle',
\                               'pydocstyle', 'pyflakes', 'pylint', 'pyls'], }
"\   'R': ['lintr'],
let g:ale_fixers = {
\   'python': ['yapf'],
\}
" enable running the linters when files are saved, on by default
"let g:ale_lint_on_save = 1
" lint as you type - on by default
"let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_delay = 500
" if you don't want linters to run on opening a file
"let g:ale_lint_on_enter = 0
" use quickfix instead of loclist
"let g:ale_set_loclist = 0
"let g:ale_set_quickfix = 1
" show window for quickfix items when file contains warnings/errors
" let g:ale_open_list = 1
" Show 5 lines of errors (default: 10)
let g:ale_list_window_size = 5

" We use deoplete-jedi for async completion
let g:jedi#completions_enabled = 0

"Get Vim-DevIcons to work with startify
function! StartifyEntryFormat()
    return 'WebDevIconsGetFileTypeSymbol(absolute_path) ." ". entry_path'
endfunction
