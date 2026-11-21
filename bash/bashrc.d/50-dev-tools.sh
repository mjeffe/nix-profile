# language/version managers and completions; each block is a no-op when the
# tool is not installed

# pyenv: install with   curl https://pyenv.run | bash
export PYENV_ROOT="$HOME/.pyenv"
[ -d "$PYENV_ROOT/bin" ] && PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv >/dev/null; then
    eval "$(pyenv init -)"
    pyenv commands 2>/dev/null | grep -qx virtualenv-init && eval "$(pyenv virtualenv-init -)"
fi

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

# stripe cli completion
[ -r "$HOME/.stripe-completion.bash" ] && . "$HOME/.stripe-completion.bash"
