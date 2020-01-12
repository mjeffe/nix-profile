#
# mjeffe .bashrc
#
# Nowadays, I just add this to the bottom of the distribution's default .bashrc
#

#
# ---------- mjeffe's stuff ------------------
#

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

set -o vi       # use vi for command history editing
umask 002       # make files read/write-able by group

# git helpers
source /etc/bash_completion.d/git-prompt
source /usr/share/bash-completion/completions/git

# -------------------------------
# aliases
# -------------------------------
alias ls="ls -F"
alias ll="~/bin/ll"
alias more=`which less`
alias vi=`which vim`
alias view="`which vim` -R"
alias vide='vim -u ~/.vimrc-ide'
#alias prhex="prhex -l -w"
alias gitsdiff="git difftool -y -x 'sdiff -w `tput cols`'"
alias fucking='sudo'

