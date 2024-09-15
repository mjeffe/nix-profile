#
# Matt Jeffery's .bashrc
#
# Nowadays, I just source this at the bottom of the distribution's default .bashrc
#

set -o vi       # use vi for command history editing
umask 002       # make files read/write-able by group

# git helpers
#source /etc/bash_completion.d/git-prompt
#source /usr/share/bash-completion/completions/git

# -------------------------------
# functions
# -------------------------------

# long listing, directories last, like on DEC Unix
#unalias ll
#ll() {
#    ls -lF $* | grep --color=no -v '/$'
#    ls -lF $* | grep --color=no '/$'
#}

# list the most recently changed files
lt() {
    ls -lArtF "$@" | tail -20
}

git_branch() {
    git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

dusort() {
    dir=${@:-.}
    du -k $dir | sort -nr | head -20
}

# new gnome-terminal on ubuntu 22.04, no longer reports lines x cols when
# resizing so here I create the function to set it in the title
set_window_title() {
    #echo -en "\033]0;$(pwd | sed -e 's;^$HOME;~;') ($(stty size))\a"
    #echo -en "\033]0;$(pwd | sed -e 's;^$HOME;~;') ($(tput lines) x $(tput cols))\a"
    echo -en "\033]0;(${LINES}x${COLUMNS}) $(pwd | sed -e "s;^$HOME;~;")\a"
}
export PROMPT_COMMAND=set_window_title

# add current dir to path - security risk... eh
#export PATH=.:$PATH
#export PGPASSFILE=$HOME/.pgpass

# -------------------------------
# PS1 command prompt
# a very cool bash prompt generator: https://robotmoon.com/bash-prompt-generator/
# -------------------------------

#export PS1=‘[\u@\h:\w]$ ’
PS1="\[\e[0;32m\]\u@\h\[\e[m\]" # username
PS1+=":"
PS1+="\[\e[0;36m\]\w\[\e[m\]" # pwd
#PS1+="\[\e[0;92m\]\$(git_branch)\[\e[m\]" # git branch
PS1+="\$(git_branch)" # git branch
PS1+="$ "
export PS1;

# -------------------------------
# aliases
# -------------------------------

alias ls="ls -F"
#alias ll="ls -lF"   # mac
alias ll="ls -lF --group-directories-first"   # linux or linuxified mac
alias more=`which less`
alias vi=`which vim`
alias view="`which vim` -R"
alias vide='vim -u ~/.vimrc-ide'
#alias prhex="prhex -l -w"
alias gitsdiff="git difftool -y -x 'sdiff -w `tput cols`'"
alias fucking='sudo'
alias hulksmash='rm -fr'
alias sail='bash vendor/bin/sail'
alias opn="xdg-open"
alias ol='aws sso login'
#alias ab='./scripts/ab'
#alias amarki='./utils/amarki'
alias darc='./darc'

# -------------------------------
# shit to make working on the bletcherous MacOS more tolerable
# -------------------------------

if [ "$OSTYPE" = 'darwin'* ]; then
    source ~/.bashrc-mrj-mac
fi


# add my stuff
#source ~/.bashrc-mrj

# ----- python/pyenv stuff ---------
# This adds the pyenv executable to PATH and enables the pyenv "python family of commands" shims
export PYENV_ROOT=/usr/local/var/pyenv
#export PATH="$PYENV_ROOT/bin:$PATH"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
#eval "$(pyenv init --path)"
eval "$(pyenv init -)"

#This one is NOT from the pyenv init command...it is from the pyenv-virtualenv docs.
eval "$(pyenv virtualenv-init -)"
# ----------------------------------

# ----- npm/nvm/node stuff ---------
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# ----------------------------------
