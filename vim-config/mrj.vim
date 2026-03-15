" Vim color file
" Maintainer: Matt Jeffery
" Remark:     Matt's color scheme

set background=dark
highlight clear
if exists("syntax_on")
    syntax reset
endif

let colors_name = "mrj"

hi Comment      ctermfg=Brown
hi Constant     NONE
hi Identifier   NONE
hi Statement    cterm=NONE ctermfg=DarkCyan
  hi Operator     NONE
hi PreProc      cterm=NONE ctermfg=DarkMagenta
hi Type         ctermfg=DarkGreen
hi Special      NONE
hi Delimiter    NONE
