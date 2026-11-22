# nix-profile

My shell, vim, and git setup for new Unix/Linux/macOS boxes ("nix" as in *nix, not the Nix package manager). See README.md for the layout.

- This repo is public. Never add secrets, client names, hostnames, IP addresses, or private keys. Machine-specific and private settings belong in `~/.bashrc.local`, `~/.bashrc.d/`, `~/.gitconfig`, and `~/src/<client>/.gitconfig`, which are never committed. The repo only ships `*.example` templates and generic recipes (`git/clients/`) for them. Client-specific mappings belong in the private companion repo (see `private.example/`)
- `install.sh` must stay idempotent and safe to pipe from curl: re-running it changes nothing, and it backs up any file it replaces
- Other projects curl `vim-config/install.sh` and `coding-agents/pi/install.sh` from `master`. Keep those paths working
- After changing `install.sh`, test it against a throwaway home: `HOME=$(mktemp -d) ./install.sh`

## Writing style

Applies to docs, plans, commit messages, and any other prose you write.

- Use plain, simple English and ASCII characters only: no em-dashes, curly quotes, or arrows
- Replace an em-dash with a comma, a colon, or a new sentence
- Cut puff words that add no information, such as strong, robust, canonical, seamless, comprehensive, and leverage
- Cut filler transitions such as therefore, furthermore, moreover, and notably unless they carry real logic
- End bullet list items without punctuation: no periods, no semicolons, no "; and"
- Avoid repeating one sentence pattern, such as three sentences in a row that start "The estimate ...". Make direct statements instead
