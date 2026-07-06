# Dotfiles

Personal dotfiles for macOS.

```sh
./install.sh
```

`install.sh` symlinks configs to `~/.config/`, scripts to `~/.local/bin/`, runs `brew bundle`, installs Nix packages (neovim nightly), and applies macOS defaults (keyboard, dock, trackpad, autocorrect, hotkeys, Ghostty keybinding).

## Nix

Install [Nix](https://github.com/NixOS/nix-installer) before running `install.sh`. Trusting your user lets the flake's `nixConfig` pull prebuilt nightlies from the nix-community cache instead of compiling from source:

```sh
curl -sSfL https://artifacts.nixos.org/nix-installer | sh -s -- install --extra-conf "extra-trusted-users = $USER"
```

`install.sh` registers this repo in the flake registry as `dotfiles` and installs neovim nightly from it via `nix profile`. Update with:

```sh
nix flake update && nix profile upgrade neovim
```

