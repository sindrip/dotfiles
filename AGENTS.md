# AGENTS.md

This file provides guidance to coding agents when working with code in this repository.

## Overview

Personal dotfiles for macOS. Package ownership:

- Nix: portable CLI and editor tools, wrapped tmux, and Neovim nightly
- Homebrew: GUI casks and macOS integration
- mise: language runtimes and ecosystem tools

## Setup

```sh
./install.sh
```

The installer links tracked configs, scripts, and Claude skills, then installs
packages and applies macOS defaults.

## Structure

- `Brewfile` - Homebrew packages and casks
- `flake.nix` - Nix packages
- `config/` - XDG configs linked to `~/.config/`
- `bin/` - scripts linked to `~/.local/bin/`
- `claude/skills/` - versioned Claude skills
- `install.sh` - idempotent installer

## Guidelines

- Consult [xdg-ninja](https://github.com/b3nj5m1n/xdg-ninja) when configuring tools; prefer XDG paths.
- Preserve the installer's idempotent behavior; never overwrite non-symlink files.
- Don't symlink configs that may contain runtime secrets (auth tokens, credentials). Document manual setup in `README.md` instead.
