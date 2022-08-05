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

# -------------------------------
# PS1 command prompt
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

# -------------------------------
# shit to make working on the bletcherous MacOS more tolerable
# -------------------------------

BREW_HOME=$(brew --prefix)
export PATH="$BREW_HOME/opt/curl/bin:$PATH"

# https://github.com/fabiomaia/linuxify
if [ -f ~/.linuxify ]; then
    . ~/.linuxify
fi


