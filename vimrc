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
    Plugin 'preservim/nerdtree'
    "Plugin 'scrooloose/nerdtree'       " seems to be abandoned?
    Plugin 'jistr/vim-nerdtree-tabs'   " definitely abandoned, see below and my nix-profile repo for my copy

    " language error checking
    Plugin 'vim-syntastic/syntastic'

    " CtrlP quick file finder
    Plugin 'ctrlpvim/ctrlp.vim'

    " ctags management
    " be sure to `sudo apt install exuberant-ctags`
    Plugin 'ludovicchabant/vim-gutentags'

    " Vue.js syntax highlighting
    Plugin 'posva/vim-vue'

    call vundle#end()
    filetype plugin indent on           " required - turn on file type specific indening
    " --- Vundle end ------------------------------------------------------------


    " --- Plugin-specfic settings -----------------------------------------------

    " ----- nerdtree -----
    " open/close NERDTree with Ctrl-n
    map <C-n> :NERDTreeToggle<CR>

    "
    " !!! See below for nerdtree section
    "

    " ----- jistr/vim-nerdtree-tabs -----
    " See :help mrj
    " NOTE: this plugin is abandoned and the source version is broken.  I have
    " a "fixed" version in my nix-profile repo which must be copied over after
    " bundle install.  See notes at the bottom of this file on some attempts
    " to workaround using this plugin at all.

    " open/close NERDTree with Ctrl-n
    "map <C-n> :NERDTreeToggle<CR>

    " open/close NERDTree Tabs with \t
    nmap <silent> <leader>t :NERDTreeTabsToggle<CR>
    nmap <C-n> :NERDTreeTabsToggle<CR>

    let g:nerdtree_tabs_open_on_console_startup = 0 " To have NERDTree always open on startup, set to 1
    let g:signify_sign_delete_first_line = 'x'     " workaround if not using utf-8
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

    " default to python3 - to swtich to python2, change this manually 
    let g:syntastic_python_python_exec = 'python3'
    let g:syntastic_python_checkers = ['python']

    " doesn't work... I haven't tried to debug, but it's probably some path issue
    let g:syntastic_javascript_checkers = ['eslint']
    "let g:syntastic_javascript_checkers = '$(npm bin)/eslint'
    "let g:syntastic_javascript_eslint_exe = 'npm run lint --'

    " disable for html - this didn't work for me
    "let g:syntastic_disabled_filetypes=['html']
    " Ignore all of tidy's warnings:
    let g:syntastic_html_tidy_quiet_messages = { "level" : "warnings" }

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

    " ----- ludovicchabant/vim-gutentags settings -----
    " big help from: https://www.reddit.com/r/vim/comments/d77t6j/guide_how_to_setup_ctags_with_gutentags_properly/
    let g:gutentags_generate_on_new = 1
    let g:gutentags_generate_on_missing = 1
    let g:gutentags_generate_on_write = 1
    let g:gutentags_generate_on_empty_buffer = 0
    " define some extra root markers - useful for javascript projects within
    " other projects
    "let g:gutentags_add_default_project_roots = 0
    "let g:gutentags_project_root = ['package.json', '.git', '.svn']
    let g:gutentags_project_root = ['package.json']
    " generate tags and tags.lock files in this dir rather than the project dir
    let g:gutentags_cache_dir = expand('~/.cache/vim/ctags/')
    " set message in status line when gutentags is generating tags
    "set statusline+=%{gutentags#statusline()}
    " generate a little extra info with the tags
    let g:gutentags_ctags_extra_args = [
        \ '--tag-relative=yes',
        \ '--fields=+ailmnS',
        \ ]
    let g:gutentags_ctags_exclude = [
        \ 'tmp/*',
        \ 'log/*',
        \ 'coverage/*',
        \ '*.git', '*.svg', '*.hg',
        "\ '*/tests/*',
        \ 'build',
        \ 'dist',
        \ '*sites/*/files/*',
        \ 'bin',
        \ 'node_modules',
        \ 'bower_components',
        \ 'cache',
        \ 'compiled',
        \ 'docs', 'doc/*',
        \ 'example',
        \ 'bundle',
        \ 'vendor',
        \ '*.md',
        \ '*-lock.json',
        \ '*.lock',
        \ '*bundle*.js',
        \ '*build*.js',
        \ '.*rc*',
        \ '*.json',
        \ '*.min.*',
        \ '*.map',
        \ '*.bak',
        \ '*.zip',
        \ '*.pyc',
        \ '*.class',
        \ '*.sln',
        \ '*.Master',
        \ '*.csproj',
        \ '*.tmp',
        \ '*.csproj.user',
        \ '*.cache',
        \ '*.pdb',
        \ 'tags*',
        \ 'cscope.*',
        \ '*.css',
        \ '*.less',
        \ '*.scss',
        \ '*.exe', '*.dll',
        \ '*.mp3', '*.ogg', '*.flac',
        \ '*.swp', '*.swo',
        \ '*.bmp', '*.gif', '*.ico', '*.jpg', '*.png',
        \ '*.rar', '*.zip', '*.tar', '*.tar.gz', '*.tar.xz', '*.tar.bz2',
        \ '*.pdf', '*.doc', '*.docx', '*.ppt', '*.pptx',
        \ ]


    " --- A few general settings that I only want in the IDE

    " mouse copy/paste
    " on Ubuntu: mouse=a works as expected, hold SHIFT to paste with middle mouse button
    " on Mac: everythign is fucked up... mouse=r seems to work with simple highlight and middle mouse button paste
    set mouse=a    " Linux or Mac with iTerm2
    "set mouse=r    " Mac Terminal

    set number                          " show line numbers in left gutter
    "set foldcolumn=4                    " the number of columns to use for folding display at the left

    " F6 to toggle settings allowing copy of multiline text
    map <F6> :set nonumber!<CR>:NERDTreeTabsToggle<CR>
endif

" find (grep) in files
" vimgrep is really slow...
"map <F4> :execute "vimgrep /" . expand("<cword>") . "/j **" <Bar> cw<CR>
" regular grep has anoying extra messages
map <F4> :execute " grep -srnw --binary-files=without-match --exclude-dir=.git --exclude-from=$HOME/.vim/exclude.list . -e " . expand("<cword>") . " " <bar> cwindow<CR>

" --- General settings ------------------------------------------------------
"
"  note, a great resource is the vimrc of vim devs. For example, some of these
"  settings were inspired by scrooloose: https://github.com/scrooloose/vimfiles/blob/master/vimrc
"
filetype plugin indent on           " required - turn on file type specific indening
set backspace=indent,eol,start      " make backspace work as you would expect - allow backspacing over line breaks,
                                    " automatically-inserted indentation, or the place where insert mode started
set ruler                           " show vim ruler
set showcmd                         " show incomplete cmds in bottom status bar
set showmode                        " show current mode in bottom status bar
set incsearch                       " jump to search results as typing?
set encoding=utf-8
set cryptmethod=blowfish            " algorithm to use for encrypted files (use :X)

"display tabs and trailing spaces, turn of with :set nolist
set list
set listchars=tab:▷⋅,trail:⋅,nbsp:⋅

" put swap files under ~/.vim (to prevent Dropbox from syncing them)
set backupdir=~/.vim/backup//
set directory=~/.vim/swap//

" set the width at which gq command will wrap (default is 78)
"set textwidth=118

" set shiftwidth and tabstop to the same value, and set expandtab to always insert spaces
set shiftwidth=4                    " set the number of spaces to use for a tab
set tabstop=4                       " sets a tab equivalent to n spaces
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

" use system clipboard (I've never tested this)
"set clipboard=unnamed

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
"set fillchars=vert:\|

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

" function to add acent marks to vowels
" Mapped to the '-' key
function! ToggleAccent()
   " Vowels
   let withAccent   = [ "á", "é", "í", "ó", "ú", "ñ", "Á", "É", "Í", "Ó", "Ú", "Ñ" ]
   let withNoAccent = [ "a", "e", "i", "o", "u", "n", "A", "E", "I", "O", "U", "N" ]

   " A better way of getting the character under the cursor
   " From: https://stackoverflow.com/a/23323958/1121933
   let character = matchstr( getline('.'), '\%' . col('.') . 'c.' )

   " If it's a vowel without an acute accent over it, 'position' will contain
   " the index of the matching element in the 'withNoAccent' list or -1 otherwise.
   let position = match( withNoAccent , character )
   if position != -1
      " Replace it with an accented vowel
      execute ":normal! r" . withAccent[position]
   else
      " Check if it's a vowel with an acute accent over it
      let position = match( withAccent , character )
      if position != -1
         " Replace it with a vowel with no accent
         execute ":normal! r" . withNoAccent[position]
     endif
   endif

   " Do nothing if it isn't a vowel
endfunction

" Map the '-' key
nnoremap <silent> - :call ToggleAccent()<CR>

" spell checking and correcting
" To manually turn spell checking on/off
" :setlocal spell
" :set spell
" :set nospell
"
set spelllang=en_us
set spellfile=$HOME/Dropbox/vim/spell/en.utf-8.add
" auto turn on spell checking for certain types of files
"autocmd BufRead,BufNewFile *.md setlocal spell
"autocmd BufRead,BufNewFile *.txt setlocal spell

" spell check when writing commit logs
autocmd filetype svn,*commit* setlocal spell
autocmd filetype git,*commit* setlocal spell

"source project specific config files
runtime! projects/**/*.vim

" ---------------------------------------------------------------------------
" Experiments to try and replace the abandoned and now broken
" vim-nerdtree-tabs plugin.
"
" The basic problem that broke vim-nerdtree-tabs is that an update to vim
" sometime around Jan 2023 changed the behavior of autocommands. You can
" no longer close your current buffer from within an autocmd.
" ---------------------------------------------------------------------------
"
" This autocmd breaks with error (detected by running :9verbose quit):
"   Error detected while processing BufEnter Autocommands for "*":
"   E1312: Not allowed to change the window layout in this autocmd
"
"   Looks like a change in Vim no longer allows deleting your current buffer from within an autocmd:
"       https://groups.google.com/g/vim_dev/c/Cw8McBH6DDM
"
" Close the tab if NERDTree is the only window remaining in it.
"autocmd BufEnter * if winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif
"
" Have the same NERDTree on every tab - Open the existing NERDTree on each new tab
"autocmd BufWinEnter * if getcmdwintype() == '' | silent NERDTreeMirror | endif
"
" Exit Vim if NERDTree is the only window remaining in the only tab.
"autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif
"
"
" might be able to exploit this:
"
"I use the following function to check for the NERDTree existence (in the current tab page; if you need this globally, you'd have to iterate over all tabs with gettabvar()).
"
"function! IsNerdTreeEnabled()
"    return exists('t:NERDTreeBufName') && bufwinnr(t:NERDTreeBufName) != -1
"endfunction
"
"
"-----------------------------------
"  This is an attempt to eliminate the NerdTree and vim-nerdtree-tabs plugins
"  by using the vim native netrw file browser behave like nerdtree.
"  See: https://shapeshed.com/vim-netrw/
"let g:netrw_banner = 0
"let g:netrw_liststyle = 3
"let g:netrw_browse_split = 4
"let g:netrw_altv = 1
"let g:netrw_winsize = 25
"augroup ProjectDrawer
"  autocmd!
"  autocmd VimEnter * :Vexplore
"augroup END

