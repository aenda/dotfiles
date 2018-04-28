"Color Config"{{{
"set termguicolors
if (empty($TMUX))
  if (has("nvim"))
    "For Neovim 0.1.3 and 0.1.4
    let $NVIM_TUI_ENABLE_TRUE_COLOR=1
  endif
  "For Neovim > 0.1.5, based on Vim patch 7.4.1770 (`guicolors` option)
  if (has("termguicolors"))
    set termguicolors
  endif
endif

"Set background - in file so its writable
"source $HOME/.config/nvim/background.vim
"
"colorscheme nord
"let g:nord_italic=1
"let g:nord_comment_brightness=18
"
colorscheme onedark
let g:onedark_terminal_italics = 1
"
"colorscheme NeoSolarized
"let g:neosolarized_italic = 1
"set background=dark
"
let g:lightline = { 'colorscheme': 'onedark', }
"let g:lightline = { 'colorscheme': 'solarized', }

let g:rout_follow_colorscheme = 1 "nvim-r uses colorscheme
let g:Rout_more_colors = 1"}}}
