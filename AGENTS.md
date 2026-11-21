# nix-profile

My shell, vim, and git setup for new Unix/Linux/macOS boxes ("nix" as in *nix, not the Nix package manager). See README.md for the layout.

- This repo is public. Never add secrets, client names, hostnames, IP addresses, or private keys. Machine-specific and private settings belong in `~/.bashrc.local`, `~/.bashrc.d/`, `~/.gitconfig`, and `~/src/<client>/.gitconfig`, which are never committed; the repo only ships `*.example` templates and generic recipes (`git/clients/`) for them. Client-specific mappings belong in the private companion repo (see `private.example/`).
- `install.sh` must stay idempotent and safe to pipe from curl: re-running it changes nothing, and it backs up any file it replaces.
- Other projects curl `vim-config/install.sh` and `coding-agents/pi/install.sh` from `master`; keep those paths working.
- After changing `install.sh`, test it against a throwaway home: `HOME=$(mktemp -d) ./install.sh`.
