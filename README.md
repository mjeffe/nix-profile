# Matt's *nix profile

My bash, vim, and git setup for new Unix/Linux/macOS boxes. "nix" as in *nix, not the Nix package manager.

These are my preferences; feel free to borrow the techniques, or [fork it](#forking).

## Install

### Requirements

- `bash` and `curl`
- `git`, recommended: without it the installer downloads a tarball, which you can't update with `git pull`, and vim plugins can't install
- `vim` or Neovim for the `vim` module

Tested on Ubuntu. macOS should work but hasn't been tested since the restructure.

### Quick install

```sh
curl -fsSL https://raw.githubusercontent.com/mjeffe/nix-profile/master/install.sh | bash
```

This clones the repo to `~/src/mrj/nix-profile` over HTTPS, so no ssh key or git setup is needed first, and installs the default modules: `bash`, `git`, `vim`, and `agents`. Then open a new shell.

### Choosing modules

Name modules after `-s --`, or use `all` for every module except `private`:

```sh
curl -fsSL https://raw.githubusercontent.com/mjeffe/nix-profile/master/install.sh | bash -s -- bash git
curl -fsSL https://raw.githubusercontent.com/mjeffe/nix-profile/master/install.sh | bash -s -- all
```

| Module | Installs |
|---|---|
| `bash` (default) | `~/.bashrc-mrj` and `~/.profile-mrj` loaders, hooked into the distro's `~/.bashrc` and `~/.profile`; creates `~/.bashrc.local` (mode 600) |
| `git` (default) | an `[include]` of `git/gitconfig` at the top of `~/.gitconfig` (created if missing), plus `~/.gitignore_global` |
| `vim` (default) | [vim-config](vim-config): `~/.vimrc`, colors, `:help mrj`, vim-plug plugins, and Neovim's `init.vim` when Neovim is installed |
| `agents` (default) | `~/AGENTS.md`, baseline guidance for coding agents |
| `pi` | the pi coding agent and subagents ([coding-agents/pi](coding-agents/pi/README.md)) |
| `desktop` | X resources and conky |
| `private` | clones a private companion repo and runs its `install.sh` (see [Private settings](#private-settings)); never part of `all` |

### From a clone, or somewhere else

```sh
git clone https://github.com/mjeffe/nix-profile.git ~/src/mrj/nix-profile
~/src/mrj/nix-profile/install.sh [module...]
```

Run from a clone, the installer uses that clone wherever it is and never pulls. To have the curl install clone somewhere else, set `NIX_PROFILE_DIR`:

```sh
curl -fsSL https://raw.githubusercontent.com/mjeffe/nix-profile/master/install.sh | NIX_PROFILE_DIR=~/dotfiles bash
```

`./install.sh --help` lists the modules and the environment variables.

### After installing

- Open a new shell, or run `. ~/.bashrc`.
- Put API keys and machine-specific settings in `~/.bashrc.local`, and client git mappings in `~/.gitconfig` or the private repo (see [Git for many clients](#git-for-many-clients)).
- On boxes where you'll commit to this repo, add an ssh key to GitHub. Clones use HTTPS, and `git/gitconfig` sends pushes to `github.com/mjeffe/` over ssh.

### Updating

Files are symlinked into the clone, so `git -C ~/src/mrj/nix-profile pull` updates every installed module. Re-run `install.sh` only when modules or links change. Re-running is always safe: it changes nothing that is already in place.

### Vim only

For containers and servers that only need vim (as ralph-loop sandboxes do), `vim-config/install.sh` downloads the files without cloning anything:

```sh
curl -fsSL https://raw.githubusercontent.com/mjeffe/nix-profile/master/vim-config/install.sh | bash          # full
curl -fsSL https://raw.githubusercontent.com/mjeffe/nix-profile/master/vim-config/install.sh | bash -s min   # minimal
```

### Undoing

The installer moves any file it replaces to `<file>.bak.<timestamp>` beside it. To back out a module, delete its symlinks (`find ~ -maxdepth 3 -lname '*nix-profile*'` lists them) and restore the `.bak` files. Then delete the `# nix-profile` lines from `~/.bashrc` and `~/.profile`, and the `[include]` block at the top of `~/.gitconfig`.

### Forking

Change `NIX_PROFILE_REPO` and the default `NIX_PROFILE_DIR` in `install.sh`, the identity and `pushInsteadOf` URL in `git/gitconfig`, `git/gitconfig-mrj`, and the URLs in this README.

## Layout

```
install.sh              bootstrap and modules
bash/bashrc             loader: bashrc.d/*.sh, then ~/.bashrc.d/*.sh, then ~/.bashrc.local
bash/bashrc.d/          one snippet per concern; delete a file to retire it
bash/profile            login environment (PATH, EDITOR)
git/gitconfig           shared behavior, aliases, default identity
git/*.example           templates for ~/.gitconfig and per-client gitconfigs
git/clients/            reusable credential recipes, e.g. aws-codecommit.gitconfig
ssh/config.example      per-client ~/.ssh/config.d layout
agents/AGENTS.md        becomes ~/AGENTS.md
private.example/        starter layout for the private companion repo
vim-config/             vimrc-full, vimrc-min, Neovim init.vim; its own install.sh
                        serves boxes that only want vim (e.g. ralph-loop sandboxes)
desktop/                Linux desktop extras
```

## Keeping secrets out

This repo is public. Anything specific to one machine or client lives outside it:

- `~/.bashrc.local` (created mode 600 from `bash/bashrc.local.example`) and `~/.bashrc.d/*.sh`: API keys, client aliases, PATH tweaks.
- `~/.gitconfig`: the per-machine file that includes the shared one. `git config --global` writes here, never into the repo.
- `~/src/<client>/.gitconfig`, `~/.ssh/`, `~/.aws/`.

`.githooks/pre-commit`, which the installer enables, blocks commits that look like they contain keys or tokens. It uses [gitleaks](https://github.com/gitleaks/gitleaks) when installed. Also turn on GitHub secret scanning push protection for the repo.

## Git for many clients

Each client gets a directory under `~/src/`, and `~/.gitconfig` maps each directory to that client's settings with `includeIf`. Later settings win, so client settings override the shared defaults.

```
~/.gitconfig                        [include] <clone>/git/gitconfig, then one includeIf per client
<clone>/git/clients/*.gitconfig     reusable recipes, e.g. AWS CodeCommit via the AWS CLI
~/src/acme/.gitconfig               a client that needs its own identity or ssh key
```

```ini
# ~/.gitconfig
# a client that only needs a stock recipe
[includeIf "gitdir:~/src/acme/"]
    path = ~/src/mrj/nix-profile/git/clients/aws-codecommit.gitconfig
# a client with its own settings
[includeIf "gitdir:~/src/globex/"]
    path = ~/src/globex/.gitconfig
# repos outside the client's directory: match the remote instead (git 2.36+)
[includeIf "hasconfig:remote.*.url:git@github.com:globex/**"]
    path = ~/src/globex/.gitconfig
```

A client file ([git/client.gitconfig.example](git/client.gitconfig.example)) can set:

- `user.email`, for the client identity.
- `core.sshCommand = ssh -i ~/.ssh/globex_ed25519 -o IdentitiesOnly=yes`, which picks the client's ssh key by directory. Clone URLs stay exactly as the client gives them, with no `Host github-globex` aliases.
- `url.<base>.insteadOf`, which forces ssh or https for that client's host.
- `[credential "https://host"]`, which scopes a credential helper to one host.

Check what applies in a repo with `git config --list --show-origin --show-scope`.

For ssh hosts that aren't git servers, keep one file per client in `~/.ssh/config.d/` and `Include config.d/*.conf` at the top of `~/.ssh/config` ([ssh/config.example](ssh/config.example)).

## Private settings

This repo is public, so it holds only what anyone could reuse. The rest splits by sensitivity:

| Kind | Example | Lives in |
|---|---|---|
| Generic config | aliases, vimrc, credential recipes | this repo |
| Private, not secret | client names, hosts, IPs, `includeIf` mappings, client aliases | a private companion repo |
| Secret | ssh private keys, `~/.aws` credentials, API keys | a password manager, never a repo |

The `private` module clones the companion repo (default `mjeffe/nix-profile-private`, next to this clone; override with `NIX_PROFILE_PRIVATE_REPO` and `NIX_PROFILE_PRIVATE_DIR`) and runs its `install.sh`. [private.example/](private.example) is a starter for it. Its installer includes the repo's `gitconfig` from `~/.gitconfig`, links `ssh/config.d/*.conf` and `bashrc.d/*.sh`, and is safe to re-run.

## Moving to a new machine

```sh
curl -fsSL https://raw.githubusercontent.com/mjeffe/nix-profile/master/install.sh | bash
gh auth login && gh auth setup-git      # HTTPS access to the private repo; no ssh key needed
~/src/mrj/nix-profile/install.sh private
ssh-keygen -t ed25519 && gh ssh-key add ~/.ssh/id_ed25519.pub
```

Then restore `~/.aws`, `~/.bashrc.local`, and any client keys from the password manager. Better still, generate fresh keys on the new machine, register them with each client, and retire the old laptop's keys.
