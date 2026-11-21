#!/usr/bin/env bash
#
# Installer for a private companion repo to nix-profile.
#
# Copy private.example/ into the root of your private repo. nix-profile's
# `./install.sh private` clones that repo and runs this script; you can also
# run it directly. It wires in, idempotently:
#
#   gitconfig          included from ~/.gitconfig (client includeIf blocks)
#   ssh/config.d/*.conf  linked into ~/.ssh/config.d/, Included from ~/.ssh/config
#   bashrc.d/*.sh      linked into ~/.bashrc.d/ (nix-profile's bashrc loads them)
#
# Private is not secret: keep keys, tokens, and ~/.aws credentials in a
# password manager, not in this repo.

set -euo pipefail

HERE=$(cd "$(dirname "$0")" && pwd)

# git: add an include of this repo's gitconfig to ~/.gitconfig
if [ -f "$HERE/gitconfig" ]; then
    if ! git config --global --get-all include.path 2>/dev/null | grep -qxF "$HERE/gitconfig"; then
        git config --global --add include.path "$HERE/gitconfig"
        echo "    included $HERE/gitconfig from ~/.gitconfig"
    fi
fi

# ssh: per-client host files. ssh rejects config files others can write to,
# so tighten permissions on the checked-out files too.
if compgen -G "$HERE/ssh/config.d/*.conf" >/dev/null; then
    mkdir -p ~/.ssh/config.d
    chmod 700 ~/.ssh ~/.ssh/config.d
    for f in "$HERE"/ssh/config.d/*.conf; do
        chmod 600 "$f"
        ln -sfn "$f" ~/.ssh/config.d/
    done
    if ! grep -qxF 'Include config.d/*.conf' ~/.ssh/config 2>/dev/null; then
        # Include must come before any Host block
        { printf 'Include config.d/*.conf\n\n'; cat ~/.ssh/config 2>/dev/null || true; } >~/.ssh/config.new
        mv ~/.ssh/config.new ~/.ssh/config
        chmod 600 ~/.ssh/config
        echo "    added Include config.d/*.conf to ~/.ssh/config"
    fi
fi

# bash: client aliases and environment
if compgen -G "$HERE/bashrc.d/*.sh" >/dev/null; then
    mkdir -p ~/.bashrc.d
    for f in "$HERE"/bashrc.d/*.sh; do
        ln -sfn "$f" ~/.bashrc.d/
    done
fi
