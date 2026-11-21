# Machine-wide agent guidance

Installed as `~/AGENTS.md` by nix-profile, so it applies to every project under my home directory. Project AGENTS.md files override it.

## This machine

- Source lives in `~/src/<client>/<repo>`. Each client directory has its own git identity, ssh key, and credentials through `~/src/<client>/.gitconfig`; don't change git or ssh config to make a push or fetch work.
- Shell is bash with vi mode. Editor is vim.

## Working rules

- Never commit, print, or copy secrets: API keys, tokens, passwords, private keys, `.env` files, `~/.bashrc.local`, `~/.ssh/`, `~/.aws/`.
- Ask before pushing, deploying, or changing anything shared or outside the current repo.
- Follow the project's existing patterns, tooling, and formatting. Keep changes small and focused on the request.
- Verify changes by running the project's tests or the program itself, and say plainly what you could not verify.
