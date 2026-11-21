# Matt's *nix profile

My bash, vim, and git setup for new Unix/Linux/macOS boxes. "nix" as in *nix, not the Nix package manager.

These are my preferences; feel free to borrow the techniques. Fork it and change `NIX_PROFILE_REPO`, the identity in `git/gitconfig`, and the `pushInsteadOf` URL.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/mjeffe/nix-profile/master/install.sh | bash
```

This clones the repo to `~/src/mrj/nix-profile` over HTTPS and symlinks the default modules into `$HOME`. You need no ssh key or git setup first. `git/gitconfig` makes later pushes to my GitHub repos go over ssh. Without git, it downloads a tarball.

To pick modules, pass them after `-s --`, or run `./install.sh [module...|all]` from a clone:

| Module | Installs |
|---|---|
| `bash` (default) | `~/.bashrc-mrj` and `~/.profile-mrj` loaders, hooked into the distro's `~/.bashrc` and `~/.profile` |
| `git` (default) | an `[include]` of `git/gitconfig` at the top of `~/.gitconfig`, plus `~/.gitignore_global` |
| `vim` (default) | `~/.vimrc`, `~/.vimrc-ide`, `~/.vim/*`, and Vundle plugins |
| `agents` (default) | `~/AGENTS.md`, baseline guidance for coding agents |
| `pi` | the pi coding agent and subagents ([coding-agents/pi](coding-agents/pi/README.md)) |
| `desktop` | X resources and conky |

Re-running is safe. Any file it replaces is moved to `<file>.bak.<timestamp>`. To update a box, `git pull` in the clone; re-run only when modules or links change.

## Layout

```
install.sh              bootstrap and modules
bash/bashrc             loader: bashrc.d/*.sh, then ~/.bashrc.d/*.sh, then ~/.bashrc.local
bash/bashrc.d/          one snippet per concern; delete a file to retire it
bash/profile            login environment (PATH, EDITOR)
git/gitconfig           shared behavior, aliases, default identity
git/*.example           templates for ~/.gitconfig and per-client gitconfigs
ssh/config.example      per-client ~/.ssh/config.d layout
agents/AGENTS.md        becomes ~/AGENTS.md
vimrc, vimrc-ide, vim/  current vim setup (Vundle)
vim-config/             newer vim-plug setup, used by ralph-loop sandboxes
desktop/                Linux desktop extras
```

## Keeping secrets out

This repo is public. Anything specific to one machine or client lives outside it:

- `~/.bashrc.local` (created mode 600 from `bash/bashrc.local.example`) and `~/.bashrc.d/*.sh`: API keys, client aliases, PATH tweaks.
- `~/.gitconfig`: the per-machine file that includes the shared one. `git config --global` writes here, never into the repo.
- `~/src/<client>/.gitconfig`, `~/.ssh/`, `~/.aws/`.

`.githooks/pre-commit`, which the installer enables, blocks commits that look like they contain keys or tokens. It uses [gitleaks](https://github.com/gitleaks/gitleaks) when installed. Also turn on GitHub secret scanning push protection for the repo.

## Git for many clients

Each client gets a directory under `~/src/` and one gitconfig beside its repos:

```
~/.gitconfig                  [include] <repo>/git/gitconfig, then one includeIf per client
~/src/acme/.gitconfig         identity, ssh key, credential helpers for acme
~/src/acme/<repos>
```

```ini
# ~/.gitconfig
[includeIf "gitdir:~/src/acme/"]
    path = ~/src/acme/.gitconfig
# repos outside the client's directory: match the remote instead (git 2.36+)
[includeIf "hasconfig:remote.*.url:git@github.com:acme-corp/**"]
    path = ~/src/acme/.gitconfig
```

In the client file ([git/client.gitconfig.example](git/client.gitconfig.example)):

- `user.email` sets the client identity.
- `core.sshCommand = ssh -i ~/.ssh/acme_ed25519 -o IdentitiesOnly=yes` picks the client's ssh key by directory. Clone URLs stay exactly as the client gives them, with no `Host github-acme` aliases.
- `url.<base>.insteadOf` forces ssh or https for that client's host.
- `[credential "https://host"]` scopes helpers such as the AWS CodeCommit or `gh` helper to one host.

Check what applies in a repo with `git config --show-origin --show-scope --list`.

For ssh hosts that aren't git servers, keep one file per client in `~/.ssh/config.d/` and `Include config.d/*.conf` at the top of `~/.ssh/config` ([ssh/config.example](ssh/config.example)).

## Moving to a new machine

The repo covers the shared setup. Carry these over privately, for example in an encrypted archive or a password manager:

- `~/.bashrc.local`, `~/.bashrc.d/`
- `~/.gitconfig` (client `includeIf` blocks) and `~/src/*/.gitconfig`
- `~/.ssh/` (keys, `config`, `config.d/`)
- `~/.aws/`

Better still, generate fresh ssh keys on the new machine and register them with each client. Then retire the old laptop's keys.
