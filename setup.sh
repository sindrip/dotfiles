#!/usr/bin/env bash

DOTFILES=$(realpath $(dirname "$0"))

mkdir -p ~/.{config,cache,local/bin,local/share,local/state}
mkdir -p ~/.config/zsh
mkdir -p ~/.config/git
mkdir -p ~/.config/ghostty
mkdir -p ~/.config/tmux
mkdir -p ~/.config/mise

# XDG directories for applications
mkdir -p ~/.local/state/{less,zsh}

link() {
  if [ -e "$2" ] && [ ! -L "$2" ]; then
    echo "Warning: $2 exists and is not a symlink, skipping"
    return
  fi
  ln -sfn "$1" "$2"
}

link "$DOTFILES/zshenv" ~/.zshenv
link "$DOTFILES/config/zsh/.zshrc" ~/.config/zsh/.zshrc
link "$DOTFILES/config/zsh/.zprofile" ~/.config/zsh/.zprofile
link "$DOTFILES/config/git/config" ~/.config/git/config
link "$DOTFILES/config/ghostty/config" ~/.config/ghostty/config
link "$DOTFILES/config/nvim" ~/.config/nvim
link "$DOTFILES/config/tmux/tmux.conf" ~/.config/tmux/tmux.conf
link "$DOTFILES/config/mise/config.toml" ~/.config/mise/config.toml

link "$DOTFILES/local/bin/tmux-sessionizer" ~/.local/bin/tmux-sessionizer
