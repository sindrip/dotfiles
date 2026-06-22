# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles for macOS. Manages Homebrew packages, config files (symlinked to `~/.config/`), and scripts (symlinked to `~/.local/bin/`).

## Setup

```sh
./install.sh
```

`install.sh` symlinks everything in `config/` to `~/.config/`, everything in `bin/` to `~/.local/bin/`, runs `brew bundle`, and applies macOS defaults.

## Structure

- `Brewfile` — Homebrew packages and casks
- `install.sh` — idempotent installer (symlinks, warns on conflicts instead of overwriting)
- `bin/macos-defaults` — Swift script applying macOS defaults (keyboard, dock, trackpad, hotkeys, Ghostty keybinding)
- `config/` — XDG config files, mirroring `~/.config/` layout
- `bin/` — custom scripts exposed as commands (e.g. `git-bare` becomes `git bare`)

## Guidelines

- When adding or configuring new tools, consult [xdg-ninja](https://github.com/b3nj5m1n/xdg-ninja) to ensure configs use XDG-compliant paths (`~/.config/`, `~/.local/share/`, etc.) rather than cluttering `~`.
- Don't symlink configs that may contain runtime secrets (auth tokens, credentials). Document manual setup in `README.md` instead.
