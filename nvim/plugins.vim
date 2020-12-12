" vim:fdm=marker et si fdl=2 ft=vim sts=0 sw=4 ts=4

"""Vimtex Config"{{{
let g:vimtex_view_general_viewer = 'qpdfview'
let g:vimtex_view_general_options
  \ = '--unique @pdf\#src:@tex:@line:@col'
let g:vimtex_view_general_options_latexmk = '--unique'
" for qpdfview: sourceEditor = 'nvr --remote +\":%2\" \"%1\" --servername=/tmp/texsocket'
" for okular: set editor command: 'nvr --remote-silent %f -c %l'
" defaults fine, see :h g:vimtex_compiler_latexmk
"add after hook - latexmk -c will clean files?
let g:vimtex_view_method = 'zathura' "window id/back search broken
let g:vimtex_view_general_options = '--unique file:@pdf\#src:@line@tex'
let g:vimtex_view_general_options_latexmk = '--unique'
nnoremap <silent> <localleader>lr <plug>(vimtex-reverse-search)
nnoremap <silent> <localleader>ls <plug>(vimtex-toggle-main)
" vimtex has added new improved formatexpr, off by default
" however it may cause compatibility issues w other plugins
" it can be enabled with g:vimtex_format_enabled=1
"}}}

"""Nvim-R"{{{
"get rid of annoying binding
let R_user_maps_only = 1
"alternately : let R_disable_cmds = ['Rsetwd', 'RDputObj']
"add new bindings
function! s:customNvimRMappings()
    nmap <buffer> <LocalLeader>rf <Plug>RStart
    nmap <buffer> <LocalLeader>rq <Plug>RClose
    nmap <buffer> <LocalLeader>rl <Plug>RSendLine
    nmap <buffer> <LocalLeader>rp <Plug>RSendParagraph
    nmap <buffer> <LocalLeader>ra <Plug>RSendFile
    nmap <buffer> <LocalLeader>rc <Plug>RSendChunk
    nmap <buffer> <LocalLeader>rk <Plug>RKnit
    nmap <buffer> <LocalLeader>rm <Plug>RMakeRmd
endfunction
augroup myNvimR
    au!
    autocmd FileType r call s:customNvimRMappings()
augroup end
let g:pandoc#spell#enabled = 0
" nvim-r can fold loops and other syntax
" let r_syntax_folding = 1
"}}}

"""""""LCN Config""""""""""""{{{
" let g:LanguageClient_settingsPath = '$HOME/.dotfiles/nvim/'
let g:LanguageClient_serverCommands = {}
if executable('pyls')
    let g:LanguageClient_serverCommands.python = ['pyls'] " vv for debug
endif
if executable('rustup')
    let g:LanguageClient_serverCommands.rust = ['rustup', 'run', 'stable', 'rls']
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
if executable('R')
    let g:LanguageClient_serverCommands.r =
        \ ['R', '--quiet', '--slave', '-e', 'languageserver::run()']
endif

" Better way of setting mappings
nnoremap <silent> <F5> <Plug>(lcn-menu)
" nnoremap <silent> K <Plug>(lcn-hover)
nnoremap <silent> <leader>ld <Plug>(lcn-definition)
nnoremap <silent> <leader>lf <Plug>(lcn-format)
nnoremap <silent> <leader>lr <Plug>(lcn-rename)
nnoremap <silent> <leader>ls <Plug>(lcn-symbols)
nnoremap <silent> K :call <SID>show_docs()<CR>
function! s:show_docs()
    if(index(['vim','help'], &filetype) >= 0)
        execute 'h '.expand('<cword>')
    else
        LanguageClient#textDocument_hover()
    endif
endfunction
" Use the language server with Vim's formatting operator |gq|
set formatexpr=LanguageClient#textDocument_rangeFormatting()

" augroup LanguageClientConfig
"     autocmd!
"     autocmd FileType python,r nnoremap <silent> <F5>
"       \ :call LanguageClient_contextMenu()<CR>
"     " <leader>ld to go to definition
"     autocmd FileType python,r nnoremap <buffer> <leader>ld
"       \ :call LanguageClient#textDocument_definition()<CR>
"     " <leader>lf to autoformat document
"     autocmd FileType python,r nnoremap <buffer> <leader>lf
"       \ :call LanguageClient#textDocument_formatting()<CR>
"     " <leader>lh for type info under cursor
"     autocmd FileType python,r nnoremap <buffer> K
"       \ :call LanguageClient#textDocument_hover()<CR>
"     " <leader>lr to rename variable under cursor
"     autocmd FileType python,r nnoremap <buffer> <leader>lr
"       \ :call LanguageClient#textDocument_rename()<CR>
"     " <leader>ls to fuzzy find the symbols in the current document
"     autocmd FileType python,r nnoremap <buffer> <leader>ls
"       \ :call LanguageClient#textDocument_documentSymbol()<CR>
"     " <leader>lc to switch omnifunc to LanguageClient
"     " autocmd FileType python,R nnoremap <buffer> <leader>lc
"     "   \ :setlocal omnifunc=LanguageClient#complete<CR>
"     " Use LanguageServer for completion - no need with deoplete integration
"     " autocmd FileType python,R setlocal completefunc=LanguageClient#complete
" augroup END
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
set completeopt=menuone

""" Disable the candidates in Comment/String syntaxes.
call deoplete#custom#source('_',
            \ 'disabled_syntaxes', ['Comment', 'String'])

""" Deoplete and vimtex config
call deoplete#custom#var('omni', 'input_patterns', {
    \ 'tex' : g:vimtex#re#deoplete,
\})

" we can explicitly set the only sources we want like this
" call deoplete#custom#option('sources', {
"     \ 'python': ['LanguageClient', 'ultisnips'],
"     \ 'python3': ['LanguageClient', 'ultisnips'],
"     \ 'rust': ['LanguageClient', 'ultisnips'],
"     \ 'tex': ['ultisnips', 'omni'],
"     \ 'r': ['LanguageClient', 'ultisnips']
" \})
"\ '_': ['file', 'buffer'],
"\ 'r': ['LanguageClient', 'omni', 'ultisnips']
"
" disables around/buffer sources see :h deoplete-sources
" or selectively disable certain sources
" call deoplete#custom#option('ignore_sources', {'_': ['around', 'buffer']})

" or enable them in certain filetypes
" call deoplete#custom#source('buffer',
" \ 'filetypes', ['tex', 'latex'])

" put snippets at the top of completion menu
"call deoplete#custom#source('ultisnips', 'rank', 1000)

" disable deoplete in R files (no longer needed, compatible now)
" autocmd FileType r call deoplete#custom#buffer_option('auto_complete', v:false)
" this augroup maps tab to r lang server supplied omnicomplete
" augroup r
"   autocmd!
"   set completefunc=LanguageClient#complete
"   autocmd FileType r
"         \ inoremap <silent><expr> <TAB>
"         \ pumvisible() ? "\<C-n>" :
"         \ <SID>check_back_space() ? "\<TAB>" :
"         \ "\<C-x>\<C-o>"
"   function! s:check_back_space() abort "{{{
"     let col = col('.') - 1
"     return !col || getline('.')[col - 1]  =~ '\s'
"   endfunction"}}}
" augroup END

" deoplete calls omnicomplete directly after ., ::, $, and ( for r
" call deoplete#custom#option('omni_patterns', {
"     \ 'r'   : ['[^. *\t]\.\w*', '\h\w*::\w*', '\h\w*\$\w*', '\h\w*{2,}\w*', '\h\w*(w*']
" \})
"}}}

"Get Vim-DevIcons to work with startify
function! StartifyEntryFormat()
    return 'WebDevIconsGetFileTypeSymbol(absolute_path) ." ". entry_path'
endfunction
" Set session dir
let g:startify_session_dir = expand("$HOME/.config/nvim/session")

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

command! -bang -nargs=* Find
   \ call fzf#vim#grep(
   \ 'rg --column --line-number --no-heading --fixed-strings --no-ignore --hidden --follow --glob "!.git/*" --color "always" --smart-case '.shellescape(<q-args>), 1,
   \ <bang>0 ? fzf#vim#with_preview('up:60%')
   \         : fzf#vim#with_preview('right:50%:hidden', '?'),
   \ <bang>0)
nnoremap <silent> <leader>f :Find<CR>
" use ripgrep for grepprg
set grepprg=rg\ --vimgrep\ --smart-case
set grepformat=%f:%l:%c:%m,%f:%l:%m
"}}}

""" vim-slime config
" let g:slime_target = "neovim"
" let g:slime_paste_file = expand("$TMP/.slime_paste")
" function! Slime_Term() abort "abort on errors
"     " Split window and open terminal
"     vsp
"     enew | terminal
"     " get job id so slime can send lines correctly
"     let l:repl_job_id = b:terminal_job_id
"     " switch back
"     execute 'normal!' . "\<c-w>p"
"     " set job id
"     let b:slime_config = {'jobid': l:repl_job_id}
" endfunction
