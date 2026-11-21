# stuff to make working on the bletcherous macOS more tolerable

[[ $OSTYPE == darwin* ]] || return 0

if command -v brew >/dev/null; then
    export PATH="$(brew --prefix)/opt/curl/bin:$PATH"
fi

# This is the life saver!!!  https://github.com/fabiomaia/linuxify
[ -f "$HOME/.linuxify" ] && . "$HOME/.linuxify"

# git completion, from git/git contrib/completion:
#   curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash \
#       -o ~/.git-completion.bash
[ -f "$HOME/.git-completion.bash" ] && . "$HOME/.git-completion.bash"

# perl local::lib (set up by linuxify's brewed perl)
[ -d "$HOME/perl5/lib/perl5" ] && eval "$(perl -I"$HOME/perl5/lib/perl5" -Mlocal::lib="$HOME/perl5")"

alias espeak='say'
