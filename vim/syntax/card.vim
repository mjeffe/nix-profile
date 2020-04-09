" $Id: card.vim 14 2011-03-09 19:25:46Z mjeffe $
"
" Vim syntax file
" Language:	Generic sectioned control card
" Maintainer:	Matt Jeffery <mjeffe@acxiom.com>
" Last Change:	2002 Apr 30


" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

"syn case ignore

" Keywords:
syn region cardKeyword    start="\["  end="\]"

" Comments:
syn region cardComment    start="/\*"  end="\*/"
syn match cardComment	"#.*"

hi link cardComment	Comment
hi link cardKeyword	Statement

let b:current_syntax = "sql"

" read in my statndard syntax file
so <sfile>:p:h/std_syntax.vim


