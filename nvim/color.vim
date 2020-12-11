"Color Config"{{{
"set termguicolors
if (empty($TMUX))
  "For Neovim > 0.1.5, based on Vim patch 7.4.1770 (`guicolors` option)
  if (has("termguicolors"))
    set termguicolors
  endif
endif

"let g:nord_italic=1
"let g:nord_comment_brightness=18
"colorscheme nord

let g:onedark_terminal_italics = 1
colorscheme onedark

"let g:neosolarized_italic = 1
"colorscheme NeoSolarized
"Set background - in file so its writable
"source $HOME/.config/nvim/background.vim

let g:lightline = { 'colorscheme': 'onedark', }
"let g:lightline = { 'colorscheme': 'solarized', }

let g:rout_follow_colorscheme = 1 "nvim-r uses colorscheme
let g:Rout_more_colors = 1
"}}}
