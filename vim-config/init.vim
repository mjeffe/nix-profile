" Neovim: use the same ~/.vimrc, colors, docs, and plugins as vim.
" Install as ~/.config/nvim/init.vim.
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc
