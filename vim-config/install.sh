#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Matt's Vim config installer
#
# Installs vim config with optional IDE mode (plugins via vim-plug).
# Defaults to the full config. Pass 'min' for a minimal config suitable
# for remote servers, containers, etc.
#
# Usage:
#   # full config (default)
#   curl -fsSL https://raw.githubusercontent.com/mjeffe/nix-profile/master/vim-config/install.sh | bash
#
#   # minimal config
#   curl -fsSL https://raw.githubusercontent.com/mjeffe/nix-profile/master/vim-config/install.sh | bash -s min
#
# After install, add this alias to your ~/.bashrc:
#   alias vide='VIM_IDE=1 vim'
#
# Then use `vim` for normal editing, or `vide` for IDE mode with plugins.
# ------------------------------------------------------------------------------

set -euo pipefail

PROFILE="${1:-full}"
BASE_URL="https://raw.githubusercontent.com/mjeffe/nix-profile/master/vim-config"

if [[ "$PROFILE" != "full" && "$PROFILE" != "min" ]]; then
    echo "Error: unknown profile '$PROFILE'. Use 'full' or 'min'."
    exit 1
fi

echo "Installing vim config (profile: $PROFILE)..."

# backup existing .vimrc
if [[ -f "$HOME/.vimrc" ]]; then
    echo "Backing up existing ~/.vimrc to ~/.vimrc.bak"
    cp "$HOME/.vimrc" "$HOME/.vimrc.bak"
fi

# create required directories
mkdir -p "$HOME/.vim"/{swap,backup,colors}

# install vim-plug
if [[ ! -f "$HOME/.vim/autoload/plug.vim" ]]; then
    echo "Installing vim-plug..."
    curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

# install vimrc
echo "Installing ~/.vimrc (vimrc-$PROFILE)..."
curl -fsSL "$BASE_URL/vimrc-$PROFILE" -o "$HOME/.vimrc"

# install color scheme
echo "Installing color scheme..."
curl -fsSL "$BASE_URL/mrj.vim" -o "$HOME/.vim/colors/mrj.vim"

# install plugins
echo "Installing vim plugins..."
VIM_IDE=1 vim +PlugInstall +qall

echo ""
echo "Done! Add this alias to your ~/.bashrc if you haven't already:"
echo "  alias vide='VIM_IDE=1 vim'"
