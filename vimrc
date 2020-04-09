" --------------------------------------------------------------------------------
" $Id: vimrc 230 2014-09-11 17:59:40Z u35616872 $
"
" Matt's .vimrc
"
" See :help mrj or view ~/.vim/doc/mrj.txt for my notes on my vim setup as
"   well as my other vim notes
" --------------------------------------------------------------------------------

set nocompatible                    " required by Vundle
filetype off                        " required by Vundle

" Special settings for running VIM as an IDE
" Invoked by running:    vim -u ~/.vimrc-ide
" see :help mrj
if exists("vim_as_ide") && vim_as_ide==1
    " --- Vundle (Vim Plugin manager) begin --------------------------------------
    " Keep all Plugin command between vundle#begin/end

    set rtp+=~/.vim/bundle/Vundle.vim   
    call vundle#begin()                 " use default ~/.vim/bundle/ as install dir for plugins 
    Plugin 'VundleVim/Vundle.vim'       " required - let Vundle manage Vundle

    "
    " After adding a new plugin, be sure to Launch vim and run :PluginInstall
    "

    " file tree browser
    Plugin 'scrooloose/nerdtree'
    Plugin 'jistr/vim-nerdtree-tabs'

    " language error checking
    Plugin 'vim-syntastic/syntastic'

    " CtrlP quick file finder
    Plugin 'ctrlpvim/ctrlp.vim'

    " Vue.js syntax highlighting
    Plugin 'posva/vim-vue'

    call vundle#end()
    filetype plugin indent on           " required - turn on file type specific indening
    " --- Vundle end ------------------------------------------------------------


    " --- Plugin-specfic settings -----------------------------------------------

    " ----- jistr/vim-nerdtree-tabs -----
    " See :help mrj

    " open/close NERDTree with Ctrl-n
    "map <C-n> :NERDTreeToggle<CR>

    " open/close NERDTree Tabs with \t
    "nmap <silent> <leader>t :NERDTreeTabsToggle<CR>
    nmap <C-n> :NERDTreeTabsToggle<CR>

    let g:nerdtree_tabs_open_on_console_startup = 0 " To have NERDTree always open on startup, set to 1
    "let g:signify_sign_delete_first_line = 'x'     " workaround if not using utf-8
    let NERDTreeShowBookmarks = 1                   " start with bookmarks open


    " ----- scrooloose/syntastic settings -----
    let g:syntastic_error_symbol = '✘'
    let g:syntastic_warning_symbol = "▲"
    augroup mySyntastic
        au!
        au FileType tex let b:syntastic_mode = "passive"
    augroup END

    " These are recommended but seem to mess up the vim ruler (status bar)
    "set statusline+=%#warningmsg#
    "set statusline+=%{SyntasticStatuslineFlag()}
    "set statusline+=%*

    let g:syntastic_always_populate_loc_list = 1
    let g:syntastic_auto_loc_list = 1
    let g:syntastic_check_on_open = 1
    let g:syntastic_check_on_wq = 0

    " enable some additional syntax checkers
    let g:syntastic_perl_checkers = ['perl']
    let g:syntastic_enable_perl_checker = 1
    
    " doesn't work... I haven't tried to debug, but it's probably some path issue
    "let g:syntastic_javascript_checkers = ['eslint']
    "let g:syntastic_javascript_eslint_exe = 'npm run lint --'

    " ----- crtlpvim/ctrlp settings -----
    let g:ctrlp_match_window = 'order:ttb,min:1,max:30,results:30'
    let g:ctrlp_working_path_mode = 'ra' " 'ra' - search from project root, 'c' from current dir
    let g:ctrlp_by_filename = 1         " set searching by filename = 1, by full path = 0
    let g:ctrlp_regexp = 1              " set to 1 to set regexp search (vs string search) as the default
                                        " Can be toggled on/off by pressing <c-r> inside the prompt
    " To clear the ctrlp cache, invoke CtrlP, then hit <F5>
    " HOWEVER, this doesn't seem to work for me... so I've manually deleted
    " .cache/ctrlp/mru/cache.txt and .cache/ctrlp/hist/cache.txt
    " wildignore is a vim wide setting, so other plugins will honor it, so
    " avoid setting if possible
    "set wildignore+=*/.git/*,*/.svn/*,*/node_modules/*,*/vendor/*,.swp,*.so,*.zip
      "\ 'file': '\.(exe|so|jpg)$'   " I can't get this style regex to work...
    let g:ctrlp_custom_ignore = {
      \ 'dir':  '\.git$\|\.svn$\|node_modules$\|vendor$\|log$\|tmp$',
      \ 'file': '\.exe$\|\.so$\|\.dat$\|\.jpg$\|\.jpeg$\|\.png\|\.pdf$'
      \ }

    " --- A few general settings that I only want in the IDE
    set number                          " show line numbers in left gutter
    set mouse=a                         " enable mouse - hold the SHIFT key to use normal mouse copy/paste buffer
    set foldcolumn=4                    " the number of columns to use for folding display at the left
endif


" --- General settings ------------------------------------------------------
filetype plugin indent on           " required - turn on file type specific indening
set backspace=indent,eol,start      " make backspace work as you would expect - allow backspacing over line breaks,
                                    " automatically-inserted indentation, or the place where insert mode started
set ruler                           " show vim ruler
set showcmd
set incsearch                       " jump to search results as typing?
set encoding=utf-8
set cryptmethod=blowfish            " algorithm to use for encrypted files (use :X)

" put swap files under ~/.vim (to prevent Dropbox from syncing them)
set backupdir=~/.vim/backup//
set directory=~/.vim/swap//

" set shiftwidth and tabstop to the same value, and set expandtab to always insert spaces
set shiftwidth=4                    " set the number of spaces to use for a tab
set tabstop=4                       " sets a tab equivalent to 3 spaces
set expandtab                       " insert shiftwidth or tabstop spaces whenever a tab is used 
set pastetoggle=<F12>               " toggles the paste nopaste modes to turn on/off automatic indenting
colorscheme mrj
"syntax enable                       " enable syntax highlighting, but allow customization (v.s. syn on)
syntax on                           " enable syntax highlighting, but allow customization (v.s. syn on)
hi clear SignColumn                 " need this for plugins like syntastic which put symbols in the sign column
"set nohlsearch                      " turn of highlighting a searches target
let g:loaded_matchparen=1           " turn off highlighting of matching brackets
runtime macros/matchit.vim          " allow % to match html/xml tags

" jump to last position you were at when you were last in a given file
:au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g'\"" | endif

" have % bounce between angled brackets (keep other match pairs):
"set matchpairs+=<:>

helptags ~/.vim/doc                 " include user defined help doc

" use syntax checking for python3
let g:pymode_python = 'python3'

" folding
" See :help mrj
set foldmethod=syntax               " fold based on syntax highlighting files
set foldnestmax=20                  " deepest fold is 20 levels
"set nofoldenable                    " dont fold by default - seems foldlevelstart=bignum works better
set foldlevel=1                     " only fold 1 level at a time?
set foldlevelstart=99               " start folding at this level (99 = essentially don't fold)
" only want foldcolumn set for IDE - see above
"set foldcolumn=4                    " the number of columns to use for folding display at the left


" abbreviations allow you do :<abbrev><space> and it will expand
abbrev gm !php artisan generate:model

" insert sequence number column
" not sure how to make this a command, so I'm just documenting it here
" Select lines with V (Shift-v), then type
"
"   :let i=1 | '<,'>g/^/ s//\=i . " "/ | let i+=1

" --- FileType-specfic settings -----------------------------------------------
" --- NOTE: Also see files in ~/.vim/after/ftplugin/

" for /* */ style comments, automatically insert comment leader if comment lines wrap
au! FileType c,sql set formatoptions+=ro

" in makefiles, don't expand tabs to spaces, since actual tab characters are
" needed, and have indentation at 8 chars to be sure that all indents are tabs
" (despite the mappings later):
au FileType make set noexpandtab shiftwidth=8 tabstop=8

" php
"au FileType php let g:php_folding=2  " I don't know why this doesn't work...
let g:php_folding=2


