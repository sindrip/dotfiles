#/usr/bin/env sh

DOTFILES=$(realpath $(dirname $0))

mkdir -p ~/.{config,cache,local/share,local/state}
mkdir -p ~/.config/zsh

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
link "$DOTFILES/config/git" ~/.config/git
