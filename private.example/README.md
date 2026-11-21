# Private companion to nix-profile

A starting point for a **private** repo that holds the parts of my setup that are private but not secret: which client directory uses which git identity and credentials, client ssh hosts, and client aliases.

| Kind | Example | Lives in |
|---|---|---|
| Generic config | aliases, vimrc, credential recipes | public nix-profile |
| Private, not secret | client names, hosts, IPs, `includeIf` mappings | this private repo |
| Secret | ssh private keys, `~/.aws` credentials, API keys | a password manager, never a repo |

## Layout

```
install.sh              wires everything below into $HOME; safe to re-run
gitconfig               client includeIf blocks; included from ~/.gitconfig
clients/*.gitconfig     clients that need more than a public recipe
ssh/config.d/*.conf     one file per client; linked into ~/.ssh/config.d/
bashrc.d/*.sh           client aliases and environment; linked into ~/.bashrc.d/
```

## New machine

```sh
curl -fsSL https://raw.githubusercontent.com/mjeffe/nix-profile/master/install.sh | bash
gh auth login && gh auth setup-git      # HTTPS access to private repos, no ssh key needed
cd ~/src/mrj/nix-profile && ./install.sh private
ssh-keygen -t ed25519 && gh ssh-key add ~/.ssh/id_ed25519.pub
```

Then restore `~/.aws` and any client keys from the password manager, or generate new keys and register them with each client.
