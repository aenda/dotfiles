""""""ALE config"""""""{{{
"let g:ale_enabled = 0
"autocmd FileType r let g:ale_enabled = 1
"All linters on by default, otherwise enable specific ones
"pyls: lint: mccabe, pycodestyle, pydocstyle, pyflakes, rope | autopep8, yapf
"let g:ale_linters = { 'python': ['pycodestyle',
"                               \ 'pyflakes', 'pylint', 'pyls'] }
"function! ALEEnableMypy() abort 
"    "let b:previous_ale_fixers = {}
"    "let b:previous_ale_fixers.python = g:ale_linters['python']
"    try
"        let b:ale_linters = g:ale_linters
"        let b:ale_linters['python'] += ['mypy']
"        "let b:ale_fixers.python: b:previous_ale['python'] + ['isort']
"    "    ALEFix
"    "finally
"    "    unlet b:ale_linters
"    endtry
"endfunction
"let g:ale_fixers = {
"\   'python': ['autopep8', 'yapf', 'isort'],
"\   'rust': ['rustfmt']
"\}
""let g:ale_lint_on_text_changed = 'never' "lint as you type options
"let g:ale_lint_delay = 500 "delay of no typing to lint
"let g:ale_list_window_size = 5 " Show 5 lines of errors (default: 10)
" if you don't want linters to run on opening a file
"let g:ale_lint_on_enter = 0
" use ale_set_loclist or ale_set_quickfix - loclist is default
" let g:ale_open_list = 1 "show quickfix window when file contains warnings
""""""""""""""""""""""""""""""""""""""}}}

