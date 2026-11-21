# prompt and terminal title
# a very cool bash prompt generator: https://robotmoon.com/bash-prompt-generator/

git_branch() {
    git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

# new gnome-terminal on ubuntu 22.04 no longer reports lines x cols when
# resizing, so put it in the title
set_window_title() {
    echo -en "\033]0;(${LINES}x${COLUMNS}) $(pwd | sed -e "s;^$HOME;~;")\a"
}
export PROMPT_COMMAND=set_window_title

PS1="\[\e[0;32m\]\u@\h\[\e[m\]"     # username@host
PS1+=":"
PS1+="\[\e[0;36m\]\w\[\e[m\]"       # pwd
PS1+="\$(git_branch)"               # git branch
PS1+="$ "
export PS1
