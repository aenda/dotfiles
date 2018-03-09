"Neosolarized Config
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
"
"Vimtex Config
"let g:vimtex_latexmk_progname = 'nvr'
"let g:vimtex_view_method = 'zathura' #window id/back search broken
let g:vimtex_view_method = 'general'
let g:vimtex_view_general_viewer = 'okular'
let g:vimtex_view_general_options = '--unique file:@pdf\#src:@line@tex'
let g:vimtex_view_general_options_latexmk = '--unique'
let g:vimtex_fold_enabled = 0
"and under okular set editor command: "nvr --remote-silent %f -c %l"

"Deoplete config
let g:deoplete#enable_at_startup = 1
set completeopt=longest,menuone,preview
let g:deoplete#sources = {}
let g:deoplete#sources._ = ['file', 'ultisnips']
let g:SuperTabDefaultCompletionType = "<C-x><C-o>"
let g:UltiSnipsExpandTrigger="<C-j>"
inoremap <expr><tab> pumvisible() ? "\<C-n>" : "\<tab>"

"Deoplete and vimtex config
if !exists('g:deoplete#omni#input_patterns')
    let g:deoplete#omni#input_patterns = {}
endif
let g:deoplete#omni#input_patterns.tex = '\\(?:'
      \ .  '\w*cite\w*(?:\s*\[[^]]*\]){0,2}\s*{[^}]*'
      \ . '|\w*ref(?:\s*\{[^}]*|range\s*\{[^,}]*(?:}{)?)'
      \ . '|hyperref\s*\[[^]]*'
      \ . '|includegraphics\*?(?:\s*\[[^]]*\]){0,2}\s*\{[^}]*'
      \ . '|(?:include(?:only)?|input)\s*\{[^}]*'
      \ . '|\w*(gls|Gls|GLS)(pl)?\w*(\s*\[[^]]*\]){0,2}\s*\{[^}]*'
      \ . '|includepdf(\s*\[[^]]*\])?\s*\{[^}]*'
      \ . '|includestandalone(\s*\[[^]]*\])?\s*\{[^}]*'
      \ . '|usepackage(\s*\[[^]]*\])?\s*\{[^}]*'
      \ . '|documentclass(\s*\[[^]]*\])?\s*\{[^}]*'
      \ .')'

set hidden

"v for some debug logging
let g:LanguageClient_serverCommands = {
    \ 'r': ['R', '--quiet', '--slave', '-e', 'languageserver::run()'],
    \ 'python': ['pyls', '-v'],
    \ 'rust': ['rustup', 'run', 'nightly', 'rls'],
    \ 'javascript': ['javascript-typescript-stdio'],
    \ }

nnoremap <silent> K :call LanguageClient_textDocument_hover()<CR>
nnoremap <silent> gd :call LanguageClient_textDocument_definition()<CR>
nnoremap <silent> <F2> :call LanguageClient_textDocument_rename()<CR>
