" vim:fdm=marker et fdl=2 ft=vim sts=2 sw=2 ts=2

"Vimtex Config"{{{
let g:vimtex_compiler_progname = 'nvr'
let g:vimtex_view_method = 'general'
let g:vimtex_view_general_viewer = 'qpdfview'
let g:vimtex_view_general_options
  \ = '--unique @pdf\#src:@tex:@line:@col'
let g:vimtex_view_general_options_latexmk = '--unique'
" for qpdfview: sourceEditor = "nvr --remote +\":%2\" \"%1\" --servername=/tmp/texsocket"
" for okular: set editor command: "nvr --remote-silent %f -c %l"
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
"let g:vimtex_view_method = 'zathura' "window id/back search broken
"let g:vimtex_view_general_options = '--unique file:@pdf\#src:@line@tex'
"let g:vimtex_view_general_options_latexmk = '--unique'}}}

""""""ALE config"""""""{{{
let g:ale_enabled = 0
"autocmd FileType r let g:ale_enabled = 1
"All linters on by default, otherwise enable specific ones
"pyls: lint: mccabe, pycodestyle, pydocstyle, pyflakes, rope | autopep8, yapf
let g:ale_linters = { 'python': ['pycodestyle',
                               \ 'pyflakes', 'pylint', 'pyls'] }
function! ALEEnableMypy() abort 
    "let b:previous_ale_fixers = {}
    "let b:previous_ale_fixers.python = g:ale_linters['python']
    try
        let b:ale_linters = g:ale_linters
        let b:ale_linters['python'] += ['mypy']
        "let b:ale_fixers.python: b:previous_ale['python'] + ['isort']
    "    ALEFix
    "finally
    "    unlet b:ale_linters
    endtry
endfunction
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
""""""""""""""""""""""""""""""""""""""}}}

"""""""LCN Config""""""""""""{{{
" autostart lang serv
let g:LanguageClient_autoStart = 1
" Use location list instead of quickfix
"let g:LanguageClient_diagnosticsList = 'Location'
"let g:LanguageClient_diagnosticsEnable = 0
let g:LanguageClient_serverCommands = {}
" let g:LanguageClient_settingsPath = '$HOME/.dotfiles/nvim/'
" let g:LanguageClient_loadSettings = 1
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
let g:LanguageClient_serverCommands.r = ['R', '--quiet', '--slave', '-e', 'languageserver::run()']
" or run(debug = TRUE)

"""""""""""""""""""""""""""""""""""""

augroup LanguageClientConfig
    autocmd!
    " <leader>ld to go to definition
    autocmd FileType python,json,css,less,html nnoremap <buffer> <leader>ld
      \ :call LanguageClient#textDocument_definition()<cr>
    " <leader>lf to autoformat document
    autocmd FileType python,json,css,less,html nnoremap <buffer> <leader>lf
      \ :call LanguageClient#textDocument_formatting()<cr>
    " <leader>lh for type info under cursor
    autocmd FileType python,json,css,less,html nnoremap <buffer> <leader>lh
      \ :call LanguageClient#textDocument_hover()<cr>
    " <leader>lr to rename variable under cursor
    autocmd FileType python,json,css,less,html nnoremap <buffer> <leader>lr
      \ :call LanguageClient#textDocument_rename()<cr>
    " <leader>lc to switch omnifunc to LanguageClient
    autocmd FileType python,json,css,less,html nnoremap <buffer> <leader>lc
      \ :setlocal omnifunc=LanguageClient#complete<cr>
    " <leader>ls to fuzzy find the symbols in the current document
    autocmd FileType python,json,css,less,html nnoremap <buffer> <leader>ls
      \ :call LanguageClient#textDocument_documentSymbol()<cr>
    " Use LanguageServer for omnifunc completion
    " autocmd FileType python,json,css,less,html,R setlocal omnifunc=LanguageClient#complete
augroup END

"nnoremap <silent> K :call LanguageClient_textDocument_hover()<CR>
nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>
"nnoremap <silent> <F2> :call LanguageClient_textDocument_rename()<CR>}}}
"""""""""""""""""""""""""""""""""""""""""""

"let g:SuperTabDefaultCompletionType = "<C-x><C-o>"
let g:UltiSnipsExpandTrigger="<C-j>"

""" Deoplete config
" automatically start{{{
let g:deoplete#enable_at_startup = 1
let g:deoplete#enable_smart_case = 1
" could we gain startup time by lazy loading?
" let g:deoplete#enable_at_startup = 0
" call deoplete#enable()
"set completeopt=longest,menuone,preview
" we stopped using jedi as a python source.
call deoplete#custom#option('sources', {
    \ '_': ['file', 'buffer'],
    \ 'python': ['LanguageClient', 'ultisnips'],
    \ 'python3': ['LanguageClient', 'ultisnips'],
    \ 'rust': ['LanguageClient', 'ultisnips'],
    \ 'tex': ['ultisnips', 'omni'],
\})
"\ 'r': ['LanguageClient', 'omni', 'ultisnips']

" this would disable deoplete in R files
autocmd FileType r call deoplete#custom#buffer_option('auto_complete', v:false)
" this augroup maps tab to nvim-r supplied omnicomplete
augroup r
  autocmd!
  set completefunc=LanguageClient#complete
  set formatexpr=LanguageClient#textDocument_rangeFormatting()
  autocmd FileType r
        \ inoremap <silent><expr> <TAB>
        \ pumvisible() ? "\<C-n>" :
        \ <SID>check_back_space() ? "\<TAB>" :
        \ "\<C-x>\<C-o>"
  function! s:check_back_space() abort "{{{
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~ '\s'
  endfunction"}}}
augroup END

""" Disable the candidates in Comment/String syntaxes.
call deoplete#custom#source('_',
            \ 'disabled_syntaxes', ['Comment', 'String'])

""" deoplete-racer config
"let g:deoplete#sources#rust#racer_binary='/usr/local/bin/racer'
"let g:deoplete#sources#rust#rust_source_path='$HOME/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/lib/rustlib/src/rust/src'

" put snippets at the top of completion menu
"call deoplete#custom#source('ultisnips', 'rank', 1000)

""" Deoplete and vimtex config
call deoplete#custom#var('omni', 'input_patterns', {
    \ 'tex' : g:vimtex#re#deoplete,
\})
" deoplete calls omnicomplete directly after ., ::, $, and ( for r
" call deoplete#custom#option('omni_patterns', {
"     \ 'r'   : ['[^. *\t]\.\w*', '\h\w*::\w*', '\h\w*\$\w*', '\h\w*{2,}\w*', '\h\w*(w*']
" \})

" We use deoplete-jedi for async completion
" let g:jedi#completions_enabled = 0

" nvim-r can fold loops and other syntax
" let r_syntax_folding = 1

"Get Vim-DevIcons to work with startify
function! StartifyEntryFormat()
    return 'WebDevIconsGetFileTypeSymbol(absolute_path) ." ". entry_path'
endfunction

""" FZF Config"""

" --column: Show column number
" --line-number: Show line number
" --no-heading: Do not show file headings in results
" --fixed-strings: Search term as a literal string
" --ignore-case: Case insensitive search
" --no-ignore: Do not respect .gitignore, etc...
" --hidden: Search hidden files and folders
" --follow: Follow symlinks
" --glob: Additional conditions for search (in this case ignore everything in the .git/ folder)
" --color: Search color options

command! -bang -nargs=* Find call fzf#vim#grep('rg --column --line-number --no-heading --fixed-strings --ignore-case --no-ignore --hidden --follow --glob "!.git/*" --color "always" '.shellescape(<q-args>), 1, <bang>0)
" use ripgrep for greprg
set grepprg=rg\ --vimgrep
