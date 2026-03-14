# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles for macOS. Manages Homebrew packages, config files (symlinked to `~/.config/`), and scripts (symlinked to `~/.local/bin/`).

## Setup

```sh
./install.sh
```

This runs `brew bundle`, symlinks everything in `config/` to `~/.config/`, and symlinks everything in `bin/` to `~/.local/bin/`.

## Structure

- `Brewfile` — Homebrew packages and casks
- `install.sh` — idempotent installer (symlinks, warns on conflicts instead of overwriting)
- `config/` — XDG config files, mirroring `~/.config/` layout
- `bin/` — custom scripts exposed as commands (e.g. `git-bare` becomes `git bare`)

## Guidelines

- When adding or configuring new tools, consult [xdg-ninja](https://github.com/b3nj5m1n/xdg-ninja) to ensure configs use XDG-compliant paths (`~/.config/`, `~/.local/share/`, etc.) rather than cluttering `~`.
