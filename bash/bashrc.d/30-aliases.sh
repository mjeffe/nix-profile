# aliases

alias ls="ls -F"
alias ll="ls -lF --group-directories-first"   # linux or linuxified mac
command -v less >/dev/null && alias more=less
alias vi=vim
alias view="vim -R"
alias vide='vim -u ~/.vimrc-ide'
alias gitsdiff='git difftool -y -x "sdiff -w $(tput cols)"'
alias fucking='sudo'
alias hulksmash='rm -fr'
alias opn="xdg-open"

# you can start docker manually by simply running `dockerd` and stopping it with Ctrl+c
alias start-docker='sudo systemctl start docker'
alias stop-docker='sudo systemctl stop docker'

# project helpers (run from a project root)
alias sail='./vendor/bin/sail'
alias darc='./darc'
alias sb='./sandbox/sb'
alias ol='aws sso login'
