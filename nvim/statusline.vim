" Statusline (requires Powerline font, with highlight groups using Solarized theme)
set statusline=
set statusline+=%(%{'help'!=&filetype?bufnr('%'):''}\ \ %)
set statusline+=%< " Where to truncate line
set statusline+=%f " Path to the file in the buffer, as typed or relative to current directory
set statusline+=%{&modified?'\ +':''}
set statusline+=%{&readonly?'\ ':''}
set statusline+=\ %1*%= " Separation point between left and right aligned items.
set statusline+=\ %{''!=#&filetype?&filetype:'none'}
set statusline+=%(\ %{(&bomb\|\|'^$\|utf-8'!~#&fileencoding?'\ '.&fileencoding.(&bomb?'-bom':''):'')
    \.('unix'!=#&fileformat?'\ '.&fileformat:'')}%)
set statusline+=%(\ \ %{&modifiable?(&expandtab?'et\ ':'noet\ ').&shiftwidth:''}%)
set statusline+=\ %*\ %2v " Virtual column number.
set statusline+=\ %3p%% " Percentage through file in lines as in |CTRL-G|
hi StatusLine term=reverse cterm=reverse gui=reverse ctermfg=14 ctermbg=8 guifg=#ace5e5 guibg=#052b35
hi StatusLineNC term=reverse cterm=reverse gui=reverse ctermfg=11 ctermbg=0 guifg=#657b83 guibg=#073642
hi User1 ctermfg=14 ctermbg=0 guifg=#ace5e5 guibg=#052b35
