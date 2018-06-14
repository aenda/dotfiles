" vim:fdm=marker et si fdl=2 ft=vim sts=0 sw=4 ts=4

"Vimtex Config"{{{
let g:vimtex_compiler_progname = 'nvr'
let g:vimtex_view_method = 'general'
let g:vimtex_view_general_viewer = 'qpdfview'
let g:vimtex_view_general_options
  \ = '--unique @pdf\#src:@tex:@line:@col'
let g:vimtex_view_general_options_latexmk = '--unique'
" for qpdfview: sourceEditor = 'nvr --remote +\":%2\" \"%1\" --servername=/tmp/texsocket'
" for okular: set editor command: 'nvr --remote-silent %f -c %l'
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
let g:vimtex_compiler_engine='lualatex'
"add after hook - latexmk -c will clean files?
let g:vimtex_view_method = 'zathura' "window id/back search broken
let g:vimtex_view_general_options = '--unique file:@pdf\#src:@line@tex'
let g:vimtex_view_general_options_latexmk = '--unique'
"}}}

"""""""LCN Config""""""""""""{{{
" let g:LanguageClient_settingsPath = '$HOME/.dotfiles/nvim/'
let g:LanguageClient_serverCommands = {}
if executable('pyls')
    let g:LanguageClient_serverCommands.python = ['pyls', '-vv'] " vv for debug
endif
if executable('rls')
    let g:LanguageClient_serverCommands.rust = ['rustup', 'run', 'nightly', 'rls']
elseif executable('rustup')
    let g:LanguageClient_serverCommands.rust = ['rustup', 'run', 'nightly']
endif
if executable('julia')
    let g:LanguageClient_serverCommands.julia =
        \ ['julia', '--startup-file=no', '--history-file=no', '-e', '
        \     using LanguageServer;
        \     server = LanguageServer.LanguageServerInstance(STDIN, STDOUT, false);
        \     server.runlinter = true;
        \     run(server);
        \ ']
endif
let g:LanguageClient_serverCommands.r =
    \ ['R', '--quiet', '--slave', '-e', 'languageserver::run(debug = TRUE)']
"""""""""""""""""""""""""""""""""""""

augroup LanguageClientConfig
    autocmd!
    autocmd FileType python,R nnoremap <silent> <F5>
      \ :call LanguageClient_contextMenu()<CR>
    " <leader>ld to go to definition
    autocmd FileType python,R nnoremap <buffer> <leader>ld
      \ :call LanguageClient#textDocument_definition()<CR>
    " <leader>lf to autoformat document
    autocmd FileType python,R nnoremap <buffer> <leader>lf
      \ :call LanguageClient#textDocument_formatting()<CR>
    " <leader>lh for type info under cursor
    autocmd FileType python,R nnoremap <buffer> K
      \ :call LanguageClient#textDocument_hover()<CR>
    " <leader>lr to rename variable under cursor
    autocmd FileType python,R nnoremap <buffer> <leader>lr
      \ :call LanguageClient#textDocument_rename()<CR>
    " <leader>ls to fuzzy find the symbols in the current document
    autocmd FileType python,R nnoremap <buffer> <leader>ls
      \ :call LanguageClient#textDocument_documentSymbol()<CR>
    " Use the language server with Vim's formatting operator |gq|
    set formatexpr=LanguageClient#textDocument_rangeFormatting()
    " <leader>lc to switch omnifunc to LanguageClient
    " autocmd FileType python,R nnoremap <buffer> <leader>lc
    "   \ :setlocal omnifunc=LanguageClient#complete<CR>
    " Use LanguageServer for completion - no need with deoplete integration
    " autocmd FileType python,R setlocal completefunc=LanguageClient#complete
augroup END
"}}}

let g:UltiSnipsExpandTrigger="<C-j>"

""" Deoplete config {{{
" automatically start
" could we gain startup time by lazy loading?
let g:deoplete#enable_at_startup = 1
call deoplete#custom#option({
\ 'auto_complete_delay': 200,
\ 'smart_case': v:true,
\ })
set completeopt=longest,menuone,preview

" we stopped using jedi as a python source.
call deoplete#custom#option('sources', {
    \ '_': ['file', 'buffer'],
    \ 'python': ['LanguageClient', 'ultisnips'],
    \ 'python3': ['LanguageClient', 'ultisnips'],
    \ 'rust': ['LanguageClient', 'ultisnips'],
    \ 'tex': ['ultisnips', 'omni'],
\})
"\ 'r': ['LanguageClient', 'omni', 'ultisnips']

" disable deoplete in R files
autocmd FileType r call deoplete#custom#buffer_option('auto_complete', v:false)
" this augroup maps tab to r lang server supplied omnicomplete
augroup r
  autocmd!
  set completefunc=LanguageClient#complete
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

""" Deoplete and vimtex config
call deoplete#custom#var('omni', 'input_patterns', {
    \ 'tex' : g:vimtex#re#deoplete,
\})

" put snippets at the top of completion menu
"call deoplete#custom#source('ultisnips', 'rank', 1000)

" deoplete calls omnicomplete directly after ., ::, $, and ( for r
" call deoplete#custom#option('omni_patterns', {
"     \ 'r'   : ['[^. *\t]\.\w*', '\h\w*::\w*', '\h\w*\$\w*', '\h\w*{2,}\w*', '\h\w*(w*']
" \})
"
" }}}

" nvim-r can fold loops and other syntax
" let r_syntax_folding = 1

"Get Vim-DevIcons to work with startify
function! StartifyEntryFormat()
    return 'WebDevIconsGetFileTypeSymbol(absolute_path) ." ". entry_path'
endfunction

""" FZF Config"""{{{

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
"}}}

let g:slime_target = "neovim"
let g:slime_paste_file = expand("$TMP/.slime_paste")
function! Slime_Term() abort "abort on errors
    " Split window and open terminal
    vsp
    enew | terminal
    " get job id so slime can send lines correctly
    let l:repl_job_id = b:terminal_job_id
    " switch back
    execute 'normal!' . "\<c-w>p"
    " set job id
    let b:slime_config = {'jobid': l:repl_job_id}
endfunction
