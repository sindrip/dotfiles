#!/usr/bin/env sh
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

info() { printf '\033[32mOK:\033[0m %s\n' "$1"; }
warn() { printf '\033[33mWARN:\033[0m %s\n' "$1"; }
header() { printf '\n\033[1m==> %s\033[0m\n' "$1"; }

link() {
  src="$1"
  dest="$2"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    warn "$dest already exists (not a symlink), skipping"
    return
  fi
  ln -sf "$src" "$dest"
  info "$dest -> $src"
}

header "Touch ID sudo"
if [ ! -f /etc/pam.d/sudo_local ]; then
  printf 'auth       optional       /opt/homebrew/lib/pam/pam_reattach.so\n' | sudo tee /etc/pam.d/sudo_local >/dev/null
  sudo sed 's/^#auth/auth/' /etc/pam.d/sudo_local.template | sudo tee -a /etc/pam.d/sudo_local >/dev/null
  info "created /etc/pam.d/sudo_local with Touch ID + pam-reattach"
else
  info "/etc/pam.d/sudo_local already exists, skipping"
fi

header "macOS defaults"
# NOTE: Disable Ctrl+Space for input source switching in System Settings > Keyboard > Keyboard Shortcuts > Input Sources
defaults write com.mitchellh.ghostty NSUserKeyEquivalents -dict-add "Hide Ghostty" '\0'

header "Dotfiles"
(cd "$DOTFILES/config"
find . -type f | while read -r f; do
  f="${f#./}"
  mkdir -p "$HOME/.config/$(dirname "$f")"
  link "$DOTFILES/config/$f" "$HOME/.config/$f"
done)

header "Non-XDG dotfiles"
# zshenv (must live in ~/ to bootstrap ZDOTDIR)
link "$DOTFILES/zshenv" "$HOME/.zshenv"
# hushlogin (suppress "Last login" message)
link "$DOTFILES/hushlogin" "$HOME/.hushlogin"

header "Scripts"
mkdir -p "$HOME/.local/bin"
for f in "$DOTFILES/bin/"*; do
  link "$f" "$HOME/.local/bin/$(basename "$f")"
done


header "Directories"
# ensure directories exist for paths introduced by zshenv
# sources zshenv in a clean shell (env -i) and diffs the environment
# before and after to find only the variables zshenv adds
ensure_dirs() {
  env -i HOME="$HOME" ZSHENV="$DOTFILES/zshenv" sh -c '
    before=$(env | grep -v "^_=")
    . "$ZSHENV"
    env | grep -v "^_=" | grep -vxF "$before"
  ' | while IFS='=' read -r name value; do
    case "$value" in
      /*)
        case "$name" in
          *FILE|*HISTORY|*USERCONFIG) dir="$(dirname "$value")" ;;
          *) dir="$value" ;;
        esac
        mkdir -p "$dir"
        info "ensured $dir"
        ;;
    esac
  done
}
ensure_dirs

header "Packages"
brew bundle --verbose --file="$DOTFILES/Brewfile"

header "Mise tools"
mise trust "$HOME/.config/mise/config.toml"
mise upgrade

