# Dotfiles

Personal dotfiles for macOS.

```sh
./install.sh
```

`install.sh` symlinks configs to `~/.config/`, scripts to `~/.local/bin/`, runs `brew bundle`, installs Nix packages, and applies macOS defaults (keyboard, dock, trackpad, autocorrect, hotkeys, Ghostty keybinding).

Portable CLI tools are installed by Nix. Homebrew is reserved for GUI casks and
`pam-reattach`, which integrates with the macOS PAM configuration.

Google Cloud CLI components are declared in `flake.nix`; the immutable Nix
package disables `gcloud components install` and `gcloud components update`.

## Nix

Install [Nix](https://github.com/NixOS/nix-installer) before running `install.sh`. Trusting your user lets the caches in `config/nix/nix.conf` take effect, pulling prebuilt neovim nightlies (built by CI) instead of compiling from source:

```sh
curl -sSfL https://artifacts.nixos.org/nix-installer | sh -s -- install --extra-conf "extra-trusted-users = $USER"
```

`install.sh` registers this repo in the flake registry as `dotfiles` and installs
the CLI tools, wrapped tmux, and neovim nightly from it via `nix profile`. Update
all three profiles with:

```sh
nix flake update && nix profile upgrade --all
```
