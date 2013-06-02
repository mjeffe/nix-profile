# .bashrc

# User specific aliases and functions

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

stty erase    # set backspace to erase
set -o vi       # use vi for command history editing
umask 002       # make files read/write-able by group
#umask 0        # make files read/write-able by everyone

# -------------------------------
# aliases
# -------------------------------
alias ls="ls -F"
alias ll="~/bin/ll"
alias more=`which less`
alias vi=`which vim`
alias view="`which vim` -R"
#alias prhex="prhex -l -w"

# the LANG environment variable can mess up stuff in more, man pages, etc.
unset LANG

# help keep track of how many subshell's I've spawned
if [ -z "$MRJ_SUBSHELL_LEVEL" ]; then
   export MRJ_SUBSHELL_LEVEL=1
else
   export MRJ_SUBSHELL_LEVEL=`expr $MRJ_SUBSHELL_LEVEL + 1`
fi

