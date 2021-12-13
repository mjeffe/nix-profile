#
# mjeffe .bashrc
#
# Nowadays, I just add this to the bottom of the distribution's default .bashrc
#

#
# ---------- mjeffe's stuff ------------------
#

set -o vi       # use vi for command history editing
umask 002       # make files read/write-able by group

# git helpers
#source /etc/bash_completion.d/git-prompt
#source /usr/share/bash-completion/completions/git

# -------------------------------
# aliases
# -------------------------------
alias ls="ls -F"
alias ll="ls -lF --group-directories-first"
alias more=`which less`
alias vi=`which vim`
alias view="`which vim` -R"
alias vide='vim -u ~/.vimrc-ide'
#alias prhex="prhex -l -w"
alias gitsdiff="git difftool -y -x 'sdiff -w `tput cols`'"
alias fucking='sudo'
alias hulksmash='rm -fr'
alias opn="xdg-open"
alias ab='./scripts/ab'
alias amarki='./utils/amarki'
alias sail='bash vendor/bin/sail'

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
#export PS1=‘[\u@\h:\w]$ ’
PS1="\[\e[0;32m\]\u@\h\[\e[m\]" # username
PS1+=":"
PS1+="\[\e[0;36m\]\w\[\e[m\]" # pwd
#PS1+="\[\e[0;92m\]\$(git_branch)\[\e[m\]" # git branch
PS1+="\$(git_branch)" # git branch
PS1+="$ "
export PS1;

