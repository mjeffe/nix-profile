#!/usr/bin/env bash
#
# Matt Jeffery's *nix profile installer ("nix" as in Unix/Linux, not the Nix
# package manager).
#
#   curl -fsSL https://raw.githubusercontent.com/mjeffe/nix-profile/master/install.sh | bash
#   curl -fsSL .../install.sh | bash -s -- pi desktop     # pick modules
#   ./install.sh [module...]                              # from a clone
#
# Without a clone, it clones the repo over HTTPS (no ssh key or git config
# needed; git/gitconfig makes later pushes use ssh), or downloads a tarball
# when git is missing. From a clone, it uses that clone as is.
#
# Files are symlinked into $HOME, so `git pull` updates every box. Any file it
# replaces is moved aside to <file>.bak.<timestamp>. Safe to re-run.
#
# Environment:
#   NIX_PROFILE_DIR    where to clone   (default: ~/src/mrj/nix-profile)
#   NIX_PROFILE_REPO   repo to clone    (default: https://github.com/mjeffe/nix-profile.git)
#   NIX_PROFILE_REF    branch           (default: master)
#   NIX_PROFILE_PRIVATE_REPO  private companion repo for the private module
#                             (default: https://github.com/mjeffe/nix-profile-private.git)
#   NIX_PROFILE_PRIVATE_DIR   where to clone it (default: next to this clone)
#

set -euo pipefail

DEFAULT_MODULES=(bash git vim agents)
ALL_MODULES=(bash git vim agents pi desktop)
MODULES=("${ALL_MODULES[@]}" private)    # private is never part of "all"

usage() {
    cat <<EOF
usage: install.sh [module...|all]

modules (default: ${DEFAULT_MODULES[*]}):
  bash     ~/.bashrc-mrj, ~/.profile-mrj loaders and the bashrc.d/ snippets
  git      ~/.gitconfig include, ~/.gitignore_global
  vim      vim-config: ~/.vimrc, colors, help, vim-plug plugins (and Neovim's init.vim)
  agents   ~/AGENTS.md
  pi       pi coding agent with subagents (coding-agents/pi)
  desktop  X resources, conky (Linux desktops)
  private  clone a private companion repo and run its install.sh
           (see private.example/; log in first with: gh auth login && gh auth setup-git)
EOF
}

say() { printf '==> %s\n' "$*"; }
warn() { printf '  ! %s\n' "$*" >&2; }

STAMP=$(date +%Y%m%d%H%M%S)

# link SRC DEST: symlink DEST -> SRC, moving any existing DEST aside.
link() {
    local src=$1 dest=$2
    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        return 0
    fi
    mkdir -p "$(dirname "$dest")"
    if [ -L "$dest" ] && [[ $(readlink "$dest") == "$DIR"/* ]]; then
        rm "$dest"    # an older link into this repo; nothing to back up
    elif [ -e "$dest" ] || [ -L "$dest" ]; then
        mv "$dest" "$dest.bak.$STAMP"
        echo "    moved $dest to $dest.bak.$STAMP"
    fi
    ln -s "$src" "$dest"
    echo "    linked $dest"
}

# hook FILE MARKER LINE: append LINE to FILE unless MARKER already appears in it.
hook() {
    local file=$1 marker=$2 line=$3
    if [ -f "$file" ] && grep -qF -- "$marker" "$file"; then
        return 0
    fi
    printf '\n# nix-profile\n%s\n' "$line" >>"$file"
    echo "    hooked $file"
}

# --- locate or fetch the repo ---------------------------------------------------

REPO_URL=${NIX_PROFILE_REPO:-https://github.com/mjeffe/nix-profile.git}
REF=${NIX_PROFILE_REF:-master}

self=${BASH_SOURCE[0]:-}
if [ -n "$self" ] && [ -f "$self" ] && [ -f "$(dirname "$self")/bash/bashrc" ]; then
    DIR=$(cd "$(dirname "$self")" && pwd)
    say "using clone at $DIR"
else
    DIR=${NIX_PROFILE_DIR:-$HOME/src/mrj/nix-profile}
    if [ -d "$DIR/.git" ]; then
        say "updating $DIR"
        git -C "$DIR" pull --ff-only || warn "could not fast-forward $DIR; using it as is"
    elif command -v git >/dev/null; then
        say "cloning $REPO_URL to $DIR"
        mkdir -p "$(dirname "$DIR")"
        git clone --branch "$REF" "$REPO_URL" "$DIR"
    else
        say "git not found; downloading $REF tarball to $DIR"
        mkdir -p "$DIR"
        curl -fsSL "${REPO_URL%.git}/archive/refs/heads/$REF.tar.gz" | tar -xz --strip-components=1 -C "$DIR"
    fi
fi

if [ -d "$DIR/.git" ]; then
    git -C "$DIR" config core.hooksPath .githooks
fi

# --- modules ----------------------------------------------------------------------

install_bash() {
    say "bash"
    link "$DIR/bash/bashrc" "$HOME/.bashrc-mrj"
    link "$DIR/bash/profile" "$HOME/.profile-mrj"
    hook "$HOME/.bashrc" ".bashrc-mrj" '[ -f "$HOME/.bashrc-mrj" ] && . "$HOME/.bashrc-mrj"'
    # bash reads ~/.bash_profile instead of ~/.profile when it exists
    local login=$HOME/.profile
    [ -f "$HOME/.bash_profile" ] && login=$HOME/.bash_profile
    hook "$login" ".profile-mrj" '[ -f "$HOME/.profile-mrj" ] && . "$HOME/.profile-mrj"'
    if [ ! -e "$HOME/.bashrc.local" ]; then
        (umask 077 && cp "$DIR/bash/bashrc.local.example" "$HOME/.bashrc.local")
        echo "    created ~/.bashrc.local (mode 600) for machine-specific settings and secrets"
    fi
}

install_git() {
    say "git"
    link "$DIR/git/gitignore_global" "$HOME/.gitignore_global"
    local include="$DIR/git/gitconfig"
    if [ ! -e "$HOME/.gitconfig" ]; then
        sed "s|@NIX_PROFILE_DIR@|$DIR|g" "$DIR/git/gitconfig.example" >"$HOME/.gitconfig"
        echo "    created ~/.gitconfig"
    elif ! git config --global --get-all include.path 2>/dev/null | grep -qxF "$include"; then
        # Put the include first so everything already in ~/.gitconfig still wins.
        cp "$HOME/.gitconfig" "$HOME/.gitconfig.bak.$STAMP"
        { printf '[include]\n\tpath = %s\n\n' "$include"; cat "$HOME/.gitconfig.bak.$STAMP"; } >"$HOME/.gitconfig"
        echo "    added include to ~/.gitconfig (backup: ~/.gitconfig.bak.$STAMP)"
    fi
}

install_vim() {
    say "vim"
    local editor
    editor=$(command -v vim || command -v nvim || true)
    if [ -z "$editor" ]; then
        warn "neither vim nor neovim installed, skipping"
        return 0
    fi
    local src=$DIR/vim-config
    link "$src/vimrc-full" "$HOME/.vimrc"
    link "$src/vimrc-largefile" "$HOME/.vimrc-largefile"
    # remove links left by the Vundle-era installer (~/.vimrc-ide, ~/.vim/colors, ...)
    local old
    for old in "$HOME/.vimrc-ide" "$HOME"/.vim/{after,colors,doc,syntax,side-by-side-diff.sh}; do
        if [ -L "$old" ] && [[ $(readlink "$old") == "$DIR"/* ]]; then
            rm "$old"
            echo "    removed old link $old"
        fi
    done
    link "$src/mrj.vim" "$HOME/.vim/colors/mrj.vim"
    link "$src/doc/mrj.txt" "$HOME/.vim/doc/mrj.txt"
    mkdir -p "$HOME/.vim/swap" "$HOME/.vim/backup"
    if command -v nvim >/dev/null; then
        link "$src/init.vim" "$HOME/.config/nvim/init.vim"
    fi
    if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
        curl -fsSLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    fi
    local rc=$HOME/.vimrc
    [[ $editor == */nvim ]] && rc=$HOME/.config/nvim/init.vim
    echo "    installing vim plugins"
    VIM_IDE=1 "$editor" -es -u "$rc" -i NONE +PlugInstall +qall </dev/null ||
        warn "PlugInstall reported errors"
}

install_agents() {
    say "agents"
    link "$DIR/agents/AGENTS.md" "$HOME/AGENTS.md"
}

install_pi() {
    say "pi"
    bash "$DIR/coding-agents/pi/install.sh"
}

install_desktop() {
    say "desktop"
    link "$DIR/desktop/Xdefaults" "$HOME/.Xdefaults"
    link "$DIR/desktop/conky.conf" "$HOME/.config/conky/conky.conf"
    echo "    optional: see $DIR/desktop/mss-clamp.service for the WireGuard/docker MSS fix"
}

install_private() {
    say "private"
    local repo=${NIX_PROFILE_PRIVATE_REPO:-https://github.com/mjeffe/nix-profile-private.git}
    local dir=${NIX_PROFILE_PRIVATE_DIR:-$(dirname "$DIR")/nix-profile-private}
    if [ -d "$dir/.git" ]; then
        git -C "$dir" pull --ff-only || warn "could not fast-forward $dir; using it as is"
    # never wait on a password prompt; this may be running under curl | bash
    elif ! GIT_TERMINAL_PROMPT=0 git clone --quiet "$repo" "$dir"; then
        warn "could not clone $repo"
        warn "log in first (gh auth login && gh auth setup-git, or add an ssh key), then run: $DIR/install.sh private"
        return 0
    fi
    if [ -f "$dir/install.sh" ]; then
        bash "$dir/install.sh"
    else
        warn "$dir has no install.sh; see $DIR/private.example/"
    fi
}

# --- main ---------------------------------------------------------------------------

modules=("$@")
[ ${#modules[@]} -eq 0 ] && modules=("${DEFAULT_MODULES[@]}")
[ "${modules[0]}" = all ] && modules=("${ALL_MODULES[@]}")

for m in "${modules[@]}"; do
    case $m in
        -h | --help) usage; exit 0 ;;
    esac
    case " ${MODULES[*]} " in
        *" $m "*) ;;
        *) usage >&2; echo "unknown module: $m" >&2; exit 1 ;;
    esac
done

for m in "${modules[@]}"; do
    "install_$m"
done

say "done. Open a new shell, or: . ~/.bashrc"
